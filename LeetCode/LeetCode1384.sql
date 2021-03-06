-----------------------------------------------------------------------
--  LeetCode 1384. Total Sales Amount by Year
--
--  Hard
--
--  SQL Schema
--
--  Table: Product
--
--  +---------------+---------+
--  | Column Name   | Type    |
--  +---------------+---------+
--  | product_id    | int     |
--  | product_name  | varchar |
--  +---------------+---------+
--  product_id is the primary key for this table.
--  product_name is the name of the product.
--
--  Table: Sales
--
--  +---------------------+---------+
--  | Column Name         | Type    |
--  +---------------------+---------+
--  | product_id          | int     |
--  | period_start        | varchar |
--  | period_end          | date    |
--  | average_daily_sales | int     |
--  +---------------------+---------+
--  product_id is the primary key for this table. 
--  period_start and period_end indicates the start and end date for sales 
--- period, both dates are inclusive.
--  The average_daily_sales column holds the average daily sales amount of 
--  the items for the period.
--
--  Write an SQL query to report the Total sales amount of each item for each 
--  year, with corresponding product name, product_id, product_name and 
--  report_year.
--
--  Dates of the sales years are between 2018 to 2020. Return the result table 
--  ordered by product_id and report_year.
--
--  The query result format is in the following example:
--  Product table:
--  +------------+--------------+
--  | product_id | product_name |
--  +------------+--------------+
--  | 1          | LC Phone     |
--  | 2          | LC T-Shirt   |
--  | 3          | LC Keychain  |
--  +------------+--------------+
-- 
--  Sales table:
--  +------------+--------------+-------------+---------------------+
--  | product_id | period_start | period_end  | average_daily_sales |
--  +------------+--------------+-------------+---------------------+
--  | 1          | 2019-01-25   | 2019-02-28  | 100                 |
--  | 2          | 2018-12-01   | 2020-01-01  | 10                  |
--  | 3          | 2019-12-01   | 2020-01-31  | 1                   |
--  +------------+--------------+-------------+---------------------+
--
--  Result table:
--  +------------+--------------+-------------+--------------+
--  | product_id | product_name | report_year | total_amount |
--  +------------+--------------+-------------+--------------+
--  | 1          | LC Phone     |    2019     | 3500         |
--  | 2          | LC T-Shirt   |    2018     | 310          |
--  | 2          | LC T-Shirt   |    2019     | 3650         |
--  | 2          | LC T-Shirt   |    2020     | 10           |
--  | 3          | LC Keychain  |    2019     | 31           |
--  | 3          | LC Keychain  |    2020     | 31           |
--  +------------+--------------+-------------+--------------+
--  LC Phone was sold for the period of 2019-01-25 to 2019-02-28, and there 
--  are 35 days for this period. Total amount 35*100 = 3500. 
--  LC T-shirt was sold for the period of 2018-12-01 to 2020-01-01, and there 
--  are 31, 365, 1 days for years 2018, 2019 and 2020 respectively.
--  LC Keychain was sold for the period of 2019-12-01 to 2020-01-31, and 
--  there are 31, 31 days for years 2019 and 2020 respectively.
--
--------------------------------------------------------------------
WITH ThreeYear_CTE
(
    StartDate,
    EndDate
)
AS
(
    SELECT 
        CONVERT(DATE, '2018-01-01') AS StartDate,
        CONVERT(DATE, '2018-12-31') AS EndDate
    UNION ALL
    SELECT 
        CONVERT(DATE, '2019-01-01') AS StartDate,
        CONVERT(DATE, '2019-12-31') AS EndDate
    UNION ALL
    SELECT 
        CONVERT(DATE, '2020-01-01') AS StartDate,
        CONVERT(DATE, '2020-12-31') AS EndDate	
)

SELECT
    A.PRODUCT_ID,
    B.PRODUCT_NAME,
    CONVERT(NVARCHAR(10), A.report_year) AS REPORT_YEAR,
    A.Days * A.average_daily_sales AS TOTAL_AMOUNT
FROM
(
    SELECT
        product_id,
        YEAR(StartDate) AS report_year,
        DATEDIFF (DAY, StartDate, EndDate) + 1 AS Days,
        average_daily_sales
    FROM
    (
        SELECT 
            A.product_id,
            CASE WHEN A.period_start < B.StartDate THEN B.StartDate ELSE A.period_start END AS StartDate,
            CASE WHEN A.period_end < B.EndDate THEN A.period_end ELSE B.EndDate END AS EndDate,
            A.average_daily_sales
        FROM
           Sales AS A
        CROSS JOIN
           ThreeYear_CTE AS B
    ) AS T
    WHERE
        StartDate <= EndDate
) AS A
LEFT OUTER JOIN 
    Product AS B
ON 
    A.product_id = B.product_id	
ORDER BY 
    A.product_id,
    A.report_year
;
