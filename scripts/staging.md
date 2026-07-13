Here we will clean the data, perform transformations and standardization so that we can have a clean operational layer ready for dimensional modeling.
Below are the tasks we will do in this phase

1.CORRECT DATATYPES
-For example: convert the NVARCHAR dates datatypes to DATETIME2.

2. STANDARDIZE TEXT
-For example: remove the leading and trailing spaces.

3.HANDLING MISSING VALUES

4.PRESERVE BUSINESS KEYS
-For example: product_id, customer_id, order_id, seller_id. Surrogate keys come later in the warehouse.

We will build the staging tables one by one. The order_items will the last one to be built because it is the transactional table and depends on several dimensions.

We will use the SELECT INTO to create the staging tables because it is concise and it helps us focus on the transformations. Later when we build the warehouse we'll switch
to explicitly creating tables with the exact data types and constraints we want.
