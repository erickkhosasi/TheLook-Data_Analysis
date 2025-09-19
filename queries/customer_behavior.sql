/*
================================================================================
Query script: Customer Behavior Pattern / Churn Analysis
================================================================================
Script Purpose:
    This script extract users behavioral insights, focusing on user activeness
    and churn status.
    Two perspectives are provided:
    1. Geographic segmentation - distribution by country.
    2. Demographic segmentation - distribution by age group.

    Data Source: `users` and `orders` tables

    Business Value:
    - Provides insights into customer base activity patterns, identify churn, and
      understand user distribution across geographic and demographic segments.
================================================================================
*/


-- =========================
-- Churn Analysis by Country
-- =========================

-- Step 1: Retrieve completed orders and assign sequence by desending order_date
WITH seed_orders AS (
  SELECT
    u.id AS user_id,
    u.country,
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
    country,
    order_date AS last_purchase_date,
    DATE_DIFF(CURRENT_DATE(), order_date, DAY) AS days_since_last_purchase
  FROM seed_orders
  WHERE rn_last_purchased = 1
),

-- Step 3: Segment customers behavior by days since last purchase
user_segments AS (
  SELECT
    user_id,
    country,
    last_purchase_date,
    days_since_last_purchase,
    CASE
      WHEN days_since_last_purchase < 31 THEN 'Active'
      WHEN days_since_last_purchase < 91 THEN 'Warm'
      ELSE 'Churned'
    END AS status_bucket
  FROM last_purchase
)

-- Step 4 Extract behavior distribution by country
SELECT
  country,
  status_bucket,
  COUNT(user_id) AS user_count,
  ROUND(
    COUNT(user_id) * 100.0 / SUM(COUNT(user_id)) OVER (PARTITION BY country),
    2
  ) AS percentage
FROM user_segments
GROUP BY country, status_bucket
ORDER BY
  SUM(COUNT(user_id)) OVER (PARTITION BY country) DESC,
  country,
  status_bucket;


-- ===========================
-- Churn Analysis by Age Group
-- ===========================

-- Step 1: Retrieve completed orders and assign sequence by desending order_date
WITH seed_orders AS (
  SELECT
    u.id AS user_id,
    u.age,
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
    age,
    order_date AS last_purchase_date,
    DATE_DIFF(CURRENT_DATE(), order_date, DAY) AS days_since_last_purchase
  FROM seed_orders
  WHERE rn_last_purchased = 1
),

-- Step 3: Segment customer by age demographic and days since last purchase
user_segments AS (
  SELECT
    user_id,
    CASE
      WHEN age <= 25 THEN 'Gen-Z'
      WHEN age <= 45 THEN 'Gen-Y'
      ELSE 'Gen-X and Above'
    END AS age_bucket,
    last_purchase_date,
    days_since_last_purchase,
    CASE
      WHEN days_since_last_purchase < 31 THEN 'Active'
      WHEN days_since_last_purchase < 91 THEN 'Warm'
      ELSE 'Churned'
    END AS status_bucket
  FROM last_purchase
)

-- Step 4: Extract behavior distribution by age demographic
SELECT
  age_bucket,
  status_bucket,
  COUNT(user_id) AS user_count,
  ROUND(
    COUNT(user_id) * 100.0 / SUM(COUNT(user_id)) OVER (PARTITION BY age_bucket),
    2
  ) AS percentage
FROM user_segments
GROUP BY age_bucket, status_bucket
ORDER BY
  SUM(COUNT(user_id)) OVER (PARTITION BY age_bucket) DESC,
  age_bucket,
  status_bucket;