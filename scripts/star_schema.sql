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









