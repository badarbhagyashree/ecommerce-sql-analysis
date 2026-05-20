

use project1
-- ============================================
-- OLIST E-COMMERCE SQL ANALYSIS
-- Author  : Bhagyashree Badar
-- Tool    : SQL Server Management Studio 22
-- Database: SQL Server
-- Dataset : Olist Brazilian E-Commerce
-- ============================================


-- ============================================
-- PROJECT OVERVIEW
-- This project performs end-to-end analysis
-- of 99,000+ orders from Olist, Brazil's
-- largest e-commerce marketplace covering:
-- 1. Exploratory Data Analysis
-- 2. Sales & Revenue Analysis
-- 3. RFM Customer Segmentation
-- 4. Seller Performance Analysis
-- ============================================

-- ============================================
-- STEP 1: EXPLORATORY ANALYSIS
-- ============================================

-- 1.1 Total Orders & Date Range
-- Business Question: What is the size and time
-- span of our dataset?
-- ============================================
SELECT 
    COUNT(*) AS total_orders,
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM olist_orders_dataset;


-- ============================================
-- 3.2 Order Status Breakdown
-- Business Question: What percentage of orders
-- are successfully delivered?
-- ============================================
SELECT 
    order_status,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total DESC;


-- ============================================
-- 1.3 Top 10 States by Number of Customers
-- Business Question: Which regions drive the
-- most customers?
-- ============================================
SELECT TOP 10
    customer_state,
    COUNT(*) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY total_customers DESC;


-- ============================================
-- 1.4 Top 10 Product Categories by Orders
-- Business Question: Which product categories
-- get the most orders?
-- ============================================
SELECT TOP 10
    t.column2 category_english,
    COUNT(oi.order_id) AS total_orders
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p 
    ON oi.product_id = p.product_id
JOIN product_category_name_translation t 
    ON p.product_category_name = t.column1
GROUP BY t.column2
ORDER BY total_orders DESC;


-- ============================================
-- 1.5 Average Order Value
-- Business Question: What is the typical,
-- minimum and maximum order value?
-- ============================================
SELECT 
    ROUND(AVG(payment_value), 2) AS avg_order_value,
    ROUND(MIN(payment_value), 2) AS min_order_value,
    ROUND(MAX(payment_value), 2) AS max_order_value
FROM olist_order_payments_dataset;


-- ============================================
-- STEP 2: SALES & REVENUE ANALYSIS
-- ============================================

-- 2.1 Monthly Revenue Trend
-- Business Question: How has revenue grown
-- month by month over time?
-- ============================================
SELECT 
    FORMAT(order_purchase_timestamp, 'yyyy-MM') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;


-- ============================================
-- 2.2 Revenue by Product Category
-- Business Question: Which categories generate
-- the most revenue (not just most orders)?
-- ============================================
SELECT TOP 10
    t.column2 AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p 
    ON oi.product_id = p.product_id
JOIN product_category_name_translation t 
    ON p.product_category_name = t.column1
GROUP BY t.column2
ORDER BY total_revenue DESC;


-- ============================================
-- 2.3 Revenue by State
-- Business Question: Which states generate
-- the most revenue and highest order values?
-- ============================================
SELECT TOP 10
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue,
    ROUND(AVG(p.payment_value), 2) AS avg_order_value
FROM olist_orders_dataset o
JOIN olist_customers_dataset c 
    ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- ============================================
-- 2.4 Peak Sales Days
-- Business Question: Which days of the week
-- do customers shop the most?
-- ============================================
SELECT 
    DATENAME(WEEKDAY, order_purchase_timestamp) AS day_of_week,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
WHERE order_status = 'delivered'
GROUP BY DATENAME(WEEKDAY, order_purchase_timestamp)
ORDER BY total_orders DESC;


-- ============================================
-- 2.5 Delivery Time vs Review Score
-- Business Question: Does faster delivery
-- lead to better customer reviews?
-- ============================================
SELECT 
    CASE 
        WHEN DATEDIFF(day, order_purchase_timestamp, 
             order_delivered_customer_date) <= 7  
             THEN '0-7 days'
        WHEN DATEDIFF(day, order_purchase_timestamp, 
             order_delivered_customer_date) <= 14 
             THEN '8-14 days'
        WHEN DATEDIFF(day, order_purchase_timestamp, 
             order_delivered_customer_date) <= 21 
             THEN '15-21 days'
        ELSE '21+ days'
    END AS delivery_bucket,
    COUNT(*) AS total_orders,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r 
    ON o.order_id = r.order_id
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY 
    CASE 
        WHEN DATEDIFF(day, order_purchase_timestamp, 
             order_delivered_customer_date) <= 7  
             THEN '0-7 days'
        WHEN DATEDIFF(day, order_purchase_timestamp, 
             order_delivered_customer_date) <= 14 
             THEN '8-14 days'
        WHEN DATEDIFF(day, order_purchase_timestamp, 
             order_delivered_customer_date) <= 21 
             THEN '15-21 days'
        ELSE '21+ days'
    END
