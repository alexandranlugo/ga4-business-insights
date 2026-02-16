-- =====================================================
-- CHURN RISK ANALYSIS
-- Purpose: Identify at-risk customers using RFM scoring
-- Business Question: Which customers are likely to churn 
-- and how do we prioritize retention efforts?
-- =====================================================

-- -------------------------------------------------------
-- QUERY 1: RFM Base Metrics
-- -------------------------------------------------------
-- Calculate Recency, Frequency, Monetary value for each customer
-- Reference date: 2021-02-01 (30 days after dataset ends)

with rfm_base AS (
    SELECT
        user_pseudo_id,
        DATE_DIFF(
            DATE '2021-02-01',
            MAX(PARSE_DATE('%Y%m%d', event_date)),
            DAY
        ) AS recency_days,
        COUNT(DISTINCT CONCAT(user_pseudo_id, event_timestamp)) AS frequency,
        ROUND(SUM(ecommerce.purchase_revenue), 2) AS monetary_value,
        MAX(PARSE_DATE('%Y%m%d', event_date)) AS last_purchase_date,
        MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_purchase_date
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE event_name = 'purchase' AND ecommerce.purchase_revenue IS NOT NULL
    GROUP BY user_pseudo_id
),

-- -------------------------------------------------------
-- QUERY 2: RFM Scoring
-- -------------------------------------------------------
-- score each dimension 1-5 using NTILE window function
-- higher score = better customer behavior

rfm_scores AS (
    SELECT
        user_pseudo_id,
        recency_days,
        frequency,
        monetary_value,
        last_purchase_date,
        first_purchase_date,

        -- recency = lower days = better = higher score
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,

        -- frequency = higher purchase = better = higher score
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        
        -- monetary = higher spend = better = higher score
        NTILE(5) OVER (ORDER BY monetary_value ASC) as m_score

    FROM rfm_base
),

-- -------------------------------------------------------
-- QUERY 3: rfm composite score + risk segmentation
-- -------------------------------------------------------

rfm_segments AS (
    SELECT
        user_pseudo_id,
        recency_days,
        frequency,
        monetary_value,
        last_purchase_date,
        r_score,
        f_score,
        m_score,

        -- composite rfm score (weighted - recency matters most for churn)
        ROUND((r_score * 0.4) + (f_score * 0.3) + (m_score * 0.3), 2) AS rfm_score,

        -- risk tier based on recency and composite score
        CASE
            WHEN r_score >= 4 AND f_score >= 3 THEN 'Champion'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customer'
            WHEN r_score >= 3 AND f_score < 3 THEN 'Potential Loyalist'
            WHEN r_score = 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score = 2 AND f_score < 3 THEN 'Need Attention'
            WHEN r_score = 1 AND f_score >= 3 THEN "Can't Lose Them"
            ELSE 'Lost/Churned'
        END AS customer_segment,

        -- simple churn risk flag
        CASE
            WHEN recency_days >= 60 THEN 'High Risk'
            WHEN recency_days BETWEEN 30 AND 59 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS churn_risk_tier
    
    FROM rfm_scores
)

-- final output with all segments
SELECT
    user_pseudo_id,
    recency_days,
    frequency,
    monetary_value,
    last_purchase_date,
    r_score,
    f_score,
    m_score,
    rfm_score,
    customer_segment,
    churn_risk_tier,
FROM rfm_segments
ORDER BY rfm_score DESC;

-- -------------------------------------------------------
-- QUERY 4: Segment Summary for Visualization
-- -------------------------------------------------------
-- Aggregate view for charts and executive

with rfm_base AS (
    SELECT
        user_pseudo_id,
        DATE_DIFF(
            DATE '2021-02-01',
            MAX(PARSE_DATE('%Y%m%d', event_date)),
            DAY
        ) AS recency_days,
        COUNT(DISTINCT CONCAT(user_pseudo_id, event_timestamp)) AS frequency,
        ROUND(SUM(ecommerce.purchase_revenue), 2) AS monetary_value
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE event_name = 'purchase' AND ecommerce.purchase_revenue IS NOT NULL
    GROUP BY user_pseudo_id
),

rfm_scores AS (
    SELECT
        user_pseudo_id,
        recency_days,
        frequency,
        monetary_value,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_value ASC) as m_score
    FROM rfm_base
),

rfm_segments AS (
    SELECT
        user_pseudo_id,
        recency_days,
        frequency,
        monetary_value,
        ROUND((r_score * 0.4) + (f_score * 0.3) + (m_score * 0.3), 2) AS rfm_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 3 THEN 'Champion'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customer'
            WHEN r_score >= 3 AND f_score < 3 THEN 'Potential Loyalist'
            WHEN r_score = 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score = 2 AND f_score < 3 THEN 'Need Attention'
            WHEN r_score = 1 AND f_score >= 3 THEN "Can't Lose Them"
            ELSE 'Lost/Churned' 
        END AS customer_segment,
        CASE
            WHEN recency_days >= 60 THEN 'High Risk'
            WHEN recency_days BETWEEN 30 AND 59 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS churn_risk_tier
    
    FROM rfm_scores
)

-- final output with all segments
SELECT
    customer_segment,
    churn_risk_tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary_value), 2) AS avg_monetary_value,
    ROUND(SUM(monetary_value), 2) AS total_segment_revenue,
    ROUND(AVG(rfm_score), 2) AS avg_rfm_score,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_revenue
FROM rfm_segments
GROUP BY customer_segment, churn_risk_tier
ORDER BY avg_rfm_score DESC;