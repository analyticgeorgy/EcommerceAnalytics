
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
