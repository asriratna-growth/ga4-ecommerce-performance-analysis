-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Session Landing Pages
-- Purpose: Identify the first landing page visited during each user session.
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

)

SELECT

user_pseudo_id,

session_id,

landing_page

FROM landing_pages

WHERE rn = 1

ORDER BY user_pseudo_id

LIMIT 100;
