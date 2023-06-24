
--Data cleaning project.
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousingData

--Standardize data format
SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousingData


Update NashvilleHousingData
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted Date;

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousingData


--------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data
 
SELECT *
FROM PortfolioProject..NashvilleHousingData

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------

--Break out Address into individual column (Address, City, State)
SELECT PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousingData

---------------------------------------------------------------------------------------------------------

--Add the column for contain the address
ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


--Add the column for contain the city
ALTER TABLE NashvilleHousingData
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))  

---SEE the result
SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..NashvilleHousingData

---------------------------------------------------------------------------------------------------------

--Seprate the Address, City, State --> WITH ANOTHER METHOD
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
From PortfolioProject..NashvilleHousingData


--Insert the column for each sepration

--Address
ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

--City
ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

--State
ALTER TABLE NashvilleHousingData
ADD OwnerSplitState nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


---SEE the result
SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject..NashvilleHousingData


---------------------------------------------------------------------------------------------------------

--Replace the 'Y' and 'N' with 'Yes' and 'No' in 'SoldAsVaccant' field

--See the values
SELECT Distinct(SoldAsVacant),  Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2


--Replacement
SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
	     When SoldAsVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	     END

FROM PortfolioProject..NashvilleHousingData


---Update the values in the table
Update NashvilleHousingData
SET SoldAsVacant = CASE  When SoldAsVacant = 'Y' THEN 'Yes'
						 When SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END

--See the result
SELECT Distinct(SoldAsVacant),  Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

---------------------------------------------------------------------------------------------------------------------------------------

--Remove the Duplicate

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY UniqueID,
		ParcelID,
		LandUse,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference
		ORDER BY 
		 UniqueID)	row_num	

FROM PortfolioProject..NashvilleHousingData
--WHERE row_num>1
)

SELECT *
FROM RowNumCTE
Where row_num>1

-----If duplicate occure in row_num = 2,3...
---DELETE it
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY UniqueID,
		ParcelID,
		LandUse,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference
		ORDER BY 
		 UniqueID)	row_num	

FROM PortfolioProject..NashvilleHousingData
--WHERE row_num>1
)

DELETE
FROM RowNumCTE
Where row_num>1


---------------------------------------------------------------------------------------------------------------------------------------

--Remove Unused Column
SELECT *
FROM PortfolioProject..NashvilleHousingData

--Because we saved it in different column
ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN SaleDate



-------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------All DATA------------------------------------------------------------------------
SELECT *
FROM PortfolioProject..NashvilleHousingData

---------------------------------------------FINAL CLEAN DATA------------------------------------------------------------------------

SELECT SaleDateConverted,PropertyAddress, PropertySplitAddress,PropertySplitCity, OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState,SoldAsVacant
FROM PortfolioProject..NashvilleHousingData