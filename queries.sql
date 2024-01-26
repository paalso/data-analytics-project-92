-- The the total number of customers
-- The output: -- The result: top_10_total_income.csv
SELECT COUNT(*) as customers_count from customers;


-- The 10 top-performing employees based on total income
-- The output: top_10_total_income.csv
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
-- The output: lowest_average_income.csv
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


