
--Create the database
CREATE DATABASE ecommerce_analytics;

--Create schemas
CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA warehouse;

--After loading the raw data into the raw schema, now we need to extract some valuable insights from the tables including:
--(a)the column names
--(b)their data types
--(c)their maximum lengths, whether they are nullable or not and other insights too
--We will use the sp_help stored procedure to find out these information

EXEC sp_help 'raw.olist_customers_dataset'
EXEC sp_help 'raw.olist_geolocation_dataset';
EXEC sp_help 'raw.olist_order_items_dataset';
EXEC sp_help 'raw.olist_order_payments_dataset';
EXEC sp_help 'raw.olist_order_reviews_dataset';
EXEC sp_help 'raw.olist_orders_dataset';
EXEC sp_help 'raw.olist_products_dataset';
EXEC sp_help 'raw.olist_sellers_dataset';
EXEC sp_help 'raw.product_category_name_translation';

--Now we begin the data profiling
--Stage 1 : Table Overview , Row counts
SELECT
COUNT(*) total_rows
FROM raw.olist_customers_dataset;

SELECT
COUNT(*) total_rows
FROM  raw.olist_geolocation_dataset;

SELECT
COUNT(*) total_rows
FROM raw.olist_order_items_dataset;

SELECT
  COUNT(*) total_rows
FROM raw.olist_order_payments_dataset;

SELECT
  COUNT(*) total_rows
FROM raw.olist_order_reviews_dataset;

SELECT
  COUNT(*) total_rows
FROM raw.olist_orders_dataset;

SELECT
  COUNT(*) total_rows
FROM raw.olist_products_dataset;

SELECT
  COUNT(*) total_rows
FROM raw.olist_sellers_dataset;

SELECT
  COUNT(*) total_rows
FROM raw.product_category_name_translation;

--Stage 2 : Missing Values
--NOTE : Here we showcase the difference between COUNT(*) and COUNT(column_name)
--The COUNT(*) counts all rows including the one with NULL while COUNT(column_name) counts only rows where that specific column is NOT NULL
SELECT
  COUNT(*) total_rows,
  COUNT(customer_id),
  COUNT(customer_unique_id),
  COUNT(customer_zip_code_prefix),
  COUNT(customer_city),
  COUNT(customer_state)
FROM raw.olist_customers_dataset;

SELECT
COUNT(*) total_rows,
COUNT(geolocation_zip_code_prefix),
COUNT(geolocation_lat),
COUNT(geolocation_lng),
COUNT(geolocation_city),
COUNT(geolocation_state)
FROM raw.olist_geolocation_dataset;

SELECT
  COUNT(*) total_rows,
  COUNT(order_id),
  COUNT(order_item_id),
  COUNT(product_id),
  COUNT(seller_id),
  COUNT(shipping_limit_date),
  COUNT(price),
  COUNT(freight_value)
FROM raw.olist_order_items_dataset;

SELECT
  COUNT(*) total_rows,
  COUNT(order_id),
  COUNT(payment_sequential),
  COUNT(payment_type),
  COUNT(payment_installments),
  COUNT(payment_value)
FROM raw.olist_order_payments_dataset;

SELECT
  COUNT(*) total_rows,
  COUNT(review_id),
  COUNT(order_id),
  COUNT(review_score),
  COUNT(review_comment_title),
  COUNT(review_comment_message),
  COUNT(review_creation_date),
  COUNT(review_answer_timestamp)
FROM raw.olist_order_reviews_dataset;
