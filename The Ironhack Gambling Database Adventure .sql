USE `The Ironhack Gambling Database`;

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'The Ironhack Gambling Database';

-- Question 01
SELECT Title, FirstName, LastName, DateOfBirth
FROM customer;

-- Question 02
SELECT CustomerGroup, COUNT(*) AS NumberOfCustomers
FROM customer
GROUP BY CustomerGroup;

-- How to Handle This in Excel
-- Use Pivot Tables
-- Select your data range.
-- Insert a Pivot Table.
-- Set CustomerGroup as the rows and use Count on the CustomerGroup to show the number of customers in each group.


-- Question 03

SELECT c.*, a.CurrencyCode
FROM customer c
JOIN account a ON c.CustId = a.CustId;


-- In Excel,VLOOKUP function or Power Query to merge data from two tables
-- Using VLOOKUP:
-- Ensure both tables are sorted based on CustId.
-- Use the formula in a new column in the customer table:
-- AccountTableRange is the range where the account data is located.
-- ColumnNumberForCurrencyCode is the column number in AccountTableRange that contains CurrencyCode.


-- Q 4
SELECT 
    b.BetDate,
    p.product AS ProductFamily,
    SUM(CAST(b.Bet_Amt AS DECIMAL)) AS TotalBetAmount
FROM 
    betting b
JOIN 
    product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
GROUP BY 
    b.BetDate, p.product
ORDER BY 
    b.BetDate, ProductFamily;
    
-- How to Handle This in Excel
-- In Excel, handling a larger dataset typically involves a Pivot Table. Here’s how you can create a similar report:

-- Prepare Data:

-- Ensure you have a consolidated table where both betting information and product details are combined, possibly using a VLOOKUP or Power Query.
-- Create a Pivot Table:

-- Select the entire data table.
-- Insert a Pivot Table.
-- Use BetDate as the Rows and ProductFamily as a second-level row or column field.
-- Use SUM on Bet_Amt as the values to aggregate by product and date.
-- Customize the Pivot Table:

-- Drill down or filter by specific dates or products as needed.

-- Q 5 

SELECT 
    b.BetDate,
    p.product AS ProductFamily,
    SUM(CAST(b.Bet_Amt AS DECIMAL)) AS TotalBetAmount
FROM 
    betting b
JOIN 
    product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE 
    b.BetDate >= '2023-11-01'  -- Adjust the date format based on your SQL environment
    AND b.Product = 'Sportsbook'  -- Filter for Sportsbook transactions
GROUP BY 
    b.BetDate, p.product
ORDER BY 
    b.BetDate, ProductFamily;


-- Q 6
SELECT 
    a.CurrencyCode,
    c.CustomerGroup,
    p.product AS Product,
    SUM(CAST(b.Bet_Amt AS DECIMAL)) AS TotalBetAmount
FROM 
    betting b
JOIN
    account a ON b.AccountNo = a.AccountNo
JOIN 
    customer c ON a.CustId = c.CustId
JOIN 
    product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE 
    b.BetDate > '2023-12-01'  -- Ensure the date format matches your SQL environment
GROUP BY 
    a.CurrencyCode, c.CustomerGroup, p.product
ORDER BY 
    a.CurrencyCode, c.CustomerGroup, p.product;
    
    
    

-- Q 7
SELECT 
    c.Title,
    c.FirstName,
    c.LastName,
    COALESCE(SUM(CAST(b.Bet_Amt AS DECIMAL)), 0) AS TotalBetAmountForNovember
FROM 
    customer c
LEFT JOIN 
    account a ON c.CustId = a.CustId
LEFT JOIN 
    betting b ON a.AccountNo = b.AccountNo AND b.BetDate >= '2023-11-01' AND b.BetDate < '2023-12-01'
GROUP BY 
    c.Title, c.FirstName, c.LastName
ORDER BY 
    c.LastName, c.FirstName
LIMIT 0, 1000;


-- Q 8
SELECT 
    b.AccountNo,
    COUNT(DISTINCT b.Product) AS NumberOfProducts
FROM 
    betting b
GROUP BY 
    b.AccountNo;
    
    SELECT 
    b.AccountNo
FROM 
    betting b
WHERE 
    b.Product IN ('Sportsbook', 'Vegas')
GROUP BY 
    b.AccountNo
HAVING 
    COUNT(DISTINCT b.Product) = 2;

-- Q 9
SELECT 
    b.AccountNo,
    SUM(CASE WHEN b.Product = 'Sportsbook' THEN CAST(b.Bet_Amt AS DECIMAL) ELSE 0 END) AS TotalSportsbookBet,
    SUM(CASE WHEN b.Product != 'Sportsbook' THEN CAST(b.Bet_Amt AS DECIMAL) ELSE 0 END) AS TotalOtherProductBet
FROM 
    betting b
WHERE 
    b.Bet_Amt > 0
GROUP BY 
    b.AccountNo
HAVING 
    COUNT(DISTINCT b.Product) = 1
    AND MAX(CASE WHEN b.Product = 'Sportsbook' THEN 1 ELSE 0 END) = 1;
    
-- Q 10

WITH PlayerProductTotals AS (
    SELECT 
        b.AccountNo, 
        b.Product, 
        SUM(CAST(b.Bet_Amt AS DECIMAL)) AS TotalBetAmount
    FROM 
        betting b
    GROUP BY 
        b.AccountNo, b.Product
), RankedProducts AS (
    SELECT 
        AccountNo,
        Product,
        TotalBetAmount,
        ROW_NUMBER() OVER (PARTITION BY AccountNo ORDER BY TotalBetAmount DESC) AS `Rank`
    FROM 
        PlayerProductTotals
)
SELECT 
    AccountNo,
    Product AS FavoriteProduct
FROM 
    RankedProducts
WHERE 
    `Rank` = 1;


-- q 11

 SELECT 
    s.student_name,
    s.GPA
FROM 
    student s
ORDER BY 
    CAST(s.GPA AS DECIMAL) DESC
LIMIT 5;

-- q 12
SELECT 
    sc.school_name,
    COUNT(st.student_id) AS NumberOfStudents
FROM 
    school sc
LEFT JOIN 
    student st ON sc.school_id = st.school_id
GROUP BY 
    sc.school_name
ORDER BY 
    sc.school_name;


-- q 13 

WITH RankedStudents AS (
    SELECT 
        st.student_name,
        st.GPA,
        sc.school_name,
        ROW_NUMBER() OVER (PARTITION BY sc.school_id ORDER BY CAST(st.GPA AS DECIMAL) DESC) AS RowNum
    FROM 
        student st
    JOIN 
        school sc ON st.school_id = sc.school_id
)
SELECT 
    student_name,
    GPA,
    school_name
FROM 
    RankedStudents
WHERE 
    RowNum <= 3
ORDER BY 
    school_name, GPA DESC;
