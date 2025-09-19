/*
================================================================================
Query script: Returned Orders Analysis
================================================================================
Script Purpose:
    This script analyzes product returns across all countries and categories.
    
    Metrics calculated include:
    - Returned Count    : Number of returned orders
    - Returned Amount   : Total value of returned orders
    - Returned AOV      : Average order value of returned orders
    - Total Sales       : Total value of completed + returned orders
    - Avg Price         : Average sale price across completed + returned orders
    - Returned Rate     : Share of returned amount as a percentage of total sales
    
    Data source: `order_items`, `users`, and `products` tables

    Business Value:
    - Provide insights into return orders and financial impact.
    - Supports root cause analysis by identifying return trends across gegraphies
      and product categories.
================================================================================
*/


-- =========================
-- Returned Rate by Country
-- =========================

-- Step 1: Retrieve order details with country information
WITH seed_orders AS (
  SELECT 
    oi.user_id,
    oi.order_id,
    u.country,
    oi.status,
    oi.sale_price
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON oi.user_id = u.id
),

-- Step 2: Aggregate total sales per country (complete + Returned)
country_orders AS (
  SELECT
    country,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sale_price) AS total_sales,
    AVG(sale_price) AS avg_price
  FROM seed_orders
  WHERE status IN ('Complete', 'Returned')
  GROUP BY country
),

-- Step 3: Aggregate returned orders per country
returned_orders AS (
  SELECT
    country,
    COUNT(DISTINCT order_id) AS returned_count,
    SUM(sale_price) AS returned_amount
  FROM seed_orders
  WHERE status = 'Returned'
  GROUP BY country
)

-- Step 4: Calculate return metrics by country
SELECT
  ro.country,
  ro.returned_count,
  ROUND(ro.returned_amount) AS returned_amount,
  ROUND(ro.returned_amount/ro.returned_count) AS returned_AOV,
  ROUND(co.total_sales) AS total_sales,
  ROUND(co.avg_price) AS avg_price,
  ROUND(ro.returned_amount * 100 / co.total_sales, 1) AS returned_rate
FROM returned_orders ro
JOIN country_orders co
  ON ro.country = co.country
ORDER BY returned_amount DESC;


-- =================================
-- Returned Rate by Product Category
-- =================================

-- Step 1: Retrieve order details with product category information
WITH seed_orders AS (
  SELECT 
    oi.user_id,
    oi.order_id,
    p.category,
    oi.status,
    oi.sale_price
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
),

-- Step 2: Aggregate total sales per category (complete + Returned)
category_orders AS (
  SELECT
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sale_price) AS total_sales,
    AVG(sale_price) AS avg_price
  FROM seed_orders
  WHERE status IN ('Complete', 'Returned')
  GROUP BY category
),

-- Step 3: Aggregate returned orders per category
returned_orders AS (
  SELECT
    category,
    COUNT(DISTINCT order_id) AS returned_count,
    SUM(sale_price) AS returned_amount
  FROM seed_orders
  WHERE status = 'Returned'
  GROUP BY category
)

-- Step 4: Calculate return metrics by category
SELECT
  ro.category,
  ro.returned_count,
  ROUND(ro.returned_amount) AS returned_amount,
  ROUND(ro.returned_amount/ro.returned_count) AS returned_AOV,
  ROUND(co.total_sales) AS total_sales,
  ROUND(co.avg_price) AS avg_price,
  ROUND(ro.returned_amount * 100 / co.total_sales, 1) AS returned_rate
FROM returned_orders ro
JOIN category_orders co
  ON ro.category = co.category
ORDER BY returned_amount DESC;