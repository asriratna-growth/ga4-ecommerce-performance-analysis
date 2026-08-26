-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Acquisition Conversion Rate
-- Purpose: Measure conversion performance across acquisition sources and channels.
-- Used by: Acquisition Performance dashboard
-- =========================================================

WITH user_acquisition AS (
  SELECT
    user_pseudo_id,
    traffic_source.source AS first_user_source,
    traffic_source.medium AS first_user_medium,
    traffic_source.name AS first_user_campaign,

    MAX(
      CASE
        WHEN event_name = 'purchase' THEN 1
        ELSE 0
      END
    ) AS is_purchaser,

    SUM(
      CASE
        WHEN event_name = 'purchase'
        THEN COALESCE(ecommerce.purchase_revenue, 0)
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

  COUNTIF(is_purchaser = 1) AS purchasing_users,

  ROUND(
    SAFE_DIVIDE(
      COUNTIF(is_purchaser = 1),
      COUNT(DISTINCT user_pseudo_id)
    ) * 100,
    2
  ) AS user_conversion_rate_pct,

  ROUND(
    SUM(purchase_revenue),
    2
  ) AS purchase_revenue,

  ROUND(
    SAFE_DIVIDE(
      SUM(purchase_revenue),
      COUNT(DISTINCT user_pseudo_id)
    ),
    2
  ) AS revenue_per_acquired_user

FROM
  user_acquisition

GROUP BY
  first_user_source,
  first_user_medium,
  first_user_campaign

ORDER BY
  acquired_users DESC;
