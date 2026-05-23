# 🛒 E-Commerce Sales & Customer Analytics (Olist Brazil)

## 📌 Project Overview
End-to-end SQL analysis of 99,000+ orders from Olist,
Brazil's largest e-commerce marketplace. This project
covers revenue analysis, customer segmentation using
RFM methodology, and seller performance evaluation.

## 🛠️ Tools Used
- SQL Server Management Studio (SSMS)
- Microsoft SQL Server
- Dataset: Olist Brazilian E-Commerce (Kaggle)

## 📁 Database Schema
9 interconnected tables covering orders, customers,
products, sellers, payments, reviews and geolocation.

## 🔍 Analysis Performed

### 1. Exploratory Analysis
- Order status distribution across 99,000+ orders
- Top 10 product categories by order volume
- Average, minimum and maximum order values
- Geographic distribution of customers by state

### 2. Sales & Revenue Analysis
- Monthly revenue trend (2016-2018)
- Top 10 revenue-generating product categories
- Revenue breakdown by Brazilian state
- Peak shopping days of the week
- Impact of delivery time on customer review scores

### 3. RFM Customer Segmentation
Segmented 93,000+ customers into 5 groups using
Recency, Frequency and Monetary scoring:

| Segment | Customers | Avg Spend | Avg Recency |
|---|---|---|---|
| Needs Attention | 52,735 | R$168 | 369 days |
| Loyal Customer | 32,396 | R$141 | 140 days |
| Lost | 3,886 | R$39 | 525 days |
| Champion | 3,347 | R$445 | 90 days |
| At Risk | 993 | R$293 | 430 days |

### 4. Seller Performance Analysis
- Top 10 sellers by revenue and order volume
- Seller quality: review score vs revenue correlation
- Fastest delivering sellers and impact on reviews

## 💡 Key Business Insights

1. **Champions spend 3x more** than average customers
   (R$445 vs R$168) — VIP program recommended
2. **Faster delivery = better reviews** — orders delivered
   in 0-7 days average 4.4 stars vs 2.9 stars for 21+ days
3. **56% of customers need re-engagement** — largest
   segment represents biggest growth opportunity
4. **At Risk customers spend R$293 avg** — urgent win-back
   campaign could recover significant revenue
5. **São Paulo dominates** revenue and order volume
   across all Brazilian states

## 📊 SQL Concepts Used
- Multi-table JOINs (up to 4 tables)
- CTEs (Common Table Expressions)
- Window Functions (NTILE, OVER)
- CASE WHEN bucketing
- DATEDIFF and date functions
- GROUP BY with HAVING
- Aggregate functions (SUM, AVG, COUNT, MIN, MAX)
- NULL handling and data cleaning


