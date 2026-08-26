-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Ecommerce Funnel Performance
-- Purpose: Measure user progression across key ecommerce funnel stages.
-- Used by: Conversion & Funnel dashboard
-- =========================================================

WITH user_funnel AS (

SELECT

    user_pseudo_id,

    MAX(CASE WHEN event_name='view_item' THEN 1 ELSE 0 END) AS viewed_item,

    MAX(CASE WHEN event_name='add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,

    MAX(CASE WHEN event_name='begin_checkout' THEN 1 ELSE 0 END) AS began_checkout,

    MAX(CASE WHEN event_name='add_shipping_info' THEN 1 ELSE 0 END) AS added_shipping,

    MAX(CASE WHEN event_name='add_payment_info' THEN 1 ELSE 0 END) AS added_payment,

    MAX(CASE WHEN event_name='purchase' THEN 1 ELSE 0 END) AS purchased

FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

GROUP BY
user_pseudo_id

)

SELECT

COUNT(*) AS total_users,

SUM(viewed_item) AS view_item_users,

SUM(added_to_cart) AS add_to_cart_users,

SUM(began_checkout) AS begin_checkout_users,

SUM(added_shipping) AS add_shipping_users,

SUM(added_payment) AS add_payment_users,

SUM(purchased) AS purchasing_users

FROM
user_funnel;
