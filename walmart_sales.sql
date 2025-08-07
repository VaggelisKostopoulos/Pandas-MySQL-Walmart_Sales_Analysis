SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

SELECT payment_method, AVG(unit_price) FROM walmart GROUP BY Payment_method;

SELECT payment_method, COUNT(*) AS 'Times seen' FROM walmart GROUP BY payment_method;

SELECT Branch, COUNT(Branch) FROM walmart GROUP BY Branch;

SELECT quantity, Branch, category FROM walmart ORDER BY quantity DESC;

-- Queries 

-- 1. For each payment method find the number of transaction and the number of quantity sold

SELECT payment_method, COUNT(*) AS 'Times used' ,SUM(quantity) AS 'Quantity sold' 
FROM walmart 
GROUP BY payment_method;

-- 2. Identify the highest-rated category in each branch

WITH ranked_categories AS (
    SELECT 
        Branch, 
        category, 
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) AS ranks
    FROM walmart
    GROUP BY Branch, category
)
SELECT *
FROM ranked_categories
WHERE ranks = 1;


-- 3. Identify the busiest day for each branch based on the number of transactions

SELECT * FROM walmart;

WITH ranked_dates AS (
SELECT Branch, date, COUNT(*) as transactions, RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS ranks
FROM walmart
GROUP BY Branch, date
)
SELECT *
FROM ranked_dates
WHERE ranks =1;

-- 4. Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT payment_method, SUM(quantity) as 'quantity sold' FROM walmart GROUP BY payment_method;

-- 5. Determine the average, minimum and maximum rating of category for each city. List the city, average_rating, min_rating and max_rating.

SELECT city, category, AVG(rating) as average_rating, MIN(rating) as min_rating, MAX(rating) as max_rating 
FROM walmart 
GROUP BY city, category;

-- 6. Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin). 

SELECT category, SUM(unit_price * quantity * profit_margin) as total_profit 
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- 7. Determine the most common payment method for each Branch, Display Branch and the preferred payment method.

SELECT Branch, payment_method, COUNT(payment_method) as total_transactions -- , RANK() OVER(PARTITION BY Branch ORDER BY COUNT(payment_method) DESC) as ranks
FROM walmart
GROUP BY Branch
ORDER BY Branch, total_transactions;

-- 8. Categorize sales into 3 groups MORNING, AFTERNOON, EVENING. Find out each of the shift and number of invoices

SELECT branch,time,
	CASE 
		WHEN (HOUR(time) ) < 12 THEN 'Morning'
        WHEN (HOUR(time) ) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END daytime,
    COUNT(*)
FROM walmart
GROUP BY Branch,daytime
ORDER BY Branch,COUNT(*) DESC;

-- 9. Identify 5 branch with the highest decrease ratio in revenue compared to last year (current year 2023)

-- revenue_decrease_ratio = last_revenue-current_revenue/last_revenue*100

WITH revenue2022 AS
(
SELECT Branch, SUM(Total_Amount) AS revenue22
FROM walmart
WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
GROUP BY Branch
),
revenue2023 AS
(
SELECT Branch, SUM(Total_Amount) AS revenue23
FROM walmart
WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
GROUP BY Branch
)
SELECT revenue2022.Branch, revenue2022.revenue22, revenue2023.revenue23, ROUND((revenue2022.revenue22 - revenue2023.revenue23)/revenue2022.revenue22 * 100) AS rdr
FROM revenue2022
JOIN revenue2023
	ON revenue2022.Branch = revenue2023.Branch 
ORDER BY rdr DESC
LIMIT 5;