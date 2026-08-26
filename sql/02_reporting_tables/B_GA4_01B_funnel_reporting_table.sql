-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Funnel Reporting Table
-- Purpose: Consolidate key funnel metrics across user sessions and ecommerce conversion stages.
-- Used by: Conversion & Funnel analysis
-- =========================================================

WITH user_funnel AS (

SELECT

    user_pseudo_id,

    MAX(CASE WHEN event_name = 'view_item' THEN 1 ELSE 0 END) AS viewed_item,
    MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS add_to_cart,
    MAX(CASE WHEN event_name = 'begin_checkout' THEN 1 ELSE 0 END) AS begin_checkout,
    MAX(CASE WHEN event_name = 'add_shipping_info' THEN 1 ELSE 0 END) AS add_shipping,
    MAX(CASE WHEN event_name = 'add_payment_info' THEN 1 ELSE 0 END) AS add_payment,
    MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase

FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

GROUP BY
user_pseudo_id

),

funnel_summary AS (

SELECT

SUM(viewed_item)      AS view_item_users,
SUM(add_to_cart)      AS add_to_cart_users,
SUM(begin_checkout)   AS begin_checkout_users,
SUM(add_shipping)     AS add_shipping_users,
SUM(add_payment)      AS add_payment_users,
SUM(purchase)         AS purchase_users

FROM user_funnel

)

SELECT

'View Item' AS funnel_stage,

view_item_users AS users,

100.00 AS stage_conversion_rate_pct,

100.00 AS overall_conversion_rate_pct,

0 AS dropoff_users,

0.00 AS dropoff_rate_pct

FROM funnel_summary

UNION ALL

SELECT

'Add to Cart',

add_to_cart_users,

ROUND(
SAFE_DIVIDE(add_to_cart_users, view_item_users) * 100,2),

ROUND(
SAFE_DIVIDE(add_to_cart_users, view_item_users) * 100,2),

view_item_users - add_to_cart_users,

ROUND(
SAFE_DIVIDE(view_item_users - add_to_cart_users, view_item_users) * 100,2)

FROM funnel_summary

UNION ALL

SELECT

'Begin Checkout',

begin_checkout_users,

ROUND(
SAFE_DIVIDE(begin_checkout_users, add_to_cart_users) * 100,2),

ROUND(
SAFE_DIVIDE(begin_checkout_users, view_item_users) * 100,2),

add_to_cart_users - begin_checkout_users,

ROUND(
SAFE_DIVIDE(add_to_cart_users - begin_checkout_users, add_to_cart_users) * 100,2)

FROM funnel_summary

UNION ALL

SELECT

'Add Shipping Info',

add_shipping_users,

ROUND(
SAFE_DIVIDE(add_shipping_users, begin_checkout_users) * 100,2),

ROUND(
SAFE_DIVIDE(add_shipping_users, view_item_users) * 100,2),

begin_checkout_users - add_shipping_users,

ROUND(
SAFE_DIVIDE(begin_checkout_users - add_shipping_users, begin_checkout_users) * 100,2)

FROM funnel_summary

UNION ALL

SELECT

'Add Payment Info',

add_payment_users,

ROUND(
SAFE_DIVIDE(add_payment_users, add_shipping_users) * 100,2),

ROUND(
SAFE_DIVIDE(add_payment_users, view_item_users) * 100,2),

add_shipping_users - add_payment_users,

ROUND(
SAFE_DIVIDE(add_shipping_users - add_payment_users, add_shipping_users) * 100,2)

FROM funnel_summary

UNION ALL

SELECT

'Purchase',

purchase_users,

ROUND(
SAFE_DIVIDE(purchase_users, add_payment_users) * 100,2),

ROUND(
SAFE_DIVIDE(purchase_users, view_item_users) * 100,2),

add_payment_users - purchase_users,

ROUND(
SAFE_DIVIDE(add_payment_users - purchase_users, add_payment_users) * 100,2)

FROM funnel_summary;
