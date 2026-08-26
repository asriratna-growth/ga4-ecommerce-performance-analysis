-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: User Acquisition Performance
-- Purpose: Analyze user acquisition performance by first-user traffic source and acquisition channel.
-- Used by: Acquisition Performance dashboard
-- =========================================================

WITH user_acquisition AS (
  SELECT
    user_pseudo_id,
    traffic_source.source AS first_user_source,
    traffic_source.medium AS first_user_medium,
    traffic_source.name AS first_user_campaign,

    COUNT(*) AS total_events,

    COUNTIF(event_name = 'session_start') AS sessions,

    COUNTIF(event_name = 'view_item') AS view_item_events,

    COUNTIF(event_name = 'add_to_cart') AS add_to_cart_events,

    COUNTIF(event_name = 'begin_checkout') AS begin_checkout_events,

    COUNTIF(event_name = 'purchase') AS purchase_events,

    SUM(
      CASE
        WHEN event_name = 'purchase'
        THEN ecommerce.purchase_revenue
        ELSE 0
      END
    ) AS purchase_revenue

  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

  GROUP BY
    user_pseudo_id,
    first_user_source,
    first_user_medium,
    first_user_campaign
)

SELECT
  first_user_source,
  first_user_medium,
  first_user_campaign,

  COUNT(DISTINCT user_pseudo_id) AS acquired_users,

  SUM(total_events) AS total_events,

  SUM(sessions) AS sessions,

  SUM(view_item_events) AS view_item_events,

  SUM(add_to_cart_events) AS add_to_cart_events,

  SUM(begin_checkout_events) AS begin_checkout_events,

  SUM(purchase_events) AS purchase_events,

  SUM(purchase_revenue) AS purchase_revenue

FROM
  user_acquisition

GROUP BY
  first_user_source,
  first_user_medium,
  first_user_campaign

ORDER BY
  acquired_users DESC;
