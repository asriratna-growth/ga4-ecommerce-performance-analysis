-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Performance Trend Summary
-- Purpose: Summarize overall ecommerce performance trends across key business metrics.
-- Used by: Performance Trends dashboard
-- =========================================================

CREATE OR REPLACE TABLE
`ga4-performance-analysis-0726.ga4_reporting.performance_trend_summary`
AS

WITH daily_metrics AS (
  SELECT
    event_date,
    sessions,
    purchases,
    purchase_revenue,
    conversion_rate_pct,
    revenue_per_session
  FROM
    `ga4-performance-analysis-0726.ga4_reporting.conversion_trend`
),

summary AS (
  SELECT
    SUM(sessions) AS total_sessions,
    AVG(sessions) AS avg_sessions_per_day,

    SUM(purchases) AS total_purchases,
    AVG(purchases) AS avg_purchases_per_day,

    SUM(purchase_revenue) AS total_revenue,
    AVG(purchase_revenue) AS avg_revenue_per_day,

    AVG(conversion_rate_pct) AS avg_conversion_rate,
    AVG(revenue_per_session) AS avg_revenue_per_session
  FROM daily_metrics
),

max_sessions AS (
  SELECT
    sessions AS max_sessions,
    event_date AS max_sessions_date
  FROM daily_metrics
  ORDER BY sessions DESC
  LIMIT 1
),

max_purchases AS (
  SELECT
    purchases AS max_purchases,
    event_date AS max_purchases_date
  FROM daily_metrics
  ORDER BY purchases DESC
  LIMIT 1
),

max_revenue AS (
  SELECT
    purchase_revenue AS max_revenue,
    event_date AS max_revenue_date
  FROM daily_metrics
  ORDER BY purchase_revenue DESC
  LIMIT 1
),

max_conversion AS (
  SELECT
    conversion_rate_pct AS max_conversion_rate,
    event_date AS max_conversion_date
  FROM daily_metrics
  ORDER BY conversion_rate_pct DESC
  LIMIT 1
),

max_rps AS (
  SELECT
    revenue_per_session AS max_revenue_per_session,
    event_date AS max_rps_date
  FROM daily_metrics
  ORDER BY revenue_per_session DESC
  LIMIT 1
)

SELECT
  s.*,

  ms.max_sessions,
  ms.max_sessions_date,

  mp.max_purchases,
  mp.max_purchases_date,

  mr.max_revenue,
  mr.max_revenue_date,

  mc.max_conversion_rate,
  mc.max_conversion_date,

  rps.max_revenue_per_session,
  rps.max_rps_date,

  CURRENT_TIMESTAMP() AS report_generated_at

FROM summary s
CROSS JOIN max_sessions ms
CROSS JOIN max_purchases mp
CROSS JOIN max_revenue mr
CROSS JOIN max_conversion mc
CROSS JOIN max_rps rps;
