select * from [ProductSales].[dbo].[Sales_Inventory]

select Category, sum(Sales) as sales from [ProductSales].[dbo].[Sales_Inventory]
where category = 'electronics'
group by Category

-- Data Cleaning: Handling NULLs
UPDATE [ProductSales].[dbo].[cleaned_inventory_sales]
SET CustomerName = 'Unknown'
WHERE CustomerName IS NULL;

-- Removing Duplicates
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY OrderID, CustomerID, Product ORDER BY OrderID) AS rn
    FROM [ProductSales].[dbo].[cleaned_inventory_sales]
)
DELETE FROM CTE WHERE rn > 1;

select * from [ProductSales].[dbo].[cleaned_inventory_sales]

-- Creating a new column for profit margin
ALTER TABLE [ProductSales].[dbo].[cleaned_inventory_sales] ADD ProfitMargin AS (Profit / NULLIF(Sales, 0) * 100);

-- Total Sales by Category
SELECT Category, SUM(Sales) AS TotalSales
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY Category;

-- Sales Trend Over Time
SELECT Date, SUM(Sales) AS TotalSales
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY Date
ORDER BY Date;

-- Top 5 Best-Selling Products
SELECT TOP 5 Product, SUM(Sales) AS TotalSales
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY Product
ORDER BY TotalSales DESC;

-- Regional Sales Distribution
SELECT Region, SUM(Sales) AS TotalSales
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY Region;

-- Top 5 customers with the highest total sales.
SELECT TOP 5 CustomerName, SUM(Sales) AS TotalSales
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY CustomerName
ORDER BY TotalSales DESC;

-- Month with the highest total sales.
SELECT TOP 1 FORMAT(Date, 'yyyy-MM') AS SalesMonth, SUM(Sales) AS TotalSales
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY FORMAT(Date, 'yyyy-MM')
ORDER BY TotalSales DESC;

-- All products that have been sold more than 100 times.
SELECT Product, SUM(Quantity) AS TotalQuantity
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY Product
HAVING SUM(Quantity) > 100;

-- Average order value per region.
SELECT Region, AVG(Sales) AS AvgOrderValue
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY Region;

-- Top 3 most profitable product categories.
SELECT TOP 3 Category, SUM(Profit) AS TotalProfit
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY Category
ORDER BY TotalProfit DESC;

-- Number of unique customers who made purchases each month.
SELECT FORMAT(Date, 'yyyy-MM') AS SalesMonth, COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY FORMAT(Date, 'yyyy-MM')
ORDER BY SalesMonth;

-- Region with the highest average profit per sale.
SELECT TOP 1 Region, AVG(Profit) AS AvgProfit
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY Region
ORDER BY AvgProfit DESC;

-- Cumulative sales for each day.
SELECT Date, SUM(Sales) OVER (ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeSales
FROM [ProductSales].[dbo].[cleaned_inventory_sales];

-- The most sold product in each category.
WITH RankedProducts AS (
    SELECT Product, Category, SUM(Quantity) AS TotalQuantity,
           RANK() OVER (PARTITION BY Category ORDER BY SUM(Quantity) DESC) AS rnk
    FROM [ProductSales].[dbo].[cleaned_inventory_sales]
    GROUP BY Product, Category
)
SELECT Product, Category, TotalQuantity
FROM RankedProducts
WHERE rnk = 1;

-- Customers who have made more than 5 purchases but have a total sales amount of less than $500.
SELECT CustomerName, COUNT(OrderID) AS TotalOrders, SUM(Sales) AS TotalSales
FROM [ProductSales].[dbo].[cleaned_inventory_sales]
GROUP BY CustomerName
HAVING COUNT(OrderID) > 5 AND SUM(Sales) < 500;