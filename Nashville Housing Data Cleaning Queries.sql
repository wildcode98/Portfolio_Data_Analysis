select * from 
PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------
-- standarize data format 

select SaleDateConverted
from
PortfolioProject.dbo.NashvilleHousing;

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date,saledate);

--------------------------------------------------------------------------
--Populate property address table

select *
from
PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is NULL;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from
PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from
PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

---------------------------------------------------------------------------------
--Breaking address into individual columns (address, city, state) 

select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as City
from
PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress));

-------------------------------------------------------------------------------------------------------------

select 
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from
PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3);

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2);

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1);

----------------------------------------------------------------------------------------------------

--Change 'Y' as Yes and 'N' as No in SoldAsVacant column

select distinct (SoldAsVacant), count(SoldAsVacant)
from
PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant;



select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from
PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

------------------------------------------------------------------------------------------

--Remove duplicates

With RowNumCTE AS(
select *, 
	ROW_NUMBER() over(
	partition by parcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by 
					uniqueID
				)row_num
from 
PortfolioProject.dbo.NashvilleHousing)
Delete from RowNumCTE
where row_num>1 
--order by [UniqueID ]

-----------------------------------------------------------------------------------------------------

--Delete unused or irrelevant columns 

alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column saledate

select * from 
PortfolioProject.dbo.NashvilleHousing