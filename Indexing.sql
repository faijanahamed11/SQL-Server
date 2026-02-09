SELECT *
INTO Sales.DBCustomers  -- Currently it's a heap structure and does not clustered, so sql do full scan in order to find anything from this table.
FROM Sales.Customers
SELECT *
FROM Sales.DBCustomers
-- Rule: Only ONE clustered index can be created per table
CREATE CLUSTERED INDEX idx_DBCustomers_CustomerID
ON Sales.DBCustomers (CustomerID)

CREATE CLUSTERED INDEX idx_DBCustomers_CustomerID
ON Sales.DBCustomers (FirstName)

DROP INDEX idx_DBCustomers_CustomerID ON Sales.DBCustomers

SELECT *
FROM Sales.DBCustomers
WHERE LastName = 'Brown'

-- Non Cluster Index
CREATE NONCLUSTERED INDEX idx_DBCustomers_LastName
ON Sales.DBCustomers (LastName)
-- Non Cluster Index(work same as above even without using keyword NONCLUSTERED)
CREATE INDEX idx_DBCustomers_FirstName
ON Sales.DBCustomers (FirstName)
DROP INDEX idx_DBCustomers_LastName ON Sales.DBCustomers

SELECT *
FROM Sales.DBCustomers
WHERE Country = 'USA' AND Score > 500
-- Rule: The columns of index order must match the order in your query. like first write country and 
-- then score, then search first country and then score like this [WHERE Country = 'USA' AND Score > 500]
-- Eg. A,B,C,D
-- Index will be used: [1. A]  [2. A,B]  [3. A,B,C]
-- Index will not be used: [1. B] [2. A,C] [3. A,B,D]
CREATE INDEX idx_Customers_CountryScore
ON Sales.DBCustomers(Country, Score)  -- Index is created for the above line 27 search.
-- Rule: Leftmost Prefix Rule: Index works only if your query filters start from the 
-- first column in the index and follow its order.
SELECT *
FROM Sales.DBCustomers
WHERE Country = 'USA' -- It is using Cluster
SELECT *
FROM Sales.DBCustomers
WHERE Score > 500  -- It is not using Cluster

-- ColumnStore
-- Create a Clustered Columnstore Index on Sales.DBCustomers
CREATE CLUSTERED COLUMNSTORE INDEX idx_DBCustomers_CS
ON Sales.DBCustomers;

-- Create a Non-Clustered Columnstore Index on the FirstName column
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_DBCustomers_CS_FirstName
ON Sales.DBCustomers (FirstName);

-- ====== UNIQUE INDEX ======
-- Attempt to create a Unique Index on the Category column in Sales.Products.
-- Note: This may fail if duplicate values exist.

CREATE UNIQUE INDEX idx_Products_Category
ON Sales.Products (Category);
  
-- Create a Unique Index on the Product column in Sales.Products
CREATE UNIQUE INDEX idx_Products_Product
ON Sales.Products (Product);
  
-- Test Insert: Attempt to insert a duplicate value (should fail if the constraint is enforced)
INSERT INTO Sales.Products (ProductID, Product)
VALUES (106, 'Caps');

-- Filtered Indexes
-- Test Query: Select Customers where Country is 'USA' 
SELECT *
FROM Sales.Customers
WHERE Country = 'USA';
  
-- Create a Non-Clustered Filtered Index on the Country column for rows where Country = 'USA'
CREATE NONCLUSTERED INDEX idx_Customers_Country
ON Sales.Customers (Country)
WHERE Country = 'USA';

/* ==============================================================================
   Index Monitoring
-------------------------------------------------------------------------------
     - List indexes and monitor their usage.
     - Report missing and duplicate indexes.
     - Retrieve and update statistics.
     - Check index fragmentation and perform index maintenance (reorganize/rebuild).
=================================================================================
*/

/* ==============================================================================
   Monitor Index Usage
============================================================================== */

