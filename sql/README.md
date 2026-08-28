# SQL

This folder contains the SQL queries developed for the GA4 Ecommerce Performance Analysis project.

The SQL workflow is organized into three stages:

## 1. Data Preparation

Folder: `01_data_preparation`

This stage explores and prepares the GA4 Obfuscated Sample Ecommerce Dataset.

The queries examine:

- Dataset overview
- Available event names
- Event parameters
- Traffic source structure
- Ecommerce fields and item-level data

## 2. Reporting Tables

Folder: `02_reporting_tables`

This stage creates reporting tables used as the data source for the dashboard and analysis.

The reporting tables support analysis across:

### Acquisition & Traffic

- User acquisition performance
- Acquisition conversion rate
- User acquisition summary
- Traffic acquisition performance
- Channel grouping performance

### Conversion & Funnel

- Ecommerce funnel performance
- Channel funnel performance
- Checkout funnel performance
- Payment drop-off analysis by device

### Landing Page & Performance

- Landing page performance
- Session landing pages
- Session performance
- Conversion trends
- Performance trend summary

## 3. Analysis Queries

Folder: `03_analysis_queries`

This stage contains analytical queries used to summarize key business performance and support dashboard insights.

The analysis includes:

- Conversion trend analysis
- User acquisition summary analysis
- Checkout analysis

## Workflow

The SQL development follows the process below:

`Raw GA4 Dataset → Data Preparation → Reporting Tables → Analysis Queries → Dashboard`

All queries are written in BigQuery Standard SQL and use the GA4 Obfuscated Sample Ecommerce Dataset.
