select * from dbo.Nashwillehousing

--standardize date format
select SaleDateconvert,cast(SaleDate as date) from dbo.Nashwillehousing

Alter table Nashwillehousing
add SaleDateconvert Date
update Nashwillehousing
set SaleDateconvert=cast(SaleDate as date)

-- Populate Property Address data
Select *
From PortfolioProject.dbo.Nashwillehousing
--Where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashwillehousing as a join Nashwillehousing as b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ] 
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashwillehousing as a join Nashwillehousing as b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ] 
where a.PropertyAddress is null

------ParseName
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.Nashwillehousing



ALTER TABLE Nashwillehousing
Add OwnerSplitAddress Nvarchar(255);

Update Nashwillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashwillehousing
Add OwnerSplitCity Nvarchar(255);

Update Nashwillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nashwillehousing
Add OwnerSplitState Nvarchar(255);

Update Nashwillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.Nashwillehousing

--- Change Y and N to Yes and No in "Sold as Vacant" field
select SoldAsVacant, count(SoldAsVacant)
from Nashwillehousing
group by SoldAsVacant order by 2

select SoldAsVacant,
case
when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end
from Nashwillehousing

update Nashwillehousing set
SoldAsVacant=case
when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end
from Nashwillehousing

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.Nashwillehousing
--order by ParcelID
)
--Delete
Select *
From RowNumCTE
Where row_num > 1



Select *
From PortfolioProject.dbo.Nashwillehousing

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.Nashwillehousing


ALTER TABLE PortfolioProject.dbo.Nashwillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

