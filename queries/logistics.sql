/*
================================================================================
Query script: Logistics Analysis
================================================================================
Script Purpose:
    This script analyzes shipping performance for completed orders across all
    countries.
    
    Metrics calculated include:
    - Processing Time : Days from order placement until the order is shipped.
    - Lead Time       : Days from order placement until the order is delivered.
    
    Data source: `orders` and `users` tables

    Business Value:
    - Provide insights into operational efficiency and customer experience by
      measuring shipping speed and delivery performance across regions.
================================================================================
*/


-- Step 1: Retrieve completed orders with user country information
WITH seed_orders AS (
  SELECT
    o.order_id,
    o.user_id,
    u.country,
    o.created_at AS order_date,
    o.shipped_at,
    o.delivered_at
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON o.user_id = u.id
  WHERE o.status = 'Complete'
),

-- Step 2: Calculate processing time and lead time
seed_duration AS (
  SELECT
    order_id,
    user_id,
    country,
    order_date,
    shipped_at,
    delivered_at,
    DATE_DIFF(shipped_at, order_date, DAY) AS processing_time,
    DATE_DIFF(delivered_at, order_date, DAY) AS lead_time
  FROM seed_orders
)

-- Step 3: Aggregate results by country
SELECT
  country,
  COUNT(order_id) AS orders,
  COUNT(DISTINCT user_id) AS users,
  ROUND(AVG(processing_time)) AS avg_processing_time,
  ROUND(AVG(lead_time)) AS avg_lead_time
FROM seed_duration
GROUP BY country
ORDER BY orders DESC