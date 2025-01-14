-- Collecting a scope of the data
SELECT *
FROM adidas_data
LIMIT 10;

-- Which retailers are present, and how many locations do each retailer occupy?

SELECT
  DISTINCT retailer,
  COUNT(retailer) AS retailer_count
FROM adidas_data
GROUP BY retailer;

-- How many states are present? (Used to group into regions, if number were to be less than 50, data could skew greatly)

SELECT 
  COUNT(DISTINCT state)
FROM adidas_data;


-- What are the product categories sold?

SELECT 
  COUNT(DISTINCT product)
FROM adidas_data;


-- How many total units(total products sold) were sold?

SELECT 
  SUM(units_sold) AS total_products_sold
FROM adidas_data;


-- Comparing 2020 and 2021, how many units were sold in each year? 

SELECT 
  sales_year, SUM(units_sold) AS num_products_sold
FROM
    (SELECT 
        units_Sold, SUBSTRING(invoice_date, 1, 4) AS sales_year
    FROM
        adidas_data) AS subquery
WHERE sales_year IN ('2020' , '2021')
GROUP BY sales_year;


-- What were the number of units sold per month? Display along with month-over-month trends as a percent

WITH monthly_units_sold AS (
    SELECT
        YEAR(invoice_date) AS sales_year,
        MONTH(invoice_date) AS sales_month,
        COUNT(units_sold) AS products_sold
    FROM
        adidas_data
    WHERE
        YEAR(invoice_date) IN (2020, 2021)
    GROUP BY
        sales_year, sales_month
    ORDER BY
        sales_year, sales_month
),
units_sold_with_change AS (
    SELECT
        sales_year,
        sales_month,
        products_sold,
        LAG(products_sold) OVER (
            PARTITION BY sales_year 
            ORDER BY sales_month
        ) AS previous_month_units_sold
    FROM
        monthly_units_sold
)
SELECT
    sales_year,
    sales_month,
    products_sold,
    previous_month_units_sold,
    CASE
        WHEN previous_month_units_sold IS NOT NULL THEN 
            ROUND(((products_sold - previous_month_units_sold) * 100.0 / previous_month_units_sold), 2)
        ELSE NULL
    END AS percent_change
FROM
    units_sold_with_change
ORDER BY
    sales_year, sales_month;

    
-- How much revenue did Adidas generate from 2020-2021? 
SELECT 
  SUM(total_sales) AS total_revenue
FROM adidas_data;
    


-- Compare revenue earned in 2020 and 2021 separately. How much did each respective year generate?

SELECT 
  sales_year, SUM(total_sales) AS overall_revenue
FROM
    (SELECT 
        Total_Sales, SUBSTRING(invoice_date, 1, 4) AS sales_year
    FROM
        adidas_data) AS subquery
WHERE sales_year IN ('2020' , '2021')
GROUP BY sales_year;


-- Show the month over month revenue trends, along with growth percentage. 

WITH monthly_revenue AS (
    SELECT
        YEAR(invoice_date) AS sales_year,
        MONTH(invoice_date) AS sales_month,
        SUM(total_sales) AS monthly_revenue
    FROM
        adidas_data
    WHERE
        YEAR(invoice_date) IN (2020, 2021)
    GROUP BY
        sales_year, sales_month
    ORDER BY
        sales_year, sales_month
),
revenue_with_change AS (
    SELECT
        sales_year,
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            PARTITION BY sales_year 
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM
        monthly_revenue
)
SELECT
    sales_year,
    sales_month,
    monthly_revenue,
    previous_month_revenue,
    CASE
        WHEN previous_month_revenue IS NOT NULL THEN 
            ROUND(((monthly_revenue - previous_month_revenue) * 100.0 / previous_month_revenue), 2)
        ELSE NULL
    END AS percent_change
FROM
    revenue_with_change
ORDER BY
    sales_year, sales_month;


-- How much did Adidas make as profit?

SELECT 
  SUM(Operating_Profit) AS total_profit
FROM adidas_data;


-- Display profit margins by month, including growth percentages.

WITH monthly_profits AS (
    SELECT
        YEAR(invoice_date) AS sales_year,
        MONTH(invoice_date) AS sales_month,
        ROUND(SUM(Operating_Profit), 2) AS monthly_profit
    FROM
        adidas_data
    WHERE
        YEAR(invoice_date) IN (2020, 2021)
    GROUP BY
        sales_year, sales_month
    ORDER BY
        sales_year, sales_month
),
profits_with_change AS (
    SELECT
        sales_year,
        sales_month,
        monthly_profit,
        LAG(monthly_profit) OVER (
            PARTITION BY sales_year 
            ORDER BY sales_month
        ) AS previous_month_profit
    FROM
        monthly_profits
)
SELECT
    sales_year,
    sales_month,
    monthly_profit,
    previous_month_profit,
    CASE
        WHEN previous_month_profit IS NOT NULL THEN 
            ROUND(((monthly_profit - previous_month_profit) * 100.0 / previous_month_profit), 2)
        ELSE NULL
    END AS percent_change
FROM
    profits_with_change
ORDER BY
    sales_year, sales_month;





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






  
