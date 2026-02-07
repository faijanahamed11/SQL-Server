SELECT
*
FROM INFORMATION_SCHEMA.COLUMNS

-- Subquery
-- 1. Find the product that have a price higher than the average price of all products.
SELECT
*
FROM(
    SELECT 
    Product,
    Price,
    AVG(Price) OVER() AS AvgPrice
    FROM Sales.Products
)t   -- t means table, we can assign anyname, we provide alias in sql server for subquery
WHERE Price > AvgPrice;

-- 2. Rank customers based on their total amount of sales
SELECT
*,
RANK() OVER(ORDER BY TotalSales DESC ) AS Rank
FROM(
    SELECT 
    CustomerID,
    SUM(sales) TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
)t 

-- 3. Show the product IDs, product names, prices and the total number of orders
SELECT
ProductID,
Price,
Product,
Price,
-- Subquery
    (SELECT COUNT(*) FROM Sales.Orders) AS TotalOrders  -- Only the scalar subquery is allowed
FROM Sales.Products;

-- 4. Show all customer details and find the total orders of each customer
SELECT 
*
FROM Sales.Customers AS c
LEFT JOIN(
    SELECT
    CustomerID,
    COUNT(*) AS TotalOrders
    FROM Sales.Orders 
    GROUP BY CustomerID) AS o
ON c.CustomerID = o.CustomerID

-- 1. again solve using different methods

    SELECT 
    Product,
    Price
    FROM Sales.Products
    WHERE Price > (SELECT AVG(Price) FROM Sales.Products)  -- scalar subquery

-- Show the details of orders made by customer in Germany
SELECT *
FROM Sales.Orders
WHERE CustomerID IN
                (SELECT 
                CustomerID
                FROM Sales.Customers
                WHERE Country = 'Germany')

/* TASK 9:
   Find female employees whose salaries are greater than the salaries of any male employees.
*/
SELECT
    EmployeeID, 
    FirstName,
    Salary
FROM Sales.Employees
WHERE Gender = 'F'
  AND Salary > ANY (   -- Use 'ALL' in place of 'ANY' when all male employees asked.
      SELECT Salary
      FROM Sales.Employees
      WHERE Gender = 'M'
  );

-- Show all customer details and find the total orders of each customer
-- Main Query
-- Example of Non-Correlated Subquery
SELECT *,
(SELECT COUNT(*) FROM Sales.Orders o WHERE o.CustomerID = c.CustomerID) Total_Sales
FROM Sales.Customers c

-- Show the details of orders made by customer in Germany(Solved again using EXISTS)
-- Example of Correlates Subquery- where main and subquery are dependent
SELECT *
FROM Sales.Orders o
WHERE EXISTS(
            SELECT 1   -- can be '1', '2', '*' or any random number
            FROM Sales.Customers c
            WHERE Country = 'Germany'
            AND o.CustomerID = c.CustomerID)

-- CTE(Common Table Expression)
-- Step:1 Find the total sales per customer
WITH CTE_Total_Sales AS
(
SELECT
CustomerID,
SUM(Sales) TotalSales
FROM Sales.Orders
GROUP BY CustomerID
)
-- Step:2 Find the last order date for each customer
, CTE_Last_Order AS
(
SELECT
    CustomerID,
    MAX(OrderDate) AS LastOrder
FROM Sales.Orders
GROUP BY CustomerId
)
-- Step:3 Rank Customers based on Total Sales per Customer (Nested CTE)
, CTE_Customer_Rank AS
(
SELECT 
CustomerID,
TotalSales,
RANK() OVER (ORDER BY TotalSales DESC) AS CustomerRank
FROM CTE_Total_Sales
)
-- Step:4 Segment customers based on their total sales
, CTE_Customer_Segments AS
(
SELECT
CustomerID,
CASE WHEN TotalSales > 100 THEN 'High'
     WHEN TotalSales > 50 THEN 'Medium'
     ELSE 'Low'
END CustomerSegments
FROM CTE_Total_Sales
)
-- Main Query
SELECT
c.CustomerID,
c.FirstName,
cts.TotalSales,
clo.LastOrder,
ccr.CustomerRank,
ccs.CustomerSegments
FROM Sales.Customers c
LEFT JOIN CTE_Total_Sales cts
ON cts.CustomerID = c.CustomerID
LEFT JOIN CTE_Last_Order clo
ON clo.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Rank ccr
ON ccr.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Segments ccs
ON ccs.CustomerID = c.CustomerID

-- Generate a sequence of numbers from 1 to 20
WITH Series AS (
    -- Anchor Query
    SELECT
    1 AS MyNumber

    UNION ALL
    -- Recursive Query
    SELECT
    MyNumber + 1
    FROM Series
    WHERE MyNumber < 20
)
-- Main Query
SELECT * FROM Series
OPTION(MAXRECURSION 5000)

/* TASK 4:
   Build the employee hierarchy by displaying each employee's level within the organization.
   - Anchor Query: Select employees with no manager.
   - Recursive Query: Select subordinates and increment the level.
*/
WITH CTE_Emp_Hierarchy AS
(
    -- Anchor Query: Top-level employees (no manager)
    SELECT
        EmployeeID,
        FirstName,
        ManagerID,
        1 AS Level
    FROM Sales.Employees
    WHERE ManagerID IS NULL
    UNION ALL
    -- Recursive Query: Get subordinate employees and increment level
    SELECT
        e.EmployeeID,
        e.FirstName,
        e.ManagerID,
        Level + 1
    FROM Sales.Employees AS e
    INNER JOIN CTE_Emp_Hierarchy AS ceh
        ON e.ManagerID = ceh.EmployeeID
)
-- Main Query
SELECT *
FROM CTE_Emp_Hierarchy;

-- VIEWS
-- Find the running total of sales for each month
WITH CTE_Monthly_Summary AS(
    SELECT
    DATETRUNC(month, OrderDate) OrderMonth,
    SUM(Sales) TotalSales,
    COUNT(OrderID) TotalOrders,
    SUM(Quantity) TotalQuantities
    FROM Sales.Orders
    GROUP BY DATETRUNC(month, OrderDate)
)
SELECT
OrderMonth,
TotalSales,
SUM(TotalSales) OVER(ORDER BY OrderMonth) RunningTotal
FROM CTE_Monthly_Summary