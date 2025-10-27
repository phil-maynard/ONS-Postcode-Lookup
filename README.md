# 🗺️ UK Postcode Lookup Builder (Power Query)

This project builds a consolidated **postcode lookup table** using open data from the **Office for National Statistics (ONS)** and the **Register of Geographic Codes (RGC)**.  
It’s designed for use in Power BI / Power Query pipelines where postcode data is needed to join CRM or service data to current UK geographic areas (Local Authority, Region, Constituency, etc.).

---

## 📋 Overview

The Power Query script [`PostcodeLookup.pq`](PostcodeLookup.pq) automates the process of:

1. Loading the **ONS Postcode Directory (ONSPD)** — or, optionally, the **National Statistics Postcode Lookup (NSPL)**.
2. Joining related **Register of Geographic Codes** (UK and Scotland) to enrich each postcode with readable names.
3. Filtering out postcodes terminated before a configurable date (default: January 2013).
4. Producing a single, clean table ready to load into Power BI or other analytical tools.

Output column set includes postcode, key codes (LAD, ward, region, etc.), human-readable area names, coordinates, and a flag for “live” postcodes.

---

## 🧩 Data Sources

| Dataset | Description | Publisher | Update Frequency |
|----------|--------------|------------|------------------|
| **ONS Postcode Directory (ONSPD)** | Maps current and historic postcodes to statistical and administrative areas. | ONS Geography | Quarterly |
| **National Statistics Postcode Lookup (NSPL)** | Alternative postcode lookup with simplified fields and similar coverage. | ONS Geography | Quarterly |
| **Register of Geographic Codes (RGC)** – UK | Lookup of official geographic code names and statuses. | ONS Geography | Quarterly |
| **Register of Geographic Codes (RGC)** – Scotland | Scottish Government maintained register of codes. | Scottish Government | Quarterly |

---

## 🌐 Key Reference URLs

- **Overview of ONS postcode products:**  
  <https://www.ons.gov.uk/methodology/geography/geographicalproducts/postcodeproducts>

- **ONS Open Geography Portal:**  
  <https://geoportal.statistics.gov.uk/>

- **Latest ONSPD releases (search results):**  
  <https://geoportal.statistics.gov.uk/search?q=PRD_ONSPD%20AUG_2025&sort=Date%20Created%7Ccreated%7Cdesc>

- **CSV version of the current ONSPD data file:**  
  <https://geoportal.statistics.gov.uk/datasets/295e076b89b542e497e05632706ab429/about>

- **Register of Geographic Codes (UK) – June 2025:**  
  <https://geoportal.statistics.gov.uk/datasets/da3fb8af12e842a69255b0d21116bcaa/about>

- **Register of Geographic Codes (Scotland):**  
  <https://www.gov.scot/publications/geography-code-register-for-official-statistics/>

---

## ⚙️ Configuration

Edit the parameters at the top of `PostcodeLookup.pq`:

```m
SharePointRoot = "https://exampletenant.sharepoint.com/sites/exampleworkspace",
FolderPath = "ReferenceData/Postcode",
RGC_Scotland_File = "Register_of_Geographic_Codes_Scotland.xlsx",
RGC_UK_File = "Register_of_Geographic_Codes_UK.xlsx",
Postcode_File = "ONSPD_UK.csv",
FilterYear = 2013
```

> **Note:**  
> Never commit real tenant URLs or credentials to a public repository.  
> Replace them with placeholders or use a local `config.json` that you `.gitignore`.

---

## 🔄 Updating the Data

1. **Download the latest ONSPD or NSPL files**
   - Visit the [Open Geography Portal](https://geoportal.statistics.gov.uk/).
   - Search for **“ONSPD”** or **“NSPL”** and select the latest quarterly release (ZIP file).
   - Extract the CSV file (e.g., `ONSPD_AUG_2025_UK.csv`) into your local or SharePoint `ReferenceData/Postcode` folder.

2. **Download updated RGC files**
   - UK register (Excel): [ONS RGC June 2025](https://geoportal.statistics.gov.uk/datasets/da3fb8af12e842a69255b0d21116bcaa/about)
   - Scotland register (Excel): [Scottish Government RGC](https://www.gov.scot/publications/geography-code-register-for-official-statistics/)

3. **Update filenames** in the `.pq` script if the file names change (for example `ONSPD_MAY_2026.csv`).

4. **Refresh the Power Query** to rebuild the lookup table with new data.

---

## 🧠 Notes and Best Practice

- Keep both **live** and **terminated** postcodes if you need historical data linkage.  
  For current reporting, the default filter keeps postcodes terminated after 2013 or still active.
- You can switch to the NSPL dataset by adjusting the source CSV and column names.  
  The overall logic remains the same.
- ONS releases new versions quarterly (typically February, May, August, and November).  
  It’s good practice to store both the raw files and the resulting processed table for reproducibility.

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
