-- Total number of customers
-- Output: -- The result: top_10_total_income.csv
SELECT COUNT(*) as customers_count from customers;


-- Top ten highest performing employees by total income
-- Output: top_10_total_income.csv
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    COUNT(*) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN employees e ON e.employee_id = s.sales_person_id
JOIN products p ON p.product_id = s.product_id
GROUP BY CONCAT(e.first_name, ' ', e.last_name)
ORDER BY income DESC
LIMIT 10;


-- Employees whose individual average operation income is below the overall average income
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


-- Income grouped by days of the week and employees
-- Output: day_of_the_week_income.csv
WITH reformatted_sales AS (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS name,
        TO_CHAR(sale_date, 'day') AS weekday,
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


-- Number of customers grouped by age category
-- Output: age_groups.csv
WITH customers_age_categories AS (
    SELECT
        CASE 
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category
    FROM customers
)
SELECT
    age_category,
    COUNT(*) AS count
FROM customers_age_categories
GROUP BY age_category
ORDER BY
    LEFT(age_category, 1);


-- Number of unique customers and total income per month
-- Output: customers_by_month.csv
SELECT
    TO_CHAR(sale_date, 'YYYY-MM') AS date,
    COUNT(DISTINCT customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN products p ON p.product_id = s.product_id
GROUP BY date;


-- Customers whose first purchase was during promotions
-- (with promotional price equal to 0)
-- special_offer.csv
SELECT
    DISTINCT ON (c.customer_id)
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    s.sale_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
FROM sales s
JOIN customers c ON c.customer_id = s.customer_id
JOIN employees e ON e.employee_id = s.sales_person_id
JOIN products p ON p.product_id = s.product_id
WHERE p.price = 0
ORDER BY c.customer_id;
