# The Look Sales & Retention Analysis with SQL (BigQuery)

## Project Overview
This project was completed as the final assignment for my **SQL with BigQuery Mini Bootcamp**. The goal is to analyze an e-commerce dataset to uncover key insights on **sales performance, customer behavior, return rates, and retention**. The analysis highlights the business challenges of high product return rates, dependency on first-time orders, and sales concentration in top countries.
The project concludes with **data-driven recommendations** to improve customer lifetime value (CLV), optimize retention strategies, an strengthen market-focuse campaigns.

---

## Dataset
- **Source:** Google BigQuery public dataset  
- **Dataset ID:** `bigquery-public-data.thelook_ecommerce`  
- **Database:** `thelook_ecommerce`  
- **Tables Used:**  
  - `order_items`  
  - `orders`  
  - `users`  
  - `products`  
- **Periods Covered:** 2019–2025  

⚠️ **Note:** The dataset is updated regularly. As a result, query outputs may differ slightly depending on when you run them.

---

## Exploratory Data Analysis (EDA)
- **Customer Behavior / Activeness**  
  Segmented customers based on last active date to understand churn and retention patterns.  

- **Customer Geographic & Demographic Segmentation**  
  Analyzed users by **country, gender, and age group** to identify top markets and demographic-driven sales.  

- **Revenue Distribution**  
  Explored revenue contribution across geographies, demographics, product categories, and order types (first vs. repeat purchases).  

- **Return Orders**  
  Investigated product return trends, quantifying **return rate and revenue loss** from returned orders.  

- **Average Order Value (AOV)**  
  Evaluated AOV across different dimensions to identify whether revenue is driven by order frequency or spending per order.  

- **Logistics Performance**
  Evaluated shipping performance for completed orders across all countries.

---

## Tools
- **Google BigQuery** – Core tool for querying and analyzing data at scale.  
- **Google Sheets** – Used to visualize aggregated results and present insights in a clear format.  

---
