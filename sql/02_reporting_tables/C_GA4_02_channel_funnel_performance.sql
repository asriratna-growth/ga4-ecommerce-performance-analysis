-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Channel Funnel Performance
-- Purpose: Compare ecommerce funnel performance across marketing acquisition channels.
-- Used by: Conversion & Funnel dashboard
-- =========================================================

CREATE OR REPLACE TABLE
`ga4-performance-analysis-0726.ga4_reporting.channel_funnel_performance`
AS

/*=========================================================
  C_GA4_02_channel_funnel_performance
==========================================================*/

WITH user_channel_funnel AS (

SELECT

    user_pseudo_id,

    COALESCE(
        traffic_source.source,
        '(direct)'
    ) AS channel,

    MAX(CASE WHEN event_name='view_item' THEN 1 ELSE 0 END) AS viewed_item,

    MAX(CASE WHEN event_name='add_to_cart' THEN 1 ELSE 0 END) AS add_to_cart,

    MAX(CASE WHEN event_name='begin_checkout' THEN 1 ELSE 0 END) AS begin_checkout,

    MAX(CASE WHEN event_name='add_shipping_info' THEN 1 ELSE 0 END) AS add_shipping,

    MAX(CASE WHEN event_name='add_payment_info' THEN 1 ELSE 0 END) AS add_payment,

    MAX(CASE WHEN event_name='purchase' THEN 1 ELSE 0 END) AS purchase

FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

GROUP BY
user_pseudo_id,
channel

),

channel_summary AS (

SELECT

channel,

COUNT(*) AS users,

SUM(viewed_item) AS view_item_users,

SUM(add_to_cart) AS add_to_cart_users,

SUM(begin_checkout) AS begin_checkout_users,

SUM(add_shipping) AS add_shipping_users,

SUM(add_payment) AS add_payment_users,

SUM(purchase) AS purchase_users

FROM user_channel_funnel

GROUP BY
channel

)

SELECT

DENSE_RANK() OVER(
ORDER BY purchase_users DESC
) AS channel_rank,

channel,

users,

view_item_users,

add_to_cart_users,

begin_checkout_users,

add_shipping_users,

add_payment_users,

purchase_users,

ROUND(
SAFE_DIVIDE(view_item_users,users)*100,2
) AS view_item_pct,

ROUND(
SAFE_DIVIDE(add_to_cart_users,view_item_users)*100,2
) AS add_to_cart_pct,

ROUND(
SAFE_DIVIDE(begin_checkout_users,add_to_cart_users)*100,2
) AS checkout_pct,

ROUND(
SAFE_DIVIDE(add_shipping_users,begin_checkout_users)*100,2
) AS shipping_pct,

ROUND(
SAFE_DIVIDE(add_payment_users,add_shipping_users)*100,2
) AS payment_pct,

ROUND(
SAFE_DIVIDE(purchase_users,add_payment_users)*100,2
) AS purchase_pct,

ROUND(
SAFE_DIVIDE(purchase_users,users)*100,2
) AS overall_purchase_pct,

CURRENT_TIMESTAMP() AS report_generated_at

FROM channel_summary

ORDER BY
channel_rank;
