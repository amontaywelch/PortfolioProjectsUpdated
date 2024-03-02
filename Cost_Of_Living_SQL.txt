/* Creating tables to use for data export from Excel 

CREATE TABLE CaseTable (
 caseID SMALLINT,
 state VARCHAR(20),
 metro_area BOOLEAN,
 area_name VARCHAR(255),
 county VARCHAR(255),
 num_adults SMALLINT,
 num_children SMALLINT,
 PRIMARY KEY (caseID)
);

CREATE TABLE CostTable (
 caseID SMALLINT,
 housing_cost FLOAT,
 food_cost FLOAT,
 transportation_cost FLOAT,
 childcare_cost FLOAT,
 other_costs FLOAT,
 annual_taxes FLOAT,
 total_cost FLOAT,
 median_income FLOAT,
 FOREIGN KEY (caseID) REFERENCES CaseTable(caseID) */



/* Selecting all data from both tables to ensure proper export, and to get an idea on what insights to work with. */
SELECT * FROM cost_table;
SELECT * FROM case_table;

SELECT COUNT (DISTINCT state)
FROM case_table;
/* Note: This dataset classifies Washington, DC as a state, hence the query returning 51 distinct states */

/* Counting the distinct number of counties */
SELECT COUNT (DISTINCT county)
FROM case_table;

/* Looking at the average for each individual cost category */
SELECT AVG(housing_cost)
FROM cost_table;

SELECT AVG(food_cost)
FROM cost_table;

SELECT AVG(transportation_cost)
FROM cost_table;

SELECT AVG(healthcare_cost)
FROM cost_table;

SELECT AVG(childcare_cost)
FROM cost_table;

SELECT AVG(other_costs)
FROM cost_table;

SELECT AVG(annual_taxes)
FROM cost_table;

/* Now looking at the US average total cost of living, and the average income */
SELECT AVG(total_cost)
FROM cost_table;

SELECT AVG(median_income)
FROM cost_table;

/* Joining tables to look at the 10 most expensive states to live in, on average */
SELECT DISTINCT cases.state, AVG(costs.total_cost) AS total_avg_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.state
ORDER BY total_avg_cost DESC
LIMIT 10;

/* Taking the 10 highest cost of living averages per state and comparing them to their respective median income */
SELECT DISTINCT cases.state, AVG(costs.total_cost) AS total_avg_cost, AVG(median_income) AS avg_median_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.state
ORDER BY total_avg_cost DESC
LIMIT 10;

/* 10 most expensive counties to live in, on average */
SELECT DISTINCT cases.county, cases.state, AVG(costs.total_cost) AS total_avg_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.county, cases.state
ORDER BY total_avg_cost DESC
LIMIT 10;

/* Taking the 10 most expensive counties and comparing to their average median income */
SELECT DISTINCT cases.county, cases.state, AVG(costs.total_cost) AS total_avg_cost, AVG(median_income) AS avg_median_income
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.county, cases.state
ORDER BY total_avg_cost DESC
LIMIT 10;

/* Showing the 10 states with the cheapest cost of living */
SELECT DISTINCT cases.state, AVG(costs.total_cost) AS total_avg_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.state
ORDER BY total_avg_cost
LIMIT 10;

/* 10 least expensive states to live in, compared to their average median income */
SELECT DISTINCT cases.state, AVG(costs.total_cost) AS total_avg_cost, AVG(median_income) AS avg_median_income
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.state
ORDER BY total_avg_cost
LIMIT 10;

/* Showing the 10 least expensive counties to live in, on average */
SELECT DISTINCT cases.county, cases.state, AVG(costs.total_cost) AS total_avg_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.county, cases.state
ORDER BY total_avg_cost
LIMIT 10;

/* Showing the 10 least expensive counties, and compare to each county's respective median income */
SELECT DISTINCT cases.county, cases.state, AVG(costs.total_cost) AS total_avg_cost, AVG(median_income) AS avg_median_income
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.county, cases.state
ORDER BY total_avg_cost
LIMIT 10;

/* Showing counties in Oregon and Washington, ordering by highest median income descending */
SELECT DISTINCT cases.state, cases.county, AVG(median_income) OVER(PARTITION BY county) AS avg_income
FROM case_table AS cases
FULL JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE state = 'OR'
OR state = 'WA'
ORDER BY 3 DESC;

