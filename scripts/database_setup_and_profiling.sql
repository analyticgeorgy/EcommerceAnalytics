
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

