-- Sales Data Analysis using SQL
--The queries written in this sql file answers the questions below

	--1. Which of the seasons (Spring, Summer, Fall and Winter) has the highest profit?
	--2. Which Age Group contributed the most to the business in terms of profit (Note: Group the age column using: less than 25 – Youth, 25-34 – Young Adult, 35-64 – Adults, 65 and above – Seniors)?
	--3. How is profit performing over the years?
	--4. Which day of the week did the company made the highest profit?
	--5. Which gender contributed the most to the profitability of the company?
	--6.Identify the top 10 best selling sub-product category based on profit.




select * from SalesData;

-- Creating the profits column
--	PROFIT = TOTAL REVENUE - TOTAL EXPENSE
alter table SalesData
add [Total Revenue] decimal(10,2), [Total Expense] decimal(10,2), Profit decimal(10,2)

update SalesData -- TOTAL REVENUE
set [Total Revenue] = Unit_Price * Order_Quantity

update SalesData -- TOTAL EXPENSE
set [Total Expense] = Unit_Cost * Order_Quantity

update SalesData --PROFIT
set Profit = [TOTAL REVENUE] - [TOTAL EXPENSE]


--							1. Which of the seasons (Spring, Summer, Fall and Winter) has the highest profit?


-- Add a Seasons column to the table 
alter table SalesData
add Seasons nvarchar(50);


-- Updating the seasons column according to the Date's column respective seasons
update SalesData
set Seasons = case
	when MONTH(Date) >= 3 and MONTH(Date) <= 5 then 'Spring'
	when MONTH(Date) >= 6 and MONTH(Date) <= 8 then 'Summer'
	when MONTH(Date) >= 9 and MONTH(Date) <= 11 then 'Autumn(Fall)'
	when MONTH(Date) = 12 or MONTH(Date) <= 2 then 'Winter'
end 

select Date,DATENAME(MM, Date) as Months, Seasons
from SalesData


-- Season with highest profit
select Seasons, max(Profit) as Profit from 
SalesData
group by Seasons
order by Profit asc

-- Season with highest profit total
select Seasons, sum(Profit) as Profit from 
SalesData
group by Seasons
order by Profit asc




--							2. Which Age Group contributed the most in terms of profits?


--Adding Age Group column and updating it 
alter table SalesData
add [Age Group] nvarchar(100);


-- updating the Age group column to match a specificed group according to customer's age
update SalesData
set [Age Group] = 
case
	when Customer_Age < 25 then 'Youth'
	when Customer_Age >= 25 and Customer_Age < 35 then 'Young Adult'
	when Customer_Age >= 35 and Customer_Age < 65 then 'Adult'
	when Customer_Age >= 65 then 'Senior'
end ;

-- Finding the age group with the most contribution in percent 

select [Age Group],sum(Profit) Profit_Sum
into [#Profit by Age Group] -- select the group and the sum of profit per group into a temp table
from SalesData
group by [Age Group]

declare @ttlProfit int = 0;
select @ttlProfit = sum(Profit_Sum)
from [#Profit by Age Group]

select *, ((Profit_Sum / @ttlProfit) * 100) as _percentage
from [#Profit by Age Group]
order by _percentage desc;


--							3. How is profit performing over the years?

-- Creating a year column 
alter table SalesData
add Years int

update SalesData
set Years = YEAR(Date)

select Years,sum(Profit) as [Yearly Performance]
from SalesData
group by Years
order by [Yearly Performance] asc


--							4. Which day of the week did the company made the highest profit?

-- Creating a day column
alter table SalesData
alter column WeekDays nvarchar(50)


update SalesData
set WeekDays = DATENAME(DW, Date)

-- Finding which day of the week has the highest profit
select WeekDays, SUM(Profit) as [Daily Performance]
from SalesData
group by WeekDays
order by [Daily Performance] desc


--							5. Which gender contributed the most to the profitability of the company?
-- Changing the gender column to proper text, like F - Female

update SalesData
set Customer_Gender = case
	when Customer_Gender = 'M' then 'Male'
	when Customer_Gender = 'F' then 'Female'
end

select Customer_Gender, SUM(Profit) [Gender Profit]
into [#Gender Profit Contribution]
from SalesData
group by Customer_Gender
order by [Gender Profit] desc

-- Finding the gender contribution percent in respect to the total gender profit
declare @totalGProfit int = 0;

select @totalGProfit = sum([Gender Profit])
from [#Gender Profit Contribution]

select Customer_Gender, SUM(Profit) as [Gender Profit], ((SUM(Profit) / @totalGProfit) * 100) as PercentageProfit
from SalesData
group by Customer_Gender


--							6.Identify the top 10 best selling sub-product category based on profit.
select top 10 sub_category, sum(profit) as [category_profit]
from SalesData
group by Sub_Category
order by [category_profit] desc;