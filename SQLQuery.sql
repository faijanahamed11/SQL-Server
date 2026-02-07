/*
=============================================================
Database Creation and Table Setup Script
=============================================================
Script Purpose:
    This script creates a new SQL Server database named 'MyDatabase'. 
    If the database already exists, it is dropped to ensure a clean setup. 
    The script then creates three tables: 'customers', 'orders', and 'employees' 
    with their respective schemas, and populates them with sample data.
    
WARNING:
    Running this script will drop the entire 'MyDatabase' database if it exists, 
    permanently deleting all data within it. Proceed with caution and ensure you 
    have proper backups before executing this script.
*/

USE master;
GO

-- Drop and recreate the 'MyDatabase' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'MyDatabase')
BEGIN
    ALTER DATABASE MyDatabase SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MyDatabase;
END;
GO

-- Create the 'MyDatabase' database
CREATE DATABASE MyDatabase;
GO

USE MyDatabase;
GO

-- ======================================================
-- Table: customers
-- ======================================================
DROP TABLE IF EXISTS customers;
GO

CREATE TABLE customers (
    id INT NOT NULL,
    first_name  VARCHAR(50) NOT NULL,
    country     VARCHAR(50),
    score       INT,
    CONSTRAINT PK_customers PRIMARY KEY (id)
);
GO

-- Insert customers data
INSERT INTO customers (id, first_name, country, score) VALUES
    (1, 'Maria',     'Germany', 350),
    (2, ' John',     'USA',     900),
    (3, 'Georg',   'UK',      750),
    (4, 'Martin', 'Germany', 500),
    (5, 'Peter',   'USA',     0);
GO

-- ======================================================
-- Table: orders
-- ======================================================
DROP TABLE IF EXISTS orders;
GO

CREATE TABLE orders (
    order_id    INT NOT NULL,
    customer_id INT NOT NULL,
    order_date  DATE,
    sales    INT,
    CONSTRAINT PK_orders PRIMARY KEY (order_id)
);
GO

-- Insert orders data
INSERT INTO orders (order_id, customer_id, order_date, sales) VALUES
    (1001, 1, '2021-01-11', 35),
    (1002, 2, '2021-04-05', 15),
    (1003, 3, '2021-06-18', 20),
    (1004, 6, '2021-08-31', 10);
GO

USE MyDatabase;
-- Find the total score for each country
SELECT 
	country,
    sum(score) AS total_score
FROM customers
GROUP BY country;

SELECT 
	country,
    first_name,
    SUM(score)
FROM customers
GROUP BY country, first_name;

-- Find the total score and total number of customers for each country
SELECT
	country,
	sum(score) AS total_scores,
    count(id) AS total_customers
FROM customers
GROUP BY country;

/*
	Find the average score for each country considering
	only customers with the scores not equal to 0 and return 
    only those countries with an average score greater than 430
*/

SELECT 
	id,
	country,
    AVG(score) AS avg_score
FROM customers
WHERE score != 0
GROUP BY country, id
HAVING AVG(score) > 430;
SELECT * FROM customers

-- Return unique list of all countries
SELECT DISTINCT
	country
FROM customers;

-- Retrieve only 3 customers
SELECT TOP 3*
FROM customers;

-- Retrieve the top 3 customers with the highest scores
SELECT TOP 3*
FROM customers
ORDER BY score DESC;

SELECT * FROM customers;

-- Starting new table from here...
-- Get the two most recent orders
SELECT TOP 2* 
FROM orders
ORDER BY order_date DESC;

/* Create a new column called Persons
with columns: id, person_name, birth_date, and phone
*/

CREATE TABLE Persons(
	id INT NOT NULL,
    person_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    phone VARCHAR(15) NOT NULL,
    CONSTRAINT pk_persons PRIMARY KEY (id)
);
SELECT * FROM Persons;
-- Add a new column called email to the Persons table
ALTER TABLE Persons
ADD email VARCHAR(50) NOT NULL;
ALTER TABLE Persons
ADD email VARCHAR(50) NULL;

UPDATE Persons
SET phone = '+91-234-2345'
WHERE phone = 'Unknown'


ALTER TABLE Persons
ADD homecode INT DEFAULT 500;
ALTER TABLE Persons
DROP COLUMN homecode;

-- Remove the column phone from the Persons table
ALTER TABLE Persons
DROP COLUMN phone;

-- Delete the table Persons from the database
DROP TABLE Persons;

-- Insert data from 'customers' into 'persons'
INSERT INTO persons(id, person_name, birth_date, phone)
SELECT 
	id,
    first_name,
    NULL,
    'Unknown'
    FROM customers;
-- End

-- Change the score of customer4 to '0' and country to 'UK' 
UPDATE customers
SET score = 0,
	country = 'UK'
WHERE id = 4;

-- Update all custoemers with a NULL score by setting their score to 0
UPDATE customers 
SET score = 0
WHERE score IS NULL;

-- Delete all customers with an ID greater than 5
DELETE FROM customers
WHERE id > 5;

-- Delete all data from table persons
TRUNCATE TABLE persons;  -- TRUNCATE is faster
DELETE FROM Persons;     -- DELETE is slower

SELECT * FROM customers
where id > 5;
SELECT * FROM Persons;
DROP TABLE Persons;


-- COMPARISON OPERATORS
-- Retrieve all customers who are from Germany
SELECT * FROM customers 
WHERE country = 'Germany';

