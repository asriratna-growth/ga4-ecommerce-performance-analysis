-- ========================================================
-- GA4 Ecommerce Performance Analysis
-- Stage: 01 - Data Preparation
-- Query: Traffic Source Structure
-- File: A_GA4_04_traffic_source_structure.sql
-- Purpose: Explore available traffic source dimensions
-- ========================================================

SELECT
  traffic_source.source AS source,
  traffic_source.medium AS medium,
  traffic_source.name AS campaign,
  COUNT(*) AS total_events,
  COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY
  source,
  medium,
  campaign
ORDER BY
  unique_users DESC;
