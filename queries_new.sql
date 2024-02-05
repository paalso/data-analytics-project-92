-- Data-mart
SELECT
    TO_CHAR(sale_date, 'YYYY-MM') AS month,
    CASE 
        WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
        WHEN c.age > 40 THEN '40+'
    END AS age_category,
    s.quantity,
    ROUND(p.price, 2)  AS price,
    ROUND(s.quantity * p.price, 0) AS amount
FROM sales s
JOIN products p ON p.product_id = s.product_id
JOIN customers c ON c.customer_id  = s.customer_id
ORDER BY sales_id
LIMIT 10;
-- sales_id|employee          |customer       |age_category|product                       |quantity|round  |amount |sale_date |weekday  |weekday_id|month  |
-- --------+------------------+---------------+------------+------------------------------+--------+-------+-------+----------+---------+----------+-------+
--        1|Albert Ringer     |Joseph White   |40+         |ML Bottom Bracket             |     500| 101.24|  50620|1992-11-12|thursday |4         |1992-11|
--        2|Innes del Castillo|Austin Jai     |40+         |Road-550-W Yellow, 48         |     810|1120.49| 907597|1992-12-12|saturday |6         |1992-12|
--        3|Morningstar Greene|Lauren Cooper  |16-25       |Lock Nut 9                    |     123| 177.60|  21845|1992-10-08|thursday |4         |1992-10|
--  .......................


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


-- Categorizes engaged customers into age groups and
-- calculates summary sales statistics for each age category
WITH customers_age_categories AS (
    SELECT
        CASE 
            WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
            WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
            WHEN c.age > 40 THEN '40+'
        END AS age_category,
        s.quantity,
        ROUND(p.price, 2) AS price,
        ROUND(s.quantity * p.price, 0) AS amount
    FROM sales s
    JOIN products p ON p.product_id = s.product_id
    JOIN customers c ON c.customer_id  = s.customer_id
    ORDER BY sales_id    
)
SELECT
    age_category,
    SUM(quantity)  AS total_quantity,
    SUM(amount) AS total_amount,
    ROUND(SUM(amount) / SUM(quantity), 1) AS average_purchase_price
FROM customers_age_categories
GROUP BY age_category;
-- age_category|total_quantity|total_amount|average_purchase_price|
-- ------------+--------------+------------+----------------------+
-- 26-40       |      16214944|  9058940383|                 558.7|
-- 40+         |      25803235| 12453312585|                 482.6|
-- 16-25       |       7489438|  5204330449|                 694.9|


-- The whole period total quantity, total amount,
-- and average purchase price for each age category.
WITH customers_age_categories AS (
    SELECT
        CASE 
            WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
            WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
            WHEN c.age > 40 THEN '40+'
        END AS age_category,
        s.quantity,
        ROUND(p.price, 2) AS price,
        ROUND(s.quantity * p.price, 0) AS amount
    FROM sales s
    JOIN products p ON p.product_id = s.product_id
    JOIN customers c ON c.customer_id  = s.customer_id
    ORDER BY sales_id    
)
SELECT
    age_category,
    SUM(quantity)  AS total_quantity,
    SUM(amount) AS total_amount,
    ROUND(SUM(amount) / SUM(quantity), 1) AS average_purchase_price
FROM customers_age_categories
GROUP BY age_category;
-- age_category|total_quantity|total_amount|average_purchase_price|
-- ------------+--------------+------------+----------------------+
-- 26-40       |      16214944|  9058940383|                 558.7|
-- 40+         |      25803235| 12453312585|                 482.6|
-- 16-25       |       7489438|  5204330449|                 694.9|


-- Monthly total quantity, total amount,
-- and average purchase price for each age category.
WITH sales_summary AS (
    SELECT
        TO_CHAR(sale_date, 'YYYY-MM') AS month,
        CASE 
            WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
            WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
            WHEN c.age > 40 THEN '40+'
        END AS age_category,
        s.quantity,
        ROUND(p.price, 2)  AS price,
        ROUND(s.quantity * p.price, 0) AS amount
    FROM sales s
    JOIN products p ON p.product_id = s.product_id
    JOIN customers c ON c.customer_id  = s.customer_id
    ORDER BY sales_id
)
SELECT
    month,
    age_category,
    SUM(quantity)  AS total_quantity,
    SUM(amount) AS total_amount,
    ROUND(SUM(amount) / SUM(quantity), 1) AS average_purchase_price
FROM sales_summary
GROUP BY
    month, age_category
ORDER BY
    month, age_category;
-- month  |age_category|total_quantity|total_amount|average_purchase_price|
-- -------+------------+--------------+------------+----------------------+
-- 1992-09|16-25       |        749931|   490173243|                 653.6|
-- 1992-09|26-40       |       1636127|   925164126|                 565.5|
-- 1992-09|40+         |       2531371|  1203592549|                 475.5|
-- 1992-10|16-25       |       2328082|  1664622872|                 715.0|
-- 1992-10|26-40       |       5005232|  2860325409|                 571.5|
-- 1992-10|40+         |       8036374|  3833164069|                 477.0|
-- 1992-11|16-25       |       2281104|  1556649340|                 682.4|
-- 1992-11|26-40       |       4885730|  2708810388|                 554.4|
-- 1992-11|40+         |       7776942|  3765892798|                 484.2|
-- 1992-12|16-25       |       2130321|  1492884994|                 700.8|
-- 1992-12|26-40       |       4687855|  2564640460|                 547.1|
-- 1992-12|40+         |       7458548|  3650663169|                 489.5|