-- Retrieve all customers who are not from Germany
SELECT * FROM customers 
WHERE country != 'Germany';

-- Retrieve all customers with score greater than 500
SELECT * FROM customers 
WHERE score > 500;

-- Retrieve all customers who are from USA and score > 500
SELECT * FROM customers
WHERE country = 'USA' AND score > 500;

-- Retrieve all customers who are from USA or score > 500
SELECT * FROM customers
WHERE country = 'USA' OR score > 500;

SELECT * FROM customers
WHERE score BETWEEN 500 AND 900

-- Retrieve all customers with a score not less than 500
-- Uses of 'NOT' operator
SELECT * FROM customers
WHERE score >= 500;

SELECT * FROM customers 
WHERE NOT score < 500;   -- Both the query give same output, this is how NOT operator works.

-- Retrieve all customers from either Germany or USA
SELECT * FROM customers
WHERE country IN ('Germany', 'USA');

SELECT * FROM customers
WHERE country = 'Germany' or country = 'USA'
/* This is better than OR operator because if we have 100s of values to check then
this syntax is easier to write rather than WHERE country = "Germany" OR country = "USA"*/


-- Find all customers whose first name start with 'M'
SELECT * FROM customers
WHERE first_name LIKE 'M%';

-- Find all customers whose first name ends with 'n'
SELECT * FROM customers
WHERE first_name LIKE '%n';

-- Find all customers whose first name contains 'r'
SELECT * FROM customers
WHERE first_name LIKE '%r%';

-- Find all customers whose first name has 'r' in the 3rd position
SELECT * FROM customers
WHERE first_name LIKE '__r%';


-- JOINS
-- Retrieve all data from customers and orders in two different results
SELECT * FROM customers;
SELECT * FROM orders;
-- Get all customers along with their orders, but only for customers who have placed an order
-- INNER JOIN Question
SELECT 
	id, 
    first_name,
    order_id,
    sales
FROM customers
INNER JOIN orders
ON id = customer_id;

-- More correct way to avoid confusion for same column name in multiple tables.
SELECT 
	c.id, 
    c.first_name,
    o.order_id,
    o.sales
FROM customers AS c
INNER JOIN orders AS o
ON c.id = o.customer_id;

-- Get all customers along with their orders, including those without orders.
SELECT 
	c.id, 
    c.first_name,
    o.order_id,
    o.sales
FROM customers AS c
LEFT OUTER JOIN orders AS o
ON c.id = o.customer_id;

-- Get all customers along with their orders, including orders without matching customers.
SELECT 
	c.id, 
    c.first_name,
    o.order_id,
    o.sales
FROM customers AS c
RIGHT JOIN orders AS o
ON c.id = o.customer_id;
-- solved same question using left join
SELECT 
	c.id, 
    c.first_name,
    o.order_id,
    o.sales
FROM orders AS o
LEFT JOIN customers AS c
ON c.id = o.customer_id;

-- Get all customers and all orders, even if there's no match
SELECT 
	c.id, 
    c.first_name,
    o.order_id,
    o.sales
FROM customers AS c
FULL JOIN orders AS o   
ON c.id = o.customer_id

-- Get all the customers who haven't placed any order
-- LEFT ANTI JOIN
USE MyDatabase;
SELECT
	*
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.customer_id
WHERE o.customer_id IS NULL;  -- Lookup/compare ke liye right waale circle ke id ka use karte hai LEFT ANTI JOIN me.

-- Get all orders without matching customers(Using LEFT and RIGHT join)
SELECT *
	FROM customers
    RIGHT JOIN orders
    on id = customer_id
    WHERE id IS NULL;
    
SELECT *
	FROM orders
    LEFT JOIN customers
    on id = customer_id
    WHERE id IS NULL;
    
-- Find customers without orders and orders without customers
SELECT *
	FROM customers
    FULL JOIN orders 
    on id = customer_id
    WHERE id IS NULL 
    OR
    customer_id IS NULL
    
-- Get all customers along with their orders, but only for customers who have placed an order
SELECT *
	FROM customers
    LEFT JOIN orders
    on id = customer_id
    WHERE customer_id IS NOT NULL;
    
-- Generate all possible combinations of customers and orders
-- CROSS JOIN
SELECT *
FROM customers
CROSS JOIN orders;
SELECT * FROM customers
SELECT * FROM orders

-- MULTIPLE TABLE JOIN
-- Doing an example with 4 tables where other 3 connected to one master table using ER-Diagram

USE salesdb;

SELECT * 
FROM sales.orders;

SELECT
	o.orderID,
    o.Sales
FROM sales.Orders AS o;

SELECT * FROM Sales.Customers;

SELECT * FROM sales.Employees;

SELECT * FROM sales.Orders;

SELECT * FROM Sales.OrdersArchieve;

SELECT * FROM Sales.products;

/* Retrieve a list of all orders, along with the related customer,
product, and employee details. For each order, display: 
Order ID, Customer's name, Product name, Sales, Price,
Sales person's name. using ER-Diagram(Entity relationship)*/ 
SELECT 
	o.OrderID, 
    o.Sales,
    c.FirstName AS CustomerFirstName,
    c.LastName AS CustomerLastName,
    p.product AS ProductName,
    p.price,
    e.FirstName AS EmployeeFirstName,
    e.LastName AS EmployeeLastName
