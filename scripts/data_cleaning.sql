
--Prepare the customers staging table transformations
SELECT
	TRIM(customer_id) AS customer_id,
	TRIM(customer_unique_id) AS customer_unique_id,
	customer_zip_code_prefix,
	TRIM(customer_city) AS customer_city,
	UPPER(TRIM(customer_state)) AS customer_state
INTO staging.olist_customers_dataset
FROM raw.olist_customers_dataset;

--Validate the table
--Check the row count
SELECT
  COUNT(*) total_rows
FROM staging.olist_customers_dataset

--Check whether the candidate key is still unique
SELECT
  customer_id,
  COUNT(*) AS occurrences
FROM staging.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1


--Create the products staging table
CREATE TABLE staging.olist_products_dataset
(
product_id VARCHAR(100),
product_category_name NVARCHAR(50),
product_name_length INT,
product_description_length INT,
product_photos_qty INT,
product_weight_g INT,
product_length_cm INT, 
product_height_cm INT,
product_width_cm INT
);

--Create the products staging table
CREATE TABLE staging.olist_products_dataset
(
product_id VARCHAR(100),
product_category_name NVARCHAR(50),
product_name_length INT,
product_description_length INT,
product_photos_qty INT,
product_weight_g INT,
product_length_cm INT, 
product_height_cm INT,
product_width_cm INT
)

--Load the data
INSERT INTO staging.olist_products_dataset
(
product_id,
product_category_name,
product_name_length,
product_description_length,
product_photos_qty,
product_weight_g,
product_length_cm,
product_height_cm,
product_width_cm
)
SELECT
TRIM(product_id),
TRIM(product_category_name),
product_name_length,
product_description_length,
product_photos_qty,
product_weight_g,
product_length_cm,
product_height_cm,
product_width_cm
FROM raw.olist_products_dataset

--Validation
--Check the row count
SELECT
COUNT(*)
FROM staging.olist_products_dataset

--Check whether the candidate key is still unique
SELECT
product_id,
COUNT(*) occurrences
FROM staging.olist_products_dataset
GROUP BY product_id
HAVING COUNT(*) > 1

SELECT * FROM staging.olist_products_dataset
WHERE product_name_length IS NULL

	
--Create the product_category_name_translation staging table
CREATE TABLE staging.product_category_name_translation
(
product_category_name NVARCHAR(50),
product_category_name_english VARCHAR(50)
)

--Load the data
INSERT INTO staging.product_category_name_translation
(
product_category_name,
product_category_name_english
)
SELECT
TRIM(product_category_name),
TRIM(product_category_name_english)
FROM raw.product_category_name_translation

--Validation
--Row count
SELECT
COUNT(*)
FROM staging.product_category_name_translation

--Create products_dataset table staging
CREATE TABLE staging.olist_products_dataset
(
product_id VARCHAR(100),
product_category_name NVARCHAR(50),
product_category_name_english VARCHAR(50),
product_name_length INT,
product_description_length INT,
product_photos_qty INT,
product_weight_g INT,
product_length_cm INT,
product_height_cm INT,
product_width_cm INT
)

--Load the data
INSERT INTO staging.olist_products_dataset
(
product_id,
product_category_name,
product_category_name_english,
product_name_length,
product_description_length,
product_photos_qty,
product_weight_g,
product_length_cm,
product_height_cm,
product_width_cm
)
SELECT
TRIM(p.product_id) product_id,
TRIM(p.product_category_name) product_category_name,
TRIM(t.product_category_name_english) product_category_name_english,
p.product_name_length,
p.product_description_length,
p.product_photos_qty,
p.product_weight_g,
p.product_length_cm,
p.product_height_cm,
p.product_width_cm
FROM raw.olist_products_dataset p
LEFT JOIN staging.product_category_name_translation t
ON p.product_category_name = t.product_category_name

--Validation
--Row Count
SELECT
COUNT(*)
FROM staging.olist_products_dataset

