use walmart;

-- Task 1 : 

SELECT Branch, 
       DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS month,
       SUM(Total) AS total_sales
FROM sales
GROUP BY Branch, month
ORDER BY Branch, month;

-- Task 2 :

SELECT Branch, 
       `Product line`, 
       SUM(`cogs` - `gross income`) AS profit
FROM sales
GROUP BY Branch, `Product line`
ORDER BY Branch, profit DESC;

-- Task 3 :

SELECT `Customer ID`,
       SUM(Total) AS total_spending,
       CASE
           WHEN SUM(Total) >= 22000 THEN 'High'
           WHEN SUM(Total) >= 20000 THEN 'Medium'
           ELSE 'Low'
       END AS spender_tier
FROM sales
GROUP BY `Customer ID`;

-- Task 4 :

WITH product_stats AS (
  SELECT 
    `Product line`,
    AVG(Total) AS avg_total,
    STDDEV(Total) AS std_total
  FROM sales
  GROUP BY `Product line`
)
SELECT 
  s.`Invoice ID`,
  s.`Product line`,
  s.Total,
  (s.Total - ps.avg_total) / ps.std_total AS z_score,
  'Anomaly' AS status
FROM sales s
JOIN product_stats ps ON s.`Product line` = ps.`Product line`
WHERE ABS((s.Total - ps.avg_total) / ps.std_total) > 2; 

-- Task 5 :

WITH payment_ranking AS (
  SELECT 
    City,
    Payment,
    COUNT(*) AS transaction_count,
    RANK() OVER (PARTITION BY City ORDER BY COUNT(*) DESC) AS cityrank
  FROM sales
  GROUP BY City, Payment
)
SELECT 
  City,
  Payment AS most_popular_payment,
  transaction_count
FROM payment_ranking
WHERE cityrank = 1;

-- Task 6 :

SELECT 
    DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS month,
    Gender,
    SUM(Total) AS total_sales
FROM sales
GROUP BY 
    DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m'),
    Gender
ORDER BY 
    month, 
    Gender;

-- Task 7 :

WITH ranked_products AS (
  SELECT 
    `Customer type`,
    `Product line`,
    SUM(Total) AS total_sales,
    RANK() OVER (PARTITION BY `Customer type` ORDER BY SUM(Total) DESC) AS productrank
  FROM sales
  GROUP BY `Customer type`, `Product line`
)
SELECT 
  `Customer type`,
  `Product line` AS best_product_line,
  total_sales
FROM ranked_products
WHERE productrank = 1;

-- Task 8 :

WITH customer_purchases AS (
  SELECT 
    `Customer ID`,
    STR_TO_DATE(Date, '%d-%m-%Y') AS purchase_date,
    LAG(STR_TO_DATE(Date, '%d-%m-%Y')) OVER (
      PARTITION BY `Customer ID` 
      ORDER BY STR_TO_DATE(Date, '%d-%m-%Y')
    ) AS previous_purchase_date
  FROM sales
)

SELECT DISTINCT
  `Customer ID`,
  'Repeat Customer' AS customer_status
FROM customer_purchases
WHERE 
  previous_purchase_date IS NOT NULL
  AND DATEDIFF(purchase_date, previous_purchase_date) <= 30
ORDER BY `Customer ID`;

-- Task 9 :

SELECT 
    `Customer ID`,
    SUM(Total) AS total_revenue
FROM sales
GROUP BY `Customer ID`
ORDER BY total_revenue DESC
LIMIT 5;

-- Task 10 :

SELECT 
    DAYNAME(STR_TO_DATE(Date, '%d-%m-%Y')) AS day_of_week,
    SUM(Total) AS total_sales,
    COUNT(*) AS transaction_count,
    ROUND(SUM(Total)/COUNT(*), 2) AS avg_sale_per_transaction
FROM sales
GROUP BY day_of_week
ORDER BY total_sales DESC;