FROM sales.orders AS o
LEFT JOIN sales.customers AS c
ON o.customerID = c.customerID
LEFT JOIN sales.products AS p
ON o.productID = p.productID
LEFT JOIN sales.employees AS e
ON o.salesPersonId = e.EmployeeID;


-- SET OPERATORS
-- 1. Union Operator

SELECT
	LastName,
	CustomerId
FROM sales.customers
UNION
SELECT 
    LastName,
    EmployeeId
FROM sales.employees;

-- Combine the data from the employees and customers into one table.
SELECT 
	firstname,
    lastname
FROM sales.customers
UNION
SELECT 
	firstname,
    lastname
FROM sales.employees;

-- Combine the data from the employees and customers into one table including duplicates.
SELECT 
	firstname,
    lastname
FROM sales.customers
UNION ALL
SELECT 
	firstname,
    lastname
FROM sales.employees;

-- Find the employees who are not customers at the same time.
SELECT 
	firstname,
    lastname
FROM sales.customers
EXCEPT
SELECT 
	firstname,
    lastname
FROM sales.employees;

-- Find the data from the employees who are also customers.
SELECT 
	firstname,
    lastname
FROM sales.customers
INTERSECT
SELECT 
	firstname,
    lastname
FROM sales.employees;

CREATE TABLE persons(
	id INT PRIMARY KEY,
    person_name VARCHAR(50) NOT NULL
);

SELECT
DATENAME(YEAR, GETDATE());

-- SQL Functions
-- Row level functions
-- String Functions
SELECT 
    first_name,
    country,
CONCAT(first_name, '-', country) AS name_country
FROM customers;

-- TRIM Function
-- Find customers whose first_name contains leading trailing spaces
SELECT 
    first_name
FROM customers
WHERE first_name != TRIM(first_name);
-- Length Function, UPPER Case and lower case
SELECT 
    first_name,
    LEN(first_name) AS length,
    UPPER(TRIM(first_name)) AS upper_case,
    LOWER(first_name) AS lower_case
FROM customers;

-- Remove dashes(-) from a phone number
-- Replace Function
SELECT
'123-456-7890' AS phone,
REPLACE('123-456-7890', '-', '/') AS clean_phone;
-- Replace file extension from .txt to .csv
SELECT
'report.txt' AS file_name,
REPLACE('report.txt', '.txt', '.csv') AS new_file_name;

-- LEFT and RIGHT Function
SELECT 
    first_name,
    LEFT(first_name, 2) AS first_2_char,
    RIGHT(first_name, 2) AS last_2_char
FROM customers;

-- Retrieve a list of customers' first names after removing the first character
SELECT 
    first_name,
    SUBSTRING(TRIM(first_name), 2, LEN(first_name)) AS trimmed_name
FROM customers;

-- Nesting
SELECT
first_name, 
UPPER(LOWER(first_name)) AS nesting
FROM customers

-- Number Functions
-- Demonstrate rounding a number to different decimal places
SELECT 
    3.516 AS original_number,
    ROUND(3.516, 2) AS round_2,
    ROUND(3.516, 1) AS round_1,
    ROUND(3.516, 0) AS round_0;

-- ABS() - Absolute Value
-- Demonstrate absolute value function
SELECT 
    -10 AS original_number,
    ABS(-10) AS absolute_value_negative,
    ABS(10) AS absolute_value_positive;

/*Table of Contents:
     1. GETDATE | Date Values
     2. Date Part Extractions (DATETRUNC, DATENAME, DATEPART, YEAR, MONTH, DAY)
     3. DATETRUNC
     4. EOMONTH
     5. Date Parts
     6. FORMAT
     7. CONVERT
     8. CAST
     9. DATEADD / DATEDIFF
    10. ISDATE
*/
/* TASK 1:
   Display OrderID, CreationTime, a hard-coded date, and the current system date.
*/
SELECT
    OrderID,
    CreationTime,
    '2025-08-20' AS HardCoded,
    GETDATE() AS Today
FROM Sales.Orders;
SELECT GETDATE() AS Today
/* TASK 2:
   Extract various parts of CreationTime using DATETRUNC, DATENAME, DATEPART,
   YEAR, MONTH, and DAY.
*/
SELECT
    OrderID,
    CreationTime,
    -- DATETRUNC Examples
    DATETRUNC(year, CreationTime) AS Year_dt,
    DATETRUNC(day, CreationTime) AS Day_dt,
    DATETRUNC(minute, CreationTime) AS Minute_dt,
    -- DATENAME Examples
    DATENAME(month, CreationTime) AS Month_dn,
    DATENAME(weekday, CreationTime) AS Weekday_dn,
    DATENAME(day, CreationTime) AS Day_dn,
    DATENAME(year, CreationTime) AS Year_dn,
    -- DATEPART Examples
    DATEPART(year, CreationTime) AS Year_dp,
    DATEPART(month, CreationTime) AS Month_dp,
    DATEPART(day, CreationTime) AS Day_dp,
    DATEPART(hour, CreationTime) AS Hour_dp,
    DATEPART(quarter, CreationTime) AS Quarter_dp,
    DATEPART(week, CreationTime) AS Week_dp,
    YEAR(CreationTime) AS Year,
    MONTH(CreationTime) AS Month,
    DAY(CreationTime) AS Day
FROM Sales.Orders;

