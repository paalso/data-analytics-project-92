-- The the total number of customers
select COUNT(*) as customers_count from customers;


-- The 10 top-performing employees based on total income
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    COUNT(*) AS operations,
    ROUND(SUM(s.quantity * p.price), 0) AS income
FROM sales s
JOIN employees e ON e.employee_id = s.sales_person_id
JOIN products p ON p.product_id = S.product_id
GROUP BY CONCAT(e.first_name, ' ', e.last_name)
ORDER BY income DESC
LIMIT 10;


-- The employees whose individual average operation income is below the total average income
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


