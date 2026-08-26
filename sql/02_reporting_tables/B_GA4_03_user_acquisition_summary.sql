-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: User Acquisition Summary
-- Purpose: Summarize user acquisition performance using key user and engagement metrics.
-- Used by: Acquisition Performance dashboard
-- =========================================================

WITH event_base AS (
  SELECT
    user_pseudo_id,

    traffic_source.source AS first_user_source,
    traffic_source.medium AS first_user_medium,
    traffic_source.name AS first_user_campaign,

    event_name,

    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS ga_session_id,

    (
      SELECT COALESCE(
        value.string_value,
        CAST(value.int_value AS STRING)
      )
      FROM UNNEST(event_params)
      WHERE key = 'session_engaged'
    ) AS session_engaged,

    ecommerce.purchase_revenue

  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
),

user_acquisition AS (
  SELECT
    user_pseudo_id,
    first_user_source,
    first_user_medium,
    first_user_campaign,

    COUNT(*) AS total_events,

    COUNT(
      DISTINCT CONCAT(
        user_pseudo_id,
        '-',
        CAST(ga_session_id AS STRING)
      )
    ) AS sessions,

    COUNT(
      DISTINCT CASE
        WHEN session_engaged = '1'
        THEN CONCAT(
          user_pseudo_id,
          '-',
          CAST(ga_session_id AS STRING)
        )
      END
    ) AS engaged_sessions,

    MAX(
      CASE
        WHEN event_name = 'purchase' THEN 1
        ELSE 0
      END
    ) AS is_purchaser,

    SUM(
      CASE
        WHEN event_name = 'purchase'
        THEN COALESCE(purchase_revenue, 0)
        ELSE 0
      END
    ) AS purchase_revenue

  FROM
    event_base

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

  SUM(sessions) AS sessions,

  SUM(engaged_sessions) AS engaged_sessions,

  SUM(total_events) AS total_events,

  COUNTIF(is_purchaser = 1) AS purchasing_users,

  ROUND(
    SAFE_DIVIDE(
      SUM(engaged_sessions),
      SUM(sessions)
    ) * 100,
    2
  ) AS engagement_rate_pct,

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
  ) AS revenue_per_acquired_user,

  ROUND(
    SAFE_DIVIDE(
      SUM(total_events),
      COUNT(DISTINCT user_pseudo_id)
    ),
    2
  ) AS events_per_user

FROM
  user_acquisition

GROUP BY
  first_user_source,
  first_user_medium,
  first_user_campaign

ORDER BY
  acquired_users DESC;