/* Looking at total cost of living and median income for the West Reigon of the US */
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
WHERE state IN ('WA', 'OR', 'CA', 'ID', 'NV', 'UT', 'CO', 'WY', 'MT', 'HI', 'AK')
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY state_total_cost DESC;

/* Looking at the total cost of living and median income for the Southwest reigon of the US */
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
WHERE state IN ('AZ', 'NM', 'TX', 'OK')
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY state_total_cost DESC;

/* Looking at the total cost of living and median income for the Midwest reigon of the US */
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
WHERE state IN ('ND', 'SD', 'NE', 'KS', 'MN', 'IA', 'MO', 'WI', 'IL', 'MI', 'IN', 'OH')
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY state_total_cost DESC;

/* Looking at the total cost of living and median income of the Southeast reigon of the US */
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
WHERE state IN ('AK', 'LA', 'MS', 'AL', 'GA', 'FL', 'SC', 'NC', 'VA', 'MD', 'DE', 'DC', 'WV', 'KY', 'TN')
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY state_total_cost DESC;

/* Looking at the total cost of living and median income for the Northeast reigon of the US */
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
WHERE state IN ('PA', 'NJ', 'NY', 'VT', 'NH', 'ME', 'MA', 'RI', 'CT')
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY state_total_cost DESC;

/* Looking at the Maximum and Minimum costs of each cost category, and where those numbers are located */

/* Using window function to find the highest housing cost, ranked from highest to lowest */
SELECT DISTINCT
  housing_cost,
  RANK () OVER(ORDER BY housing_cost DESC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Finding where the highest housing cost is located */
SELECT DISTINCT cases.state, cases.county, costs.housing_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.housing_cost = 61735.59;

/* Using a CTE to see if the location with the highest housing cost is part of a major metro area */
WITH housing_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.housing_cost
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'San Mateo County'
 AND costs.housing_cost = 61735.59
)
SELECT * FROM housing_metro;
 
/* Finding the lowest housing cost */
SELECT DISTINCT
  housing_cost,
  RANK () OVER(ORDER BY housing_cost ASC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Where the lowest housing cost is located */
SELECT DISTINCT cases.state, cases.county, costs.housing_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.housing_cost = 4209.31;

/* Cheapest housing cost, looking if the number is part of a major metro area */
WITH housing_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.housing_cost
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'Trigg County'
 AND costs.housing_cost = 4209.31
)
SELECT * FROM housing_metro;

/* Highest food cost */
SELECT DISTINCT
  food_cost,
  RANK () OVER(ORDER BY food_cost DESC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Looking at where the highest food cost is located */
SELECT DISTINCT cases.state, cases.county, costs.food_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.food_cost = 31178.62;

/* Is the location part of a major metro area? */
WITH food_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.food_cost
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'Leelanau County'
 AND costs.food_cost = 31178.62
)
SELECT * FROM food_metro;

/* Lowest food cost */
SELECT DISTINCT
  food_cost,
  RANK () OVER(ORDER BY food_cost ASC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Location of lowest food cost */
SELECT DISTINCT cases.state, cases.county, costs.food_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.food_cost = 2220.28;

/* Is the location part of a major metro area? */
WITH food_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.food_cost
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'Llano County'
 AND costs.food_cost = 2220.28
)
SELECT * FROM food_metro;

/* Highest transportation cost */
SELECT DISTINCT
  transportation_cost,
  RANK () OVER(ORDER BY transportation_cost DESC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Location of highest transportation cost */
SELECT DISTINCT cases.state, cases.county, costs.transportation_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.transportation_cost = 19816.48;

/* Is the location part of a major metro area? */
WITH transportation_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.transportation_cost
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'Marin County'
 AND costs.transportation_cost = 19816.48
)
SELECT * FROM transportation_metro;

/* Lowest transportation cost */
SELECT DISTINCT
  transportation_cost,
  RANK () OVER(ORDER BY transportation_cost ASC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Location of lowest transportation cost */
SELECT DISTINCT cases.state, cases.county, costs.transportation_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.transportation_cost = 2216.46;

/* Is the location part of a major metro area? */
WITH transportation_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.transportation_cost
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'New York County'
 AND costs.transportation_cost = 2216.46
)
SELECT * FROM transportation_metro;


