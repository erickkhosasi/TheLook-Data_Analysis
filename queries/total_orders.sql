/*
================================================================================
Query script: Churned Customers - Total Orders
================================================================================
Script Purpose:
    This script calculates the total number of completed orders placed by
    customers who are classified as "churned".

    Data Source: `users` and `orders` tables

    Business Value:
    - Provides insight into Customer Lifetime Value (CLV) by quantifying
      how much customers contributed before becoming inactive.
    - Supports retention analysis by highlighting the order activity of
      churned users prior to leaving.
================================================================================
*/


-- Step 1: Join users and orders table and number orders descending by date
WITH seed_orders AS (
  SELECT
    u.id AS user_id,
    o.order_id,
    DATE(o.created_at) AS order_date,
    ROW_NUMBER() OVER (
      PARTITION BY o.user_id
      ORDER BY o.created_at DESC
    ) AS rn_last_purchased
  FROM `bigquery-public-data.thelook_ecommerce.users` u
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON u.id = o.user_id
  WHERE o.status = 'Complete'
),

-- Step 2: Calculate days since customers' last purchase
last_purchase AS (
  SELECT
    user_id,
    order_id,
    order_date AS last_purchase_date,
    DATE_DIFF(CURRENT_DATE(), order_date, DAY) AS days_since_last_purchase
  FROM seed_orders
  WHERE rn_last_purchased = 1
),

-- Step 3: Segment customers behavior by days since last purchase
user_segments AS (
  SELECT
    user_id,
    last_purchase_date,
    days_since_last_purchase,
    CASE
      WHEN days_since_last_purchase < 31 THEN 'Active'
      WHEN days_since_last_purchase < 91 THEN 'Warm'
      ELSE 'Churned'
    END AS status_bucket
  FROM last_purchase
)

-- Step 4: Calculate total orders by churned users
SELECT
  us.user_id,
  COUNT(DISTINCT so.order_id) AS total_orders,
FROM user_segments us
INNER JOIN seed_orders so
  ON us.user_id = so.user_id
WHERE us.status_bucket = 'Churned'
GROUP BY 1