/* ==============================================================================
   DATETRUNC() DATA AGGREGATION
===============================================================================*/

/* TASK 3:
   Aggregate orders by month and then by year using DATETRUNC on CreationTime.
*/
SELECT
    DATETRUNC(month, CreationTime) AS Creation,
    COUNT(*) AS OrderCount
FROM Sales.Orders
GROUP BY DATETRUNC(month, CreationTime);

SELECT
    DATETRUNC(year, CreationTime) AS Creation,
    COUNT(*) AS OrderCount
FROM Sales.Orders
GROUP BY DATETRUNC(year, CreationTime);

/* ==============================================================================
   EOMONTH()
===============================================================================*/
SELECT 
GETDATE() today_date,
EOMONTH(GETDATE()) end_of_month,
DATENAME(MONTH, GETDATE()),
DATENAME(WEEKDAY, GETDATE()),
DATETRUNC(month, GETDATE()),
DATEPART(MONTH, GETDATE());

-- IMPORTANT
SELECT
    OrderID,
    CreationTime,
    CAST(DATETRUNC(MONTH, CreationTime) AS DATE) AS StartOfMonth -- CAST changes the date and time to only date.
FROM Sales.Orders;

/* TASK 4:
   Display OrderID, CreationTime, and the end-of-month date for CreationTime.
*/
SELECT
    OrderID,
    CreationTime,
    EOMONTH(CreationTime) AS EndOfMonth
FROM Sales.Orders;

/* ==============================================================================
   DATE PARTS | USE CASES
===============================================================================*/

/* TASK 5:
   How many orders were placed each year?
*/
SELECT 
    YEAR(OrderDate) AS OrderYear, 
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY YEAR(OrderDate);

/* TASK 6:
   How many orders were placed each month?
*/
SELECT 
    MONTH(OrderDate) AS OrderMonth, 
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY MONTH(OrderDate);

/* TASK 7:
   How many orders were placed each month (using friendly month names)?
*/
SELECT 
    DATENAME(month, OrderDate) AS OrderMonth, 
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate);

/* TASK 8:
   Show all orders that were placed during the month of February.
*/
SELECT
    *
FROM Sales.Orders
WHERE MONTH(OrderDate) = 2;

/* ==============================================================================
   FORMAT()
===============================================================================*/

/* TASK 9:
   Format CreationTime into various string representations.
*/
SELECT
    OrderID,
    CreationTime,
    FORMAT(CreationTime, 'MM-dd-yyyy') AS USA_Format,
    FORMAT(CreationTime, 'dd-MM-yyyy') AS EURO_Format,
    FORMAT(CreationTime, 'dd') AS dd,
    FORMAT(CreationTime, 'ddd') AS ddd,
    FORMAT(CreationTime, 'dddd') AS dddd,
    FORMAT(CreationTime, 'MM') AS MM,
    FORMAT(CreationTime, 'MMM') AS MMM,
    FORMAT(CreationTime, 'MMMM') AS MMMM
FROM Sales.Orders;

/* TASK 10:
   Display CreationTime using a custom format:
   Example: Day Wed Jan Q1 2025 12:34:56 PM
*/
SELECT
OrderID,
CreationTime,
'Day ' + FORMAT(CreationTime, 'ddd MMM') + ' Q' + DATENAME(quarter, CreationTime)
+ ' ' + FORMAT(CreationTime, 'yyyy hh:mm:ss tt')
FROM sales.Orders;

SELECT
    OrderID,
    CreationTime,
    'Day ' + FORMAT(CreationTime, 'ddd MMM') +
    ' Q' + DATENAME(quarter, CreationTime) + ' ' +
    FORMAT(CreationTime, 'yyyy hh:mm:ss tt') AS CustomFormat
FROM Sales.Orders;

/* TASK 11:
   How many orders were placed each year, formatted by month and year (e.g., "Jan 25")?
*/
SELECT
    FORMAT(CreationTime, 'MMM yy') AS OrderDate,
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY FORMAT(CreationTime, 'MMM yy');

/* ==============================================================================
   CONVERT()
===============================================================================*/

/* TASK 12:
   Demonstrate conversion using CONVERT.
*/
-- IMPORTANT
-- when we are using 'convert' then it loses the time and keeps only date and vice-versa.
SELECT
    CONVERT(INT, '123') AS [String to Int CONVERT],
    CONVERT(DATE, '2025-08-20') AS [String to Date CONVERT],
    CreationTime,
    CONVERT(DATE, CreationTime) AS [Datetime to Date CONVERT],
    CONVERT(VARCHAR, CreationTime, 32) AS [USA Std. Style:32],
    CONVERT(VARCHAR, CreationTime, 34) AS [EURO Std. Style:34]
FROM Sales.Orders;

/* ==============================================================================
   CAST()
===============================================================================*/

/* TASK 13:
   Convert data types using CAST.
*/
SELECT
    CAST('123' AS INT) AS [String to Int],
    CAST(123 AS VARCHAR) AS [Int to String],
    CAST('2025-08-20' AS DATE) AS [String to Date],
    CAST('2025-08-20' AS DATETIME2) AS [String to Datetime],
    CreationTime,
    CAST(CreationTime AS DATE) AS [Datetime to Date]
FROM Sales.Orders;

/* ==============================================================================
   DATEADD() / DATEDIFF()
===============================================================================*/

