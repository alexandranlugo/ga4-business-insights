# GA4 E-Commerce Business Insights

## 📊 Project Overview
SQL-based analysis of Google Analytics 4 e-commerce data to identify actionable business insights around customer retention, revenue optimization, and churn prevention.

## 🎯 Business Goals
This project answers key business questions:
1. **Customer Retention:** Which customer cohorts have the highest lifetime value?
2. **Revenue Drivers:** What products and categories drive growth?
3. **Marketing Attribution:** Which channels deliver the best ROI?
4. **Churn Prevention:** How can we identify at-risk customers early?

## 🛠 Tech Stack
- **SQL:** BigQuery (Google Analytics 4 public dataset)
- **Python:** Pandas, Matplotlib, Seaborn for visualization
- **Tools:** Jupyter Notebooks, Git

## 📁 Project Structure
```
├── sql/                    # SQL queries for business analysis
├── notebooks/              # Python notebooks with visualizations
├── visualizations/         # Charts and graphs
└── README.md              # Project documentation
```
## 📋 Data Exploration Findings

### Dataset Overview
- **Source:** Google Analytics 4 Sample E-commerce Dataset (BigQuery Public Data)
- **Date Range:** November 1, 2020 - January 31, 2021 (91 days / ~3 months)
- **Total Events:** 4,295,584 events
- **Total Users:** 270,154 unique users

### Key Business Metrics
- **Total Transactions:** 5,692 purchases
- **Total Revenue:** $362,165.00
- **Average Order Value:** $69.09
- **Total Items Sold:** 22,720 items
- **Purchasing Users:** 4,419 (1.64% conversion rate)
- **Purchase-to-Item Ratio:** ~4 items per transaction

### Event Distribution Insights
**Top User Actions:**
- `page_view` (31.44%) - Primary browsing behavior
- `user_engagement` (24.65%) - Active engagement tracking
- `scroll` (11.48%) - Content consumption
- `view_item` (8.99%) - Product interest
- `add_to_cart` (1.36%) - Purchase intent
- `purchase` (0.13%) - Final conversion

**Conversion Funnel Drop-off:**
- Add to cart → Begin checkout: 66% drop-off (58,543 → 38,757)
- Begin checkout → Purchase: 85% drop-off (38,757 → 5,692)

### Data Quality Assessment
✅ **Strengths:**
- Zero null values in critical fields (`user_pseudo_id`, `event_name`, `traffic_source.source`)
- Complete user tracking across all events
- Clean transaction data structure

⚠️ **Considerations:**
- **7.91% of purchase events** have null revenue values (450 out of 5,692 purchases)
  - Impact: May slightly underestimate total revenue
  - Mitigation: Flag these transactions in analysis; investigate if pattern exists
- Dataset covers holiday season (Nov-Jan) - may show elevated purchasing behavior
- 3-month window limits longitudinal cohort analysis beyond 90 days

### User Behavior Patterns
**Engagement Distribution:**
- **47.16%** are low-engagement users (2-5 events) - casual browsers
- **25.89%** moderate engagement (6-10 events) - comparison shoppers
- **21.47%** high engagement (11-50 events) - serious shoppers
- **5.42%** are power users (50+ events) - brand enthusiasts or repeat customers

**Key Insight:** Power users (5.42%) show 0.37 avg purchases per user, suggesting these engaged users are prime targets for retention and upsell strategies.

## 📈 Cohort Retention Analysis

### Cohort Performance Summary
**Analysis Period:** November 2020 - January 2021

| Cohort Month | Cohort Size | Month 1 Retention | Month 2 Retention | Month 3 Retention | Revenue per Customer | Avg Order Value |
|--------------|-------------|-------------------|-------------------|-------------------|----------------------|-----------------|
| 2020-11      | 1,484       | 6.4%              | 0.67%             | 0.0%              | $103.54              | $72.07          |
| 2020-12      | 1,810       | 2.04%             | 0.0%              | N/A               | $85.23               | $68.32          |
| 2021-01      | 772         | 0.0%              | N/A               | N/A               | $70.26               | $63.66          |

### Critical Retention Insights

🚨 **Major Retention Challenge Identified:**
- **93.6% of November cohort customers never made a second purchase** (only 6.4% returned in Month 1)
- **Retention drops to near-zero by Month 2** (0.67% for November cohort)
- **December cohort shows even worse retention** at 2.04% Month 1
- **January cohort has 0% Month 1 retention** (though limited observation window)

📊 **Retention Curve Analysis:**
The detailed retention curve shows:
- **November 2020:** 1,481 customers → 95 active in Month 1 (6.41%) → 10 active in Month 2 (0.68%)
- **December 2020:** 1,810 customers → 37 active in Month 1 (2.04%)
- **Steep drop-off pattern:** 93%+ of customers churn immediately after first purchase

💰 **Revenue Impact:**
- **Total cohort revenue:** $354,165 across 4,066 customers
- **November cohort** generated highest revenue per customer ($103.54) despite poor retention
- **Average order values declining** across cohorts: $72.07 → $68.32 → $63.66

### User Engagement Context
From earlier analysis, power users (50+ events, 5.42% of users) have:
- **0.37 average purchases per user** - even highly engaged users rarely convert multiple times
- This suggests **engagement ≠ conversion** - users browse extensively but don't repurchase

### Root Cause Hypothesis
Several factors may explain the severe retention problem:

1. **Holiday Shopping Pattern:** Nov-Jan data captures gift-buying season
   - Many customers are one-time gift purchasers, not repeat buyers
   - Explains high initial traffic with near-zero retention

2. **Product/Category Mix:** Possible focus on one-time purchase items
   - Need to analyze product categories in next phase
   - May lack consumables or subscription-worthy products

3. **No Retention Strategy Visible:** 0.67% Month 2 retention suggests:
   - Lack of post-purchase email campaigns
   - No loyalty program or incentives
   - Missing re-engagement touchpoints

### Business Recommendations

**IMMEDIATE PRIORITIES:**

1. **Launch Month 1 Re-engagement Campaign** 🎯
   - Email series at Day 7, 14, 30 post-purchase
   - Offer 15% discount on second purchase
   - **Potential impact:** Even 5% retention improvement = +$17,700 in recovered revenue

2. **Product Strategy Audit** 📦
   - Identify which products/categories drive repeat purchases
   - Shift marketing spend toward repeat-purchase categories
   - Consider subscription or auto-replenishment options

3. **Loyalty Program for High-AOV Customers** 💎
   - Target November cohort (highest AOV at $72.07)
   - Points-based system or VIP tier benefits
   - Focus on customers who spent $100+ on first purchase

4. **Post-Holiday Retention Test** 🧪
   - Re-run this analysis on Feb-April data to isolate seasonal effect
   - If retention improves, confirms holiday gift-buying hypothesis
   - If remains low, indicates fundamental business model issue

**NEXT ANALYSIS NEEDED:**
- Revenue driver analysis to identify repeat-purchase product categories
- Marketing attribution to see if certain channels bring higher-LTV customers
- Customer segmentation by first product purchased (consumable vs. one-time)


---

*This project is part of my data analytics portfolio demonstrating SQL proficiency and business analytics for client-facing roles in media/entertainment.*
