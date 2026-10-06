# Olist E-Commerce Analysis

## Project Overview

An end-to-end e-commerce analytics project using SQL, Python, and Power BI to evaluate sales performance, customer behavior, category growth, delivery experience, and seller performance using the Olist Brazilian E-Commerce Public Dataset.

The project focuses on answering practical business questions rather than simply describing the data: identifying where growth is coming from, where performance is weakening, and which areas may require management attention.

## Business Objectives

The analysis was designed to answer five key business areas:

* How are sales, orders, customers, and average order value performing?
* What is driving category-level growth or decline?
* How much of the customer base consists of repeat buyers?
* How does delivery performance relate to customer experience?
* How concentrated is marketplace performance among sellers?

## Dataset

**Source:** Olist Brazilian E-Commerce Public Dataset

The dataset contains approximately 100K orders from a Brazilian e-commerce marketplace and includes information on:

* Customers
* Orders
* Order items
* Payments
* Reviews
* Products
* Sellers
* Geolocation
* Product category translations

### Analysis Period

The dataset spans from September 2016 to October 2018.

For comparable growth analysis, the project focuses primarily on January 2017 to August 2018, with January versus August 2018 used for the final month-to-month performance comparison.

## Tools and Technologies

| Tool             | Purpose                                                                              |
| ---------------- | ------------------------------------------------------------------------------------ |
| SQL / PostgreSQL | Business analysis, joins, aggregations, CTEs, window functions, and KPI calculations |
| Python / Pandas  | Data preparation, exploratory analysis, and validation                               |
| Power BI         | Interactive dashboard, KPI reporting, and business storytelling                      |
| Jupyter Notebook | Python analysis and documentation                                                    |

## Analytical Approach

The project followed an end-to-end analytical workflow:

**Raw Data → Data Preparation → SQL Analysis → Python Validation → Power BI Dashboard → Business Insights → Recommendations**

### SQL

Key techniques included:

* Multi-table joins
* CTEs
* Subqueries
* CASE statements
* Aggregations
* Window functions
* Customer purchase-frequency analysis
* Month-over-month comparisons
* Category growth-driver classification
* Seller performance analysis
* Delivery-time analysis

### Python

Python was used for:

* Data loading and preparation
* Exploratory data analysis
* KPI validation
* Customer and category analysis
* Cross-checking important SQL results

### Power BI

The final dashboard contains five analytical pages:

1. Executive Overview
2. Customer & Growth
3. Category & Product
4. Delivery & Customer Experience
5. Seller Performance

## Key Business Findings

### 1. Sales declined despite a slight increase in AOV

Comparing January 2018 with August 2018:

* Delivered orders declined by 10.16%
* Sales declined by 9.31%
* Average Order Value increased by 0.94%

**Business meaning:**
The decline was primarily driven by lower order volume rather than a deterioration in transaction value.

**Management implication:**
Improving order acquisition and conversion should be a higher priority than simply increasing basket size.

### 2. Category performance shows multiple growth patterns

The category analysis classified categories according to changes in sales and order volume between January and August 2018.

The analysis identified:

* 18 Volume-driven categories
* 17 Double-pressure categories
* 16 Value/mix-pressure categories
* 10 Expansion categories
* 7 New/no-January-activity categories
* 5 categories with no material change

**Business meaning:**
Marketplace performance was not moving uniformly. Some categories were expanding while others were experiencing simultaneous pressure in both sales and volume.

The Expansion group represents the strongest positive signal, while Double pressure represents the most concerning pattern.

### 3. Double-pressure categories experienced a major decline

Sales from the Double-pressure group declined from approximately:

**R$371.3K to R$201.6K**

between January and August 2018.

**Business meaning:**
These categories experienced deterioration in both sales and order volume, making them stronger candidates for investigation than categories where only the sales mix changed.

**Management implication:**
Management should investigate demand, pricing, assortment, availability, and seller coverage within these categories before allocating additional resources.

### 4. Repeat customers represent a small but valuable segment

