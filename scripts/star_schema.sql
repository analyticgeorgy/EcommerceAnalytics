--1. DimDate
SELECT
    MIN(order_purchase_timestamp) AS first_purchase_date,
    MAX(order_purchase_timestamp) AS last_purchase_date
FROM staging.olist_orders_dataset; --Find the date range in which we will create our calendar DimDate

CREATE TABLE warehouse.DimDate
(
	date_key INT NOT NULL,
	full_date DATE NOT NULL,
	year INT NOT NULL,
	quarter INT NOT NULL,
	month INT NOT NULL,
	month_name VARCHAR(20) NOT NULL,
	month_short_name VARCHAR(3) NOT NULL,
	week_of_year INT NOT NULL,
	day_of_month INT NOT NULL,
	day_of_year INT NOT NULL,
	day_name VARCHAR(20) NOT NULL,
	day_of_week INT NOT NULL,
	is_weekend BIT NOT NULL,
	CONSTRAINT PK_DimDate PRIMARY KEY (date_key)
)

DECLARE @Start_date DATE;
DECLARE @End_date DATE;

SELECT
	@Start_date = CAST(MIN(order_purchase_timestamp) AS DATE),
	@End_date = CAST(MAX(order_purchase_timestamp) AS DATE)
FROM staging.olist_orders_dataset;

WITH DateSeries AS
(
	SELECT @Start_date AS full_date
	UNION ALL
	SELECT DATEADD(DAY, 1, full_date)
	FROM DateSeries
	WHERE full_date < @End_date
)
INSERT INTO warehouse.DimDate
(
	date_key,
	full_date,
	[year],
	[quarter],
	[month],
	month_name,
	month_short_name,
	week_of_year,
	day_of_month,
	day_of_year,
	day_name,
	day_of_week,
	is_weekend
)
SELECT
	CONVERT(INT, CONVERT(CHAR(8), full_date, 112)) AS date_key,
	full_date,
	YEAR(full_date),
	DATEPART(QUARTER, full_date),
	MONTH(full_date),
	DATENAME(MONTH, full_date),
	LEFT(DATENAME(MONTH, full_date), 3),
	DATEPART(WEEK, full_date),
	DAY(full_date),
	DATEPART(DAYOFYEAR, full_date),
	DATENAME(WEEKDAY, full_date),
	DATEPART(WEEKDAY, full_date),
	CASE WHEN DATEPART(WEEKDAY, full_date) IN (1, 7)
	     THEN 1
		 ELSE 0
	END
FROM DateSeries
OPTION (MAXRECURSION 0);

--Validation
SELECT
	COUNT(*) date_rows
FROM warehouse.DimDate

SELECT
	MIN(full_date) first_date,
	MAX(full_date) last_date
FROM warehouse.DimDate

--Check for gaps inside the dates (whether SQL has mistakenly skipped some days in between dates)
SELECT
	d1.full_date AS [current_date],
	d2.full_date AS next_date
FROM warehouse.DimDate d1
JOIN warehouse.DimDate d2
ON d2.date_key = d1.date_key + 1
WHERE DATEDIFF(DAY, d1.full_date, d2.full_date) <> 1 --returns no rows meaning no days were skipped

--2.DimCustomer
CREATE TABLE warehouse.DimCustomer
(
	customer_key INT IDENTITY(1,1) NOT NULL,
	customer_id VARCHAR(100) NOT NULL,
	customer_unique_id VARCHAR(100) NOT NULL,
	customer_zip_code INT,
	customer_city NVARCHAR(50),
	customer_state NVARCHAR(50),
	
	CONSTRAINT PK_DimCustomer PRIMARY KEY(customer_key)
);

INSERT INTO warehouse.DimCustomer
(
	customer_id,
	customer_unique_id,
	customer_zip_code,
	customer_city,
	customer_state
)
SELECT
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state
FROM staging.olist_customers_dataset;

