/*
=======================================================================================
QUALITY CHECKS AND TESTING
=======================================================================================
PURPOSE = The script will performs the quality checks like consistency, integrity and
          accuracy of Gold Layer. This wil perform
          1. Uniquness of surrogate keys in dimension table
          2. Integrity between facts table and dimension table
          3. Validation of relationship in data model

USAGE 
    Run this script after loading the data into silver layer and 
    before creating views inside gold layers.
    Investigate and resolve any descripancies if arrived. 
=======================================================================================


*/





#Around 4554 rows where truth source dont have info about gender and we gonna take it from er
SELECT DISTINCT count(*)
FROM silver.crm_cust_info AS ci LEFT JOIN silver.erp_cust_az12 AS er 
ON ci.cst_key = er.cid LEFT JOIN silver.erp_loc_a101 AS erl
ON ci.cst_key = erl.cid
WHERE ci.cst_gndr = 'n/a' and er.gen != 'n/a';

SELECT count(*)
FROM silver.crm_cust_info AS ci LEFT JOIN silver.erp_cust_az12 AS er 
ON ci.cst_key = er.cid LEFT JOIN silver.erp_loc_a101 AS erl
ON ci.cst_key = erl.cid;

SELECT DISTINCT 
    ci.cst_gndr,
    er.gen
FROM silver.crm_cust_info AS ci LEFT JOIN silver.erp_cust_az12 AS er 
ON ci.cst_key = er.cid LEFT JOIN silver.erp_loc_a101 AS erl
ON ci.cst_key = erl.cid;


SELECT DISTINCT ci.cst_gndr, er.gen,
	CASE
		WHEN ci.cst_gndr !='n/a' THEN ci.cst_gndr
        ELSE COALESCE(er.gen,'n/a') 
	END new_gen
FROM silver.crm_cust_info AS ci LEFT JOIN silver.erp_cust_az12 AS er 
ON ci.cst_key = er.cid LEFT JOIN silver.erp_loc_a101 AS erl
ON ci.cst_key = erl.cid;

SELECT *
FROM gold.dim_customer;

#checking if any duplicates are there or not after combiningl
SELECT count(ci.cat_key)
FROM silver.crm_prd_info AS ci LEFT JOIN silver.erp_px_cat_g1v2 AS er
ON ci.cat_key = er.id
WHERE prd_end_dt IS NULL #Filter out the historical data.
GROUP BY ci.prd_id
HAVING count(ci.prd_id)>1;


SELECT * 
FROM gold.dim_product;


#checking is there any customer and products who is in sales table but not in dimension table. Expectation No result Perfect everything here. 
SELECT sd.sls_ord_num,
dp.product_key,
dc.customer_key,
sd.sls_order_dt,
sd.sls_ship_dt,
sd.sls_due_dt,
sd.sls_sales,
sd.sls_quantity,
sd.sls_price
FROM silver.crm_sales_details AS sd LEFT JOIN gold.dim_customer AS dc 
ON sd.sls_cust_id = dc.customer_id LEFT JOIN gold.dim_product AS dp
ON sd.sls_prd_key = dp.product_number 
WHERE sd.sls_prd_key NOT IN (SELECT product_number FROM gold.dim_product);
