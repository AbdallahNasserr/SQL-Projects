/*------------------------ Data Cleaning Portfolio Project ------------------------*/


/* Cleaning Data using SQL Queries */


/*-----------------------------------------------------------------------------------*/


SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[Nashville_Housing]


  /**************************************************/
  
  
  /* Select Everything From Dataset */

  SELECT * FROM PortfolioProject.dbo.Nashville_Housing


/*----- Change Salesdate Datatype From Datetime To Date -----*/
SELECT SaleDate , CONVERT(DATE,SaleDate) FROM PortfolioProject.dbo.Nashville_Housing ORDER BY 1;
UPDATE PortfolioProject.dbo.Nashville_Housing SET SaleDate = CONVERT(DATE, SaleDate)
/*IF THE ABOVE NOT WORKING */

ALTER TABLE Nashville_Housing ALTER COLUMN SaleDate DATE
SELECT SaleDate , CONVERT(DATE,SaleDate) FROM PortfolioProject.dbo.Nashville_Housing ORDER BY 1;
/*Done*/

--OR I CAN DO LIKE VIDEO

ALTER TABLE portfolioproject.dbo.nashville_housing ADD salesdate DATE;
UPDATE portfolioproject.dbo.nashville_housing SET salesdate = CONVERT(DATE,saledate)

SELECT salesdate FROM portfolioproject.dbo.nashville_housing

/*******************************************************/

SELECT * FROM portfolioproject.dbo.nashville_housing
ORDER BY 2
--WHERE PropertyAddress IS NULL

/********************************************************/


-- Populate Property Address data --> REMOVING NULL VALUES


SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress) 
FROM portfolioproject.dbo.nashville_housing A
JOIN portfolioproject.dbo.nashville_housing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL
--OR U CAN USING 
/*
AND A.[PropertyAddress] <>B.[PropertyAddress]
*/


UPDATE A
SET A.PropertyAddress = ISNULL(A.PropertyAddress ,B.PropertyAddress)
FROM portfolioproject.dbo.nashville_housing A
JOIN portfolioproject.dbo.nashville_housing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
--OR U CAN USING 
/*
AND A.[PropertyAddress] <>B.[PropertyAddress]
*/
WHERE A.PropertyAddress IS NULL


/***************************************************************/

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT * FROM Nashville_Housing

select PROPERTYADDRESS, SUBSTRING(Nashville_Housing.PropertyAddress, 1, CHARINDEX(',',Nashville_Housing.PropertyAddress)-1)
,SUBSTRING(Nashville_Housing.PropertyAddress, CHARINDEX(',',Nashville_Housing.PropertyAddress)+1, LEN(Nashville_Housing.PropertyAddress))
FROM Nashville_Housing

/*-- OR WE CAN DO THIS --*/

SELECT Nashville_Housing.PROPERTYADDRESS,PARSENAME(REPLACE(PROPERTYADDRESS,',','.'),2),PARSENAME(REPLACE(PROPERTYADDRESS,',','.'),1) FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PROPERTY_SPLIT_ADDRESS VARCHAR(255)

ALTER TABLE Nashville_Housing
ADD PROPERTY_SPLIT_CITY VARCHAR(255)

UPDATE Nashville_Housing
SET PROPERTY_SPLIT_ADDRESS = PARSENAME(REPLACE(PROPERTYADDRESS,',','.'),2)


UPDATE Nashville_Housing
SET PROPERTY_SPLIT_CITY = PARSENAME(REPLACE(PROPERTYADDRESS,',','.'),1)

SELECT * FROM Nashville_Housing


/*THE SAME IDEA WITH OWNERADDRESS TO MAKE IT MORE USEFUL */

Select OwnerAddress
From PortfolioProject.dbo.Nashville_Housing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.Nashville_Housing



ALTER TABLE Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville_Housing
Add OwnerSplitCity Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nashville_Housing
Add OwnerSplitState Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProject.dbo.Nashville_Housing


/****************************************************************************/


-- REPLACING EACH N WITH NO AND Y WITH YES


SELECT * FROM Nashville_Housing
SELECT DISTINCT(SOLDASVACANT), COUNT(SoldAsVacant) FROM Nashville_Housing GROUP BY SoldAsVacant
SELECT
CASE SOLDASVACANT
WHEN 'N' THEN 'No'
WHEN 'Y' THEN 'Yes'
ELSE SOLDASVACANT
END SELLCASE
FROM Nashville_Housing

UPDATE Nashville_Housing 
SET SoldAsVacant = 
CASE 
WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant='Y' THEN 'Yes'
ELSE SoldAsVacant
END

/*************************************************************************/

/****** DELETE SOME UNUSED COLUMNS AFTER EDITING IT *********/

ALTER TABLE NASHVILLE_HOUSING  
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * FROM Nashville_Housing

