
-- Stanadardize date/time

SELECT SaleDateConverted,CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND A.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND A.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking out address into indevidual columns (Address, City, Sate)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID 

SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..NashvilleHousing



SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END


-- Remove Duplicates

WITH RowNumbCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID
				) row_num
	 

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumbCTE
WHERE row_num > 1 
--Order by PropertyAddress


-- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate








