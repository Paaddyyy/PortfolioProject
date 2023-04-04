

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing


--- Standardizing Date Format


SELECT SaleDateConverted, CONVERT(date,Saledate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,Saledate)


-- Another way if facing any issue


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,Saledate)



--- Populate Property Address Data


SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress ,ISNULL( a.PropertyAddress , b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a 
SET PropertyAddress = ISNULL( a.PropertyAddress , b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL



---- Breaking Address Into Individual Column ( Address , City , State )


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING( PropertyAddress , 1 , CHARINDEX(',', PropertyAddress) -1) as Address , 
SUBSTRING( PropertyAddress , CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress , 1 , CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress , CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT * 
FROM PortfolioProject..NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

SELECT * 
FROM PortfolioProject..NashvilleHousing



---- CHange Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE When SoldAsVacant  = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   End
FROM PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
                        When SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						End



---- Removing Duplicate


WITH RowNumCTE AS(
Select *,
     ROW_NUMBER() Over(
     PARTITIOn by ParcelID,
			      PropertyAddress ,
			      SalePrice,
			      SaleDate, 
			      LegalReference
			      Order by
			        UniqueID
			        ) row_num
FROM PortfolioProject..NashvilleHousing
)
Select * 
FROM RowNumCTE
WHERE row_num > 1
Order By PropertyAddress

---DELETE
---FROM RowNumCTE
---WHERE row_num > 1
-----Order By PropertyAddress


---- Delete Unused Column


SELECT * 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate