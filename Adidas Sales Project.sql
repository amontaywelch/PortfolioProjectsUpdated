CREATE DATABASE Adidas;
USE adidas;

/* Data Analysis on Adidas sales in the United States */


/* Insights analyzed:
1.) Distinct retailers, cities, states
2.) Count of retailers, cities, and states present in the data
3.) Total Amount of units sold(overall, by year and month)
4.) Revenue for Adidas(overall, by year and month)
5.) Retailers with highest amount of orders
6.) Total Revenue for each retailer(overall, by year and month)
7.) Percent of total sales for each retailer(overall, by year)
8.) Top/bottom revenue numbers based on city, state, region
9.) Profit
10.) Most popular categories 
11.) Most popular method of ordering */

SELECT 
    *
FROM
    adidas_data;

/* Distinct retailers, cities, and states in the data */
SELECT DISTINCT
    retailer
FROM
    adidas_data;

SELECT DISTINCT
    state, city
FROM
    adidas_data;


/* Number of distinct states and cities */
SELECT 
    COUNT(DISTINCT state)
FROM
    adidas_data;

SELECT 
    COUNT(DISTINCT city)
FROM
    adidas_data;


/* Number of distinct products sold */
SELECT 
    COUNT(DISTINCT product)
FROM
    adidas_data;


/* Total amount of units sold */
SELECT 
    SUM(units_sold) AS total_products_sold
FROM
    adidas_data;


/* Number of products sold in 2020 and 2021 */
SELECT 
    sales_year, SUM(units_sold) AS num_products_sold
FROM
    (SELECT 
        Units_Sold, SUBSTRING(invoice_date, 1, 4) AS sales_year
    FROM
        adidas_data) AS subquery
WHERE
    sales_year IN ('2020' , '2021')
GROUP BY sales_year;


/* Number of products sold in 2020 and 2021, listed by month */
WITH month_sales_2020 AS (SELECT
    YEAR(invoice_date) AS sales_year,
    MONTH(invoice_date) AS sales_month,
    COUNT(units_sold) AS products_sold
FROM
    adidas_data
WHERE YEAR(Invoice_Date) = 2020
GROUP BY
    sales_year, sales_month
ORDER BY
    sales_year, sales_month
)
SELECT *
FROM month_sales_2020
JOIN 
  (SELECT
    YEAR(invoice_date) AS sales_year,
    MONTH(invoice_date) AS sales_month,
    COUNT(units_sold) AS products_sold
FROM
    adidas_data
WHERE YEAR(Invoice_Date) = 2021
GROUP BY
    sales_year, sales_month
ORDER BY
    sales_year, sales_month) AS month_sales_2021
ON month_sales_2020.sales_month = month_sales_2021.sales_month;



/* The amount increase of units sold from 2020 to 2021 as a percentage */
WITH SalesByYear AS (
    SELECT
        sales_year,
        SUM(units_sold) AS num_products_sold
    FROM (
        SELECT
            units_sold,
            SUBSTRING(invoice_date, 1, 4) AS sales_year
        FROM
            adidas_data
    ) AS subquery
    WHERE sales_year IN ('2020', '2021')
    GROUP BY sales_year
)
SELECT
    sales_year,
    num_products_sold,
    LAG(num_products_sold) OVER (ORDER BY sales_year) AS prev_year_sold,
    ROUND(((num_products_sold - LAG(num_products_sold) OVER (ORDER BY sales_year)) / LAG(num_products_sold) OVER (ORDER BY sales_year)) * 100, 2) AS percentage_jump
FROM
    SalesByYear;
    
    
    /* Total revenue for Adidas*/
SELECT 
    SUM(total_sales) AS total_revenue
FROM
    adidas_data;
    


/* Total revenue listed for 2020 and 2021 */
SELECT 
    sales_year, SUM(total_sales) AS overall_revenue
FROM
    (SELECT 
        Total_Sales, SUBSTRING(invoice_date, 1, 4) AS sales_year
    FROM
        adidas_data) AS subquery
WHERE
    sales_year IN ('2020' , '2021')
GROUP BY sales_year;


/* Total monthly revenue per month */
WITH month_revenue_2020 AS (SELECT
    YEAR(invoice_date) AS sales_year,
    MONTH(invoice_date) AS sales_month,
    SUM(total_sales) AS monthly_revenue
FROM
    adidas_data
WHERE YEAR(Invoice_Date) = 2020
GROUP BY
    sales_year, sales_month
ORDER BY
    sales_year, sales_month
)
SELECT *
FROM month_revenue_2020
JOIN 
  (SELECT
    YEAR(invoice_date) AS sales_year,
    MONTH(invoice_date) AS sales_month,
    SUM(total_sales) AS monthly_revenue
FROM
    adidas_data
WHERE YEAR(Invoice_Date) = 2021
GROUP BY
    sales_year, sales_month
ORDER BY
    sales_year, sales_month) AS month_revenue_2021
ON month_revenue_2020.sales_month = month_revenue_2021.sales_month;


/* Percent increase from 2020 to 2021 for total revenue */
WITH SalesByYear AS (
    SELECT
        sales_year,
        SUM(total_sales) AS yearly_revenue
    FROM (
        SELECT
            total_sales,
            SUBSTRING(invoice_date, 1, 4) AS sales_year
        FROM
            adidas_data
    ) AS subquery
    WHERE sales_year IN ('2020', '2021')
    GROUP BY sales_year
)
SELECT
    sales_year,
    yearly_revenue,
    LAG(yearly_revenue) OVER (ORDER BY sales_year) AS prev_year_sold,
    ROUND(((yearly_revenue - LAG(yearly_revenue) OVER (ORDER BY sales_year)) / LAG(yearly_revenue) OVER (ORDER BY sales_year)) * 100, 2) AS percentage_jump
FROM
    SalesByYear;


/* Total profit */
SELECT 
    SUM(Operating_Profit) AS total_profit
FROM
    adidas_data;



/* Total profit by year and month, looking at months where numbers increase or decrease significantly */
WITH profits_2020 AS (SELECT
    YEAR(invoice_date) AS sales_year,
    MONTH(invoice_date) AS sales_month,
    ROUND(SUM(Operating_Profit), 2) AS monthly_profit
FROM
    adidas_data
WHERE
    YEAR(invoice_date) = 2020
GROUP BY
    sales_year, sales_month
ORDER BY
    sales_year, sales_month
)
SELECT *
FROM profits_2020
JOIN
  (SELECT
    YEAR(invoice_date) AS sales_year,
    MONTH(invoice_date) AS sales_month,
    ROUND(SUM(Operating_Profit), 2) AS monthly_profit
FROM
    adidas_data
WHERE
    YEAR(invoice_date) = 2021
GROUP BY
    sales_year, sales_month
ORDER BY
    sales_year, sales_month) AS profits_2021
ON profits_2020.sales_month = profits_2021.sales_month;


/* Products and how many orders fall into their respective categories */
SELECT 
    product, COUNT(product) AS product_count
FROM
    adidas_data
GROUP BY product
ORDER BY product_count DESC;



/* Products ranked by total sales, by month */
     WITH ProductRanking AS (
    SELECT
        product,
        YEAR(invoice_date) AS sales_year,
        MONTH(invoice_date) AS sales_month,
        SUM(total_sales) AS total__revenue,
        DENSE_RANK() OVER (ORDER BY SUM(total_sales) DESC) AS product_dense_rank
    FROM
        adidas_data
    GROUP BY
        product, sales_year, sales_month
)
SELECT
    product,
    sales_year,
    sales_month,
    total__revenue,
    product_dense_rank
FROM
    ProductRanking
ORDER BY
    product_dense_rank, sales_year, sales_month;
    
    
    
    /* Ranking each product by number of units sold, by month */
    WITH ProductRanking AS (
    SELECT
        product,
        YEAR(invoice_date) AS sales_year,
        MONTH(invoice_date) AS sales_month,
        SUM(units_sold) AS total__quantity_sold,
        DENSE_RANK() OVER (ORDER BY SUM(units_sold) DESC) AS product_dense_rank
    FROM
        adidas_data
    GROUP BY
        product, sales_year, sales_month
)
SELECT
    product,
    sales_year,
    sales_month,
    total__quantity_sold,
    product_dense_rank
