-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Stage: 03 - Analysis Queries
-- Query: Checkout Analysis
-- File: D_GA4_03_checkout_analysis.sql
-- Purpose: Summarize user progression through the checkout, shipping, payment, and purchase stages
-- =========================================================

SELECT
  SUM(users) AS total_users,
  SUM(sessions) AS total_sessions,
  SUM(purchases) AS total_purchases,
  SUM(purchase_revenue) AS total_revenue
FROM `ga4-performance-analysis-0726.ga4_reporting.conversion_trend`;
