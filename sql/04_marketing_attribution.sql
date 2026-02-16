-- =====================================================
-- MARKETING ATTRIBUTION ANALYSIS
-- Purpose: Identify which channels drive conversions and revenue
-- Business Question: Where should we allocate marketing budget?
-- =====================================================

-- -------------------------------------------------------
-- QUERY 1: Traffic Source Performance Overview
-- -------------------------------------------------------
-- Analyze all traffic sources and their conversion metrics

with traffic_performance AS (
    SELECT
        COALESCE(traffic_source.source, '(direct)') AS source,
        COALESCE(traffic_source.medium, '(none)') AS medium,
        COUNT(DISTINCT user_pseudo_id) AS total_users,
        COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_pseudo_id END) AS converting_users,
        COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN CONCAT(user_pseudo_id, event_timestamp) END) AS total_purchases,
        ROUND(SUM(CASE WHEN event_name = 'purchase' THEN ecommerce.purchase_revenue END), 2) AS total_revenue
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    GROUP BY source, medium
)

SELECT
    source,
    medium,
    total_users,
    converting_users,
    total_purchases,
    total_revenue,

    --conversion rate
    ROUND(converting_users * 100.0 / total_users, 2) AS conversion_rate_pct,

    --revenue per user
    ROUND(total_revenue / total_users, 2) AS revenue_per_user, 

    --average order value
    ROUND(total_revenue / NULLIF(total_purchases, 0), 2) AS avg_order_value,

    -- percentage of total revenue
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER(), 2) AS pct_of_total_revenue
FROM traffic_performance
WHERE total_users >= 10
ORDER BY total_revenue DESC
LIMIT 25;

-- -------------------------------------------------------
-- QUERY 2: Channel Performance by Conversion Funnel
-- -------------------------------------------------------
-- Analyze how different channels move users thru the funnel

WITH channel_funnel AS (
    SELECT
        COALESCE(traffic_source.source, '(direct)') AS source,
        COUNT(DISTINCT user_pseudo_id) AS total_users,
        COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN user_pseudo_id END) AS users_viewed_product,
        COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_pseudo_id END) AS users_added_to_cart,
        COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN user_pseudo_id END) AS users_began_checkout,
        COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_pseudo_id END) AS users_purchased
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    GROUP BY source
)

SELECT
    source,
    total_users,
    users_viewed_product,
    users_added_to_cart,
    users_began_checkout,
    users_purchased,

    -- funnel conversion rates
    ROUND(users_viewed_product * 100.0 / total_users, 2) AS view_rate_pct,
    ROUND(users_added_to_cart * 100.0 / NULLIF(users_viewed_product, 0), 2) AS add_to_cart_rate_pct,
    ROUND(users_began_checkout * 100.0 / NULLIF(users_added_to_cart, 0), 2) AS checkout_rate_pct,
    ROUND(users_purchased * 100.0 / NULLIF(users_began_checkout, 0), 2) AS purchase_rate_pct,

    -- overall conversion
    ROUND(users_purchased * 100.0 / total_users, 2) AS overall_conversion_pct
FROM channel_funnel
WHERE total_users >= 50
ORDER BY users_purchased DESC
LIMIT 20;

-- -------------------------------------------------------
-- QUERY 3: First-Touch vs Last-Touch Attribution
-- -------------------------------------------------------
-- compare which channels initiate sessions vs close sales

WITH user_first_touch AS (
  SELECT DISTINCT
    user_pseudo_id,
    FIRST_VALUE(COALESCE(traffic_source.source, '(direct)')) 
      OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS first_touch_source
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
),

user_purchases AS (
  SELECT 
    user_pseudo_id,
    COALESCE(traffic_source.source, '(direct)') AS last_touch_source,
    ecommerce.purchase_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase'
    AND ecommerce.purchase_revenue IS NOT NULL
),

