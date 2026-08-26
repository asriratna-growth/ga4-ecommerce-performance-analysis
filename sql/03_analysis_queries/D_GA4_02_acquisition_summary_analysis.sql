-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Stage: 03 - Analysis Queries
-- Query: Acquisition Summary Analysis
-- File: D_GA4_02_acquisition_summary_analysis.sql
-- Purpose: Summarize total acquired users, sessions, purchasing users, and revenue from the user acquisition reporting table
-- =========================================================

SELECT
  SUM(acquired_users) AS total_acquired_users,
  SUM(sessions) AS total_sessions,
  SUM(purchasing_users) AS total_purchasing_users,
  SUM(purchase_revenue) AS total_revenue
FROM `ga4-performance-analysis-0726.ga4_reporting.user_acquisition_summary`;
