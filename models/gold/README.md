# Gold Layer - Dimensional Models

This directory contains the gold layer models that transform the Data Vault models from the silver layer into dimensional models (facts and dimensions) optimized for analytics.

## Structure

The gold layer is organized by business domains:

- **Sales**: Models related to customers, products, sales orders, and opportunities
- **HR**: Models related to employees, departments, job positions, and benefits
- **Inventory**: Models related to products, stock locations, inventory levels, and stock movements

Each domain contains dimension and fact tables following the dimensional modeling approach.

## Shared Dimensions

Some dimensions are shared across domains:

- **dim_date**: A date dimension used across all domains for time-based analysis
- **dim_product**: A product dimension used by both Sales and Inventory domains

## Dimensional Modeling Approach

The gold layer follows these dimensional modeling principles:

1. **Type 2 Slowly Changing Dimensions (SCD)**: Historical changes are tracked in dimension tables with effective dates and current flags
2. **Star Schema**: Fact tables reference dimension tables via surrogate keys
3. **Conformed Dimensions**: Shared dimensions are used across multiple fact tables
4. **Denormalized Dimensions**: Dimension tables contain denormalized attributes for easier querying

## Usage

The gold layer models are designed to be used directly by BI tools and for analytical queries. They provide:

- **Business-friendly naming**: Columns are named using business terminology
- **Performance optimization**: Tables are materialized for query performance
- **Analytical context**: Historical tracking and relationships are maintained
- **Consistency**: Common dimensions ensure consistent reporting across domains

## Naming Conventions

- Dimension tables: `dim_<entity>`
- Fact tables: `fact_<process>`

## Dependencies

The gold layer models depend on:

- Silver layer Data Vault models (hubs, links, satellites)
- Source data from the bronze layer for some fact tables
