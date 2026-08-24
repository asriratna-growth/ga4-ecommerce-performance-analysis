-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Stage: 01 - Data Preparation
-- Query: Dataset Overview
-- File: A_GA4_01_dataset_overview.sql
-- Purpose: Explore the structure and contents of the GA4 ecommerce dataset
-- =========================================================

SELECT
  MIN(PARSE_DATE('%Y%m%d', event_date)) AS start_date,
  MAX(PARSE_DATE('%Y%m%d', event_date)) AS end_date,
  COUNT(*) AS total_events,
  COUNT(DISTINCT user_pseudo_id) AS total_users,
  COUNT(DISTINCT event_name) AS total_event_types
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
