-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Landing Page Performance
-- Purpose: Evaluate landing page performance using traffic, engagement, and conversion metrics.
-- Used by: Landing Page Performance dashboard
-- =========================================================

CREATE OR REPLACE TABLE
`ga4-performance-analysis-0726.ga4_reporting.landing_page_performance`
AS

/*=========================================================
  C_GA4_04_landing_page_performance
=========================================================*/

WITH page_views AS (

SELECT

    user_pseudo_id,

    (
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key='ga_session_id'
    ) AS session_id,

    (
        SELECT value.string_value
        FROM UNNEST(event_params)
        WHERE key='page_location'
    ) AS landing_page_url,

    event_timestamp

FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE event_name='page_view'

),

landing_pages AS (

SELECT

    user_pseudo_id,

    session_id,

    landing_page_url,

    REGEXP_EXTRACT(
        landing_page_url,
        r'https?://[^/]+(/.*)?'
    ) AS landing_page_path,

    ROW_NUMBER() OVER(

        PARTITION BY
            user_pseudo_id,
            session_id

        ORDER BY event_timestamp

    ) AS rn

FROM page_views

),

session_performance AS (

SELECT

    user_pseudo_id,

    (
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key='ga_session_id'
    ) AS session_id,

    MAX(CASE WHEN event_name='view_item' THEN 1 ELSE 0 END) AS viewed_product,

    MAX(CASE WHEN event_name='add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,

    MAX(CASE WHEN event_name='begin_checkout' THEN 1 ELSE 0 END) AS began_checkout,

    MAX(CASE WHEN event_name='purchase' THEN 1 ELSE 0 END) AS purchased,

    SUM(
        CASE
            WHEN event_name='purchase'
            THEN ecommerce.purchase_revenue
            ELSE 0
        END
    ) AS purchase_revenue

FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

GROUP BY
user_pseudo_id,
session_id

),

landing_summary AS (

SELECT

    lp.landing_page_url,

    lp.landing_page_path,

    COUNT(*) AS sessions,

    COUNT(DISTINCT lp.user_pseudo_id) AS users,

    SUM(sp.viewed_product) AS viewed_product_sessions,

    SUM(sp.added_to_cart) AS add_to_cart_sessions,

    SUM(sp.began_checkout) AS checkout_sessions,

    SUM(sp.purchased) AS purchasing_sessions,

    ROUND(SUM(sp.purchase_revenue),2) AS purchase_revenue

FROM landing_pages lp

LEFT JOIN session_performance sp

ON lp.user_pseudo_id = sp.user_pseudo_id
AND lp.session_id = sp.session_id

WHERE lp.rn = 1

GROUP BY
landing_page_url,

landing_page_path

)

SELECT

DENSE_RANK() OVER(
ORDER BY sessions DESC
) AS traffic_rank,

DENSE_RANK() OVER(
ORDER BY purchase_revenue DESC
) AS revenue_rank,

DENSE_RANK() OVER(
ORDER BY SAFE_DIVIDE(purchase_revenue,sessions) DESC
) AS efficiency_rank,

landing_page_url,

landing_page_path,

sessions,

users,

viewed_product_sessions,

add_to_cart_sessions,

checkout_sessions,

purchasing_sessions,

purchase_revenue,

ROUND(
SAFE_DIVIDE(purchasing_sessions,sessions)*100,2
) AS conversion_rate_pct,

ROUND(
SAFE_DIVIDE(purchase_revenue,sessions),2
) AS revenue_per_session,

ROUND(
SAFE_DIVIDE(purchasing_sessions,sessions)*100,2
) AS purchases_per_100_sessions,

CURRENT_TIMESTAMP() AS report_generated_at

FROM landing_summary

ORDER BY revenue_rank;
