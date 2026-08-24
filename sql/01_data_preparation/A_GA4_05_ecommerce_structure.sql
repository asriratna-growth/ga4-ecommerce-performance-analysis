-- ========================================================
-- GA4 Ecommerce Performance Analysis
-- Stage: 01 - Data Preparation
-- Query: Ecommerce Structure
-- File: A_GA4_05_ecommerce_structure.sql
-- Purpose: Explore available ecommerce fields and item-level data
-- ========================================================

SELECT
  event_name,
  ecommerce.total_item_quantity,
  ecommerce.purchase_revenue,
  ecommerce.transaction_id,
  ARRAY_LENGTH(items) AS total_items_in_event,
  COUNT(*) AS total_events
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
  event_name IN (
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'add_shipping_info',
    'add_payment_info',
    'purchase'
  )
GROUP BY
  event_name,
  ecommerce.total_item_quantity,
  ecommerce.purchase_revenue,
  ecommerce.transaction_id,
  total_items_in_event
ORDER BY
  event_name,
  total_events DESC;
