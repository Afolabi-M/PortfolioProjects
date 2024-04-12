/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing;


-- Standardize Date Format

SELECT SaleDate
FROM ProjectPortfolio.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD saleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT	SaleDateConverted,
		CONVERT(DATE, SaleDate)
FROM ProjectPortfolio.dbo.NashvilleHousing;

SELECT * FROM ProjectPortfolio.dbo.NashvilleHousing;


-- Populate Property Address Data

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT	a.ParcelID,
		a.PropertyAddress,
		b.ParcelID,
		b.PropertyAddress,
		ISNULL (a.propertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL (a.propertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]


-- Breaking Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM ProjectPortfolio.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT	SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
		SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE ProjectPortfolio.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE ProjectPortfolio.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing

SELECT OwnerAddress
FROM ProjectPortfolio.dbo.NashvilleHousing

SELECT 
	PARSENAME (REPLACE (OwnerAddress, ',', '.') ,3),
	PARSENAME (REPLACE (OwnerAddress, ',', '.') ,2),
	PARSENAME (REPLACE (OwnerAddress, ',', '.') ,1)
FROM ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE ProjectPortfolio.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress, ',', '.') ,3)

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE ProjectPortfolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress, ',', '.') ,2)

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE ProjectPortfolio.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE (OwnerAddress, ',', '.') ,1)



-- Change Y and N to Yes and NO in ('Sold as Vacant') field

SELECT	DISTINCT (SoldAsVacant),
		COUNT (SoldAsVacant)
FROM ProjectPortfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
FROM ProjectPortfolio.dbo.NashvilleHousing

UPDATE ProjectPortfolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END


-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
						) row_num 

From ProjectPortfolio.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress



-- Delete Unused Columns

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,
			TaxDistrict,
			PropertyAddress

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate