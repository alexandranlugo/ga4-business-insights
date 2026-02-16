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

## 💰 Revenue Drivers Analysis

### Top Revenue-Generating Categories
| Category | Revenue | Customers | AOV | % of Total Revenue |
|----------|---------|-----------|-----|-------------------|
| Apparel | $171,786 | 2,430 | $57.13 | 47.4% |
| New | $25,800 | 907 | $24.57 | 7.12% |
| Bags | $23,854 | 498 | $39.96 | 6.58% |
| Campus Collection | $20,060 | 737 | $23.88 | 5.54% |
| Accessories | $17,839 | 775 | $20.00 | 4.92% |

### Key Product Insights
**Top 5 Products by Revenue:**
- Google Zip Hoodie F/C (Apparel): $13,692 | 217 buyers | $50.54 AOV
- Google Men's Tech Fleece Grey (Apparel): $9,964 | 90 buyers | $74.37 AOV
- Google Badge Heavyweight Pullover (Apparel): $9,564 | 149 buyers | $48.49 AOV
- Super G Unisex Joggers (Shop by Brand): $8,964 | 209 buyers | $31.04 AOV
- Google Crewneck Sweatshirt (Apparel): $8,118 | 146 buyers | $45.64 AOV

**Notable Outliers:**
- Gift Cards: Tiny volume (9 customers) but highest AOV at $206.25
- Google Men's Puff Jacket Black: Premium pricing at $96.75 avg with strong demand
- Google Utility BackPack: $99.23 avg price, solid revenue per unit at $99.17

### Cross-Sell Opportunities
**Top Category Pairs Purchased Together:**
- Apparel + New: 508 customers (strongest cross-sell pair)
- Accessories + Apparel: 379 customers
- Apparel + Campus Collection: 343 customers
- Apparel + Shop by Brand: 336 customers
- Apparel + Office: 287 customers

**Key Insight:** Apparel appears in 8 of the top 10 cross-sell pairs, making it the 
anchor category for bundle and recommendation strategies.

### Customer Value Segmentation
| Segment | Customers | Avg LTV | Total Revenue | % of Revenue |
|---------|-----------|---------|---------------|--------------|
| Medium Value - One-Time Buyer | 1,050 | $71.97 | $75,565 | 20.86% |
| High Value - One-Time Buyer | 465 | $138.42 | $64,364 | 17.77% |
| VIP - One-Time Buyer | 143 | $342.99 | $49,047 | 13.54% |
| Low Value - One-Time Buyer | 1,687 | $28.25 | $47,658 | 13.16% |
| VIP - Repeat Buyer (3+) | 97 | $392.48 | $38,071 | 10.51% |
| VIP - Returning Customer (2) | 98 | $370.73 | $36,332 | 10.03% |

**Critical Insight:** The top 338 VIP customers (143 one-time + 97 repeat + 98 returning) 
generate 34.08% of total revenue despite representing only 7.6% of the customer base.

### Revenue Trends (Weekly)
**Peak Performance:**
- Peak week: Dec 6, 2020 with $57,798 revenue (696 customers)
- Strong pre-holiday surge: Nov 15-Dec 6 showed consistent 30-40% WoW growth

**Holiday Cliff Effect:**
- Dec 20 week crashed -70.27% ($57,798 → $14,954) - post-holiday drop
- Dec 27 continued declining -27.27% ($10,876)
- January recovery: +51.29% WoW Jan 10, +80.33% WoW Jan 17

**Seasonal Pattern:**
- Holiday season (Nov 15 - Dec 13) drove the majority of revenue
- Post-holiday period (Dec 20 - Jan 10) represents significant revenue trough
- Late January showed strong recovery signals (+80% WoW by Jan 17)

### Business Recommendations
1. **Double Down on Apparel:** Dominates at 47.4% of revenue - priority for inventory, 
   marketing, and new product development
2. **Bundle Strategy:** Apparel + New Items is the #1 cross-sell pair (508 customers) - 
   create curated bundles to increase AOV
3. **VIP Program:** Top 338 customers generate 34% of revenue - a dedicated VIP 
   retention program could protect this revenue concentration risk
4. **Holiday Planning:** Replicate Nov 15-Dec 6 growth strategies; build post-holiday 
   re-engagement campaign to reduce the December cliff effect
5. **Premium Product Investment:** High-AOV items (Puff Jackets $96, Backpacks $99, 
   Gift Cards $206) show strong demand - expand premium product line

---

## 🎯 Marketing Attribution Analysis

### Channel Performance Summary
| Channel | Users | Conversion Rate | Revenue | Revenue/User |
|---------|-------|----------------|---------|--------------|
| Google Organic | 103,487 | 1.19% | $95,775 | $0.93 |
| Direct | 75,951 | 1.39% | $79,650 | $1.05 |
| Data Deleted | 17,948 | 3.79% | $50,064 | $2.79 |
| shop.googlemerchandisestore referral | 26,065 | 2.18% | $46,521 | $1.78 |
| Other Referral | 32,880 | 1.42% | $37,000 | $1.13 |
| Google CPC | 15,527 | 0.98% | $9,056 | $0.58 |

### Conversion Funnel by Channel
**All top channels show similar overall conversion (1.17-1.39%) with one exception:**
- Data Deleted segment: 3.79% overall conversion - highest quality traffic
- Biggest funnel drop-off across ALL channels: View Item → Add to Cart (~18-27%)
- Checkout completion rates are strong across channels (73-83%)

**Key Funnel Insight:** The primary conversion problem is getting users from product 
views to cart, not from cart to checkout. This points to product page optimization 
as the highest-leverage improvement area.

### First-Touch vs Last-Touch Attribution
| Channel | First-Touch Revenue | Last-Touch Revenue | Difference |
|---------|--------------------|--------------------|------------|
| Google | $131,334 | $104,831 | +$26,503 |
| Other | $96,571 | $81,099 | +$15,472 |
| Direct | $83,743 | $79,650 | +$4,093 |
| shop.googlemerchandisestore | $28,616 | $46,521 | -$17,905 |
| Data Deleted | $21,901 | $50,064 | -$28,163 |

**Attribution Insights:**
- **Google is an awareness driver:** $26,503 gap means Google initiates far more 
  journeys than it closes - it introduces customers who convert elsewhere
- **shop.googlemerchandisestore.com is a closing channel:** -$17,905 difference means 
  it rarely initiates but frequently closes sales - high purchase intent traffic
- **Direct traffic is balanced:** Small $4,093 difference suggests loyal/returning users 
  who both discover and convert directly

### Customer Acquisition Cost (CAC) Recommendations
**Highest Quality Channels (invest more):**
- Data Deleted: $73.62 revenue/customer, max CAC $24.54 for 3x ROI
- shop.googlemerchandisestore referral: $81.90 revenue/customer, max CAC $27.30
- Other Referral: $79.06 revenue/customer, max CAC $26.35

**Optimize or Reduce:**
- Google CPC: Lowest quality score (0.58) with only $58.05 revenue/customer
  and 0.98% conversion - paid search ROI needs immediate review
- Google Organic: Highest volume but lowest revenue/user ($0.93) - 
  focus on conversion rate optimization for organic traffic

### Campaign Performance
- Majority of campaigns tagged as "(not set)" - indicates significant gap in 
  UTM tracking implementation
- Referral campaigns consistently outperform across all sources
- Recommendation: Implement consistent UTM tagging to unlock campaign-level insights

### Marketing Budget Allocation Recommendations
1. **Protect referral partnerships:** shop.googlemerchandisestore.com and other 
   referral sources show highest revenue per customer ($79-82)
2. **Audit Google CPC immediately:** Lowest quality score (0.58) suggests poor 
   keyword targeting or landing page mismatch - pause underperforming campaigns
3. **Fix UTM tracking:** Most campaigns show "(not set)" - missing critical data 
   for campaign optimization decisions
4. **Invest in product page optimization:** View-to-cart drop-off (18-27%) is the 
   primary conversion bottleneck across ALL channels
5. **Leverage Google for awareness:** Use Google Organic/CPC for top-of-funnel 
   awareness; retarget these users through direct and referral channels to close

### Combined Revenue + Attribution Insight
**The most valuable customer profile:**
- Acquired via referral or direct channel (highest conversion rates)
- First purchase in Apparel category (47.4% of revenue, strongest cross-sell anchor)
- Engaged enough to become VIP ($200+ spend) = $370-392 LTV
- Targeted with cross-sell bundle (Apparel + New Items = top pairing)

*This profile represents the ideal customer acquisition and retention strategy 
for maximum ROI.*


---

*This project is part of my data analytics portfolio demonstrating SQL proficiency and business analytics for client-facing roles in media/entertainment.*
