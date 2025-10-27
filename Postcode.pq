let
    // === Editable file names ===
    SharePointRoot = "https://companyname.sharepoint.com/sites/datasite",
    FolderPath = "ReferenceData/Postcode",
    RGC_Scotland_File = "Register_of_Geographic_Codes_Scottland.xlsx",
    RGC_UK_File = "Register_of_Geographic_Codes_UK.xlsx",
    Postcode_File = "ONSPD_UK.csv",

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

    // === Load and combine RGC files ===
    ScotlandFile = Table.SelectRows(FilteredFiles, each [Name] = RGC_Scotland_File),
    ScotlandContent = Excel.Workbook(ScotlandFile{0}[Content], null, true),
    ScotlandSheets = Table.SelectRows(ScotlandContent, each IsValidSheetName([Name])),
    ScotlandCombinedRaw = Table.Combine(List.Transform(ScotlandSheets[Data], each Table.PromoteHeaders(_))),
    ScotlandCombined = Table.SelectColumns(ScotlandCombinedRaw, {"EntityCode", "InstanceCode", "InstanceName", "AlternateName", "Status"}),

    UKFile = Table.SelectRows(FilteredFiles, each [Name] = RGC_UK_File),
    UKContent = Excel.Workbook(UKFile{0}[Content], null, true),
    UKSheets = Table.SelectRows(UKContent, each IsValidSheetName([Name])),
    UKCombinedRaw = Table.Combine(List.Transform(UKSheets[Data], each Table.PromoteHeaders(_))),
    UKRenamed = Table.RenameColumns(UKCombinedRaw, {
        {"GEOGCD", "InstanceCode"},
        {"GEOGNM", "InstanceName"},
        {"GEOGNMW", "AlternateName"},
        {"ENTITYCD", "EntityCode"},
        {"STATUS", "Status"}
    }),
    UKFinal = Table.SelectColumns(UKRenamed, {"EntityCode", "InstanceCode", "InstanceName", "AlternateName", "Status"}),

    Combined = Table.Combine({ScotlandCombined, UKFinal}),
    FilteredRGC = Table.SelectRows(Combined, each [InstanceName] <> null and [InstanceName] <> ""),
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
    PostcodeCSV = Csv.Document(PostcodeFileMatch{0}[Content], [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]),
    Headers = Table.PromoteHeaders(PostcodeCSV),

    // === Keep only required columns ===
    ColumnsToKeep = {
        "pcds", "doterm", "oscty", "oslaua", "osward", "usertype", "oseast1m", "osnrth1m", "osgrdind",
        "ctry", "rgn", "pcon", "lsoa21", "msoa21", "ur01ind", "lat", "long"
    },
    PostcodeTrimmed = Table.SelectColumns(Headers, ColumnsToKeep),

    // === Filter out postcodes terminated before 2013 or where doterm is null/blank ===
    PostcodeFiltered =
        Table.SelectRows(PostcodeTrimmed, each
            let
                dotermText = try Text.PadStart(Text.From([doterm]), 6, "0") otherwise null,
                dotermNumber = try Number.FromText(Text.Start(dotermText, 6)) otherwise null
            in
                if [doterm] = null or [doterm] = "" then true else dotermNumber >= 201301
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
