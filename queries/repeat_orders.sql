/*
================================================================================
Query script: Repeat Orders Analysis
================================================================================
Script Purpose:
    This script analyzes sales performance by comparing first-time orders to
    repeat orders. 
    
    Metrics calculated include:
    - Total users               : Total number of users who place orders
    - Total orders              : Total number of completed orders
    - Total sales               : Total value of completed orders
    - Average Order Value (AOV) : Average order value of completed orders
    
    Data source: `orders` and `order_items` tables

    Business Value:
    - Identifies whether sales are primarily driven by new customers or
      repeat purchases.
    - Provides insight into customer loyalty and revenue sustainability.
================================================================================
*/


-- Step 1: Retrieve completed orders and aggregate total sales per order
WITH seed_orders AS (
  SELECT
    o.order_id,
    o.user_id,
    o.created_at AS order_date,
    SUM(oi.sale_price) AS total_sales
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
  GROUP BY ALL
),

-- Step 2: Assign order sequence number for each customer
sequence_orders AS (
  SELECT
    user_id,
    order_id,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY order_date
    ) AS rn_order,
    total_sales
  FROM seed_orders
)

-- Step 3: Calculate metrics by order type (First vs Repeat)
SELECT 
  CASE
    WHEN rn_order = 1 THEN 'First'
    WHEN rn_order > 1 THEN 'Repeat'
  END AS order_type,
  COUNT(DISTINCT user_id) AS total_users,
  COUNT(DISTINCT order_id) AS total_orders,
  ROUND(SUM(total_sales), 2) AS total_sales,
  ROUND(sum(total_sales)/COUNT(DISTINCT order_id), 2) AS AOV
FROM sequence_orders
GROUP BY order_type