FROM
    ProductRanking
ORDER BY
    product_dense_rank, sales_year, sales_month;
    


/* Products and their percent of total sales */
	SELECT 
    product,
    SUM(total_sales) AS total_revenue,
    ROUND((SUM(total_sales) / (SELECT 
                    SUM(total_sales)
                FROM
                    adidas_data)) * 100,
            2) AS percentage_of_total
FROM
    adidas_data
GROUP BY product
ORDER BY percentage_of_total DESC;

/* Sales Methods */
SELECT DISTINCT
    sales_method
FROM
    adidas_data;

/* Most popular methods of sales */
SELECT 
    sales_method, COUNT(sales_method) AS method_count
FROM
    adidas_data
GROUP BY sales_method
ORDER BY method_count DESC;


/* Sale Method, amount of orders, and percent of sales */
SELECT 
    sales_method,
    COUNT(*) AS total_orders,
    (COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            adidas_data)) * 100 AS percentage_of_sales
FROM
    adidas_data
GROUP BY sales_method
ORDER BY percentage_of_sales DESC;
    
/* Ranks the best selling methods of sale by total quantity sold */
 WITH MethodRanking AS (
    SELECT
        sales_method,
        YEAR(invoice_date) AS sales_year,
        MONTH(invoice_date) AS sales_month,
        SUM(units_sold) AS total__quantity_sold,
        DENSE_RANK() OVER (ORDER BY SUM(units_sold) DESC) AS product_dense_rank
    FROM
        adidas_data
    GROUP BY
        sales_method, sales_year, sales_month
)
SELECT
    sales_method,
    sales_year,
    sales_month,
    total__quantity_sold,
    product_dense_rank
FROM
    MethodRanking
ORDER BY
    product_dense_rank, sales_year, sales_month;

/* Ranks highest monthly revenue by sales method, by total revenue across the country */
WITH SalesRanking AS (
    SELECT
        sales_method,
        YEAR(invoice_date) AS sales_year,
        MONTH(invoice_date) AS sales_month,
        SUM(total_sales) AS total__revenue,
        DENSE_RANK() OVER (ORDER BY SUM(total_sales) DESC) AS product_dense_rank
    FROM
        adidas_data
    GROUP BY
        sales_method, sales_year, sales_month
)
SELECT
    sales_method,
    sales_year,
    sales_month,
    total__revenue,
    product_dense_rank
FROM
    SalesRanking
ORDER BY
    product_dense_rank, sales_year, sales_month;


/* Retailers with the highest count of orders, regardless of order method */
SELECT 
    retailer, COUNT(retailer) AS retailer_count
FROM
    adidas_data
WHERE
    retailer IN ('Foot Locker' , 'Walmart',
        'Sports Direct',
        'West Gear',
        'Kohls',
        'Amazon')
GROUP BY retailer
ORDER BY retailer_count DESC;


/* Finding the total revenue for each retailer, ordering DESC */
 SELECT DISTINCT
   retailer,
   SUM(total_sales) OVER(PARTITION BY retailer) AS retailer_revenue
FROM adidas_data
GROUP BY retailer, region, total_sales
ORDER BY retailer_revenue DESC;


/* Taking the total revenue for each retailer, and calculating the percentage of total sales */
SELECT 
    retailer,
    SUM(total_sales) AS total_revenue,
    ROUND((SUM(total_sales) / (SELECT 
                    SUM(total_sales)
                FROM
                    adidas_data)) * 100,
            2) AS percentage_of_total
FROM
    adidas_data
GROUP BY retailer
ORDER BY percentage_of_total DESC;

    
/* Percent of total revenue by state, showing top 10 states */
SELECT DISTINCT
    state,
    SUM(total_sales) AS state_revenue,
    ROUND((SUM(total_sales) / (SELECT 
                    SUM(total_sales)
                FROM
                    adidas_data)) * 100,
            2) AS state_percentage
FROM
    adidas_data
GROUP BY state
ORDER BY state_percentage DESC
LIMIT 10;


