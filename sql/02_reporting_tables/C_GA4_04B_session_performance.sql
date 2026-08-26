-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Session Performance
-- Purpose: Build session-level performance metrics for landing page and user behavior analysis.
-- Used by: Landing Page Performance analysis
-- =========================================================

WITH page_views AS (

SELECT

    user_pseudo_id,

    (
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key = 'ga_session_id'
    ) AS session_id,

    (
        SELECT value.string_value
        FROM UNNEST(event_params)
        WHERE key = 'page_location'
    ) AS page_location,

    event_timestamp

FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE event_name = 'page_view'

),

landing_pages AS (

SELECT

    user_pseudo_id,

    session_id,

    page_location AS landing_page,

    ROW_NUMBER() OVER (

        PARTITION BY
            user_pseudo_id,
            session_id

        ORDER BY event_timestamp

    ) AS rn

FROM page_views

),

session_events AS (

SELECT

    user_pseudo_id,

    (
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key = 'ga_session_id'
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

)

SELECT

lp.user_pseudo_id,

lp.session_id,

lp.landing_page,

se.viewed_product,

se.added_to_cart,

se.began_checkout,

se.purchased,

se.purchase_revenue

FROM landing_pages lp

LEFT JOIN session_events se

ON lp.user_pseudo_id = se.user_pseudo_id
AND lp.session_id = se.session_id

WHERE lp.rn = 1

LIMIT 100;
