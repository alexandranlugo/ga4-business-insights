-- =====================================================
-- COHORT RETENTION ANALYSIS
-- Purpose: Analyze customer retention patterns by first purchase cohort
-- Business Question: Which cohorts have the highest lifetime value and retention?
-- =====================================================

-- -------------------------------------------------------
-- step 1: identify first purchase date for each customer
-- -------------------------------------------------------
-- this CTE finds when each customer made their first purchase to assign them to a cohort

WITH first_purchases AS (
  SELECT 
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_purchase_date,
    DATE_TRUNC(MIN(PARSE_DATE('%Y%m%d', event_date)), MONTH) AS cohort_month
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase'
  GROUP BY user_pseudo_id
),

-- -------------------------------------------------------
-- STEP 2: Get All Subsequent Purchases with Cohort Assignment
-- -------------------------------------------------------
-- Join each purchase back to the customer's cohort
-- Calculate months since first purchase

all_purchases AS (
  SELECT 
    e.user_pseudo_id,
    PARSE_DATE('%Y%m%d', e.event_date) AS purchase_date,
    fp.first_purchase_date,
    fp.cohort_month,
    DATE_DIFF(
      PARSE_DATE('%Y%m%d', e.event_date), 
      fp.first_purchase_date, 
      MONTH
    ) AS months_since_first_purchase,
    e.ecommerce.purchase_revenue AS revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
  INNER JOIN first_purchases fp
    ON e.user_pseudo_id = fp.user_pseudo_id
  WHERE e.event_name = 'purchase'
    AND e.ecommerce.purchase_revenue IS NOT NULL  -- Filter out null revenue
),

-- -------------------------------------------------------
-- STEP 3: Calculate Cohort Retention Metrics
-- -------------------------------------------------------
-- For each cohort, count how many customers made purchases
-- in months 0 (acquisition), 1, 3, and 6

cohort_retention AS (
  SELECT 
    cohort_month,
    COUNT(DISTINCT user_pseudo_id) AS cohort_size,
    
    -- Month 0: Acquisition month (all customers by definition)
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 0 
          THEN user_pseudo_id END) AS month_0_customers,
    
    -- Month 1: Customers who purchased again within 1 month
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 1 
          THEN user_pseudo_id END) AS month_1_customers,
    
    -- Month 2: Customers who purchased within 2 months
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 2 
          THEN user_pseudo_id END) AS month_2_customers,
    
    -- Month 3: Customers who purchased within 3 months
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 3 
          THEN user_pseudo_id END) AS month_3_customers,
    
    -- Total revenue by cohort
    SUM(revenue) AS total_cohort_revenue,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_transaction
    
  FROM all_purchases
  GROUP BY cohort_month
),

-- -------------------------------------------------------
-- STEP 4: Calculate Retention Rates as Percentages
-- -------------------------------------------------------

retention_rates AS (
  SELECT 
    cohort_month,
    cohort_size,
    month_0_customers,
    month_1_customers,
    month_2_customers,
    month_3_customers,
    
    -- Retention Rate = (Customers who returned / Total cohort size) * 100
    ROUND(month_1_customers * 100.0 / cohort_size, 2) AS month_1_retention_pct,
    ROUND(month_2_customers * 100.0 / cohort_size, 2) AS month_2_retention_pct,
    ROUND(month_3_customers * 100.0 / cohort_size, 2) AS month_3_retention_pct,
    
    total_cohort_revenue,
    ROUND(total_cohort_revenue / cohort_size, 2) AS revenue_per_customer,
    avg_revenue_per_transaction
    
  FROM cohort_retention
)

-- -------------------------------------------------------
-- FINAL OUTPUT: Cohort Retention Summary
-- -------------------------------------------------------

SELECT 
  cohort_month,
  cohort_size,
  month_1_retention_pct,
  month_2_retention_pct,
  month_3_retention_pct,
  total_cohort_revenue,
  revenue_per_customer,
  avg_revenue_per_transaction
FROM retention_rates
ORDER BY cohort_month;

-- -------------------------------------------------------
-- BONUS QUERY: Retention Curve Analysis
-- -------------------------------------------------------
-- show retention drop-off across all months for pattern identification

WITH first_purchases AS (
  SELECT 
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_purchase_date,
    DATE_TRUNC(MIN(PARSE_DATE('%Y%m%d', event_date)), MONTH) AS cohort_month
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase'
  GROUP BY user_pseudo_id
),

monthly_activity AS (
  SELECT 
    fp.cohort_month,
    fp.user_pseudo_id,
    DATE_DIFF(
      PARSE_DATE('%Y%m%d', e.event_date), 
      fp.first_purchase_date, 
      MONTH
    ) AS months_since_first_purchase
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e
  INNER JOIN first_purchases fp
    ON e.user_pseudo_id = fp.user_pseudo_id
  WHERE e.event_name = 'purchase'
    AND e.ecommerce.purchase_revenue IS NOT NULL
)

SELECT 
  cohort_month,
  months_since_first_purchase,
  COUNT(DISTINCT user_pseudo_id) AS active_customers,
  
  -- Calculate retention rate relative to cohort size
  ROUND(
    COUNT(DISTINCT user_pseudo_id) * 100.0 / 
    FIRST_VALUE(COUNT(DISTINCT user_pseudo_id)) 
      OVER (PARTITION BY cohort_month ORDER BY months_since_first_purchase),
    2
  ) AS retention_rate_pct
  
FROM monthly_activity
WHERE months_since_first_purchase BETWEEN 0 AND 3
GROUP BY cohort_month, months_since_first_purchase
ORDER BY cohort_month, months_since_first_purchase;