/* Highest healthcare cost */
SELECT DISTINCT
  healthcare_cost,
  RANK () OVER(ORDER BY healthcare_cost DESC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Location of highest healthcare cost */
SELECT DISTINCT cases.state, cases.county, costs.healthcare_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.healthcare_cost = 37252.27;

/* Is the location part of a major metro area? */
WITH healthcare_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.healthcare_cost
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county IN ('Logan County','McDowell County','Mingo County','Wyoming County')
 AND costs.healthcare_cost = 37252.27
)
SELECT * FROM healthcare_metro;

/* Lowest healthcare cost */
SELECT DISTINCT
  healthcare_cost,
  RANK () OVER(ORDER BY healthcare_cost ASC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Location of lowest healthcare cost */
SELECT DISTINCT cases.state, cases.county, costs.healthcare_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.healthcare_cost = 3476.38;

/* Is the location part of a major metro area? */
WITH healthcare_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.healthcare_cost
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county IN ('Bernalillo County', 'Sandoval County', 'Torrance County', 'Valencia County')
 AND costs.healthcare_cost = 3476.38
)
SELECT * FROM healthcare_metro;

/* Highest childcare cost */
SELECT DISTINCT
  childcare_cost,
  RANK () OVER(ORDER BY childcare_cost DESC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Location of highest childcare cost */
SELECT DISTINCT cases.state, cases.county, costs.childcare_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.childcare_cost = 48831.09;

/* Is the location part of a major metro area? */
WITH childcare_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.childcare_cost
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'District of Columbia'
 AND costs.childcare_cost = 48831.09
)
SELECT * FROM childcare_metro;

/* Note: This datsets involves case studies with households of 0 children, so finding the minimum childcare cost is not suitable */


/* Highest amount of other costs */
SELECT DISTINCT
  other_costs,
  RANK () OVER(ORDER BY other_costs DESC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Location with the highest amount of other costs in a year */
SELECT DISTINCT cases.state, cases.county, costs.other_costs
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.other_costs = 28829.44;

/* Is the location part of a major metro area? */
WITH othercosts_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.other_costs
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'San Mateo County'
 AND costs.other_costs = 28829.44
)
SELECT * FROM othercosts_metro;

/* Lowest amount of other costs */
SELECT DISTINCT
  other_costs,
  RANK () OVER(ORDER BY other_costs ASC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Location that has the lowest amount of other costs annually */
SELECT DISTINCT cases.state, cases.county, costs.other_costs
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.other_costs = 2611.64;

/* Is the location part of a major metro area? */
WITH othercosts_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.other_costs
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'Trigg County'
 AND costs.other_costs = 2611.64
)
SELECT * FROM othercosts_metro;

/* Highest annual taxes amount */
SELECT DISTINCT
  annual_taxes,
  RANK () OVER(ORDER BY annual_taxes DESC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Location where the annual taxes is highest */
SELECT DISTINCT cases.state, cases.county, costs.annual_taxes
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.annual_taxes = 47753.39;

/* Is the location part of a major metro area? */
WITH annual_taxes_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.annual_taxes
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'San Mateo County'
 AND costs.annual_taxes = 47753.39
)
SELECT * FROM annual_taxes_metro;

/* Lowest amount of annual taxes */
SELECT DISTINCT
  annual_taxes,
  RANK () OVER(ORDER BY annual_taxes ASC) AS Rank
FROM cost_table
ORDER BY Rank;

/* Location where the annual taxes is lowest */
SELECT DISTINCT cases.state, cases.county, costs.annual_taxes
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE costs.annual_taxes = 1027.8;

/* Is the location part of a major metro area? */
WITH annual_taxes_metro AS (
 SELECT DISTINCT cases.state, cases.county, cases.metro_area, costs.annual_taxes
 FROM case_table AS cases
 LEFT JOIN cost_table AS costs
 ON cases.caseid = costs.caseid
 WHERE cases.county = 'Starr County'
 AND costs.annual_taxes = 1027.8
)
SELECT * FROM annual_taxes_metro;

/* Looking at the average household size in the US */
SELECT
  AVG(num_adults) AS avg_num_adults,
  AVG(num_children) AS avg_num_children
FROM case_table;

