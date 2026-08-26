-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Payment Drop Analysis by Device
-- Purpose: Identify payment-stage drop-off patterns across different device categories.
-- Used by: Conversion & Funnel dashboard
-- =========================================================

CREATE OR REPLACE TABLE
`ga4-performance-analysis-0726.ga4_reporting.payment_dropoff_by_device`
AS

WITH user_checkout AS (

SELECT

    user_pseudo_id,

    device.category AS device_type,

    MAX(CASE WHEN event_name = 'begin_checkout' THEN 1 ELSE 0 END) AS began_checkout,

    MAX(CASE WHEN event_name = 'add_shipping_info' THEN 1 ELSE 0 END) AS added_shipping,

    MAX(CASE WHEN event_name = 'add_payment_info' THEN 1 ELSE 0 END) AS added_payment,

    MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchased

FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

GROUP BY
user_pseudo_id,
device_type

),

summary AS (

SELECT

device_type,

COUNTIF(began_checkout = 1) AS checkout_users,

COUNTIF(added_shipping = 1) AS shipping_users,

COUNTIF(added_payment = 1) AS payment_users,

COUNTIF(purchased = 1) AS purchase_users

FROM user_checkout

GROUP BY device_type

)

SELECT

device_type,

checkout_users,

shipping_users,

payment_users,

purchase_users,

ROUND(SAFE_DIVIDE(shipping_users, checkout_users) * 100, 2) AS shipping_completion_pct,

ROUND(SAFE_DIVIDE(payment_users, shipping_users) * 100, 2) AS payment_completion_pct,

ROUND(SAFE_DIVIDE(purchase_users, payment_users) * 100, 2) AS purchase_completion_pct,

ROUND(SAFE_DIVIDE(purchase_users, checkout_users) * 100, 2) AS overall_checkout_completion_pct,

ROUND(100 - SAFE_DIVIDE(payment_users, shipping_users) * 100, 2) AS payment_dropoff_pct,

CURRENT_TIMESTAMP() AS report_generated_at

FROM summary

ORDER BY overall_checkout_completion_pct DESC;
