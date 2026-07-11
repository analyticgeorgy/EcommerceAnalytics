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
If the answer to these questions is no, then we have orphan records and that may cause problems when building the star schema.

NOTE :
It has come to our attention that there are some product_id values which are present in the order_items_dataset table but are missing in the products_dataset table.
When we build the star schema without addressing this, we will have broken foreign keys(foreign keys in the fact table which cannot be tracked back to the dimension tables)
THE SOLUTION
We will the build the Product Dimension from All Referenced Products. Conceptually, we will LEFT JOIN the order_items_dataset(left table) and the products_dataset(right table) and the result output will be the staged Products_dataset table, by doing this we will have grabbed all the product_ids in the order_items_table and make sure they are also in the products_dataset table even though we dont have their descriptive information. This reflects a common ETL principle, "The fact table drives dimension completeness"; if a product appears in a sale, it deserves a row in the product dimension even if the descriptive information is unavailable.









