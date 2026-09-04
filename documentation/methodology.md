# Methodology

This document describes the analytical workflow used to transform the GA4 ecommerce event-level dataset into reporting tables, analysis outputs, and the final dashboard.

## 1. Data Source

The analysis uses the GA4 Obfuscated Sample Ecommerce Dataset available through the Google BigQuery Public Dataset.

The source data contains event-level ecommerce and user interaction data.

## 2. Data Preparation

The first stage explores the structure and contents of the dataset.

The analysis includes:

- Dataset overview
- Available event names
- Event parameters
- Traffic source dimensions
- Ecommerce fields and item-level data

These queries establish the available data structure before building the reporting layer.

## 3. Reporting Tables

The second stage transforms the source data into structured reporting tables for analysis and dashboard development.

The reporting layer covers three major areas:

### Acquisition & Traffic

- User acquisition performance
- Acquisition conversion rate
- User acquisition summary
- Traffic acquisition performance
- Channel grouping performance

### Conversion & Funnel

- Ecommerce funnel performance
- Funnel reporting table
- Channel funnel performance
- Checkout funnel performance
- Payment drop-off analysis by device

### Landing Page & Performance

- Session landing pages
- Session performance
- Landing page performance
- Conversion trends
- Performance trend summary

## 4. Analysis Queries

The third stage uses the reporting tables to answer specific business questions.

The analysis queries cover:

- Conversion trend analysis
- Acquisition summary analysis
- Checkout analysis

## 5. Dashboard Development

The reporting tables and analysis outputs are used to build the GA4 Ecommerce Performance Dashboard.

The dashboard evaluates:

- Overall ecommerce performance
- Acquisition performance
- Conversion funnel performance
- Checkout performance
- Landing page effectiveness
- Performance trends
- Business insights
- Strategic recommendations & Key takeaways

## 6. Insight Development

The final stage translates analytical findings into business insights and strategic recommendations.

The objective is to move from:

`Data → Metrics → Analysis → Insight → Business Action`

## Analytical Workflow

`Raw GA4 Data`
↓
`Data Preparation`
↓
`Reporting Tables`
↓
`Analysis Queries`
↓
`Dashboard`
↓
`Business Insights`
↓
`Strategic Recommendations`