--Check whether candidate key is unique
SELECT
product_id,
COUNT(*) occurrences
FROM staging.olist_products_dataset
GROUP BY product_id
HAVING COUNT(*) > 1

--Missing translation names
SELECT
COUNT(*) missing_translations
FROM staging.olist_products_dataset
WHERE product_category_name IS NOT NULL
AND product_category_name_english IS NULL

SELECT
product_category_name,
COUNT(*) occurrences
FROM staging.olist_products_dataset
WHERE product_category_name_english IS NULL
GROUP BY product_category_name
ORDER BY occurrences DESC

SELECT *
FROM staging.product_category_name_translation
WHERE product_category_name IN
(
'portateis_cozinha_e_preparadores_de_alimentos',
'pc_gamer'
);


INSERT INTO staging.product_category_name_translation
(
product_category_name,
product_category_name_english
)
VALUES('portateis_cozinha_e_preparadores_de_alimentos', 'portable kitchen appliances'),
('pc_gamer', 'pc_gamer')

SELECT *
FROM staging.product_category_name_translation
WHERE product_category_name IN
(
'portateis_cozinha_e_preparadores_de_alimentos',
'pc_gamer'
);

UPDATE staging.olist_products_dataset
SET product_category_name_english = 'portable kitchen appliances'
WHERE product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'

UPDATE staging.olist_products_dataset
SET product_category_name_english = 'pc_gamer'
WHERE product_category_name = 'pc_gamer'

SELECT
COUNT(*) missing_translations
FROM staging.olist_products_dataset
WHERE product_category_name IS NOT NULL 
AND product_category_name_english IS NULL

--Now we move on to the staging orders_dataset table
--Check Date Conversion
--Here we verify whether the SQL Server can correct every timestamp correctly (checks for values that are not NULLs but will still cause problems while datatype casting/converting)
--Any column that returns a value not 0 has an issue
SELECT
SUM(
	CASE WHEN order_purchase_timestamp IS NOT NULL
	AND TRY_CONVERT(DATETIME2, order_purchase_timestamp) IS NULL THEN 1 ELSE 0 END 
) AS invalid_purchase,
SUM(
	CASE WHEN order_approved_at IS NOT NULL
	AND TRY_CONVERT(DATETIME2, order_approved_at) IS NULL THEN 1 ELSE 0 END
) AS invalid_approved,
SUM(
	CASE WHEN order_delivered_carrier_date IS NOT NULL
	AND TRY_CONVERT(DATETIME2, order_delivered_carrier_date) IS NULL THEN 1 ELSE 0 END
) AS invalid_carrier,
SUM(
	CASE WHEN order_delivered_customer_date IS NOT NULL
	AND TRY_CONVERT(DATETIME2, order_delivered_customer_date) IS NULL THEN 1 ELSE 0 END
) AS invalid_delivered,
SUM(
	CASE WHEN order_estimated_delivery_date IS NOT NULL
	AND TRY_CONVERT(DATETIME2, order_estimated_delivery_date) IS NULL THEN 1 ELSE 0 END
) AS invalid_estimated
FROM raw.olist_orders_dataset

--Load the data
INSERT INTO staging.olist_orders_dataset
(
order_id,
customer_id,
order_status,
order_purchase_timestamp,
order_approved_at,
order_delivered_carrier_date,
order_delivered_customer_date,
order_estimated_delivery_date
)
SELECT
TRIM(order_id),
TRIM(customer_id),
TRIM(order_status),
TRY_CONVERT(DATETIME2, order_purchase_timestamp),
TRY_CONVERT(DATETIME2, order_approved_at),
TRY_CONVERT(DATETIME2, order_delivered_carrier_date),
TRY_CONVERT(DATETIME2, order_delivered_customer_date),
TRY_CONVERT(DATETIME2, order_estimated_delivery_date)
FROM raw.olist_orders_dataset


