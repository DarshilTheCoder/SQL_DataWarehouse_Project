
/*
================================================================================================================
Stored Procedure - Load Silver Layer (Bronze -> Silver)
================================================================================================================
Purpose = The script will perform the ETL (Extract, Transform, Load) in silver schema from bronze schema
Actions Performed:
    DELETE ALL ROWS FROM TABLE IF EXIST (Using delete so that i can rollback everything if code get's stuck somewhere)
    LOAD THE CLEANSED AND TRANSFORMED DATA INTO SILVER FROM BRONZE

Parameters:
    This store procedure does not required any parameters

Usage:
    CALL silver.load_silver();

I have set SQL_SAFE_UPDATES = 0 as i am deleting without where clause and due to mysql default behaviour of not allowing to delete something
without where clause, I put turned off that thing.
================================================================================================================


*/


-- 1. Run this once first, on its own
SET SQL_SAFE_UPDATES = 0;
DELIMITER //
CREATE PROCEDURE silver.load_silver()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        SELECT CONCAT('ERROR',@errno ,':',@msg) AS error_detail;
        ROLLBACK;
	END;
    START TRANSACTION;
		SET @total_start_time = NOW(3);

		SET @start_time = NOW(3);
		DELETE FROM silver.crm_cust_info;
		INSERT INTO silver.crm_cust_info (cst_id, 
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)

		SELECT cst_id,
		cst_key,
		TRIM(cst_firstname) as cst_firstname, 
		TRIM(cst_lastname) as cst_lastname,
		CASE
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			ELSE 'n/a'
		END cst_marital_status,
		CASE
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE 'n/a'
		END cst_gndr,
		cst_create_date
		FROM (
		SELECT * , 
			ROW_NUMBER () OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
		FROM bronze.crm_cust_info) as t
		WHERE flag_last = 1 and cst_id !=0;
		SET @end_time = NOW(3);
		SELECT CONCAT('silver.crm_cust_info :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;



		#LOADING CRM_PRD_INFO INTO SILVER TABLE
		SET @start_time = NOW(3);
		DELETE FROM silver.crm_prd_info;
		INSERT INTO silver.crm_prd_info(prd_id,
		prd_key,
		cat_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt)

		SELECT prd_id,
		substring(prd_key,7,length(prd_key)) as prd_key,
		REPLACE(substring(prd_key,1,5),'-','_') as cat_key,
		prd_nm,
		prd_cost, 
		CASE UPPER(TRIM(prd_line))
			WHEN 'R' THEN 'Road'
			WHEN 'M' THEN 'Mountain'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			else 'n/a'
		END prd_line,
		CAST(prd_start_dt AS DATE) as prd_start_dt,
		CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL 1 DAY AS DATE) as prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end_time = NOW(3);
		SELECT CONCAT('silver.crm_prd_info :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;



		#LOADING CRM_SALES_DETAILS INTO SILVER TABLE
		SET @start_time = NOW(3);
		DELETE FROM silver.crm_sales_details;
		INSERT INTO silver.crm_sales_details (sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price)

		SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE 
			WHEN sls_order_dt = 0 or length(sls_order_dt)!=8 then null
			ELSE CAST(CAST(sls_order_dt AS char)  AS DATE) 
		END sls_ord_dt,
		CASE 
			WHEN sls_ship_dt = 0 or length(sls_ship_dt)!=8 then null
			ELSE CAST(CAST(sls_ship_dt AS char)  AS DATE)
		END sls_ship_dt,
		CASE 
			WHEN sls_due_dt = 0 or length(sls_due_dt) !=8 then null
			ELSE CAST(CAST(sls_due_dt AS char)  AS DATE)
		END sls_due_dt,
		CASE
			WHEN sls_sales != sls_quantity * abs(sls_price) AND sls_price != 0 THEN sls_quantity*abs(sls_price)
			WHEN sls_sales <=0 OR sls_sales IS NULL THEN sls_quantity*abs(sls_price)
			ELSE sls_sales
		END sls_sales,
		sls_quantity,
		CASE
			WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales/NULLIF(sls_quantity,0)
			ELSE sls_price
		END sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = NOW(3);
		SELECT CONCAT('silver.crm_sales_details :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;




		#LOADING ERP_CUST_AZ12 INTO SILVER TABLE
		SET @start_time = NOW(3);
		DELETE FROM silver.erp_cust_az12;
		INSERT INTO silver.erp_cust_az12 (cid,
		bdate,
		gen)
		SELECT 
			CASE WHEN cid LIKE "NAS%" THEN SUBSTRING(cid,4, length(cid))
			ELSE cid
		END cid, 
		CASE
			WHEN bdate>NOW() THEN NULL
			ELSE bdate
		END bdate,
		CASE
			WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
			ELSE 'n/a'
		END gen
		FROM bronze.erp_cust_az12;
		SET @end_time = NOW(3);
		SELECT CONCAT('silver.erp_cust_az12 :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;


		#LOADING ERP_LOC_A101 INTO SILVER TABLE
		SET @start_time = NOW(3);
		DELETE FROM silver.erp_loc_a101;
		INSERT INTO silver.erp_loc_a101 (cid,
		cntry)
		SELECT REPLACE(cid,'-','') as cid,
		CASE
			WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
			WHEN UPPER(TRIM(cntry)) IN ('DE') THEN 'Germany'
			WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
			ELSE cntry
		END cntry
		FROM bronze.erp_loc_a101;
		SET @end_time = NOW(3);
		SELECT CONCAT('silver.erp_loc_a101 :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;


		#LOADING erp_px_cat_g1v2 INTO SILVER TABLE
		SET @start_time = NOW(3);
		DELETE FROM silver.erp_px_cat_g1v2;
		INSERT INTO silver.erp_px_cat_g1v2 (id, 
		cat, 
		subcat,
		maintenance)
		SELECT id, cat, subcat, maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = NOW(3);
		SELECT CONCAT('silver.erp_px_cat_g1v2 :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;


		SET @total_end_time = NOW(3);
		SELECT CONCAT('TOTAL TIME TO LOAD SILVER LAYER :',TIMESTAMPDIFF(MICROSECOND, @total_start_time, @total_end_time)/1000000,'seconds') AS total_load_duration;
	COMMIT;
END //
DELIMITER ;