--3.DimSeller
CREATE TABLE warehouse.DimSeller
(
	seller_key INT IDENTITY(1,1) NOT NULL,
	seller_id VARCHAR(100) NOT NULL,
	seller_zip_code INT,
	seller_city NVARCHAR(50),
	seller_state NVARCHAR(50),
		
	CONSTRAINT PK_DimSeller PRIMARY KEY (seller_key)
);

INSERT INTO warehouse.DimSeller
(
	seller_id,
	seller_zip_code,
	seller_city,
	seller_state
)
SELECT
	seller_id,
	seller_zip_code_prefix,
	seller_city,
	seller_state
FROM staging.olist_sellers_dataset

--Validation
SELECT
	COUNT(*) total_rows
FROM warehouse.DimSeller

--Surrogate key
SELECT
	MIN(seller_key) first_key,
	MAX(seller_key) last_key
FROM warehouse.DimSeller

--Business key
SELECT
	seller_id,
	COUNT(*) occurrences
FROM warehouse.DimSeller
GROUP BY seller_id
HAVING COUNT(*) > 1

--4.DimProduct
CREATE TABLE warehouse.DimProduct
(
	product_key INT NOT NULL,
	product_id VARCHAR(100) NOT NULL,
	product_category_name VARCHAR(50),
	product_name_length INT,
	product_description_length INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
)

