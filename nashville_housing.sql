-- *************** CREATING TABLE TO IMPORT DATA ******************

-- CREATE TABLE nashville_housing (
--     UniqueID        INTEGER,
--     ParcelID        TEXT,
--     LandUse         TEXT,
--     PropertyAddress TEXT,
--     SaleDate        TEXT,
--     SalePrice       TEXT,
--     LegalReference  TEXT,
--     SoldAsVacant    TEXT,
--     OwnerName       TEXT,
--     OwnerAddress    TEXT,
--     Acreage         NUMERIC,
--     TaxDistrict     TEXT,
--     LandValue       NUMERIC,
--     BuildingValue   NUMERIC,
--     TotalValue      NUMERIC,
--     YearBuilt       INTEGER,
--     Bedrooms        INTEGER,
--     FullBath        INTEGER,
--     HalfBath        INTEGER
-- );

SELECT
	*
FROM nashville_housing;



-- ***************************** CLEANING DATA *************************************

-- ************************* STANDARDIZE DATE FORMAT ***************************

SELECT 
	SaleDate,
	SaleDate::DATE AS sale_date_converted
FROM nashville_housing;

UPDATE nashville_housing
	SET SaleDate = SaleDate::DATE;



-- ********************** POPULATE PROPERTY ADDRESS DATA ************************

SELECT
	PropertyAddress
FROM nashville_housing
WHERE PropertyAddress IS NULL;


WITH nul as (
	SELECT
		ParcelID AS id
	FROM nashville_housing
	WHERE PropertyAddress IS NULL)
SELECT
	DISTINCT(n.id),
	t.PropertyAddress
FROM nul n
	JOIN nashville_housing t
		ON n.id = t.ParcelID
WHERE PropertyAddress IS NOT NULL;


SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	COALESCE (a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
	JOIN nashville_housing b
		ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE nashville_housing a
	SET PropertyAddress = b.PropertyAddress
FROM nashville_housing b
WHERE a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
	AND a.PropertyAddress IS NULL
	AND b.PropertyAddress IS NOT NULL;


-- ****** BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) ******

SELECT 
	PropertyAddress
FROM nashville_housing;

SELECT
	SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) +1) AS City
FROM nashville_housing;


ALTER TABLE nashville_housing
	ADD PropertySplitAddress VARCHAR(255);

UPDATE nashville_housing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1);


ALTER TABLE nashville_housing
	ADD PropertySplitCity VARCHAR(255);

UPDATE nashville_housing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) +1);


SELECT 
	PropertyAddress,
	PropertySplitAddress,
	PropertySplitCity
FROM nashville_housing;



SELECT 
	OwnerAddress
FROM nashville_housing;

SELECT
	SPLIT_PART(OwnerAddress, ',', 1) AS OwnerSplitAddress,
	SPLIT_PART(OwnerAddress, ',', 2) AS OwnerSplitCity,
	SPLIT_PART(OwnerAddress, ',', 3) AS OwnerSplitState
FROM nashville_housing;


ALTER TABLE nashville_housing
	ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashville_housing
	SET OwnerSplitAddress = SPLIT_PART(OwnerAddress, ',', 1);


ALTER TABLE nashville_housing
	ADD OwnerSplitCity VARCHAR(255);

UPDATE nashville_housing
	SET OwnerSplitCity = SPLIT_PART(OwnerAddress, ',', 2);


ALTER TABLE nashville_housing
	ADD OwnerSplitState VARCHAR(255);

UPDATE nashville_housing
	SET OwnerSplitState = SPLIT_PART(OwnerAddress, ',', 3);
	
	

SELECT 
	OwnerAddress,
	OwnerSplitAddress,
	OwnerSplitCity,
	OwnerSplitState
FROM nashville_housing;


-- ****** CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD ******

SELECT DISTINCT
	soldasvacant
FROM nashville_housing;

SELECT
	soldasvacant,
	CASE
		WHEN soldasvacant = 'Y' THEN 'Yes'
		WHEN soldasvacant = 'N' THEN 'No'
		ELSE soldasvacant
	END AS soldformated
FROM nashville_housing;

UPDATE nashville_housing
	SET soldasvacant = 
		CASE
			WHEN soldasvacant = 'Y' THEN 'Yes'
			WHEN soldasvacant = 'N' THEN 'No'
			ELSE soldasvacant
		END;


-- *********************** REMOVE DUPLICATES **************************

WITH dupe AS (
	SELECT
		ctid,
		ROW_NUMBER() OVER (
			PARTITION BY parcelid,
						 propertyaddress,
						 saleprice,
						 saledate,
						 legalreference
			ORDER BY uniqueid
		) AS row_num
	FROM nashville_housing
)
DELETE FROM nashville_housing                 -- CONSIDER NOT DELETING DATA FROM THE DB - FOR DISPLAY PURPOSES ONLY
WHERE ctid IN (
	SELECT ctid FROM dupe WHERE row_num > 1
);



-- ********************** REMOVE UNUSED COLUMNS ************************

SELECT
	*
FROM nashville_housing;

ALTER TABLE nashville_housing  				-- CONSIDER NOT DELETING COLUMNS FROM THE DB - FOR DISPLAY PURPOSES ONLY
	DROP COLUMN owneraddress,
	DROP COLUMN taxdistrict,
	DROP COLUMN propertyaddress,
	DROP COLUMN saledate;
