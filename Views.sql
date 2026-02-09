--   SQL Views
/*   Table of Contents:
     1. Create, Drop, Modify View
     2. USE CASE - HIDE COMPLEXITY
     3. USE CASE - DATA SECURITY
*/
-- CREATE, DROP, MODIFY VIEW

/* TASK:
   Create a view that summarizes monthly sales by aggregating:
     - OrderMonth (truncated to month)
     - TotalSales, TotalOrders, and TotalQuantities.
*/

-- Drop View if it exists
IF OBJECT_ID('Sales.V_Monthly_Summary', 'V') IS NOT NULL
    DROP VIEW Sales.V_Monthly_Summary;
GO

-- Re-create the view with modified logic
CREATE VIEW Sales.V_Monthly_Summary AS
SELECT 
    DATETRUNC(month, OrderDate) AS OrderMonth,
    SUM(Sales) AS TotalSales,
    COUNT(OrderID) AS TotalOrders
FROM Sales.Orders
GROUP BY DATETRUNC(month, OrderDate);
GO
-- Query the View
SELECT * FROM Sales.V_Monthly_Summary;

-- Provide view that combines details from products, customers and employees
CREATE VIEW Sales.V_Order_Details AS(
    SELECT
    o.OrderID,
    o.orderDate,
    p.Product,
    p.Category,
    COALESCE(c.FirstName,'') + ' ' + COALESCE(c.LastName, '') CustomerName,
    c.Country CustomerCountry,
    COALESCE(e.FirstName,'') + ' ' + COALESCE(e.LastName, '') SalesName,
    e.Department,
    o.Sales,
    o.Quantity
    FROM Sales.Orders o
    LEFT JOIN Sales.Products p
    ON p.ProductID = o.ProductID
    LEFT JOIN Sales.Customers c
    ON c.CustomerID = o.CustomerID
    LEFT JOIN Sales.Employees e
    ON e.EmployeeID = o.SalesPersonID
);

SELECT * FROM Sales.V_Order_Details

/* TASK:
   Create a view for the EU Sales Team that combines details from all tables,
   but excludes data related to the USA.
*/
CREATE VIEW Sales.V_Order_Details_EU AS
(
    SELECT 
        o.OrderID,
        o.OrderDate,
        p.Product,
        p.Category,
        COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') AS CustomerName,
        c.Country AS CustomerCountry,
        COALESCE(e.FirstName, '') + ' ' + COALESCE(e.LastName, '') AS SalesName,
        e.Department,
        o.Sales,
        o.Quantity
    FROM Sales.Orders AS o
    LEFT JOIN Sales.Products AS p ON p.ProductID = o.ProductID
    LEFT JOIN Sales.Customers AS c ON c.CustomerID = o.CustomerID
    LEFT JOIN Sales.Employees AS e ON e.EmployeeID = o.SalesPersonID
    WHERE c.Country != 'USA'
);

SELECT * FROM Sales.V_Order_Details_EU

SELECT * FROM Sales.Customers