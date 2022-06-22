/* Cleaning Data in SQL Queries */

Select*
From PortfolioProject..NashvilleHousing

-- Standardize Date Format
Select Saledate, CONVERT(date,SaleDate) 
From PortfolioProject..NashvilleHousing

update NashvilleHousing
SET SaleDate=CONVERT(date,SaleDate)

ALTER TABLE nashvillehousing
add saledateconverted Date;  -- We used this because somehow on the previous two lines it didn't work

update NashvilleHousing
SET SaleDateconverted=CONVERT(date,SaleDate)

Select saledateconverted
from PortfolioProject..NashvilleHousing -- Here's the updated column 

-- Populate Property Address Data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
-- ISNULL is used to replace NULL a.property address with b. Propertyaddress 
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
-- Parcel ID as a reference point
-- We need to create a self joint so when Parcel ID are equal, property address has to be equal as well

update a
Set PropertyAddress=ISNULL(a.propertyaddress,b.PropertyAddress) -- We replace colum property address in table a with ISNULL function
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out address into individual columns ( Address, City, State)

Select
SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress)-1) as address 
, SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress)+1,LEN(Propertyaddress)) as address  -- LEN is used for length of the string// Second substring to start after ',' position
-- +1 and -1 to not include a comma 
from PortfolioProject..NashvilleHousing

-- SUBSTRING is a function in SQL which allows   the user to derive substring from any given string set as per user need.//SUBSTRING(Expression, Starting Position, Total Length)
-- CHARINDEX function searches for a substring in a string, and returns the position.//CHARINDEX(substring, string, start)

ALTER TABLE NashvilleHousing 
add PropertysplitAddress Nvarchar(225);  

update NashvilleHousing
SET PropertySplitAddress=SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress)-1)

ALTER TABLE nashvillehousing
add Propertysplitcity Nvarchar(225);  -- We used this because somehow on the previous two lines it didn't work

update NashvilleHousing
SET Propertysplitcity =SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress)+1,LEN(Propertyaddress))


-- Another Alternative way to Break Adresses

Select
PARSENAME(Replace(OWneraddress, ',','.') , 3)
, PARSENAME(Replace(OWneraddress, ',','.') , 2)
, PARSENAME(Replace(OWneraddress, ',','.') , 1)

from PortfolioProject..NashvilleHousing
where owneraddress is not Null

ALTER TABLE NashvilleHousing 
add OWnersplitAddress Nvarchar(225);  

update NashvilleHousing
SET OWnersplitAddress=PARSENAME(Replace(OWneraddress, ',','.') , 3)

ALTER TABLE nashvillehousing
add OWnersplitcity Nvarchar(225);  

update NashvilleHousing
SET OWnersplitcity =PARSENAME(Replace(OWneraddress, ',','.') , 2)

ALTER TABLE nashvillehousing
add OWnersplitstate Nvarchar(225);  

update NashvilleHousing
SET OWnersplitstate =PARSENAME(Replace(OWneraddress, ',','.') , 1)

Select*
From PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(soldasvacant), Count(Soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldasVacant, 
Case when Soldasvacant = 'Y' then 'YES'
when soldasvacant = 'N' then 'NO'
else soldasvacant 
end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
Set SoldAsVacant =Case when Soldasvacant = 'Y' then 'YES'
when soldasvacant = 'N' then 'NO'
else soldasvacant 
end

--Remove Duplicates
 -- We use  CTE

 WITH rownumCTE as(
 Select*,
 ROW_NUMBER() OVER( 
 PARTITION BY ParcelID,
 Propertyaddress,
 saleprice,
 saledate,
 legalreference
 Order by 
UniqueID 
) row_num

from portfolioproject..nashvillehousing
)
DELETE 
From RowNumCTE 
where row_num > 1


-- Delete Unused Columns 
 Select* 
 From PortfolioProject..NashvilleHousing

 Alter table portfolioproject..nashvillehousing
 Drop column owneraddress, taxdistrict, propertyaddress, saledate 