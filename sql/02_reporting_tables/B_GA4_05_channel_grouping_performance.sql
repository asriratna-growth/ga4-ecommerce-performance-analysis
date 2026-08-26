-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Channel Grouping Performance
-- Purpose: Evaluate ecommerce performance across marketing channel groups.
-- Used by: Acquisition Performance dashboard
-- =========================================================

WITH event_base AS (
  SELECT
    event_timestamp,
    user_pseudo_id,
    event_name,

    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS ga_session_id,

    (
      SELECT value.string_value
      FROM UNNEST(event_params)
      WHERE key = 'source'
    ) AS session_source,

    (
      SELECT value.string_value
      FROM UNNEST(event_params)
      WHERE key = 'medium'
    ) AS session_medium,

    (
      SELECT value.string_value
      FROM UNNEST(event_params)
      WHERE key = 'campaign'
    ) AS session_campaign,

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

session_summary AS (
  SELECT
    user_pseudo_id,
    ga_session_id,

    ARRAY_AGG(
      session_source IGNORE NULLS
      ORDER BY event_timestamp
      LIMIT 1
    )[SAFE_OFFSET(0)] AS session_source,

    ARRAY_AGG(
      session_medium IGNORE NULLS
      ORDER BY event_timestamp
      LIMIT 1
    )[SAFE_OFFSET(0)] AS session_medium,

    ARRAY_AGG(
      session_campaign IGNORE NULLS
      ORDER BY event_timestamp
      LIMIT 1
    )[SAFE_OFFSET(0)] AS session_campaign,

    MAX(
      CASE
        WHEN session_engaged = '1' THEN 1
        ELSE 0
      END
    ) AS is_engaged_session,

    MAX(
      CASE
        WHEN event_name = 'purchase' THEN 1
        ELSE 0
      END
    ) AS is_converting_session,

    COUNT(*) AS total_events,

    SUM(
      CASE
        WHEN event_name = 'purchase'
        THEN COALESCE(purchase_revenue, 0)
        ELSE 0
      END
    ) AS purchase_revenue

  FROM
    event_base

  WHERE
    ga_session_id IS NOT NULL

  GROUP BY
    user_pseudo_id,
    ga_session_id
),

channel_grouping AS (
  SELECT
    *,

    CASE

      WHEN session_source IS NULL
        AND session_medium IS NULL
        THEN 'Direct'

      WHEN LOWER(session_source) = '(direct)'
        OR LOWER(session_medium) = '(none)'
        THEN 'Direct'

      WHEN LOWER(session_medium) = 'organic'
        THEN 'Organic Search'

      WHEN LOWER(session_medium) IN (
        'cpc',
        'ppc',
        'paidsearch'
      )
        THEN 'Paid Search'

      WHEN LOWER(session_medium) = 'email'
        OR LOWER(session_source) LIKE '%mail%'
        OR LOWER(session_source) LIKE '%newsletter%'
        THEN 'Email'

      WHEN LOWER(session_medium) = 'affiliate'
        THEN 'Affiliate'

      WHEN LOWER(session_source) LIKE '%facebook%'
        OR LOWER(session_source) LIKE '%instagram%'
        OR LOWER(session_source) LIKE '%youtube%'
        OR LOWER(session_source) LIKE '%twitter%'
        OR LOWER(session_source) LIKE '%linkedin%'
        OR LOWER(session_source) LIKE '%pinterest%'
        THEN 'Organic Social'

      WHEN LOWER(session_medium) = 'referral'
        THEN 'Referral'

      ELSE 'Other / Unknown'

    END AS channel_group

  FROM
    session_summary
)

SELECT
  channel_group,

  COUNT(*) AS sessions,

  SUM(is_engaged_session) AS engaged_sessions,

  SUM(is_converting_session) AS converting_sessions,

  SUM(total_events) AS total_events,

  ROUND(
    SAFE_DIVIDE(
      SUM(is_engaged_session),
      COUNT(*)
    ) * 100,
    2
  ) AS engagement_rate_pct,

  ROUND(
    SAFE_DIVIDE(
      SUM(is_converting_session),
      COUNT(*)
    ) * 100,
    2
  ) AS session_conversion_rate_pct,

  ROUND(
    SUM(purchase_revenue),
    2
  ) AS purchase_revenue,

  ROUND(
    SAFE_DIVIDE(
      SUM(purchase_revenue),
      COUNT(*)
    ),
    2
  ) AS revenue_per_session,

  ROUND(
    SAFE_DIVIDE(
      SUM(total_events),
      COUNT(*)
    ),
    2
  ) AS events_per_session

FROM
  channel_grouping

GROUP BY
  channel_group

ORDER BY
  sessions DESC;
