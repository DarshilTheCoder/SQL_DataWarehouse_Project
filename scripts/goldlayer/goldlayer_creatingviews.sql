/*
=======================================================================================
CREATING VIEWS INSIDE GOLD LAYER
=======================================================================================
PURPOSE = This script will create the views inside the gold schema. 
          It will create three object views. 
            1. dim_customer view (includes all demographic and geographic info of customer)
            2. dim_product view (includes descriptive information of all current products)
            3. fact_sales view (includes all transactional information) 
=======================================================================================
*/



CREATE VIEW gold.dim_customer AS 
SELECT ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    ci.cst_marital_status AS marital_status,
    CASE
		WHEN ci.cst_gndr !='n/a' THEN ci.cst_gndr
        ELSE COALESCE(er.gen,'n/a') 
	END gender,
    ci.cst_create_date AS create_date,
    er.bdate AS birth_date,
    erl.cntry AS country
FROM silver.crm_cust_info AS ci LEFT JOIN silver.erp_cust_az12 AS er 
ON ci.cst_key = er.cid LEFT JOIN silver.erp_loc_a101 AS erl
ON ci.cst_key = erl.cid;


CREATE VIEW gold.dim_product AS
	SELECT ROW_NUMBER() OVER(ORDER BY ci.prd_start_dt,ci.prd_key) AS product_key, #this is surrogate key
	ci.prd_id AS product_id, 
	ci.prd_key AS product_number,
	ci.prd_nm AS product_name,
	ci.prd_cost AS product_cost,
	ci.prd_line AS product_line,
	ci.prd_start_dt AS product_start_dt,
	ci.cat_key AS category_key,
	er.cat AS category,
	er.subcat AS sub_category,
	er.maintenance AS maintenance
	FROM silver.crm_prd_info AS ci LEFT JOIN silver.erp_px_cat_g1v2 AS er
	ON ci.cat_key = er.id
	WHERE prd_end_dt IS NULL; #Filter out the historical data.


CREATE VIEW gold.fact_sales AS
	SELECT sd.sls_ord_num AS order_number,
	dp.product_key AS product_key,
	dc.customer_key AS customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
	FROM silver.crm_sales_details AS sd LEFT JOIN gold.dim_customer AS dc 
	ON sd.sls_cust_id = dc.customer_id LEFT JOIN gold.dim_product AS dp
	ON sd.sls_prd_key = dp.product_number;