/* Showing the average cost of living, and median income for the average household size (2 adults, 2 kids) */
SELECT
  cases.num_adults,
  cases.num_children,
  AVG(total_cost) AS avg_cost,
  AVG(median_income) AS avg_median_income
FROM case_table AS cases
FULL JOIN cost_table AS costs
ON cases.caseid = costs.caseid
WHERE num_adults = 2
AND num_children = 2
GROUP BY cases.num_adults, cases.num_children;

/* Showing the total cost and median income for all household demographics */
SELECT
  cases.num_adults,
  cases.num_children,
  AVG(total_cost) AS avg_cost,
  AVG(median_income) AS avg_median_income
FROM case_table AS cases
FULL JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.num_adults, cases.num_children
ORDER BY 1,2;

/* Looking at each state's income ratio by dividing the average total cost by the average median income */
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income,
   AVG(total_cost / median_income) OVER(PARTITION BY state) AS income_ratio
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY income_ratio DESC;

/* Creating views for visualization */
CREATE VIEW StateIncomeRatios AS 
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income,
   AVG(total_cost / median_income) OVER(PARTITION BY state) AS income_ratio
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY income_ratio DESC;

DROP VIEW stateincomeratio;

CREATE VIEW HouseholdDemographic AS 
SELECT
  cases.num_adults,
  cases.num_children,
  AVG(total_cost) AS avg_cost,
  AVG(median_income) AS avg_median_income
FROM case_table AS cases
FULL JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.num_adults, cases.num_children
ORDER BY 1,2;

DROP VIEW householddemographics;

CREATE VIEW WestReigonAverage AS 
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
WHERE state IN ('WA', 'OR', 'CA', 'ID', 'NV', 'UT', 'CO', 'WY', 'MT', 'HI', 'AK')
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY state_total_cost DESC;

DROP VIEW westreigonaverages;

CREATE VIEW SouthwestReigonAverage AS
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
WHERE state IN ('AZ', 'NM', 'TX', 'OK')
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY state_total_cost DESC;

DROP VIEW southwestreigonaverages;

CREATE VIEW MidwestReigonAverage AS 
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
WHERE state IN ('ND', 'SD', 'NE', 'KS', 'MN', 'IA', 'MO', 'WI', 'IL', 'MI', 'IN', 'OH')
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY state_total_cost DESC;

DROP VIEW midwestreigonaverages

CREATE VIEW SoutheastReigonAverages AS 
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
WHERE state IN ('AK', 'LA', 'MS', 'AL', 'GA', 'FL', 'SC', 'NC', 'VA', 'MD', 'DE', 'DC', 'WV', 'KY', 'TN')
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY state_total_cost DESC;

DROP VIEW southeastreigonaverage;

CREATE VIEW NortheastReigonAverage AS 
SELECT DISTINCT
   c1.state,
   AVG(total_cost) OVER(PARTITION BY state) AS state_total_cost,
   AVG(median_income) OVER(PARTITION BY state) AS state_median_income
FROM case_table AS c1
JOIN cost_table AS c2
ON c1.caseid = c2.caseid
WHERE state IN ('PA', 'NJ', 'NY', 'VT', 'NH', 'ME', 'MA', 'RI', 'CT')
GROUP BY c1.state, c2.total_cost, c2.median_income
ORDER BY state_total_cost DESC;

DROP VIEW northeastreigonaverages;

CREATE VIEW MostExpensiveState AS 
SELECT DISTINCT cases.state, AVG(costs.total_cost) AS total_avg_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.state
ORDER BY total_avg_cost DESC
LIMIT 10;

DROP VIEW MostExpensiveStates;

CREATE VIEW MostExpensiveCounty AS
SELECT DISTINCT cases.county, cases.state, AVG(costs.total_cost) AS total_avg_cost
FROM case_table AS cases
LEFT JOIN cost_table AS costs
ON cases.caseid = costs.caseid
GROUP BY cases.county, cases.state
ORDER BY total_avg_cost DESC
LIMIT 10;

SELECT *
FROM MostExpensiveCounty;

DROP VIEW MostExpensiveCounties;

SELECT *
FROM householddemographic;

SELECT *
FROM mostexpensivestate;

SELECT *
FROM mostexpensivecounty;

/* Some views were dropped in order to add the ORDER BY statements, as I thought that they weren't able to be added.
Performed a number of select queries from various views to confirm the correct data is returned. */
