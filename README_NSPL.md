# 🗺️ UK Postcode Lookup Builder (NSPL Version)

This version of the project builds a consolidated **postcode lookup table** using the **National Statistics Postcode Lookup (NSPL)** dataset instead of the ONS Postcode Directory (ONSPD).  
It provides the same structure and joins, allowing drop-in replacement for workflows that already use the ONSPD version.

---

## 📋 Overview

The Power Query script [`PostcodeLookup_NSPL.pq`](PostcodeLookup_NSPL.pq) automates the process of:

1. Loading the **NSPL May 2025** dataset from the ONS Open Geography Portal.
2. Combining it with the **Register of Geographic Codes (RGC)** for both UK and Scotland.
3. Filtering out postcodes terminated before a configurable date (default: January 2013).
4. Producing a clean, standardised output table with harmonised column names (matching ONSPD format).

---

## 🧩 Data Sources

| Dataset | Description | Publisher | URL |
|----------|--------------|------------|-----|
| **NSPL (National Statistics Postcode Lookup)** | Lookup of UK postcodes to current statistical and administrative areas. | ONS Geography | [NSPL May 2025](https://geoportal.statistics.gov.uk/datasets/national-statistics-postcode-lookup-may-2025-for-the-uk/about) |
| **Register of Geographic Codes (UK)** | Official geographic code list. | ONS Geography | [RGC June 2025](https://geoportal.statistics.gov.uk/datasets/da3fb8af12e842a69255b0d21116bcaa/about) |
| **Register of Geographic Codes (Scotland)** | Scottish Government maintained register. | Scottish Government | [Scotland RGC](https://www.gov.scot/publications/geography-code-register-for-official-statistics/) |

---

## ⚙️ Configuration

Edit the parameters at the top of the `.pq` file to match your file locations:

```m
SharePointRoot = "https://exampletenant.sharepoint.com/sites/exampleworkspace",
FolderPath = "ReferenceData/Postcode",
RGC_Scotland_File = "Register_of_Geographic_Codes_Scotland.xlsx",
RGC_UK_File = "Register_of_Geographic_Codes_UK.xlsx",
Postcode_File = "NSPL_MAY_2025_UK.csv",
FilterYear = 2013
```

> Do not commit real SharePoint URLs or credentials. Replace with placeholders or use a local config file.

---

## 🔄 Updating the Data

1. **Download the latest NSPL release**
   - Visit the [ONS Open Geography Portal](https://geoportal.statistics.gov.uk/).
   - Search for **“NSPL”** and download the latest release ZIP file.
   - Extract the CSV (e.g., `NSPL_MAY_2026_UK.csv`) to your `ReferenceData/Postcode` folder.

2. **Download updated Register of Geographic Codes (RGC) files**
   - UK: [ONS RGC June 2025](https://geoportal.statistics.gov.uk/datasets/da3fb8af12e842a69255b0d21116bcaa/about)
   - Scotland: [Scottish RGC](https://www.gov.scot/publications/geography-code-register-for-official-statistics/)

3. **Update filenames** in the `.pq` file if new versions are released.

4. **Refresh Power Query** to rebuild the lookup.

---

## 🧠 Notes and Best Practice

- The output column names are normalised to match the ONSPD version for consistency:
  - `cty` → `oscty`
  - `laua` → `oslaua`
  - `ward` → `osward`
- Additional NSPL fields (`imd`, `lep1`, `lep2`, `pfa`, etc.) can be added by extending the `ColumnsToKeep` list.
- The date logic for `doterm` is identical to ONSPD (YYYYMM numeric format).

---

## 🧾 Licence

Data © Crown copyright and database right.  
Contains OS data © Crown copyright and database right 2025.  
Contains Royal Mail data © Royal Mail copyright and database right 2025.  
Contains National Statistics data © Crown copyright and database right 2025.

Released under the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).

---

## ✨ Acknowledgements

Maintained by **Phil Maynard**  
<https://philmaynard.uk>
