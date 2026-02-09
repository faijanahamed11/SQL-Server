-- CTAS(Create Table As Select)
-- Using of TSQL to execute everything in one execution like 
-- to avoid error if table already exist using (GO) and if is not null statement.
-- CTAS are very faster than Views, but views always gives fresh data from warehouse.
-- Simply CTAS means creating copy of table and giving it a new name.
IF OBJECT_ID('Sales.MonthlyOrders', 'U') IS NOT NULL
    DROP TABLE Sales.MonthlyOrders;
GO
SELECT 
    DATENAME(month, orderDate) OrderMonth,
    COUNT(OrderID) TotalOrders
    INTO Sales.MonthlyOrders
FROM Sales.Orders
GROUP BY DATENAME(month, orderDate)

SELECT * FROM Sales.MonthlyOrders
DROP TABLE Sales.MonthlyOrders


-- Temporary Tables
SELECT *
INTO #Orders
FROM Sales.Orders
SELECT *
FROM #Orders