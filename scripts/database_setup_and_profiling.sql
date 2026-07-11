
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

SELECT
  COUNT(*) total_rows,
  COUNT(order_id),
  COUNT(customer_id),
  COUNT(order_status),
  COUNT(order_purchase_timestamp),
  COUNT(order_approved_at),
  COUNT(order_delivered_carrier_date),
  COUNT(order_delivered_customer_date),
  COUNT(order_estimated_delivery_date)
FROM raw.olist_orders_dataset;

SELECT
  COUNT(*) total_rows,
  COUNT(product_id),
  COUNT(product_category_name),
  COUNT(product_name_length),
  COUNT(product_description_length),
  COUNT(product_photos_qty),
  COUNT(product_weight_g),
  COUNT(product_length_cm),
  COUNT(product_height_cm),
  COUNT(product_width_cm)
FROM raw.olist_products_dataset;

SELECT
  COUNT(*) total_rows,
  COUNT(seller_id),
  COUNT(seller_zip_code_prefix),
  COUNT(seller_city),
  COUNT(seller_state)
FROM raw.olist_sellers_dataset;

SELECT
  COUNT(*) total_rows,
  COUNT(product_category_name),
  COUNT(product_category_name_english)
FROM raw.product_category_name_translation;

--Stage 3 : Duplicate Keys
SELECT
  customer_id,
  COUNT(*) occurrences
FROM raw.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
  order_id,
  order_item_id,
  COUNT(*) occurrences
FROM raw.olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

  
SELECT
  order_id,
  payment_sequential,
  COUNT(*) occurrences
FROM raw.olist_order_payments_dataset
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

SELECT
  review_id,
  order_id,
  COUNT(*) occurrences
FROM raw.olist_order_reviews_dataset
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;

SELECT
  order_id,
  COUNT(*) occurrences
FROM raw.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
  product_id,
  COUNT(*) occurrences
FROM raw.olist_products_dataset
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT
  seller_id,
  COUNT(*) occurrences
FROM raw.olist_sellers_dataset
GROUP BY seller_id
HAVING COUNT(*) > 1;

--Stage 3 : Referential Integrity
SELECT
  COUNT(*) orphan_records
FROM raw.olist_orders_dataset o
LEFT JOIN raw.olist_customers_dataset c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL; --returns 0, therefore no orphan records

SELECT
  COUNT(*) orphan_records
FROM raw.olist_order_items_dataset i
LEFT JOIN raw.olist_orders_dataset o
ON i.order_id = o.order_id
WHERE o.order_id IS NULL; --returns 0, therefore no orphan records

SELECT
  COUNT(*) orphan_records
FROM raw.olist_order_reviews_dataset r
LEFT JOIN raw.olist_orders_dataset o
ON r.order_id = o.order_id
WHERE o.order_id IS NULL; --returns 0, therefore no orphan records

SELECT
  COUNT(*) orphan_records
FROM raw.olist_order_items_dataset i
LEFT JOIN raw.olist_sellers_dataset s
ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL; --returns 0, therefore no orphan records

SELECT
  COUNT(*) orphan_records
FROM raw.olist_order_items_dataset i
LEFT JOIN raw.olist_products_dataset p
ON i.product_id = p.product_id
WHERE p.product_id IS NULL; --returns 34,445 rows.NOTE that this represents the number of affected rows in the order_items(34,445 order items records reference a product
--that does not exist in the products_dataset table)
--, but in those affected rows, some products were ordered more than once so we want also to find the distinct products which we dont have their records in the products table(most likely products which were removed
--from the products catalog)

SELECT
  COUNT(DISTINCT i.product_id) missing_products
FROM raw.olist_order_items_dataset i
LEFT JOIN raw.olist_products_dataset p
ON i.product_id = p.product_id
WHERE p.product_id IS NULL; --returns 9999 rows, this means that 9999 unique products in the order_items_dataset table does not have a corresponding record in the 
--products table (were most likely removed from the products catalog)





