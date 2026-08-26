-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Conversion Trend
-- Purpose: Track ecommerce conversion performance and revenue trends over time.
-- Used by: Performance Trends dashboard
-- =========================================================

CREATE OR REPLACE TABLE
`ga4-performance-analysis-0726.ga4_reporting.conversion_trend`
AS

/*=========================================================
  C_GA4_05_conversion_trend
=========================================================*/

WITH daily_metrics AS (

SELECT

    PARSE_DATE('%Y%m%d', event_date) AS event_date,

    COUNT(
        DISTINCT CONCAT(
            user_pseudo_id,
            CAST((
                SELECT value.int_value
                FROM UNNEST(event_params)
                WHERE key='ga_session_id'
            ) AS STRING)
        )
    ) AS sessions,

    COUNT(DISTINCT user_pseudo_id) AS users,

    COUNTIF(event_name='purchase') AS purchases,

    ROUND(
        SUM(
            CASE
                WHEN event_name='purchase'
                THEN ecommerce.purchase_revenue
                ELSE 0
            END
        ),
        2
    ) AS purchase_revenue

FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

GROUP BY
event_date

)

SELECT

event_date,

sessions,

users,

purchases,

purchase_revenue,

ROUND(
SAFE_DIVIDE(purchases,sessions)*100,
2
) AS conversion_rate_pct,

ROUND(
SAFE_DIVIDE(purchase_revenue,sessions),
2
) AS revenue_per_session,

CURRENT_TIMESTAMP() AS report_generated_at

FROM daily_metrics

ORDER BY
event_date;
