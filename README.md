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

### Analysis Readiness
✅ Ready to proceed with:
- Cohort retention analysis (90-day window available)
- Revenue driver identification (product/category data present)
- Marketing attribution (traffic source data complete)
- Churn risk modeling (engagement and purchase patterns clear)

⚠️ **Note on Purchase Revenue Nulls:** Will filter or impute the 7.91% null revenue values in subsequent analyses to maintain data integrity.



## 🚀 Coming Soon
- Cohort retention analysis
- Revenue driver identification
- Marketing channel performance
- Customer churn risk scoring

## 📫 Connect
[Your LinkedIn URL]

---

*This project is part of my data analytics portfolio demonstrating SQL proficiency and business analytics for client-facing roles in media/entertainment.*