/* TASK 14:
   Perform date arithmetic on OrderDate.
*/
SELECT
    OrderID,
    OrderDate,
    DATEADD(day, -10, OrderDate) AS TenDaysBefore,
    DATEADD(month, 3, OrderDate) AS ThreeMonthsLater,
    DATEADD(year, 2, OrderDate) AS TwoYearsLater
FROM Sales.Orders;

/* TASK 15:
   Calculate the age of employees.
*/
SELECT
    EmployeeID,
    BirthDate,
    DATEDIFF(year, BirthDate, GETDATE()) AS Age
FROM Sales.Employees;

-- Shipping duration in days
SELECT
    OrderID,
    OrderDate,
    ShipDate,
    DATEDIFF(day, OrderDate, ShipDate) AS Day2Ship
FROM Sales.Orders;

/* TASK 16:
   Find the average shipping duration in days for each month.
   IMPORTANT
   [each month] tells that we have to aggregate by month
*/
SELECT
    MONTH(OrderDate) AS OrderMonth,
    AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AvgShip
FROM Sales.Orders
GROUP BY MONTH(OrderDate);
-- By month name
SELECT
    DATENAME(month, OrderDate) AS OrderMonth,
    AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AvgShip
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate);


/* TASK 17:
   Time Gap Analysis: Find the number of months and number of days between each order and the previous order.
   IMPORTANT
*/
SELECT
    OrderID,
    OrderDate AS CurrentOrderDate,
    LAG(OrderDate) OVER (ORDER BY OrderDate) AS PreviousOrderDate,
    DATEDIFF(month, LAG(OrderDate) OVER (ORDER BY OrderDate), OrderDate) AS NrOfMonths,
    DATEDIFF(day, LAG(OrderDate) OVER (ORDER BY OrderDate), OrderDate) AS NrOfDays
FROM Sales.Orders;

/* ==============================================================================
   ISDATE()
===============================================================================*/

/* TASK 18:
   Validate OrderDate using ISDATE and convert valid dates.
*/
SELECT
    OrderDate,
    ISDATE(OrderDate) AS IsValidDate,
    CASE 
        WHEN ISDATE(OrderDate) = 1 THEN CAST(OrderDate AS DATE)
        ELSE '9999-01-01'
    END AS NewOrderDate
FROM (
    SELECT '2025-08-20' AS OrderDate UNION
    SELECT '2025-08-21' UNION
    SELECT '2025-08-23' UNION
    SELECT '2025-08'
) AS t
-- WHERE ISDATE(OrderDate) = 0

/*  SQL NULL Functions
    Table of Contents:
     1. Handle NULL - Data Aggregation
     2. Handle NULL - Mathematical Operators
     3. Handle NULL - Sorting Data
     4. NULLIF - Division by Zero
     5. IS NULL - IS NOT NULL
     6. LEFT ANTI JOIN
     7. NULLs vs Empty String vs Blank Spaces
*/
/* TASK 1: 
   Find the average scores of the customers.
   Uses COALESCE to replace NULL Score with 0.
*/
SELECT
    CustomerID,
    Score,
    COALESCE(Score, 0) AS Score2,
    AVG(Score) OVER () AS AvgScores,
    AVG(COALESCE(Score, 0)) OVER () AS AvgScores2
FROM Sales.Customers;

--  HANDLE NULL - MATHEMATICAL OPERATORS
/* TASK 2: 
   Display the full name of customers in a single field by merging their
   first and last names, and add 10 bonus points to each customer's score.
*/
SELECT * FROM Sales.customers;
SELECT 
FirstName,
LastName,
FirstName + ' ' + COALESCE(LastName,'') AS FullName,
Score,
COALESCE(Score,0) + 10 AS NewScore
FROM Sales.customers;

/* TASK 3: 
   Sort the customers from lowest to highest scores,
   with NULL values appearing last.
*/
SELECT
    CustomerID,
    Score
FROM Sales.Customers
ORDER BY CASE WHEN Score IS NULL THEN 1 ELSE 0 END, Score;

-- NULLIF - DIVISION BY ZERO
/* TASK 4: 
   Find the sales price for each order by dividing sales by quantity.
   Uses NULLIF to avoid division by zero.
*/
SELECT
    OrderID,
    Sales,
    Quantity,
    Sales / NULLIF(Quantity, 0) AS Price
FROM Sales.Orders;

--  IS NULL - IS NOT NULL
/* TASK 5: 
   Identify the customers who have no scores 
*/
SELECT *
FROM Sales.Customers
WHERE Score IS NULL;

/* TASK 6: 
   Identify the customers who have scores 
*/
SELECT *
FROM Sales.Customers
WHERE Score IS NOT NULL;

-- LEFT ANTI JOIN
/* TASK 7: 
   List all details for customers who have not placed any orders 
*/
SELECT
    c.*,
    o.OrderID
FROM Sales.Customers AS c
LEFT JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

-- NULLs vs EMPTY STRING vs BLANK SPACES
/* TASK 8: 
   Demonstrate differences between NULL, empty strings, and blank spaces 
*/
WITH Orders AS (
    SELECT 1 AS Id, 'A' AS Category UNION
    SELECT 2, NULL UNION
    SELECT 3, '' UNION
    SELECT 4, '  '
)
SELECT 
    *,
    DATALENGTH(Category) AS CategoryLengthBeforeTrim,
    TRIM(Category) AS Policy1,
    DATALENGTH(TRIM(Category)) AS CategoryLengthAfterTrim,  -- Datalength also calculates backspaces
    NULLIF(Category, '') AS Policy2,
    COALESCE( NULLIF(Category, ''), 'unknown') AS Policy3
