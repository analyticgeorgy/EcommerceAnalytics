Here we will profile all tables and document our findings.

ROW COUNTS
-The raw.olist_customers_dataset has a total of 99441 rows.
-The raw.olist_geolocation_dataset has a total of 1000163 rows.
-The raw.olist_order_items_dataset has a total of 112650 rows.
-The raw.olist_order_payments_dataset has a total of 103886 rows.
-The raw.olist_order_reviews_dataset has a total of 68828 rows.
-The raw.olist_orders_dataset has a total of 99441 rows.
-The raw.olist_products_dataset has a total of 22952 rows.
-The raw.olist_sellers_dataset has a total of 3095 rows.
-The raw.product_category_name_translation has a total of 71 rows.

MISSING VALUES
-The raw.olist_customers_dataset has no missing values.
-The raw.olist_geolocation_dataset has no missing values.
-The raw.olist_order_items_dataset has no missing values.
-The raw.olist_order_payments_dataset has no missing values.
-The raw.olist_order_reviews_dataset has no missing values.
-The raw.olist_orders_dataset has no missing values.
-The raw.olist_products_dataset has one NULL in the columns : product_name_length, product_description_length and the product_photos_qty.
-The raw.olist_sellers_dataset has no missing values.
-The raw.product_category_name_translation has no missing values.

DUPLICATE PRIMARY KEYS
-The raw.olist_customers_dataset has a candidate key, customer_id. (candidate key is a column that appears to uniquely identify each row)
-The raw.olist_geolocation_dataset does not have a candidate key.
-The raw.olist_order_items_dataset has a composite candidate key, the combination of order_id and order_item_id.
-The raw.olist_order_payments_dataset has composite candidate key, the combination of order_id and payment_sequential.
-The raw.olist_order_reviews_dataset does not have a candidate key.
-The raw.olist_orders_dataset has a candidate key, order_id.
-The raw.olist_products_dataset has a candidate key, product_id.
-The raw.olist_sellers_dataset has a candidate key, seller_id.
-The raw.product_category_name_translation does not have a candidate key.

REFERENTIAL INTEGRITY
Here we want to check whether we have "orphan records".
We will be asking questions like these:
-Does every customer_id in olist_orders_dataset exist olist_customers_dataset.
-Does every order_id in olist_order_items_dataset exist in olist_orders_dataset.
-Does every order_id in olist_order_reviews_dataset exist in olist_orders_dataset.
-Does every product_id in olist_order_items_dataset exist in olist_products_dataset.
-Does every seller_id in olist_order_items_dataset exist in olist_sellers_dataset.
If the answer to these questions is no, then we have orphan records and that may cause problems when building the star schema
