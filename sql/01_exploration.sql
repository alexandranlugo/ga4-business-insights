-- =====================================================
-- GA4 E-COMMERCE DATA EXPLORATION
-- Purpose: Understand data structure, date ranges, and quality
-- =====================================================

-- query1: date range of available data
-- what: identify the start and end dates of the dataset
-- why: understand temporal coverage for analysis planning

SELECT
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS earliest_date,
    MAX(PARSE_DATE('%Y%m%d', event_date)) AS latest_date,
    DATE_DIFF(MAX(PARSE_DATE('%Y%m%d', event_date)),
            MIN(PARSE_DATE('%Y%m%d', event_date)), DAY) AS days_of_data
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;

-- query2: event types and volume
-- what: breakdown of all event types and their frequency
-- why: understand what user actions are tracked and data completeness

SELECT
    event_name,
    COUNT(*) AS event_count,
    COUNT(DISTINCT user_pseudo_id) AS unique_users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),2) AS pct_of_total_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY event_name
ORDER BY event_count DESC
LIMIT 20;

-- query 3: transaction metrics overview
-- what: key e-commerce metrics (transactions, revenue, items sold)
-- why: establish baseline business performance metrics

SELECT
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_pseudo_id END) AS purchasing_users,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN CONCAT(user_pseudo_id, event_timestamp) END) AS total_transactions,
    ROUND(SUM(CASE WHEN event_name = 'purchase' THEN ecommerce.purchase_revenue END), 2) AS total_revenue,
    ROUND(AVG(CASE WHEN event_name = 'purchase' THEN ecommerce.purchase_revenue END),2) AS avg_order_value,
    SUM(CASE WHEN event_name = 'purchase' THEN (SELECT SUM(quantity) FROM UNNEST(items)) END) AS total_items_sold
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

-- query 4: data quality check - Nulls and missing values
-- what: identify missing data in critical fields
-- why: understand data completeness for reliable analysis

SELECT
    'event_name' AS field_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN event_name IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(SUM(CASE WHEN event_name IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

UNION ALL


SELECT
    'user_pseudo_id',
    COUNT(*),
    SUM(CASE WHEN user_pseudo_id IS NULL THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN user_pseudo_id IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

UNION ALL

SELECT
    'ecommerce.purchase_revenue (for purchases)',
    COUNT(*),
    SUM(CASE WHEN ecommerce.purchase_revenue IS NULL THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN ecommerce.purchase_revenue IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name = 'purchase'

UNION ALL

SELECT
    'traffic_source.source',
    COUNT(*),
    SUM(CASE WHEN traffic_source.source IS NULL THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN traffic_source.source IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`


-- query 5: user activity distribution
-- what: distribution of events per user to identify power users vs casual browsers
-- why: understand user engagement patterns for segmentation

WITH user_activity AS (
    SELECT
        user_pseudo_id,
        COUNT(*) AS total_events,
        COUNT(DISTINCT event_date) AS days_active,
        SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase_count
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    GROUP BY user_pseudo_id
)

SELECT
    CASE
        WHEN total_events = 1 THEN '1 event (bounce)'
        WHEN total_events BETWEEN 2 AND 5 THEN '2-5 events'
        WHEN total_events BETWEEN 6 AND 10 THEN '6-10 events'
        WHEN total_events BETWEEN 11 AND 50 THEN '11-50 events'
        ELSE '50+ events (power users)'
    END AS user_engagement_tier,
    COUNT(*) AS user_count,
    ROUND(AVG(purchase_count),2) AS avg_purchases_per_user,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_users
FROM user_activity
GROUP BY user_engagement_tier
ORDER BY MIN(total_events);