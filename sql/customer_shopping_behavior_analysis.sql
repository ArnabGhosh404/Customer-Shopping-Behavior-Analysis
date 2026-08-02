-- ===========================================================
-- CUSTOMER SHOPPING BEHAVIOR ANALYSIS
-- TOP 15 BUSINESS QUESTIONS
-- ===========================================================

-- ===========================================================
-- 📊 REVENUE ANALYSIS
-- ===========================================================

-- Q1. Which product categories generate the highest revenue?
-- Business Purpose: Identify the primary revenue-generating product categories.

SELECT category,
       SUM(purchase_amount) AS revenue_by_category
FROM customer_analysis
GROUP BY category;

/*
Business Insight:
- Identifies the categories contributing the highest revenue.
- Helps prioritize inventory, marketing, and strategic investments.
*/


-- ===========================================================
-- 💰 CUSTOMER SPENDING ANALYSIS
-- ===========================================================

-- Q2. Do subscribed customers spend more?
-- Compare average purchase amount and total revenue between subscribers and non-subscribers.
-- Business Purpose: Evaluate the effectiveness of the subscription program.

SELECT
    AVG(purchase_amount) AS avg_purchase_amount,
    SUM(purchase_amount) AS total_revenue,
    subscription_status
FROM customer_analysis
GROUP BY subscription_status;

/*
Business Insight:
- Compares purchasing behavior between subscribers and non-subscribers.
- Helps evaluate whether the subscription program increases customer value.
*/


-- Q3. Which payment method has the highest average purchase amount?
-- Business Purpose: Understand customer payment preferences.

SELECT payment_method,
       AVG(purchase_amount) AS avg_purchase_amount
FROM customer_analysis
GROUP BY payment_method
ORDER BY avg_purchase_amount DESC
LIMIT 1;

/*
Business Insight:
- Identifies the payment method associated with higher spending.
- Helps optimize payment incentives and promotional strategies.
*/


-- ===========================================================
-- ⭐ CUSTOMER REVIEWS & PRODUCT PERFORMANCE
-- ===========================================================

-- Q4. Which are the top 5 products with the highest average review rating?
-- Business Purpose: Identify highly rated products for promotions.

SELECT item_purchased,
       ROUND(AVG(review_rating),2) AS avg_review_rating
FROM customer_analysis
GROUP BY item_purchased
ORDER BY avg_review_rating DESC
LIMIT 5;

/*
Business Insight:
- Highlights products with excellent customer satisfaction.
- Suitable candidates for featured listings and promotional campaigns.
*/


-- Q5. What are the top 3 most preferred products within each category?
-- Business Purpose: Discover category-wise customer preferences.

WITH ranked_product AS (
SELECT item_purchased,
       category,
       COUNT(item_purchased) AS total_purchases,
       DENSE_RANK() OVER(PARTITION BY category ORDER BY COUNT(item_purchased) DESC) AS rank_num
FROM customer_analysis
GROUP BY category, item_purchased
)

SELECT *
FROM ranked_product
WHERE rank_num <= 3
ORDER BY category, rank_num;

/*
Business Insight:
- Identifies the most popular products within every category.
- Supports product assortment and inventory planning.
*/


-- Q6. Which products have below-average ratings but above-average sales?
-- Business Purpose: Detect products that sell well despite lower customer satisfaction.

WITH product_summary AS (
SELECT item_purchased,
       ROUND(AVG(review_rating),2) AS avg_review_rating,
       SUM(purchase_amount) AS total_sales
FROM customer_analysis
GROUP BY item_purchased
)

SELECT *
FROM product_summary
WHERE avg_review_rating <
(
SELECT AVG(review_rating)
FROM customer_analysis
)
AND total_sales >
(
SELECT AVG(total_sales)
FROM product_summary
);

/*
Business Insight:
- Reveals products generating strong sales despite weaker reviews.
- Indicates products requiring quality improvements without sacrificing revenue.
*/


-- ===========================================================
-- 🎯 DISCOUNT ANALYSIS
-- ===========================================================

-- Q7. Which 5 products have the highest percentage of purchases with discounts applied?
-- Business Purpose: Identify products heavily dependent on discounts.