-- List all indexes on a specific table
sp_helpindex 'Sales.DBCustomers'
SELECT * FROM sys.indexes
-- Monitor Index Usage
-- "sys" contains metadata about database tables, views, indexes etc.
SELECT 
	tbl.name AS TableName,
    idx.name AS IndexName,
    idx.type_desc AS IndexType,
    idx.is_primary_key AS IsPrimaryKey,
    idx.is_unique AS IsUnique,
    idx.is_disabled AS IsDisabled,
    s.user_seeks AS UserSeeks,
    s.user_scans AS UserScans,
    s.user_lookups AS UserLookups,
    s.user_updates AS UserUpdates,
    COALESCE(s.last_user_seek, s.last_user_scan) AS LastUpdate
FROM sys.indexes idx
JOIN sys.tables tbl
    ON idx.object_id = tbl.object_id
LEFT JOIN sys.dm_db_index_usage_stats s
    ON s.object_id = idx.object_id
    AND s.index_id = idx.index_id
ORDER BY tbl.name, idx.name;

-- IMPORTANT
SELECT 
    tbl.name AS TableName,
    idx.name AS IndexName,
    s.user_scans,
    s.last_user_scan
FROM sys.indexes idx
JOIN sys.tables tbl
ON idx.object_id = tbl.object_id
LEFT JOIN sys.dm_db_index_usage_stats s
ON s.object_id = idx.object_id
AND s.index_id = idx.index_id
ORDER BY tbl.name, idx.name;
SELECT * FROM Sales.Customers
/* ==============================================================================
   Monitor Missing Indexes
============================================================================== */

SELECT * 
FROM sys.dm_db_missing_index_details;

/* ==============================================================================
   Monitor Duplicate Indexes
============================================================================== */

SELECT  
	tbl.name AS TableName,
	col.name AS IndexColumn,
	idx.name AS IndexName,
	idx.type_desc AS IndexType,
	COUNT(*) OVER (PARTITION BY  tbl.name , col.name ) ColumnCount
FROM sys.indexes idx
JOIN sys.tables tbl ON idx.object_id = tbl.object_id
JOIN sys.index_columns ic ON idx.object_id = ic.object_id AND idx.index_id = ic.index_id
JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
ORDER BY ColumnCount DESC

/* ==============================================================================
   Update Statistics
============================================================================== */

SELECT 
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    s.name AS StatisticName,
    sp.last_updated AS LastUpdate,
    DATEDIFF(day, sp.last_updated, GETDATE()) AS LastUpdateDay,
    sp.rows AS 'Rows',
    sp.modification_counter AS ModificationsSinceLastUpdate
FROM sys.stats AS s
JOIN sys.tables AS t
    ON s.object_id = t.object_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
ORDER BY sp.modification_counter DESC;

-- Update statistics for a specific automatically created system statistic
UPDATE STATISTICS Sales.DBCustomers _WA_Sys_00000005_7E37BEF6;
GO

-- Update all statistics for the Sales.DBCustomers table
UPDATE STATISTICS Sales.DBCustomers;
GO

-- Update statistics for all tables in the database
EXEC sp_updatestats;
GO

/* ==============================================================================
   Fragementations
============================================================================== */

-- Retrieve index fragmentation statistics for the current database
SELECT 
    tbl.name AS TableName,
    idx.name AS IndexName,
    s.avg_fragmentation_in_percent,
    s.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS s
INNER JOIN sys.tables tbl 
    ON s.object_id = tbl.object_id
INNER JOIN sys.indexes AS idx 
    ON idx.object_id = s.object_id
    AND idx.index_id = s.index_id
ORDER BY s.avg_fragmentation_in_percent DESC;

-- Reorganize the index (lightweight defragmentation)
ALTER INDEX idx_Customers_CS_Country 
ON Sales.Customers REORGANIZE;
GO

-- Rebuild the index (full rebuild, more resource-intensive)
ALTER INDEX idx_Customers_Country 
ON Sales.Customers REBUILD;
GO

SELECT * FROM Sales.Orders
ORDER BY Sales
SELECT * FROM Sales.OrdersArchive
ORDER BY Sales

-- Change Execution plan of sql forcely to improve performance
SELECT
    o.Sales,
    c.country
FROM Sales.Orders o 
LEFT JOIN Sales.Customers c WITH(FORCESEEK)
ON o.CustomerID = c.CustomerID
-- OPTION(HASH JOIN)