ORDER BY avg_review_score DESC;


-- 3.1 Complete RFM Segmentation
-- Business Question: How can we classify all
-- customers into meaningful segments based on
-- their buying behaviour?
-- ============================================
;WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp)  AS last_order_date,
        COUNT(DISTINCT o.order_id)       AS frequency,
        ROUND(SUM(p.payment_value), 2)   AS monetary
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c  
        ON o.customer_id = c.customer_id
    JOIN olist_order_payments_dataset p 
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT
        customer_unique_id,
        last_order_date,
        frequency,
        monetary,
        DATEDIFF(day, last_order_date, '2018-10-17') AS recency_days,
        NTILE(5) OVER (ORDER BY DATEDIFF(day, last_order_date, '2018-10-17') DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary)  AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT
        customer_unique_id,
        last_order_date,
        frequency,
        monetary,
        recency_days,
        r_score,
        f_score,
        m_score,
        CASE 
            WHEN r_score = 5 AND f_score = 5 AND m_score = 5 THEN 'Champion'
            WHEN r_score >= 4 AND f_score >= 4               THEN 'Loyal Customer'
            WHEN r_score >= 4 AND f_score <= 2               THEN 'Promising'
            WHEN r_score <= 2 AND f_score >= 3               THEN 'At Risk'
            WHEN r_score = 1 AND f_score = 1 AND m_score = 1 THEN 'Lost'
            ELSE                                                  'Needs Attention'
        END AS segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*)                                   AS total_customers,
    ROUND(AVG(monetary), 2)                    AS avg_monetary,
    ROUND(AVG(CAST(frequency AS FLOAT)), 2)    AS avg_frequency,
    ROUND(AVG(CAST(recency_days AS FLOAT)), 2) AS avg_recency_days
FROM rfm_segments
GROUP BY segment
ORDER BY total_customers DESC;


-- ============================================
-- STEP 4: SELLER PERFORMANCE ANALYSIS
-- ============================================

-- 4.1 Top 10 Sellers by Revenue
-- Business Question: Who are our top earning
-- sellers and where are they located?
-- ============================================
SELECT TOP 10
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2)     AS total_revenue,
    ROUND(AVG(oi.price), 2)     AS avg_item_price
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s 
    ON oi.seller_id = s.seller_id
JOIN olist_orders_dataset o  
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC;


-- ============================================
-- 4.2 Seller Quality — Review Score vs Revenue
-- Business Question: Are our highest earning
-- sellers also delivering good customer
-- experience?
-- ============================================
SELECT TOP 10
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)                  AS total_orders,
    ROUND(SUM(oi.price), 2)                      AS total_revenue,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s        
    ON oi.seller_id = s.seller_id
JOIN olist_orders_dataset o         
    ON oi.order_id = o.order_id
JOIN olist_order_reviews_dataset r  
    ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id, s.seller_state
ORDER BY total_revenue DESC;


-- ============================================
-- 4.3 Seller Delivery Performance
-- Business Question: Which sellers deliver
-- fastest and does it earn them better reviews?
-- Note: HAVING >= 100 ensures statistical
-- reliability — excludes sellers with too few orders to give meaningful averages
-- ============================================
SELECT TOP 10
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)                  AS total_orders,
    ROUND(SUM(oi.price), 2)                      AS total_revenue,
    ROUND(AVG(CAST(
        DATEDIFF(day, o.order_purchase_timestamp,
        o.order_delivered_customer_date)
    AS FLOAT)), 1)                               AS avg_delivery_days,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s        
    ON oi.seller_id = s.seller_id
JOIN olist_orders_dataset o         
    ON oi.order_id = o.order_id
JOIN olist_order_reviews_dataset r  
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id, s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 100
ORDER BY avg_delivery_days ;


----------------------------------------------------------------------------------------------------------------------------------------








