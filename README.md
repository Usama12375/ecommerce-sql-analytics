# E-Commerce Sales Analytics — SQL Portfolio Project

## Overview
A end-to-end SQL analytics project simulating a real e-commerce business. 
The goal was to answer 10 real business questions using SQL — ranging from 
basic aggregations to advanced window functions and CTEs.

## Database Schema
5 tables: `customers`, `products`, `orders`, `order_items`, `returns`

## Business Questions Answered
1. Total revenue generated per month
2. Top 5 best-selling products by quantity sold
3. Customers who have placed more than one order
4. Revenue ranking per product category
5. Month-over-month revenue growth
6. Running total of revenue over time
7. Return rate by product category
8. Top 25% customers by total spend
9. First vs repeat order classification per customer
10. Average days between orders per customer

## SQL Concepts Used
- JOINs (2, 3, and 4 table joins)
- GROUP BY, HAVING
- Subqueries and CTEs
- Window Functions: ROW_NUMBER, RANK, NTILE, LAG, SUM OVER
- CASE statements
- Date functions: DATE_FORMAT, DATEDIFF

## Tools
- MySQL 8.0

## How to Run
1. Run `schema.sql` to create the database and tables
2. Run `data.sql` to insert sample data
3. Run any query from `queries.sql`
