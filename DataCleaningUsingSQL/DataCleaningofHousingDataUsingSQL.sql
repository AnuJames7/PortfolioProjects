-----Cleaning Nashville Housing Data using SQL
Select * from Portfolio_Project.dbo.Housing
------------------------------------------------------------------------------------------------------------------------------------------------------
-- Standarize Date Format (Datetime to date, update doesn't work somehow, so added a new column)

Select SaleDate from Portfolio_Project.dbo.Housing
--Select SaleDate,TRY_CONVERT(DATE,SaleDate) from Portfolio_Project.dbo.Housing
--Update Portfolio_Project.dbo.Housing set SaleDate=TRY_CONVERT(DATE,SaleDate)

alter table Portfolio_Project.dbo.Housing add SaleDateConverted date
Update Portfolio_Project.dbo.Housing set SaleDateConverted=CONVERT(DATE,SaleDate)

------------------------------------------------------------------------------------------------------------------------------------------------------
--Populate  Property Address Data

 -- Multiple property address' null
 select * from Portfolio_Project.dbo.Housing where PropertyAddress is null

 -- Now, when we go through the data, we can see that if the ParcelID is same then the PropertyAddress is also same.
 select ParcelID,PropertyAddress from Portfolio_Project.dbo.Housing where PropertyAddress is null order by ParcelID

 select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress from Portfolio_Project.dbo.Housing a join Portfolio_Project.dbo.Housing b on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ] where b.PropertyAddress is null
 
 Update b
 set PropertyAddress =isnull(b.PropertyAddress,a.PropertyAddress) from Portfolio_Project.dbo.Housing a join Portfolio_Project.dbo.Housing b on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ] where b.PropertyAddress is null

 -------------------------------------------------------------------------------------------------------------------------------------------------------
 ---- Breaking Address further into Address, City, State for better analysis later
select PropertyAddress from Portfolio_Project.dbo.Housing

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address from Portfolio_Project.dbo.Housing

alter table Portfolio_Project.dbo.Housing add PropertySepAddress nvarchar(255)
Update Portfolio_Project.dbo.Housing set PropertySepAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

select SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as address from Portfolio_Project.dbo.Housing

alter table Portfolio_Project.dbo.Housing add PropertySepCity nvarchar(255)
Update Portfolio_Project.dbo.Housing set PropertySepCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))

---Breaking Owner Address

select PARSENAME(replace(OwnerAddress,',','.'),3) from Portfolio_Project.dbo.Housing

alter table Portfolio_Project.dbo.Housing add OwnerSepAddress nvarchar(255)
Update Portfolio_Project.dbo.Housing set OwnerSepAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

alter table Portfolio_Project.dbo.Housing add OwnerSepCity nvarchar(255)
Update Portfolio_Project.dbo.Housing set OwnerSepCity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table Portfolio_Project.dbo.Housing add OwnerSepState nvarchar(255)
Update Portfolio_Project.dbo.Housing set OwnerSepState=PARSENAME(replace(OwnerAddress,',','.'),1)

---------------------------------------------------------------------------------------------------------------------------------------------

---Make Values in 'SoldAsVacant' column consistent. Change Y to Yes and N to No

SELECT DISTINCT SoldAsVacant from Portfolio_Project.dbo.Housing

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN  SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant 
	 END
from Portfolio_Project.dbo.Housing

UPDATE Portfolio_Project.dbo.Housing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN  SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant 
	 END

---- Change misspelled value in "LandUse" Column. 'VACANT RESIENTIAL LAND' to 'VACANT RESIDENTIAL LAND' 

SELECT DISTINCT LandUse FROM Portfolio_Project.dbo.Housing 

--Here, we can see that there are some instances of 'Vacant Residential Land' being mispelled as 'VACANT RESIENTIAL LAND'

UPDATE Portfolio_Project.dbo.Housing SET LandUse='VACANT RESIDENTIAL LAND' WHERE LandUse='VACANT RESIENTIAL LAND'


----REMOVE DUPLICATES

-- Checking for duplicate Unique Id's as they are primary key. 
SELECT [UniqueID ],count([UniqueID ]) FROM Portfolio_Project.dbo.Housing GROUP BY [UniqueID ] HAVING count([UniqueID ])>1 

WITH RowNumCTE AS(
Select *,
        ROW_NUMBER() over (
		PARTITION BY ParcelID,
		             PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER BY
					 UniqueID
					 ) row_num
from Portfolio_Project.dbo.Housing
)
DELETE from RowNumCTE where row_num>1


---------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------DELETE UNUSED COLUMNS

ALTER TABLE Portfolio_Project.dbo.Housing
DROP COLUMN SaleDate, PropertyAddress,OwnerAddress




