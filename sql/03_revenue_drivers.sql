-- =====================================================
-- REVENUE DRIVERS ANALYSIS
-- Purpose: Identify which products, categories, and customer segments drive revenue
-- Business Question: Where should we focus marketing and product investment?
-- =====================================================

-- -------------------------------------------------------
-- QUERY 1: Product Category Revenue Performance
-- -------------------------------------------------------
-- Identify top revenue-generating categories and their performance metrics

with category_performance AS (
    SELECT
        item.item_category AS category,
        COUNT(DISTINCT e.user_pseudo_id) AS customers,
        COUNT(DISTINCT CONCAT(e.user_pseudo_id, e.event_timestamp)) AS transactions,
        SUM(item.quantity) AS total_items_sold,
        ROUND(SUM(item.price_in_usd * item.quantity), 2) AS total_revenue,
        ROUND(AVG(item.price_in_usd), 2) AS avg_item_price,
        ROUND(SUM(item.price_in_usd * item.quantity) / COUNT(DISTINCT CONCAT(e.user_pseudo_id, e.event_timestamp)), 2) AS avg_order_value
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e, UNNEST(items) AS item
    WHERE e.event_name = 'purchase' AND item.item_category IS NOT NULL AND item.price_in_usd IS NOT NULL
    GROUP BY category
)

SELECT
    category,
    customers,
    transactions,
    total_items_sold,
    total_revenue,
    avg_item_price,
    avg_order_value,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER(), 2) AS pct_of_total_revenue,
    ROUND(transactions * 1.0 / customers, 2) AS purchases_per_customer
FROM category_performance
ORDER BY total_revenue DESC
LIMIT 20;

-- -------------------------------------------------------
-- QUERY 2: Top Individual Products by Revenue
-- -------------------------------------------------------
-- Identify star products that drive the most revenue

with product_performance AS (
    SELECT
        item.item_name AS product_name,
        item.item_category AS category,
        COUNT(DISTINCT e.user_pseudo_id) as unique_buyers,
        SUM(item.quantity) AS total_units_sold,
        ROUND(SUM(item.price_in_usd * item.quantity), 2) AS total_revenue,
        ROUND(AVG(item.price_in_usd), 2) AS avg_price,
        COUNT(DISTINCT CONCAT(e.user_pseudo_id, e.event_timestamp)) AS times_purchased
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e, UNNEST(items) AS item
    WHERE e.event_name = 'purchase' AND item.item_name IS NOT NULL AND item.price_in_usd IS NOT NULL
    GROUP BY product_name, category
)

SELECT
    product_name,
    category,
    unique_buyers,
    total_units_sold,
    total_revenue,
    avg_price,
    times_purchased,
    ROUND(total_revenue / total_units_sold, 2) AS revenue_per_unit
FROM product_performance
ORDER BY total_revenue DESC
LIMIT 25;

-- -------------------------------------------------------
-- QUERY 3: Customer Value Segmentation
-- -------------------------------------------------------
-- Segment customers by total spend to identify high-value segments

WITH customer_spending AS (
    SELECT 
        e.user_pseudo_id,
        COUNT(DISTINCT CONCAT(e.user_pseudo_id, e.event_timestamp)) AS total_purchases,
        SUM(e.ecommerce.purchase_revenue) AS total_revenue,
        ROUND(AVG(e.ecommerce.purchase_revenue), 2) AS avg_order_value,
        MIN(PARSE_DATE('%Y%m%d', e.event_date)) AS first_purchase_date,
        MAX(PARSE_DATE('%Y%m%d', e.event_date)) AS last_purchase_date,
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
    WHERE e.event_name = 'purchase' AND e.ecommerce.purchase_revenue IS NOT NULL
    GROUP BY user_pseudo_id
),

customer_segments AS (
    SELECT
        user_pseudo_id,
        total_purchases,
        total_revenue,
        avg_order_value,
        first_purchase_date,
        last_purchase_date,
        CASE
            WHEN total_revenue >= 200 THEN 'VIP ($200+)'
            WHEN total_revenue >= 100 THEN 'High Value ($100-$199)'
            WHEN total_revenue >= 50 THEN 'Medium Value ($50-$99)'
            ELSE 'Low Value (<$50)'
        END AS value_segment,
        CASE   
            WHEN total_purchases >= 3 THEN 'Repeat Buyer (3+)'
            WHEN total_purchases >= 2 THEN 'Returning Customer (2)'
            ELSE 'One-Time Buyer (1)'
        END AS purchase_frequency_segment
    FROM customer_spending
)

SELECT
    value_segment,
    purchase_frequency_segment,
    COUNT(DISTINCT user_pseudo_id) AS customer_count,
    ROUND(AVG(total_revenue), 2) AS avg_customer_ltv,
    ROUND(SUM(total_revenue), 2) AS total_segment_revenue,
    ROUND(AVG(total_purchases), 2) AS total_segment_revenue,
    ROUND(SUM(total_revenue) * 100.0 / SUM(SUM(total_revenue)) OVER (), 2) AS pct_of_total_revenue
FROM customer_segments
GROUP BY value_segment, purchase_frequency_segment
ORDER BY total_segment_revenue DESC;

-- -------------------------------------------------------
-- QUERY 4: Category Cross-Sell Analysis
-- -------------------------------------------------------
-- Identify which categories are frequently purchased together

WITH customer_categories AS (
    SELECT
        e.user_pseudo_id,
        item.item_category
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e, UNNEST(items) AS item
    WHERE e.event_name = 'purchase' AND item.item_category IS NOT NULL
    GROUP BY user_pseudo_id, item_category
),

category_pairs AS (
    SELECT
        c1.item_category AS category_1,
        c2.item_category AS category_2,
        COUNT(DISTINCT c1.user_pseudo_id) AS customers_who_bought_both
    FROM customer_categories c1 
    INNER JOIN customer_categories c2 ON c1.user_pseudo_id = c2.user_pseudo_id AND c1.item_category < c2.item_category
    GROUP BY category_1, category_2
)

SELECT
    category_1,
    category_2,
    customers_who_bought_both,
    RANK() OVER (ORDER BY customers_who_bought_both DESC) AS cross_sell_rank
FROM category_pairs
WHERE customers_who_bought_both >= 5
ORDER BY customers_who_bought_both DESC
LIMIT 20;

-- -------------------------------------------------------
-- QUERY 5: Revenue Trends Over Time
-- -------------------------------------------------------
-- analyze revenue patterns by week to identify trends

WITH weekly_data AS (
  SELECT 
    DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS week_start,
    COUNT(DISTINCT user_pseudo_id) AS unique_customers,
    COUNT(DISTINCT CONCAT(user_pseudo_id, event_timestamp)) AS total_transactions,
    ROUND(SUM(ecommerce.purchase_revenue), 2) AS total_revenue,
    ROUND(AVG(ecommerce.purchase_revenue), 2) AS avg_order_value
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase'
    AND ecommerce.purchase_revenue IS NOT NULL
  GROUP BY week_start
)

SELECT 
  week_start,
  unique_customers,
  total_transactions,
  total_revenue,
  avg_order_value,
  ROUND(total_revenue / unique_customers, 2) AS revenue_per_customer,
  
  -- Week-over-week growth
  ROUND(
    (total_revenue - LAG(total_revenue) OVER (ORDER BY week_start)) * 100.0 / 
    NULLIF(LAG(total_revenue) OVER (ORDER BY week_start), 0), 
    2
  ) AS wow_revenue_growth_pct
FROM weekly_data
ORDER BY week_start;