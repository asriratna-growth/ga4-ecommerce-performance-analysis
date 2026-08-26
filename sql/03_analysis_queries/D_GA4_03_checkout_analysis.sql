-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Stage: 03 - Analysis Queries
-- Query: Checkout Analysis
-- File: D_GA4_03_checkout_analysis.sql
-- Purpose: Summarize user progression through the checkout, shipping, payment, and purchase stages
-- =========================================================

SELECT
  SUM(checkout_users) AS checkout_users,
  SUM(shipping_users) AS shipping_users,
  SUM(payment_users) AS payment_users,
  SUM(purchase_users) AS purchase_users
FROM `ga4-performance-analysis-0726.ga4_reporting.checkout_funnel_performance`;
