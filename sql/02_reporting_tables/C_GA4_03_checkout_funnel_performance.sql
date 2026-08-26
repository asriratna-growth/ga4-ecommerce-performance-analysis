-- =========================================================
-- GA4 Ecommerce Performance Analysis
-- Reporting Table: Checkout Funnel Performance
-- Purpose: Analyze user progression and drop-off across the checkout process.
-- Used by: Conversion & Funnel dashboard
-- =========================================================

  CREATE OR REPLACE TABLE
`ga4-performance-analysis-0726.ga4_reporting.checkout_funnel_performance`
AS

WITH checkout_summary AS (

SELECT

COUNT(DISTINCT CASE
    WHEN event_name='begin_checkout'
    THEN user_pseudo_id
END) AS checkout_users,

COUNT(DISTINCT CASE
    WHEN event_name='add_shipping_info'
    THEN user_pseudo_id
END) AS shipping_users,

COUNT(DISTINCT CASE
    WHEN event_name='add_payment_info'
    THEN user_pseudo_id
END) AS payment_users,

COUNT(DISTINCT CASE
    WHEN event_name='purchase'
    THEN user_pseudo_id
END) AS purchase_users

FROM
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

),

metrics AS (

SELECT

*,

ROUND(
SAFE_DIVIDE(shipping_users,checkout_users)*100,2
) AS shipping_completion_pct,

ROUND(
SAFE_DIVIDE(payment_users,shipping_users)*100,2
) AS payment_completion_pct,

ROUND(
SAFE_DIVIDE(purchase_users,payment_users)*100,2
) AS purchase_completion_pct,

ROUND(
SAFE_DIVIDE(purchase_users,checkout_users)*100,2
) AS overall_checkout_completion_pct,

ROUND(
100 - SAFE_DIVIDE(shipping_users,checkout_users)*100,2
) AS checkout_dropoff_pct,

ROUND(
100 - SAFE_DIVIDE(payment_users,shipping_users)*100,2
) AS shipping_dropoff_pct,

ROUND(
100 - SAFE_DIVIDE(purchase_users,payment_users)*100,2
) AS payment_dropoff_pct

FROM checkout_summary

)

SELECT

checkout_users,

shipping_users,

payment_users,

purchase_users,

shipping_completion_pct,

payment_completion_pct,

purchase_completion_pct,

overall_checkout_completion_pct,

CASE

WHEN checkout_dropoff_pct >= shipping_dropoff_pct
AND checkout_dropoff_pct >= payment_dropoff_pct
THEN 'Checkout → Shipping'

WHEN shipping_dropoff_pct >= payment_dropoff_pct
THEN 'Shipping → Payment'

ELSE 'Payment → Purchase'

END AS largest_dropoff_stage,

GREATEST(

checkout_dropoff_pct,

shipping_dropoff_pct,

payment_dropoff_pct

) AS largest_dropoff_pct,

CURRENT_TIMESTAMP() AS report_generated_at

FROM metrics;