--Load the special Unknown member record first
INSERT INTO warehouse.DimProduct
(
	product_key,
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
VALUES
(
	0,
	'UNKNOWN',
	'Unknown',
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
)

--Load the other product records
INSERT INTO warehouse.DimProduct
(
	product_key,
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
	ROW_NUMBER() OVER(ORDER BY product_id) AS product_key,
	product_id,
	product_category_name_english,
	product_name_length,
	product_description_length,
	product_photos_qty,
	product_weight_g,
	product_length_cm,
	product_height_cm,
	product_width_cm
FROM staging.olist_products_dataset

--Validation
SELECT
	COUNT(*) total_records
FROM warehouse.DimProduct

SELECT
	MIN(product_key) minimum_key,
	MAX(product_key) maximum_key
FROM warehouse.DimProduct

--Check the business key
SELECT
	product_id,
	COUNT(*) AS occurrences
FROM warehouse.DimProduct
GROUP BY product_id
HAVING COUNT(*) > 1

--Check the 'Unknown' missing translations
SELECT
	COUNT(*) missing_translations
FROM warehouse.DimProduct
WHERE product_category_name = 'Unknown'

--Important reports
--Matched order items
SELECT
	COUNT(*) matched_order_items
FROM staging.olist_order_items_dataset i
INNER JOIN  warehouse.DimProduct p
ON i.product_id = p.product_id

--The number of distinct products having an order item and also included in the products catalog
SELECT
	COUNT(DISTINCT i.product_id) total_products
FROM staging.olist_order_items_dataset i
INNER JOIN warehouse.DimProduct p
ON i.product_id = p.product_id

--The number of distinct products having an order item  and not included in the products catalog
SELECT
	COUNT(DISTINCT i.product_id) total_products
FROM staging.olist_order_items_dataset i
LEFT JOIN warehouse.DimProduct p
ON i.product_id = p.product_id
WHERE p.product_id IS NULL

--The number of orphan order items, rows in the order_items with no associating record in the product catalog
SELECT
	COUNT(*) orphan_order_items
FROM staging.olist_order_items_dataset i
LEFT JOIN warehouse.DimProduct p
ON i.product_id = p.product_id
WHERE p.product_id IS NULL

--5.DimPaymentMethod
SELECT
	payment_type,
	COUNT(*) occurrences
FROM staging.olist_order_payments_dataset
GROUP BY payment_type
ORDER BY occurrences DESC;

--Create the DimPaymentMethod
CREATE TABLE warehouse.DimPaymentMethod
(
	payment_key INT IDENTITY(1,1) NOT NULL,
	payment_type VARCHAR(50) NOT NULL,

	CONSTRAINT PK_DimPaymentMethod PRIMARY KEY (payment_key)
)

INSERT INTO warehouse.DimPaymentMethod (payment_type)
SELECT
	DISTINCT payment_type
FROM staging.olist_order_payments_dataset

--Validation
SELECT
	*
FROM warehouse.DimPaymentMethod

SELECT
	payment_type,
	COUNT(*) occurrences
FROM warehouse.DimPaymentMethod
GROUP BY payment_type
HAVING COUNT(*) > 1

--5.DimReview
	--Investigation
	
--Test composite uniqueness
SELECT
    review_id,
    order_id,
    COUNT(*) AS row_count
FROM staging.olist_order_reviews_dataset
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;

-- Find exact duplicate records
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    COUNT(*) AS duplicate_count
FROM staging.olist_order_reviews_dataset
GROUP BY
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
HAVING COUNT(*) > 1;

CREATE TABLE warehouse.DimReview(
	review_key INT IDENTITY(1,1) NOT NULL,
	review_id VARCHAR(50) NOT NULL,
	order_id VARCHAR(50) NOT NULL,
	review_score INT,
	review_comment_title NVARCHAR(MAX),
	review_comment_message NVARCHAR(MAX),
	review_creation_date DATETIME2,
	review_answer_timestamp DATETIME2
)

INSERT INTO warehouse.DimReview(
	review_id,
	order_id,
	review_score,
	review_comment_message,
	review_creation_date,
	review_answer_timestamp
)
SELECT
	review_id,
	order_id,
	review_score,
	review_comment_message,
	review_creation_date,
	review_answer_timestamp
FROM staging.olist_order_reviews_dataset

--6.FactOrder
--Before defining the DDL for the FactOrder we need to execute the sp_help stored procedure of DimCustomer and DimDate because the foreign key definitions need to match 
--with the primary key ones
EXEC sp_help 'warehouse.DimCustomer'
EXEC sp_help 'warehouse.DimDate'

CREATE TABLE warehouse.FactOrder(
	order_key INT NOT NULL,
	order_id VARCHAR(50) NOT NULL,
	customer_key INT NOT NULL,
	order_status VARCHAR(50),
	purchase_date_key INT NOT NULL,
	approved_date_key INT NOT NULL,
	carrier_delivery_date_key INT NOT NULL,
	customer_delivery_date_key INT NOT NULL,
	estimated_delivery_date_key INT NOT NULL,
	order_purchase_timestamp DATETIME2,
	order_approved_at DATETIME2,
	order_delivered_carrier_date DATETIME2,
	order_delivered_customer_date DATETIME2,
	order_estimated_delivery_date DATETIME2,
	
	CONSTRAINT PK_FactOrder
	PRIMARY KEY (order_key),
	
	CONSTRAINT FK_FactOrder_DimCustomer
	FOREIGN KEY (customer_key)
	REFERENCES warehouse.DimCustomer (customer_key),
	
	CONSTRAINT FK_FactOrder_DimDatePurchase
	FOREIGN KEY (purchase_date_key)
	REFERENCES warehouse.DimDate (date_key),
	
	CONSTRAINT FK_FactOrder_DimDate_Approved
	FOREIGN KEY (approved_date_key)
	REFERENCES warehouse.DimDate (date_key),
	
	CONSTRAINT FK_FactOrder_DimDate_Carrier_Delivery
	FOREIGN KEY (carrier_delivery_date_key)
	REFERENCES warehouse.DimDate (date_key),
	
	CONSTRAINT FK_FactOrder_DimDate_Customer_Delivery
	FOREIGN KEY (customer_delivery_date_key)
	REFERENCES warehouse.DimDate (date_key),
	
	CONSTRAINT FK_FactOrder_DimDate_Estimated_Delivery
	FOREIGN KEY (estimated_delivery_date_key)
	REFERENCES warehouse.DimDate (date_key)

)