first_touch_attribution AS (
  SELECT 
    ft.first_touch_source AS channel,
    COUNT(DISTINCT up.user_pseudo_id) AS conversions,
    ROUND(SUM(up.purchase_revenue), 2) AS revenue
  FROM user_first_touch ft
  INNER JOIN user_purchases up
    ON ft.user_pseudo_id = up.user_pseudo_id
  GROUP BY ft.first_touch_source
),

last_touch_attribution AS (
  SELECT 
    last_touch_source AS channel,
    COUNT(DISTINCT user_pseudo_id) AS conversions,
    ROUND(SUM(purchase_revenue), 2) AS revenue
  FROM user_purchases
  GROUP BY last_touch_source
)

SELECT 
  COALESCE(ft.channel, lt.channel) AS channel,
  COALESCE(ft.conversions, 0) AS first_touch_conversions,
  COALESCE(ft.revenue, 0) AS first_touch_revenue,
  COALESCE(lt.conversions, 0) AS last_touch_conversions,
  COALESCE(lt.revenue, 0) AS last_touch_revenue,
  
  -- Attribution difference
  COALESCE(ft.revenue, 0) - COALESCE(lt.revenue, 0) AS attribution_difference
FROM first_touch_attribution ft
FULL OUTER JOIN last_touch_attribution lt
  ON ft.channel = lt.channel
ORDER BY first_touch_revenue DESC;

-- -------------------------------------------------------
-- QUERY 4: customer acquisition costs (CAC)
-- -------------------------------------------------------
-- calculate efficiency metrics by channel to inform CAC decisions

WITH channel_efficiency AS (
    SELECT
        COALESCE(traffic_source.source, '(direct)') AS source,
        COALESCE(traffic_source.medium, '(none)') AS medium,

        -- volume metrics
        COUNT(DISTINCT user_pseudo_id) AS total_users,
        COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_pseudo_id END) AS paying_customers,

        -- revenue metrics
        ROUND(SUM(CASE WHEN event_name = 'purchase' THEN ecommerce.purchase_revenue END), 2) AS total_revenue,
        ROUND(AVG(CASE WHEN event_name = 'purchase' THEN ecommerce.purchase_revenue END), 2) AS avg_order_value,

        -- customer lifetime value proxy
        ROUND(SUM(CASE WHEN event_name = 'purchase' THEN ecommerce.purchase_revenue END) / NULLIF(COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_pseudo_id END), 0), 2) AS revenue_per_customer
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    GROUP BY source, medium
 )

SELECT
    source,
    medium,
    total_users,
    paying_customers,
    total_revenue,
    avg_order_value,
    revenue_per_customer,

    -- conversion rate
    ROUND(paying_customers * 100.0 / total_users, 2) AS conversion_rate_pct,

    -- cac allowable 
    ROUND(revenue_per_customer / 3, 2) AS max_cac_for_3x_roi,

    -- quality score (higher is better)
    ROUND((revenue_per_customer * paying_customers) / total_users, 2) AS channel_quality_score
FROM channel_efficiency
WHERE total_users >= 20
ORDER BY channel_quality_score DESC
LIMIT 20;

-- -------------------------------------------------------
-- QUERY 5: campaign performance 
-- -------------------------------------------------------
-- analyze specific campaign effectiveness

SELECT
    COALESCE(traffic_source.source, '(direct)') AS source,
    COALESCE(traffic_source.medium, '(none)') AS medium,
    COALESCE((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'campaign'), '(not set)') AS campaign,
    COUNT(DISTINCT user_pseudo_id) AS users,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_pseudo_id END) AS conversions,
    ROUND(SUM(CASE WHEN event_name = 'purchase' THEN ecommerce.purchase_revenue END), 2) AS revenue,
    ROUND(COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_pseudo_id END) * 100.0 / COUNT(DISTINCT user_pseudo_id), 2) AS conversion_rate_pct
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY source, medium, campaign
HAVING users >= 10
ORDER BY revenue DESC
LIMIT 25;