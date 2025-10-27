# 🗺️ UK Postcode Lookup Builder (ONSPD & NSPL Versions)

This repository provides Power Query (M) scripts to build harmonised postcode lookup tables using two open datasets published by the **Office for National Statistics (ONS)**:

- **ONS Postcode Directory (ONSPD)** — comprehensive coverage of current and historical postcodes.  
- **National Statistics Postcode Lookup (NSPL)** — similar coverage with simplified and updated geography columns.

Both versions integrate with the **Register of Geographic Codes (RGC)** to attach readable area names for local authorities, regions, and other statistical areas.  
The output tables share the same schema for drop‑in use across reporting or data‑integration pipelines.

---

## 📁 Repository Contents

```
/PostcodeLookup
 ├── Postcode_ONSPD.pq     # ONSPD version
 ├── Postcode_NSPL.pq      # NSPL version
 └── README_Combined.md    # This combined file

```

---

## ⚙️ Overview of Each Version

### 🟩 ONSPD Version (`Postcode_ONSPD.pq`)

- Source: **ONS Postcode Directory (ONSPD)**  
- Typical filename: `ONSPD_AUG_2025_UK.csv`
- Includes both live and terminated postcodes (since 1996)
- Used when you require full historical coverage or compatibility with legacy ONS releases

**Key URLs**
- [ONS postcode product overview](https://www.ons.gov.uk/methodology/geography/geographicalproducts/postcodeproducts)
- [Open Geography Portal](https://geoportal.statistics.gov.uk/)
- [Current ONSPD releases](https://geoportal.statistics.gov.uk/search?q=PRD_ONSPD%20AUG_2025&sort=Date%20Created%7Ccreated%7Cdesc)
- [CSV version (Aug 2025)](https://geoportal.statistics.gov.uk/datasets/295e076b89b542e497e05632706ab429/about)

**Column set used**
```
pcds, doterm, oscty, oslaua, osward, usertype,
oseast1m, osnrth1m, osgrdind, ctry, rgn, pcon,
lsoa21, msoa21, lat, long
```

---

### 🟦 NSPL Version (`Postcode_NSPL.pq`)

- Source: **National Statistics Postcode Lookup (NSPL)**  
- Typical filename: `NSPL_MAY_2025_UK.csv`
- Updated for post‑2021 Census geography (e.g., ITL regions, IMD, LEP, ICB fields)
- Used when working with current boundaries and slightly smaller file sizes

**Key URLs**
- [NSPL May 2025 release](https://geoportal.statistics.gov.uk/datasets/national-statistics-postcode-lookup-may-2025-for-the-uk/about)
- [RGC June 2025 (UK)](https://geoportal.statistics.gov.uk/datasets/da3fb8af12e842a69255b0d21116bcaa/about)
- [Scottish RGC](https://www.gov.scot/publications/geography-code-register-for-official-statistics/)

**Column set used (before renaming)**
```
pcds, doterm, cty, laua, ward, usertype,
oseast1m, osnrth1m, osgrdind,
ctry, rgn, pcon,
lsoa21, msoa21, lat, long
```

**Renamed for consistency with ONSPD**
```
cty   → oscty
laua  → oslaua
ward  → osward
```

---

## 🧩 Shared Components

Both versions:
- Combine ONS/Scottish RGC data to enrich codes with human‑readable area names.  
- Filter postcodes so that:
  - All *live* postcodes are included.  
  - Terminated postcodes are retained only if termination ≥ January 2013 (configurable).  

allowing future extension (e.g., adding multiple derived tables).

---

## 🔧 Configuration

At the top of both `.pq` files you’ll find configurable parameters:

```m
SharePointRoot = "https://exampletenant.sharepoint.com/sites/exampleworkspace",
FolderPath = "ReferenceData/Postcode",
RGC_Scotland_File = "Register_of_Geographic_Codes_Scotland.xlsx",
RGC_UK_File = "Register_of_Geographic_Codes_UK.xlsx",
Postcode_File = "ONSPD_AUG_2025_UK.csv",   // or NSPL_MAY_2025_UK.csv
FilterYear = 2013
```

> ⚠️ **Privacy note:**  
> Do not publish real SharePoint or internal network URLs. Use placeholders or a local `config.json` file which you exclude via `.gitignore`.

---

## 🔄 Updating the Data

1. Visit the [Open Geography Portal](https://geoportal.statistics.gov.uk/).  
2. Search for **ONSPD** or **NSPL**, download the latest ZIP release.  
3. Extract the CSV (e.g. `ONSPD_MAY_2026_UK.csv` or `NSPL_MAY_2026_UK.csv`) to your `ReferenceData/Postcode` folder.  
4. Update the `Postcode_File` parameter in your `.pq` file.  
5. Download updated **Register of Geographic Codes** for both UK and Scotland:  
   - UK: [ONS RGC latest](https://geoportal.statistics.gov.uk/datasets/da3fb8af12e842a69255b0d21116bcaa/about)  
   - Scotland: [Scottish RGC](https://www.gov.scot/publications/geography-code-register-for-official-statistics/)  
6. Refresh your Power Query / Power BI dataset.

---

## 🧠 Notes & Best Practice

- For **current reporting**, both datasets perform similarly. NSPL offers slightly more up‑to‑date administrative codes (e.g., ITL vs. NUTS).  
- For **longitudinal or historical analysis**, prefer ONSPD because it retains terminated postcodes back to 1996.  
- Both scripts maintain a `IsLive` flag for filtering live postcodes.  
- Extend the `ColumnsToKeep` list if you need additional NSPL fields (e.g., `imd`, `lep1`, `pfa`, `icb`).

---

## 📦 Suggested Workflow

| Step | Action | Notes |
|------|---------|-------|
| 1 | Download ONSPD or NSPL + RGC files | From ONS and Scottish portals |
| 2 | Update `.pq` parameters | Point to latest filenames |
| 3 | Refresh query | Builds unified lookup table |
| 4 | Export to CSV / Dataflow | Optional for reuse across projects |

---

## 🧾 Licence

Data © Crown copyright and database right.  
Contains OS data © Crown copyright and database right 2025.  
Contains Royal Mail data © Royal Mail copyright and database right 2025.  
Contains National Statistics data © Crown copyright and database right 2025.

Released under the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).

---

## ✨ Acknowledgements

Maintained by **Phil Maynard**  
<https://philmaynard.uk>

Inspired by open‑data integration work supporting UK charities and data teams.
