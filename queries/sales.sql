/*
================================================================================
Query script: Sales Analysis
================================================================================
Script Purpose:
    This script analyze the company's sales performance across multipledimensions.
    Four segmentation perspectives are provided:
    1. Geographic segmentation  - distribution by country.
    2. Demographic segmentation - distribution by gender group.
    3. Demographic segmentation - distribution by age group.
    4. Product segmentation     - distribution by product category.

    Data Source: `order_items`, `products`, and `users` tables

    Business Value:
    - Provides insights into overall sales performance and customer behavior
    - Highlights top-performing regions, demographic groups, and product
      categories.
    - Helps identify revenue drivers and opportunities for targeted marketing,
      product development, and business growth.
================================================================================
*/


-- =======================
-- Total Sales by Country
-- =======================

-- Step 1: Retrieve completed orders with country information
WITH seed_orders AS (
  SELECT
    oi.order_id,
    oi.user_id,
    oi.sale_price,
    u.country
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON oi.user_id = u.id
  WHERE oi.status = 'Complete'
)

-- Step 2: Aggregate total sales by country
SELECT
  country,
  ROUND(SUM(sale_price)) AS total_sales,
  ROUND(SUM(sale_price)/COUNT(DISTINCT order_id), 2) AS AOV
FROM seed_orders
GROUP BY country
ORDER BY total_sales DESC;


-- ======================
-- Total Sales by Gender
-- ======================

-- Step 1: Retrieve completed orders with gender information
WITH seed_orders AS (
  SELECT
    oi.order_id,
    oi.user_id,
    oi.sale_price,
    u.gender
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON oi.user_id = u.id
  WHERE oi.status = 'Complete'
)

-- Step 2: Aggregate total sales by gender
SELECT
  gender,
  ROUND(SUM(sale_price)) AS total_sales,
  ROUND(SUM(sale_price)/COUNT(DISTINCT order_id), 2) AS AOV
FROM seed_orders
GROUP BY gender
ORDER BY total_sales DESC;


-- ===================
-- Total Sales by Age
-- ===================

-- Step 1: Retrieve completed orders with age information
WITH seed_orders AS (
  SELECT
    oi.order_id,
    oi.user_id,
    oi.sale_price,
    u.age
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON oi.user_id = u.id
  WHERE oi.status = 'Complete'
)

-- Step 2: Aggregate total sales by age group
SELECT
  CASE
    WHEN age <= 25 THEN 'Gen-Z'
    WHEN age <= 45 THEN 'Gen-Y'
    ELSE 'Gen-X and Above'
  END AS generation,
  ROUND(SUM(sale_price)) AS total_sales,
  ROUND(SUM(sale_price)/COUNT(DISTINCT order_id), 2) AS AOV
FROM seed_orders
GROUP BY generation
ORDER BY total_sales DESC;


-- =======================
-- Total Sales by Category
-- =======================

-- Step 1: Retrieve completed orders with product category information
WITH seed_orders AS (
  SELECT
    oi.order_id,
    oi.user_id,
    oi.sale_price,
    p.category
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE oi.status = 'Complete'
)

-- Step 2: Aggregate total sales by category
SELECT
  category,
  ROUND(SUM(sale_price)) AS total_sales,
  ROUND(SUM(sale_price)/COUNT(DISTINCT order_id), 2) AS AOV
FROM seed_orders
GROUP BY category
ORDER BY total_sales DESC;