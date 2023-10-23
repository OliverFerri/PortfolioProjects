/*

Cleaning Data in SQL Queries

*/

USE citrinne;

SELECT *
FROM NashvilleHousing;
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
FROM NashvilleHousing nh1
JOIN NashvilleHousing nh2
	ON nh1.[UniqueID ] != nh2.[UniqueID ] 
	AND nh1.ParcelID = nh2.ParcelID
WHERE nh1.PropertyAddress IS NULL;

UPDATE nh1
SET PropertyAddress = ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
FROM NashvilleHousing nh1
JOIN NashvilleHousing nh2
	ON nh1.[UniqueID ] != nh2.[UniqueID ] 
	AND nh1.ParcelID = nh2.ParcelID
WHERE nh1.PropertyAddress IS NULL;

SELECT PropertyAddress
FROM NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Property Address: Splitting into Address and City using substring
SELECT PropertyAddress
FROM NashvilleHousing;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) AS address
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress =
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

UPDATE NashvilleHousing
SET PropertySplitCity =
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress));

SELECT PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing;


-- Owner Address: Spitting into Address, City and State using parsename
SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress =
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3);

UPDATE NashvilleHousing
SET OwnerSplitCity =
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2);

UPDATE NashvilleHousing
SET OwnerSplitState =
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1);



SELECT
PARSENAME(REPLACE(PropertyAddress, ',' , '.'), 2),
PARSENAME(REPLACE(PropertyAddress, ',' , '.'), 1)
FROM NashvilleHousing;


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing;




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH Row_Num_CTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
    ORDER BY UniqueID) row_num
FROM NashvilleHousing
--ORDER BY ParcelID;
)
SELECT *
FROM Row_Num_CTE
WHERE row_num > 1
ORDER BY PropertyAddress;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT * INTO #TempNashville
FROM NashvilleHousing;

ALTER TABLE #TempNashville
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict;

SELECT *
FROM #TempNashville;

SELECT *
FROM NashvilleHousing;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	
