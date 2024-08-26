--Checks if a table has any null value in Locations table
declare @sql nvarchar(max)

select @sql = STRING_AGG(concat(QUOTENAME(COLUMN_NAME),' IS NULL'), ' OR')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Locations'

set @sql = 'select * from Locations where' + @sql

execute sp_executesql @sql

--Checks if a table has any null value in Manufacturer table
go
declare @sql nvarchar(max)

select @sql = STRING_AGG(concat(QUOTENAME(COLUMN_NAME),' IS NULL'), ' OR')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Manufacturer'

set @sql = 'select * from Manufacturer where' + @sql

execute sp_executesql @sql

--Checks if a table has any null value in Products table
go
declare @sql nvarchar(max)

select @sql = STRING_AGG(concat(QUOTENAME(COLUMN_NAME),' IS NULL'), ' OR')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Products'

set @sql = 'select * from Products where' + @sql

execute sp_executesql @sql

--Checks if a table has any null value in Sales table
go
declare @sql nvarchar(max)

select @sql = STRING_AGG(concat(QUOTENAME(COLUMN_NAME),' IS NULL'), ' OR')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Sales'

set @sql = 'select * from Sales where' + @sql

execute sp_executesql @sql

--1. Is revenue growing on a monthly base?
select * from Sales

--Creating a month column 
alter table Sales
add Months nvarchar(15)

update Sales 
set Months = DATENAME(MONTH, Date)

select Months, SUM(Revenue) as [Revenue Total]
from Sales
group by Months
order by [Revenue Total] desc

--2.What days of the week do the company make the 
--most revenue?
alter table Sales
add Weekdays nvarchar(15)

update Sales 
set Weekdays = DATENAME(DW, Date)

select top 1 Weekdays, SUM(Revenue) as [Revenue Total]
from Sales
group by Weekdays
order by [Revenue Total] desc


--3.What is the proportion of Category to total revenue
drop table if exists #CategoryPerRevenue

select pts.Category, SUM(sales.Revenue) as [Total Revenue]
into #CategoryPerRevenue
from Sales
join Products as pts
	on Sales.ProductID = pts.ProductID
group by pts.Category
order by [Total Revenue] desc

declare @revenuettl decimal(10,2)
select @revenuettl = sum([Total Revenue])
from #CategoryPerRevenue

select *,
convert(decimal(5,2),(([Total Revenue]/@revenuettl) * 100)) as ProportionPercent
from #CategoryPerRevenue
order by ProportionPercent desc


--4.What is the contribution of each state to the total 
--revenue of the company?
go
drop table if exists #StateContribution

select lts.State, SUM(Sales.Revenue) as [Total Revenue]
into #StateContribution
from Sales
join Locations as lts
on Sales.Zip = lts.Zip
group by lts.State
order by [Total Revenue]

declare @revenuettl decimal(10,2)

select @revenuettl = SUM([Total Revenue])
from #StateContribution

select *,
convert(decimal(5,2),(([Total Revenue]/@revenuettl) * 100)) as ContributionPercent
from #StateContribution
order by ContributionPercent desc


--5.What Segment has the highest amount of revenue?
select pdts.Segment, SUM(Sales.Revenue) as [Total Revenue]
from products pdts
join sales 
on pdts.ProductID = Sales.ProductID
group by pdts.Segment
order by [Total Revenue] desc

--6.What are the top 5 best-selling products?
select top 5 [Product Name], SUM(Revenue) as [SumRevenue]
from Products 
join Sales
on Products.ProductID = Sales.ProductID
group by [Product Name]
order by [SumRevenue] desc