FROM Orders

--  SQL CASE Statement
/*   Table of Contents:
     1. Categorize Data
     2. Mapping
     3. Quick Form of Case Statement
     4. Handling Nulls
     5. Conditional Aggregation
*/
-- USE CASE: CATEGORIZE DATA
/* TASK 1: 
   Create a report showing total sales for each category:
	   - High: Sales over 50
	   - Medium: Sales between 20 and 50
	   - Low: Sales 20 or less
   The results are sorted from highest to lowest total sales.
*/
SELECT
    Category,
    SUM(Sales) AS TotalSales
FROM (
    SELECT
        OrderID,
        Sales,
        CASE
            WHEN Sales > 50 THEN 'High'
            WHEN Sales > 20 THEN 'Medium'
            ELSE 'Low'
        END AS Category
    FROM Sales.Orders
) AS t
GROUP BY Category
ORDER BY TotalSales DESC;
SELECT
    OrderID,
    Sales,
    CASE
        WHEN Sales > 50 THEN 'High'
        WHEN Sales > 20 THEN 'Medium'
        ELSE 'Low'
    END AS Category
FROM Sales.Orders


-- USE CASE: MAPPING and Quick Form Syntax
/* TASK 2: 
   Retrieve customer details with abbreviated country codes 
*/
SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    CASE 
        WHEN Country = 'Germany' THEN 'DE'
        WHEN Country = 'USA'     THEN 'US'
        ELSE 'n/a'
    END AS CountryAbbr,
    CASE Country
        WHEN 'Germany' THEN 'DE'
        WHEN 'USA'     THEN 'US'
        ELSE 'n/a'
    END AS CountryAbbr2
FROM Sales.Customers;

-- HANDLING NULLS
/* TASK 4: 
   Calculate the average score of customers, treating NULL as 0,
   and provide CustomerID and LastName details.
*/
SELECT
    CustomerID,
    LastName,
    Score,
    CASE
        WHEN Score IS NULL THEN 0
        ELSE Score
    END AS ScoreClean,
    AVG(
        CASE
            WHEN Score IS NULL THEN 0
            ELSE Score
        END
    ) OVER () AS AvgCustomerClean,
    AVG(Score) OVER () AS AvgCustomer
FROM Sales.Customers;
-- same question solved using COALESCE()
SELECT 
    Score,
    AVG(Score) OVER(),
    COALESCE(Score, 0),
    AVG(COALESCE(Score, 0)) OVER()
FROM Sales.Customers;

-- CONDITIONAL AGGREGATION
/* TASK 5: 
   Count how many orders each customer made with sales greater than 30 
*/
SELECT
    CustomerID,
        SUM(CASE
            WHEN Sales > 30 THEN 1
            ELSE 0
        END) TotalOrdersHighSales,
        COUNT(*) TotalOrders
FROM Sales.Orders
GROUP BY CustomerID;

-- SQL Aggregate Functions
/*1. Basic Aggregate Functions
        - COUNT
        - SUM
        - AVG
        - MAX
        - MIN
     2. Grouped Aggregations
        - GROUP BY
*/
-- Find the total number of customers
SELECT COUNT(*) AS total_customers
FROM customers

-- Find the total sales of all orders
SELECT SUM(sales) AS total_sales
FROM orders

-- Find the average sales of all orders
SELECT AVG(sales) AS avg_sales
FROM orders

-- Find the highest score among customers
SELECT MAX(score) AS max_score
FROM customers

-- Find the lowest score among customers
SELECT MIN(score) AS min_score
FROM customers

-- GROUPED AGGREGATIONS - GROUP BY
-- Find the number of orders, total sales, average sales, highest sales, and lowest sales per customer
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    AVG(sales) AS avg_sales,
    MAX(sales) AS highest_sales,
    MIN(sales) AS lowest_sales
FROM orders
GROUP BY customer_id

-- SQL Window Functions
/*Table of Contents:
     1. SQL Window Basics
     2. SQL Window OVER Clause
     3. SQL Window PARTITION Clause
     4. SQL Window ORDER Clause
     5. SQL Window FRAME Clause
     6. SQL Window Rules
     7. SQL Window with GROUP BY
*/
-- SQL WINDOW FUNCTIONS | BASICS
/* TASK 1: 
   Calculate the Total Sales Across All Orders 
*/
SELECT
    SUM(Sales) AS Total_Sales
FROM Sales.Orders;

/* TASK 2: 
   Calculate the Total Sales for Each Product 
*/
SELECT 
    ProductID,
    SUM(Sales) AS Total_Sales
FROM Sales.Orders
GROUP BY ProductID;

-- SQL WINDOW FUNCTIONS | OVER CLAUSE
/* TASK 3: 
   Find the total sales across all orders,
   additionally providing details such as OrderID and OrderDate 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    Sales,
    SUM(Sales) OVER () AS Total_Sales
FROM Sales.Orders;

-- SQL WINDOW FUNCTIONS | PARTITION CLAUSE
/* TASK 4: 
   Find the total sales across all orders and for each product,
   additionally providing details such as OrderID and OrderDate 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    Sales,
    SUM(Sales) OVER () AS Total_Sales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS Sales_By_Product
FROM Sales.Orders;

/* TASK 5: 
   Find the total sales across all orders, for each product,
   and for each combination of product and order status,
   additionally providing details such as OrderID and OrderDate 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER () AS Total_Sales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS Sales_By_Product,
    SUM(Sales) OVER (PARTITION BY ProductID, OrderStatus) AS Sales_By_Product_Status
FROM Sales.Orders;

/* TASK 6: 
   Rank each order by Sales from highest to lowest */
