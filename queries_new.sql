-- Data-mart
SELECT
    sales_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    p.name AS product,
    s.quantity,
    ROUND(p.price, 2),
    ROUND(s.quantity * p.price, 0) AS amount,
    sale_date,
    TO_CHAR(sale_date, 'day') AS weekday,
    TO_CHAR(sale_date, 'ID') AS weekday_id,
    TO_CHAR(sale_date, 'YYYY-MM') AS month
FROM sales s
JOIN employees e ON e.employee_id = s.sales_person_id
JOIN products p ON p.product_id = s.product_id
JOIN customers c ON c.customer_id  = s.customer_id
ORDER BY sales_id
limit 10;
-- sales_id|employee          |customer       |product                       |quantity|round  |amount |sale_date |weekday  |weekday_id|month  |
-- --------+------------------+---------------+------------------------------+--------+-------+-------+----------+---------+----------+-------+
--        1|Albert Ringer     |Joseph White   |ML Bottom Bracket             |     500| 101.24|  50620|1992-11-12|thursday |4         |1992-11|
--        2|Innes del Castillo|Austin Jai     |Road-550-W Yellow, 48         |     810|1120.49| 907597|1992-12-12|saturday |6         |1992-12|
--        3|Morningstar Greene|Lauren Cooper  |Lock Nut 9                    |     123| 177.60|  21845|1992-10-08|thursday |4         |1992-10|


-- Engaged customers categorized by their age into specific age groups:
-- '16-25', '26-40', and '40+'
-- Output: age_groups.csv
WITH engaged_customers_age_categories AS (
    SELECT
        CASE 
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category
    FROM customers
    WHERE customer_id IN (SELECT DISTINCT customer_id FROM sales)
)
SELECT
    age_category,
    COUNT(*) AS count
FROM engaged_customers_age_categories
GROUP BY age_category
ORDER BY
    LEFT(age_category, 1);
-- age_category|count|
-- ------------+-----+
-- 16-25       |   37|
-- 26-40       |   65|
-- 40+         |  128|