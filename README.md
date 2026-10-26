# Data Cleaning - SQL 🧹

A data cleaning project using **PostgreSQL** on the Nashville Housing dataset. The raw data has messy dates, missing addresses, combined address fields, inconsistent values and duplicate rows. This project cleans it into a structured table ready for analysis.

## About the Project

This project is part of my data analysis portfolio. It shows how SQL can be used to clean and prepare real-world data before analysis or visualisation, for example in Power BI.

## Dataset

**Nashville Housing Data:** around 56,000 property sales records from Nashville, Tennessee. It includes parcel IDs, addresses, sale dates, prices, owner details, land and building values, and property features such as bedrooms and bathrooms.

To make the import easier, the table was created with most messy fields stored as `TEXT` and then cleaned with SQL.

## Tools Used

- **PostgreSQL**
- **pgAdmin**

## Cleaning Steps

### 1. Standardise the Date Format
Converted `SaleDate` from text into a proper `DATE` format using `::DATE`.

### 2. Fill in Missing Property Addresses
Some rows had no `PropertyAddress`. Properties with the same `ParcelID` share an address, so a **self-join** was used to fill in the missing values from matching rows.

### 3. Split Addresses into Separate Columns
- `PropertyAddress` was split into **Address** and **City** with `SUBSTRING` and `POSITION`
- `OwnerAddress` was split into **Address**, **City** and **State** with `SPLIT_PART`

### 4. Standardise the "Sold As Vacant" Field
Replaced the inconsistent `Y` and `N` values with `Yes` and `No` using a `CASE` statement.

### 5. Remove Duplicates
Found duplicate records with `ROW_NUMBER()` over a `PARTITION BY` of key columns. They were deleted with PostgreSQL's hidden `ctid` row identifier, because `UniqueID` wasn't unique for the duplicate rows.

### 6. Remove Unused Columns
Dropped the original columns that had been replaced by cleaned or split versions: `OwnerAddress`, `PropertyAddress`, `SaleDate` and `TaxDistrict`.

> **Note:** Deleting rows and dropping columns is included here for demonstration only. In a real production database it's better to keep the raw data and create cleaned tables or views instead.

## SQL Techniques Used

- `CREATE TABLE`, `ALTER TABLE`, `UPDATE` and `DELETE`
- Self-joins and `UPDATE ... FROM`
- CTEs (`WITH`)
- Window functions (`ROW_NUMBER() OVER (PARTITION BY ...)`)
- `CASE` statements
- String functions: `SUBSTRING`, `POSITION` and `SPLIT_PART`
- `COALESCE` and NULL handling
- Type casting (`::DATE`)
- PostgreSQL's `ctid` for removing exact duplicates

## How to Use

1. Download the Nashville Housing dataset (CSV).
2. Create a database in pgAdmin and run the `CREATE TABLE` statement from the script.
3. Import the CSV into the `nashville_housing` table.
4. Run the cleaning queries in order.

## Repository Structure

├── DataCleaning.sql   # SQL cleaning queries
└── README.md