SELECT
    OrderId,
    OrderDate,
    Sales,
    RANK() OVER(ORDER BY Sales DESC) RankSales
FROM Sales.Orders;

-- SQL WINDOW FUNCTIONS | FRAME CLAUSE

/* TASK 7: 
   Calculate Total Sales by Order Status for current and next two orders 
*/
SELECT
    OrderId,
    OrderDate,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate
        ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS TotalSales
FROM Sales.Orders

/* TASK 8: 
   Calculate Total Sales by Order Status for current and previous two orders 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Total_Sales
FROM Sales.Orders;

/* TASK 9: 
   Calculate Total Sales by Order Status from previous two orders only 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate 
        ROWS 2 PRECEDING
    ) AS Total_Sales
FROM Sales.Orders;

/* TASK 10: 
   Calculate cumulative Total Sales by Order Status up to the current order 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Total_Sales
FROM Sales.Orders;

/* TASK 11: 
   Calculate cumulative Total Sales by Order Status from the start to the current row 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate 
        ROWS UNBOUNDED PRECEDING
    ) AS Total_Sales
FROM Sales.Orders;

-- SQL WINDOW FUNCTIONS | RULES
/* RULE 1: 
   Window functions can only be used in SELECT or ORDER BY clauses 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (PARTITION BY OrderStatus) AS Total_Sales
FROM Sales.Orders
WHERE SUM(Sales) OVER (PARTITION BY OrderStatus) > 100;  -- Invalid: window function in WHERE clause

/* RULE 2: 
   Window functions cannot be nested 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(SUM(Sales) OVER (PARTITION BY OrderStatus)) OVER (PARTITION BY OrderStatus) AS Total_Sales  -- Invalid nesting
FROM Sales.Orders;

-- SQL WINDOW FUNCTIONS | GROUP BY
/* TASK 12: 
   Rank customers by their total sales 
*/
SELECT
    CustomerID,
    SUM(Sales) AS Total_Sales,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS Rank_Customers
FROM Sales.Orders
GROUP BY CustomerID;

-- Window Aggregate Functions
-- Task 1: Find the total number of orders
SELECT 
    COUNT(*) AS Total_Orders
FROM 
Sales.Orders

-- Task 2: Find the total number of orders
-- Additionally provide details such as order id, order date
-- Find total orders for each customer
SELECT 
    OrderId,
    OrderDate,
    CustomerId,
    COUNT(*) OVER() TotalOrders,
    COUNT(*) OVER(PARTITION BY CustomerId) OrdersByCustomers
FROM 
Sales.Orders

-- Find the total number of customers
-- Additionally provide all details of customers
SELECT 
*,
COUNT(*) OVER() TotalCustomers,
COUNT(Score) OVER() TotalScore
FROM Sales.Customers

-- Check whether the table 'orders' contains any duplicate rows
SELECT 
*
FROM (
    SELECT 
        OrderId,
        COUNT(*) OVER(PARTITION BY OrderID) CheckPk
    FROM Sales.OrdersArchive
)t WHERE CheckPk > 1

-- Sum Function
-- Find the total sales for each product
SELECT
    ProductId,
    SUM(Sales) OVER() TotalSales,
    SUM(Sales) OVER(PARTITION BY ProductId)
FROM Sales.Orders;

-- Find the percentage contribution of each product's sales to the total sales
SELECT
OrderId,
ProductId,
Sales,
SUM(Sales) OVER() TotalSales,
ROUND(CAST(Sales AS float)/SUM(Sales) OVER() * 100, 2)
FROM Sales.Orders;

-- Find the average sales for each product
SELECT
ProductID,
AVG(COALESCE(Sales, 0)) OVER(PARTITION BY ProductId)
FROM Sales.Orders;

SELECT
*
FROM(
    SELECT
    ProductID,
    Sales,
    AVG(Sales) OVER() AS AvgSales
    FROM Sales.Orders
)t WHERE Sales > AvgSales

-- MIN and MAX Functions
-- Returns the minimum and maximum value within the window
SELECT 
ProductID,
Sales,
MIN(COALESCE(Sales, 0)) OVER(PARTITION BY ProductID) AS Min_Sales,
MAX(Sales) OVER(PARTITION BY ProductID) AS Max_Sales
FROM 
Sales.Orders

-- Show the employees who have the highest salaries
SELECT 
*
FROM (
    SELECT
    *,
    MAX(Salary) OVER() AS highest_salary
    FROM Sales.Employees
)t WHERE Salary = highest_salary

-- RUNNING TOTAL and ROLLING TOTAL
-- Calculate moving average of sales for each product over time, including only the next order
SELECT
    OrderId,
    ProductID,
    OrderDate,
    Sales,
    AVG(Sales) OVER(PARTITION BY ProductID) AS AvgByProduct,
    AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate) AS RunningAvg,  -- RUNNING TOTAL
    AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS RollingAvg -- ROLLING TOTAL
