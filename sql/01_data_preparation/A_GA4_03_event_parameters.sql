-- ========================================================
-- GA4 Ecommerce Performance Analysis
-- Stage: 01 - Data Preparation
-- Query: Event Parameters
-- File: A_GA4_03_event_parameters.sql
-- Purpose: Explore available event parameters in the dataset
-- ========================================================

SELECT
  event_name,
  ep.key AS parameter_name,
  COUNT(*) AS parameter_occurrences
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(event_params) AS ep
GROUP BY
  event_name,
  parameter_name
ORDER BY
  event_name,
  parameter_occurrences DESC;
