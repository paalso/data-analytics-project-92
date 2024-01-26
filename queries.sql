-- The total number of customers
-- Output: -- The result: top_10_total_income.csv
SELECT COUNT(*) as customers_count from customers;


-- The 10 top-performing employees based on total income
-- Output: top_10_total_income.csv
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    COUNT(*) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN employees e ON e.employee_id = s.sales_person_id
JOIN products p ON p.product_id = S.product_id
GROUP BY CONCAT(e.first_name, ' ', e.last_name)
ORDER BY income DESC
LIMIT 10;


-- The employees whose individual average operation income is below the total average income
-- Output: lowest_average_income.csv
WITH
	sale_incoms AS (
	    SELECT
	        CONCAT(e.first_name, ' ', e.last_name) AS name,
	        s.quantity * p.price AS income
	    FROM sales s
	    JOIN employees e ON e.employee_id = s.sales_person_id
	    JOIN products p ON p.product_id = S.product_id
	),
	total_average_income AS (
	    SELECT AVG(income) AS average_income FROM sale_incoms
	)
SELECT
    sale_incoms.name,
    ROUND(AVG(income), 0) AS average_income
FROM sale_incoms
CROSS JOIN total_average_income
GROUP BY sale_incoms.name, total_average_income.average_income
HAVING AVG(income) < total_average_income.average_income
ORDER BY average_income;


-- The income grouped by days of week and employees
-- Output: day_of_the_week_income.csv
WITH reformatted_sales AS (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS name,
        TO_CHAR(sale_date, 'FMday') AS weekday,
        TO_CHAR(sale_date, 'ID') AS weekday_id,
        ROUND(SUM(s.quantity * p.price), 0) AS income
    FROM sales s
    JOIN employees e ON e.employee_id = s.sales_person_id
    JOIN products p ON p.product_id = S.product_id
    GROUP by
    	CONCAT(e.first_name, ' ', e.last_name), weekday, weekday_id
)
SELECT
	name, weekday, income
FROM reformatted_sales
ORDER BY weekday_id, name;