FROM Sales.Orders

-- Ranking Windows Functions
/* TASK 1:
   Rank Orders Based on Sales from Highest to Lowest
*/
SELECT
    OrderID,
    ProductID,
    Sales,
    ROW_NUMBER() OVER (ORDER BY Sales DESC) AS SalesRank_Row,
    RANK() OVER (ORDER BY Sales DESC) AS SalesRank_Rank,
    DENSE_RANK() OVER (ORDER BY Sales DESC) AS SalesRank_Dense
FROM Sales.Orders;

-- Find the top highest sales for each product
SELECT
*
FROM(
    SELECT
    OrderID,
    ProductID,
    Sales,
    ROW_NUMBER() OVER(PARTITION BY ProductID ORDER BY Sales DESC) RankingByProduct
FROM Sales.Orders
)t WHERE RankingByProduct = 1

-- Find the lowest 2 customers based on their sale
SELECT *
FROM(
SELECT 
    CustomerID,
    SUM(Sales) TotalSales,
    ROW_NUMBER() OVER(ORDER BY SUM(Sales)) Rank_Customers
FROM Sales.Orders
GROUP BY CustomerID
)t WHERE Rank_Customers <=2

-- Assign unique IDs to the rows of the 'OrdersArchieve' Table
-- This functionality used in Pagination in real-world Projects
SELECT 
ROW_NUMBER() OVER(ORDER BY OrderId, OrderDate) UniqueID,
* 
FROM Sales.OrdersArchive

/* TASK 5:
   Use Case | Identify Duplicates:
   Identify Duplicate Rows in 'Order Archive' and return a clean result without any duplicates
*/
SELECT *
FROM(
SELECT
ROW_NUMBER() OVER(PARTITION BY OrderId ORDER BY CreationTime DESC) AS row_no,
*
FROM Sales.OrdersArchive
)t WHERE row_no = 1

/* TASK 6:
   Divide Orders into Groups Based on Sales
*/
SELECT 
    OrderID,
    Sales,
    NTILE(1) OVER (ORDER BY Sales) AS OneBucket,
    NTILE(2) OVER (ORDER BY Sales) AS TwoBuckets,
    NTILE(3) OVER (ORDER BY Sales) AS ThreeBuckets,
    NTILE(4) OVER (ORDER BY Sales) AS FourBuckets,
    NTILE(2) OVER (PARTITION BY ProductID ORDER BY Sales) AS TwoBucketByProducts
FROM Sales.Orders;

-- Segment all orders into 3 categories: high, medium and low sales.
SELECT
*,
CASE WHEN Buckets = 1 THEN 'High'
     WHEN Buckets = 2 THEN 'Medium'
     WHEN Buckets = 3 THEN 'Low'
END AS SalesSegmentations
FROM(
SELECT
    OrderID,
    Sales,
    NTILE(3) OVER(ORDER BY Sales DESC) Buckets
FROM Sales.Orders
)t

/* TASK 8:
   Divide Orders into Groups for Processing
*/
SELECT 
    NTILE(5) OVER (ORDER BY OrderID) AS Buckets,
    *
FROM Sales.Orders;

-- Fing the products that fall within the highest 40% of prices
SELECT *,
CONCAT(DistRank * 100, '%') AS DistRankPerc
FROM(
SELECT 
    Product,
    Price,
    CUME_DIST() OVER(ORDER BY Price DESC) DistRank
FROM Sales.Products
)t WHERE DistRank <=0.4

-- Analyze the month-over-month performance by finding the percentage change
-- in sales between the current and previous months
SELECT
*,
ROUND(CAST((CurrentMonthSales - PreviousMonthSales) AS FLOAT)/PreviousMonthSales * 100,2) AS MoM_Change
FROM(
SELECT 
    MONTH(OrderDate) AS OrderMonth,
    -- DATENAME(MONTH, OrderDate) OrderMonth,
    SUM(Sales) AS CurrentMonthSales,
    LAG(SUM(Sales)) OVER(ORDER BY MONTH(OrderDate)) AS PreviousMonthSales
FROM Sales.Orders
GROUP BY MONTH(OrderDate)
)t 

-- In order to analyze customer loyalty,
-- rank customers based on the average days between their orders
SELECT
CustomerID,
AVG(DaysUntilNextOrder) AvgDays,
COALESCE(AVG(DaysUntilNextOrder),99999),
RANK() OVER(ORDER BY COALESCE(AVG(DaysUntilNextOrder),99999)) AS RankAvg
FROM(
    SELECT 
        OrderID,
        CustomerID,
        OrderDate AS CurrentOrder,
        LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrder,
        DATEDIFF(day, OrderDate, LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate)) AS DaysUntilNextOrder
    FROM Sales.Orders
)t GROUP BY CustomerID

-- Find the lowest and highest sales for each product
-- Find the difference between the current Sales and the lowest Sales for each Product.
SELECT 
    OrderID,
    ProductID,
    Sales,
    FIRST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales) AS LowestSales,
    LAST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales
    ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS HighestSales,
    FIRST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales DESC) AS HighestSales2,
    MIN(Sales) OVER(PARTITION BY ProductID) AS LowestSales2,
    MAX(Sales) OVER(PARTITION BY ProductID) AS HighestSales3,
    Sales - FIRST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales) AS SalesDifference
FROM Sales.Orders