SELECT item_purchased,
       SUM(CASE WHEN discount_applied='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*) AS discount_percentage
FROM customer_analysis
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;

/*
Business Insight:
- Identifies products relying heavily on promotional discounts.
- Supports pricing and profitability analysis.
*/


-- ===========================================================
-- 👥 CUSTOMER SEGMENTATION
-- ===========================================================

-- Q8. Which customer segment generates the highest revenue?
-- Business Purpose: Identify the most valuable customer segment.

SELECT
SUM(purchase_amount) AS revenue,
CASE
WHEN previous_purchases = 1 THEN 'New'
WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
ELSE 'Loyal'
END AS customer_segment
FROM customer_analysis
GROUP BY customer_segment
ORDER BY revenue DESC;

/*
Business Insight:
- Determines which customer segment contributes the most revenue.
- Helps prioritize retention and loyalty initiatives.
*/


-- ===========================================================
-- 🛍️ PURCHASE BEHAVIOR
-- ===========================================================

-- Q9. Which season generates the highest total sales?
-- Business Purpose: Optimize seasonal inventory planning.

SELECT season,
       SUM(purchase_amount) AS total_sales
FROM customer_analysis
GROUP BY season
ORDER BY total_sales DESC;

/*
Business Insight:
- Identifies peak sales seasons.
- Supports seasonal inventory and marketing decisions.
*/


-- Q10. Which color is purchased the most within each category?
-- Business Purpose: Understand customer color preferences.

WITH frequent_color AS(
SELECT category,
       color,
       COUNT(color),
       DENSE_RANK() OVER(PARTITION BY category ORDER BY COUNT(color) DESC) AS rank_num
FROM customer_analysis
GROUP BY category,color
ORDER BY COUNT(color) DESC
)

SELECT *
FROM frequent_color
WHERE rank_num=1;

/*
Business Insight:
- Reveals the most preferred colors across product categories.
- Helps optimize inventory and merchandising decisions.
*/


-- ===========================================================
-- 📈 ADVANCED SQL ANALYSIS
-- ===========================================================

-- Q11. Rank the top 5 customers based on total amount spent.
-- Business Purpose: Identify VIP customers.

WITH ranked_customers AS (
SELECT customer_id,
       SUM(purchase_amount) AS total_amount,
       ROW_NUMBER() OVER(ORDER BY SUM(purchase_amount) DESC) AS rank_num
FROM customer_analysis
GROUP BY customer_id
)

SELECT *
FROM ranked_customers
WHERE rank_num<=5;

/*
Business Insight:
- Identifies the highest-value customers.
- Supports VIP rewards and personalized engagement strategies.
*/


-- Q12. Find customers whose total spending is above the overall average customer spending.
-- Business Purpose: Identify high-value customers.

WITH customer_spending AS(
SELECT customer_id,
       SUM(purchase_amount) AS total_amount
FROM customer_analysis
GROUP BY customer_id
)

SELECT *
FROM customer_spending
WHERE total_amount>
(
SELECT AVG(total_amount)
FROM customer_spending
);

/*
Business Insight:
- Highlights customers spending above the average customer.
- Useful for premium marketing and customer retention.
*/

-- Q13. Calculate each product category's percentage contribution to total revenue.
-- Business Purpose: Measure each category's business importance.

WITH category_revenue AS
(
SELECT category,
       SUM(purchase_amount) AS revenue
FROM customer_analysis
GROUP BY category
)

SELECT category,
ROUND(((revenue/SUM(revenue) OVER())*100),2) AS percentage_contribution
FROM category_revenue;

/*
Business Insight:
- Shows how much each category contributes to overall revenue.
- Helps prioritize strategic investment and inventory allocation.
*/


-- Q14. Identify the top-performing product in each age group based on total revenue.
-- Business Purpose: Understand age-specific buying preferences.

WITH top_product AS
(
SELECT age_group,
       item_purchased,
       SUM(purchase_amount) AS revenue,
       DENSE_RANK() OVER(PARTITION BY age_group ORDER BY SUM(purchase_amount) DESC) AS rank_num
FROM customer_analysis
GROUP BY age_group,item_purchased
ORDER BY age_group,revenue DESC
)

SELECT *
FROM top_product
WHERE rank_num=1;

/*
Business Insight:
- Identifies the best-selling product for every age group.
- Enables targeted marketing and personalized recommendations.
*/


-- Q15. Create customer spending tiers (Bronze, Silver, Gold, Platinum) based on total purchase amount.
-- Business Purpose: Segment customers for loyalty programs.

WITH customer_spending AS (
SELECT customer_id,
       SUM(purchase_amount) AS total_amount
FROM customer_analysis
GROUP BY customer_id
)

SELECT customer_id,
       total_amount,
CASE
WHEN total_amount<100 THEN 'Bronze'
WHEN total_amount BETWEEN 100 AND 199 THEN 'Silver'
WHEN total_amount BETWEEN 200 AND 299 THEN 'Gold'
ELSE 'Platinum'
END AS spending_tier
FROM customer_spending
ORDER BY customer_id,total_amount DESC;

/*
Business Insight:
- Classifies customers into spending tiers based on lifetime purchases.
- Supports personalized loyalty programs and targeted promotions.
*/