/* 10 states with the lowest percent of total revenue */
SELECT DISTINCT
    state,
    SUM(total_sales) AS state_revenue,
    ROUND((SUM(total_sales) / (SELECT 
                    SUM(total_sales)
                FROM
                    adidas_data)) * 100,
            2) AS state_percentage
FROM
    adidas_data
GROUP BY state
ORDER BY state_percentage
LIMIT 10;


/* Showing the 10 cities with the highest percentage of sales from the total revenue */
SELECT DISTINCT
    city,
    SUM(total_sales) AS city_revenue,
    ROUND((SUM(total_sales) / (SELECT 
                    SUM(total_sales)
                FROM
                    adidas_data)) * 100,
            2) AS city_percentage
FROM
    adidas_data
GROUP BY city
ORDER BY city_percentage DESC
LIMIT 10;


/* 10 cities with the lowest percent of the total revenue generated */
SELECT DISTINCT
    city,
    SUM(total_sales) AS city_revenue,
    ROUND((SUM(total_sales) / (SELECT 
                    SUM(total_sales)
                FROM
                    adidas_data)) * 100,
            2) AS city_percentage
FROM
    adidas_data
GROUP BY city
ORDER BY city_percentage
LIMIT 10;


/* Regions and their revenue contribution, ordered from highest to lowest */
SELECT DISTINCT
    region,
    SUM(total_sales) AS regional_revenue,
    ROUND((SUM(total_sales) / (SELECT 
                    SUM(total_sales)
                FROM
                    adidas_data)) * 100,
            2) AS regional_percentage
FROM
    adidas_data
GROUP BY region
ORDER BY regional_percentage DESC;

/* Changing invoice date column to yyyy/mm/dd format to use SUBSTRING more effectively */
SELECT 
    invoice_date,
    DATE_FORMAT(STR_TO_DATE(invoice_date, '%m/%d/%Y'),
            '%Y/%m/%d') AS formatted_date
FROM
    adidas_data;
    
UPDATE adidas_data 
SET 
    invoice_date = DATE_FORMAT(STR_TO_DATE(invoice_date, '%m/%d/%Y'),
            '%Y/%m/%d')
WHERE
    invoice_date IS NOT NULL;

/* Looking at the total revenue for each retailer in 2020 */
SELECT DISTINCT
    retailer,
    SUBSTRING(invoice_date, 1, 4) AS sales_year,
    SUM(total_sales) AS total_revenue
FROM
    adidas_data
WHERE
    SUBSTRING(invoice_date, 1, 4) = '2020'
        AND retailer = 'Amazon'
GROUP BY retailer , sales_year
ORDER BY sales_year , total_revenue DESC;


/* Comparing each retailer's sales in 2020 with their respective sales in 2021*/
/* Note: This dataset does not have data for Amazon sales in 2020. I tried to find an average to enter but could
not find concise data */

WITH sales_2020 AS (
  SELECT DISTINCT 
   retailer,
   SUBSTRING(invoice_date, 1, 4) AS sales_year,
   SUM(total_sales) AS total_revenue
FROM adidas_data
WHERE SUBSTRING(invoice_date, 1, 4) = 2020
GROUP BY retailer, sales_year
ORDER BY sales_year, total_revenue DESC
)
SELECT *
FROM sales_2020
JOIN
  (SELECT DISTINCT 
    retailer,
    SUBSTRING(invoice_date, 1, 4) AS sales_year,
    SUM(total_sales) AS total_revenue
   FROM adidas_data
   WHERE SUBSTRING(Invoice_Date, 1, 4) = 2021
   GROUP BY retailer, sales_year
   ORDER BY sales_year, total_revenue DESC) AS sales_2021
ON sales_2020.retailer = sales_2021.retailer
JOIN
  (SELECT
    retailer,
    SUBSTRING(Invoice_Date, 1, 4) AS sales_year,
    SUM(Total_Sales) AS total_sales
   FROM adidas_data
   WHERE retailer = 'Amazon'
   AND SUBSTRING(Invoice_Date, 1, 4) = 2021
   GROUP BY retailer, sales_year) AS amazon_sales
ON sales_2021.sales_year = amazon_sales.sales_year
ORDER BY sales_2020.total_revenue DESC, sales_2021.total_revenue DESC;






  