Approximately:

* 96.88% of customers were one-time buyers
* 3.12% were repeat customers

Despite their small share, repeat customers generated approximately 5.73% of total sales.

**Business meaning:**
The marketplace has a significant opportunity to improve customer retention.

A relatively small repeat-customer segment contributes disproportionately more revenue than its customer share.

**Management implication:**
Retention initiatives should focus on converting successful first purchases into second purchases rather than relying entirely on new-customer acquisition.

### 5. Delivery performance is an important customer-experience metric

The analysis identified approximately 96.5K delivered orders with an average delivery duration of around 12 days.

The analysis also compared delivery performance with customer review outcomes to evaluate the relationship between operational performance and customer experience.

**Business meaning:**
Delivery is not simply an operational KPI. It is directly relevant to marketplace customer experience.

**Management implication:**
Monitoring delivery duration, delays, and review outcomes together can help identify operational problems that may otherwise remain hidden when logistics and customer feedback are analyzed separately.

### 6. Seller performance is concentrated

Seller-level analysis was used to examine sales contribution and marketplace concentration.

**Business meaning:**
A marketplace can become exposed to operational or commercial risk when a relatively small group of sellers contributes a significant portion of activity.

**Management implication:**
High-performing sellers should be retained and supported, while concentration risk should be monitored to maintain marketplace resilience.

## Strategic Recommendations

Based on the analysis, five priorities emerge:

### 1. Recover declining order volume

Investigate the causes behind the decline in order volume, particularly across categories showing simultaneous sales and volume pressure.

### 2. Prioritize double-pressure categories

Use category-level diagnostics to determine whether the decline is caused by demand weakness, pricing, product availability, assortment, or seller-side issues.

### 3. Increase second-purchase conversion

The very small repeat-customer base represents a meaningful retention opportunity.

### 4. Strengthen delivery monitoring

Track delivery duration and customer reviews together to identify operational issues that affect customer satisfaction.

### 5. Monitor seller concentration

Maintain strong relationships with high-performing sellers while reducing excessive dependence on a small number of marketplace participants.

## Dashboard

The Power BI dashboard provides an executive-to-operational view of the marketplace.

### Dashboard Pages

**Executive Overview**
High-level KPIs and overall sales, order, and customer trends.

**Customer & Growth**
Customer acquisition, repeat behavior, and growth patterns.

**Category & Product**
Category performance and growth-driver classification.

**Delivery & Customer Experience**
Delivery performance and review-related metrics.

**Seller Performance**
Seller contribution and marketplace concentration.

The dashboard is available in the repository as:

`olist_..._analysis.pdf`

## Validation and Quality Checks

Important KPIs and analytical outputs were cross-checked between SQL, Python, and Power BI.

Validation covered:

* Overall sales
* Orders
* Customers
* Average order value
* January to August 2018 performance
* Category growth-driver analysis
* Double-pressure category decline
* One-time versus repeat customers
* Delivery metrics
* Seller performance

The final dashboard and analytical outputs were reconciled before publication.

## Repository Structure

```text
olist-ecommerce-analysis/
│
├── README.md
├── olist_..._FINAL.ipynb
├── olist_..._FINAL.sql
└── olist_..._analysis.pdf
```

The raw Olist CSV files are not included because they are publicly available from the original dataset source.

## Future Improvements

Potential extensions to the analysis include:

* Customer lifetime value analysis
* Cohort retention analysis
* More advanced seller segmentation
* Predictive sales forecasting
* Customer churn prediction
* Delivery-delay prediction
* Product-level recommendation modeling

## Project Takeaway

This project demonstrates an end-to-end approach to turning raw marketplace data into business-focused insights using SQL, Python, and Power BI.

Rather than focusing only on descriptive KPIs, the analysis identifies what is changing, why it matters, and where management should investigate next.

### Tools

SQL | Python | Pandas | Power BI | PostgreSQL | Jupyter Notebook

**Project Type:** End-to-End E-Commerce Analytics
