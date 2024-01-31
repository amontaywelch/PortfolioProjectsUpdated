/* DATA CLEANING TASKS
 -Case Statements showing full names in products table
 -Checking for duplicate data using CTEs
 -Using COALESCE to deal with null values
 -Deleting unused columns
 -SUBSTRING to create a call code column in the customers table
 -Formatting data to have capital letters */

/* Selecting all from each table to ensure data was imported correctly */
SELECT *
FROM customers;

SELECT *
FROM orders;

SELECT *
FROM products;

/* Looking at the distinct coffee types */
SELECT DISTINCT coffeetype
FROM products;

/* Using a CASE statement to show the full name of each coffee type from the products table, and then
updating the products table with edited data */
SELECT
 coffeetype,
  CASE WHEN coffeetype = 'Ara' THEN 'Arabica'
  WHEN coffeetype = 'Rob' THEN 'Robusta'
  WHEN coffeetype = 'Exc' THEN 'Excelsa'
  ELSE 'Liberica' 
  END
FROM products;

UPDATE products
SET coffeetype =  CASE WHEN coffeetype = 'Ara' THEN 'Arabica'
  WHEN coffeetype = 'Rob' THEN 'Robusta'
  WHEN coffeetype = 'Exc' THEN 'Excelsa'
  ELSE 'Liberica' 
  END;
  
/* Adding another CASE statement to show the roast type's full name, updating the roast type column
with the updated data */
SELECT
 roasttype,
 CASE WHEN roasttype = 'L' THEN 'Light'
 WHEN roasttype = 'M' THEN 'Medium'
 ELSE 'Dark'
 END
FROM products;

UPDATE products
SET roasttype = CASE WHEN roasttype = 'L' THEN 'Light'
 WHEN roasttype = 'M' THEN 'Medium'
 ELSE 'Dark'
 END;
 
/* Casting these columns as DECIMALS instead of floats, updating values into respective tables */
 
SELECT CAST(unitprice AS DECIMAL)
FROM products;

SELECT CAST(priceper100g AS DECIMAL)
FROM products;

SELECT CAST(profit AS DECIMAL)
FROM products;

UPDATE products
SET unitprice = CAST(unitprice AS DECIMAL);

UPDATE products
SET priceper100g = CAST(priceper100g AS DECIMAL);

UPDATE products
SET profit = CAST(profit AS DECIMAL);

SELECT orderdate
FROM orders;

/* Joining customer table with itself to look at customers with null emails */
SELECT c1.customername, c1.email, c2.customername, c2.email
FROM customers AS c1
JOIN customers AS c2
ON c1.customerid = c2.customerid;

/* Filling null emails with Email not provided */
SELECT COALESCE(email, 'Email not provided')
FROM customers;

UPDATE customers
SET email = COALESCE(email, 'Email not provided');

/* Filling null phone numbers with number not provided */
SELECT COALESCE(phone, 'Number not provided')
FROM customers;

UPDATE customers
SET phone = COALESCE(phone, 'Number not provided');

/* Creating new column call_code to have another column for grouping queries */

SELECT SUBSTRING(phone,1,2)
FROM customers
WHERE phone LIKE '%+1%';

SELECT SUBSTRING(phone,1,4)
FROM customers
WHERE phone LIKE '%+353%';

SELECT SUBSTRING(phone,1,3)
FROM customers
WHERE phone LIKE '%+44%';

ALTER TABLE customers
ADD COLUMN call_code VARCHAR(5);

UPDATE customers
SET call_code = '+1'
WHERE phone LIKE '%+1%';

UPDATE customers
SET call_code = '+353'
WHERE phone LIKE '%+353%';

UPDATE customers
SET call_code = '+44'
WHERE phone LIKE '%+44%';

SELECT COALESCE(call_code, 'Number not provided')
FROM customers;

ALTER TABLE customers
ALTER COLUMN call_code TYPE VARCHAR(30);


UPDATE customers
SET call_code = COALESCE(call_code, 'Number not provided')
WHERE call_code IS NULL;

/* Formatting columns in the customer table to all capitals */
SELECT UPPER(customername) AS formatted_name
FROM customers;

UPDATE customers
SET customername = UPPER(customername);

SELECT UPPER(email)
FROM customers;

UPDATE customers
SET email = UPPER(email);

SELECT UPPER(addressline1)
FROM customers;

UPDATE customers
SET addressline1 = UPPER(addressline1);

SELECT UPPER(city)
FROM customers;

UPDATE customers
SET city = UPPER(city);

SELECT UPPER(country)
FROM customers;

UPDATE customers
SET country = UPPER(country);

/* Now capitalizing columns in the products table */
SELECT UPPER(coffeetype)
FROM products;

UPDATE products
SET coffeetype = UPPER(coffeetype);

SELECT UPPER(roasttype)
FROM products;

UPDATE products
SET roasttype = UPPER(roasttype);


/* Checking for duplicate data */
WITH duplicates_cte AS (
  SELECT
    productid,
    profit,
    ROW_NUMBER() OVER (PARTITION BY productid, profit ORDER BY (productid)) AS row_num
  FROM
    products
)
SELECT * FROM products
WHERE (productid, profit) IN (SELECT productid, profit FROM duplicates_cte WHERE row_num > 1);

WITH duplicates_cte1 AS (
  SELECT
    customerid,
    ROW_NUMBER() OVER (PARTITION BY customerid ORDER BY (customerid)) AS row_num
  FROM
    customers
)
SELECT * FROM customers
WHERE (customerid) IN (SELECT customerid FROM duplicates_cte1 WHERE row_num > 1);

/* This query returns duplicates, but they are kept as one customer can order multiple items, multiple times */
WITH duplicates_cte2 AS (
  SELECT
    orderid,
    ROW_NUMBER() OVER (PARTITION BY orderid ORDER BY (SELECT orderid)) AS row_num
  FROM
    orders
)
SELECT * FROM orders
WHERE (orderid) IN (SELECT orderid FROM duplicates_cte2 WHERE row_num > 1);

/* Creating column for 'kg' to concat with size in products table */
ALTER TABLE products
ADD COLUMN weight CHAR(2);

/* Getting rid of null values */
SELECT COALESCE(weight, 'kg')
FROM products
WHERE weight IS NULL;

UPDATE products
SET weight = COALESCE(weight, 'kg')
WHERE weight IS NULL;

/* combining size and weight to get appropriate size values */
SELECT CONCAT(size, weight) AS product_size
FROM products;

ALTER TABLE products
ADD COLUMN product_size VARCHAR(10);

UPDATE products
SET product_size = CONCAT(size, weight);

/* Deleting size and weight as they were combined in the previous query */
ALTER TABLE products
DROP COLUMN size;

ALTER TABLE products
DROP COLUMN weight;

/* deleting null values caused by adding the 'kg' column */
DELETE 
FROM products
WHERE productid IS NULL;

ALTER TABLE customers
RENAME COLUMN addressline1 TO address;



