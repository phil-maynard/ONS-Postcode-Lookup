let
// -----------------------------------------------------------------------------
// PostcodeLookup.pq
// Builds a postcode lookup table from ONS Postcode Directory (ONSPD) and the
// Register of Geographic Codes (RGC) for use in Power BI / Power Query projects.
//
// Author: Phil Maynard
// Version: 1.0.0
// Last tested with: ONSPD August 2025 release
//
// -----------------------------------------------------------------------------
// ⚠️ Configuration
// Replace placeholder paths below with your own SharePoint or network locations.
// Do not commit real tenant URLs or credentials to public repositories.
// -----------------------------------------------------------------------------

// === Editable parameters ===
SharePointRoot = "https://smartworkscharity.sharepoint.com/sites/datainsights",
FolderPath = "ReferenceData/Postcode",
RGC_Scotland_File = "Register_of_Geographic_Codes_Scotland.xlsx",
RGC_UK_File = "Register_of_Geographic_Codes_UK.xlsx",
Postcode_File = "ONSPD_UK.csv",
FilterYear = 2013, // Change this to include postcodes terminated on/after this year

// === Helper: Match sheet name pattern ===
IsValidSheetName = (sheetName as text) as logical =>
    Text.Length(sheetName) >= 4 and
    Text.Middle(sheetName, 0, 1) >= "A" and Text.Middle(sheetName, 0, 1) <= "Z" and
    Text.Middle(sheetName, 1, 1) >= "0" and Text.Middle(sheetName, 1, 1) <= "9" and
    Text.Middle(sheetName, 2, 1) >= "0" and Text.Middle(sheetName, 2, 1) <= "9" and
    Text.Middle(sheetName, 3, 1) = "_",

// === Load all files from folder ===
AllFiles = SharePoint.Files(SharePointRoot, [ApiVersion = 15]),
FilteredFiles = Table.SelectRows(AllFiles, each Text.Contains([Folder Path], FolderPath)),

// === Load and combine RGC files (UK + Scotland) ===
LoadRGC = (fileName as text, renameMap as nullable list) as table =>
    let
        FileMatch = Table.SelectRows(FilteredFiles, each [Name] = fileName),
        FileContent = if Table.IsEmpty(FileMatch) then error "❌ RGC file not found: " & fileName else FileMatch{0}[Content],
        Workbook = Excel.Workbook(FileContent, null, true),
        Sheets = Table.SelectRows(Workbook, each IsValidSheetName([Name])),
        CombinedRaw = Table.Combine(List.Transform(Sheets[Data], each Table.PromoteHeaders(_))),
        Renamed = if renameMap <> null then Table.RenameColumns(CombinedRaw, renameMap) else CombinedRaw,
        Clean = Table.SelectColumns(Renamed, {"EntityCode", "InstanceCode", "InstanceName", "AlternateName", "Status"})
    in
        Clean,

ScotlandRGC = LoadRGC(RGC_Scotland_File, null),
UKRGC = LoadRGC(
    RGC_UK_File,
    {
        {"GEOGCD", "InstanceCode"},
        {"GEOGNM", "InstanceName"},
        {"GEOGNMW", "AlternateName"},
        {"ENTITYCD", "EntityCode"},
        {"STATUS", "Status"}
    }
),

CombinedRGC = Table.Combine({ScotlandRGC, UKRGC}),
FilteredRGC = Table.SelectRows(CombinedRGC, each [InstanceName] <> null and [InstanceName] <> ""),
DeduplicatedRGC = Table.Distinct(FilteredRGC, {"InstanceCode"}),
TypedRGC = Table.TransformColumnTypes(DeduplicatedRGC, {
    {"EntityCode", type text},
    {"InstanceCode", type text},
    {"InstanceName", type text},
    {"AlternateName", type text},
    {"Status", type text}
}),

// === Load postcode CSV ===
PostcodeFileMatch = Table.SelectRows(FilteredFiles, each [Name] = Postcode_File),
PostcodeCSV = 
    if Table.IsEmpty(PostcodeFileMatch) then 
        error "❌ Postcode CSV not found: " & Postcode_File 
    else 
        Csv.Document(PostcodeFileMatch{0}[Content], [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.None]),
Headers = Table.PromoteHeaders(PostcodeCSV),

// === Keep only required columns ===
ColumnsToKeep = {
    "pcds", "doterm", "oscty", "oslaua", "osward", "usertype",
    "oseast1m", "osnrth1m", "osgrdind", "ctry", "rgn", "pcon",
    "lsoa21", "msoa21", "ur01ind", "lat", "long"
},
PostcodeTrimmed = Table.SelectColumns(Headers, ColumnsToKeep),

// === Filter out postcodes terminated before FilterYear or where doterm is null/blank ===
PostcodeFiltered =
    Table.SelectRows(PostcodeTrimmed, each
        let
            raw = [doterm],
            isBlank = raw = null or Text.Trim(Text.From(raw)) = "",
            yyyymm = if isBlank
                     then null
                     else try Number.FromText(Text.Start(Text.PadStart(Text.Trim(Text.From(raw)), 6, "0"), 6)) otherwise null
        in
            isBlank or yyyymm >= (FilterYear * 100 + 1)
    ),

// === Merge InstanceName for each geographic code column ===
MergeWithName = (baseTable as table, codeColumn as text) as table =>
    let
        merged = Table.NestedJoin(baseTable, codeColumn, TypedRGC, "InstanceCode", "Geo", JoinKind.LeftOuter),
        expanded = Table.ExpandTableColumn(merged, "Geo", {"InstanceName"}, {codeColumn & "_name"})
    in
        expanded,

PostcodeMerged1 = MergeWithName(PostcodeFiltered, "oslaua"),
PostcodeMerged2 = MergeWithName(PostcodeMerged1, "osward"),
PostcodeMerged3 = MergeWithName(PostcodeMerged2, "ctry"),
PostcodeMerged4 = MergeWithName(PostcodeMerged3, "rgn"),
PostcodeMerged5 = MergeWithName(PostcodeMerged4, "pcon")

in
    PostcodeMerged5
