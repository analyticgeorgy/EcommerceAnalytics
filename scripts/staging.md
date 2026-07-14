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

In production ETL, every transformation should be followed by validation.

TURNING POINT
-Before we continue I would like to make a small change to our staging design. Initially, I suggested creating the tables one by one by using SELECT INTO but after carefully
reviewing my options I have decided to follow a widely used ETL principle and that is instead of copying and cleaning each table at a time, every staging table should have
defined data types from the beginning. This is because SELECT INTO inherits the data types from the raw table, for example the NVARCHAR date columns remains to be NVARCHAR
and then we'll have to change it later most likely when building the warehouse. Instead, I'd rather create the staging table with the correct schema and then populate it.
That gives us full control over:
-data types
-constraints
-and also future maintenance

The customers table we have already created with SELECT INTO is absolutely fine for this project (the datatypes were correctly set by the import wizard), we dont have to redo it.

NOTE : No surrogate keys yet.
About the orphan records issue between the order_items and products will be fixed in the warehouse layer as the staging layer should still represent the source system 
as faithfully as possible.

When changing the datatypes in the staging, we will opt to change data types of columns which dont need the universal unicode NVARCHAR to VARCHAR as NVARCHAR takes twice as 
much space in the database.(NVARCHAR takes 2 bytes per character while VARCHAR takes 1 byte per character)
