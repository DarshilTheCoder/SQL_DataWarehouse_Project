/*
==============================================================================================================
QUALITY CHECKS LOGIC FOR SIVLER LAYER and CLEANING LOGIC AFTER QUALITY CHECKS
==============================================================================================================
PURPOSE = This script performs data quality checks like consistency, standardisation across
          all tables of silver schema or database. It includes checks for
          1. Null or duplicate checks for primary key
          2. Unwanted spaces in string objects
          3. Data Standardization and Normalization
          4. Data consistency across related fields
          5. Invalid date range and orders

USAGE 
      Run this QUALITY CHECKS after loading the data into silver schema
==============================================================================================================

*/

#QUALITY CHECKS LOGIC
#checking crm_cust_info table from bronze layer

SELECT * FROM silver.crm_cust_info;

#There is no null in cst_id but yes there is duplicates. 
SELECT *
FROM crm_cust_info
WHERE cst_id IS NULL;

#checking cst_id for null and duplicates. Expectation - No result
SELECT cst_id , count(cst_id) as count
FROM silver.crm_cust_info
GROUP BY cst_id 
HAVING count(cst_id)>1  OR cst_id IS NULL;

#there is no need to check similar things for cst_key as it is already gonna cover inside the cst_id during data loading. 

#now focus on cst_firstname and cst_lastname as it is a string and need to trim the spaces. Expectation - Proper names
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

#focus on gender and marital status. Expectation - Meaningfull values
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;


#WORKING ON CRM_PRD_INFO
SELECT * 
FROM bronze.crm_prd_info;

#Basics checks like prd_id. Expectations - No Result Perfect this one
SELECT prd_id , count(prd_id) as count
FROM silver.crm_prd_info
GROUP BY prd_id 
HAVING count(prd_id)>1  OR prd_id IS NULL; 

#creating cat_id to connect erp_cat with this data
SELECT prd_key
FROM silver.crm_prd_info;

#checking prd_name string object. Expectation- No Result Perfect it is
SELECT *
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) OR prd_nm IS NULL;

#checking that prd_cost should not be negative nor it should be null. If it is then I am replacing with 0. Expectation- No Result Perfect it is.
SELECT prd_cost
FROM  silver.crm_prd_info
WHERE prd_cost <0 or prd_cost IS NULL;


#adding meaningful name to prd_line
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

#checking dates
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt< prd_start_dt;

#CHECKING FOR crm_sales_details
SELECT *
FROM silver.crm_sales_details;

#checking whether ord_num and prd_key and sls_cust_id have null. Expectations - NO result all of them are pefect
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL;

#converting date from inttype to datetype to get proper date format
SELECT sls_ord_num, sls_prd_key, sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt
from silver.crm_sales_details
WHERE sls_order_dt IS NULL OR sls_order_dt = 0 OR sls_ship_dt IS NULL OR sls_ship_dt =0 or sls_due_dt IS NULL OR sls_due_dt = 0;

select *
from silver.crm_sales_details
where sls_prd_key = 'HL-U509-B' and sls_ord_num = 'SO64338' and sls_cust_id = 22819;

#checkcing any ship date is before than ord dat and same for due dt. Everything is proper here
SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt,sls_due_dt
from silver.crm_sales_details
WHERE sls_order_dt  > sls_ship_dt or sls_order_dt > sls_due_dt;

#checking any sales or quantity or price is null or negative or zero
SELECT  sls_sales,sls_quantity,sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL or sls_sales <=0 or sls_quantity IS NULL or sls_quantity <=0 or sls_price IS NULL or sls_price <=0 OR sls_sales != sls_quantity*abs(sls_price);

SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key = 'WB-H098' and sls_cust_id = 11433;

SELECT *
FROM silver.crm_sales_details;



#CHECKING ERP_CUST_AZ12
SELECT *
FROM silver.erp_cust_az12;

#Checking is any problem with cid or not. Expectation - NO Result
SELECT *
FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

#checking bdate whether its too old or any bdate greater than todays date. EXPECTATION NO RESULT
SELECT *
FROM silver.erp_cust_az12
WHERE  bdate> NOW();

#checking gen 
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


#CHECKING ERP_LOC_A101
SELECT *
FROM silver.erp_loc_a101;

#checking cid from. EXPECTATION NO RESULT PERFECT it is
SELECT *
FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key from silver.crm_cust_info);

#checking cntry 
SELECT DISTINCT cntry
FROM silver.erp_loc_a101;

SELECT DISTINCT cntry, LENGTH(cntry) AS byte_len, HEX(cntry) AS hex_value
FROM silver.erp_loc_a101;


#THERE IS NOTHING TO CHECK FOR ERP_PX_CAT_G1V2 as everything is good so far for this table. 


/*==============================================================================================================
  DATA CLEANING LOGIC
  ==============================================================================================================
  PURPOSE = The below script is used to check the data issue while loading from bronze to silver and checked 
            what are issued and wrote code accordingly

  USAGE 
      Run this script before loading the data into silver schema as it will help to find issue if exist any
  ==============================================================================================================*/
#CLEANING LOGIC
#checking crm_cust_info table from bronze layer

SELECT * FROM bronze.crm_cust_info;

#There is no null in cst_id but yes there is duplicates. 
SELECT *
FROM crm_cust_info
WHERE cst_id IS NULL;

#checking cst_id for null and duplicates. Expectation - No result
SELECT cst_id , count(cst_id) as count
FROM bronze.crm_cust_info
GROUP BY cst_id 
HAVING count(cst_id)>1  OR cst_id IS NULL;

#there is no need to check similar things for cst_key as it is already gonna cover inside the cst_id during data loading. 

#now focus on cst_firstname and cst_lastname as it is a string and need to trim the spaces. Expectation - Proper names
SELECT cst_firstname, cst_lastname
FROM bronze.crm_cust_info;

#focus on gender and marital status. Expectation - Meaningfull values
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;


#WORKING ON CRM_PRD_INFO
SELECT * 
FROM bronze.crm_prd_info;

#Basics checks like prd_id. Expectations - No Result Perfect this one
SELECT prd_id , count(prd_id) as count
FROM bronze.crm_prd_info
GROUP BY prd_id 
HAVING count(prd_id)>1  OR prd_id IS NULL; 

#creating cat_id to connect erp_cat with this data
SELECT REPLACE(substring(prd_key,1,5),'-','_')
FROM bronze.crm_prd_info;

#checking prd_name string object. Expectation- No Result Perfect it is
SELECT *
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) OR prd_nm IS NULL;

#checking that prd_cost should not be negative nor it should be null. If it is then I am replacing with 0. Expectation- No Result Perfect it is.
SELECT prd_cost
FROM  bronze.crm_prd_info
WHERE prd_cost <0 or prd_cost IS NULL;


#adding meaningful name to prd_line
SELECT DISTINCT
CASE UPPER(TRIM(prd_line))
	WHEN 'R' THEN 'Road'
    WHEN 'M' THEN 'Mountain'
    WHEN 'S' THEN 'Other Sales'
    WHEN 'T' THEN 'Touring'
	else 'n/a'
END prd_line
FROM bronze.crm_prd_info;

#checking dates
SELECT *,CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL 1 DAY AS DATE) as new_prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_end_dt< prd_start_dt AND prd_key IN ('AC-HE-HL-U509-R','AC-HE-HL-U509');

#€HECKING crm_sales_details data
SELECT *
FROM bronze.crm_sales_details;

#checking whether ord_num and prd_key and sls_cust_id have null. Expectations - NO result all of them are pefect
SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL;

#converting date from inttype to datetype to get proper date format
SELECT sls_ord_num, sls_prd_key, sls_cust_id, CAST(CAST(sls_order_dt AS char)  AS DATE) as sls_ord_dt,
CAST(CAST(sls_ship_dt AS char)  AS DATE) as sls_ship_dt,
CAST(CAST(sls_due_dt AS char)  AS DATE) as sls_due_dt
from bronze.crm_sales_details
WHERE CAST(CAST(sls_order_dt AS char) AS DATE) IS NULL or CAST(CAST(sls_ship_dt AS char)  AS DATE) IS NULL or CAST(CAST(sls_due_dt AS char) AS DATE) IS NULL;

select *
from bronze.crm_sales_details
where sls_prd_key = 'HL-U509-B' and sls_ord_num = 'SO64338' and sls_cust_id = 22819;

#checkcing any ship date is before than ord dat and same for due dt. Everything is proper here
SELECT sls_ord_num, sls_prd_key, sls_cust_id, CAST(CAST(sls_order_dt AS char)  AS DATE) as sls_ord_dt,
CAST(CAST(sls_ship_dt AS char)  AS DATE) as sls_ship_dt,
CAST(CAST(sls_due_dt AS char)  AS DATE) as sls_due_d
from bronze.crm_sales_details
WHERE CAST(CAST(sls_order_dt AS char)  AS DATE) > CAST(CAST(sls_due_dt AS char)  AS DATE);

#checking any sales or quantity or price is null or negative or zero
SELECT sls_sales,sls_quantity,sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity*sls_price or sls_sales IS NULL or sls_sales <=0 or sls_quantity IS NULL or sls_quantity <=0 or sls_price IS NULL or sls_price <=0;


SELECT sls_sales,sls_quantity,sls_price,
	CASE
		WHEN sls_sales <=0 THEN sls_quantity*sls_price
        WHEN sls_sales is null then sls_quantity*sls_price
        ELSE sls_sales
	END new_sls_sales,
    CASE
		WHEN sls_price = 0 THEN CAST(sls_sales/sls_quantity AS DECIMAL)
        WHEN sls_price is null THEN CAST(sls_sales/sls_quantity AS DECIMAL)
        WHEN sls_price <0 THEN sls_price*(-1)
        ELSE sls_price
	END new_sls_price
FROM bronze.crm_sales_details
WHERE sls_sales IS NULL or sls_sales <=0 or sls_quantity IS NULL or sls_quantity <=0 or sls_price IS NULL or sls_price <=0;




#CLEANING ERP_CUST_AZ12
SELECT *
FROM bronze.erp_cust_az12;

#Checking is any problem with cid or not. Expectation - NO Result
SELECT *, SUBSTRING(cid,4, length(cid)) as ncid
FROM bronze.erp_cust_az12;

#checking bdate whether its too old or any bdate greater than todays date
SELECT *
FROM bronze.erp_cust_az12
WHERE  bdate> NOW();
SELECT cid, 
	CASE
		WHEN bdate>NOW() THEN NULL
        ELSE bdate
	END bdate
FROM bronze.erp_cust_az12
WHERE bdate> NOW();

#checking gen 
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

#shows that \r carriage return is there which is not captured by TRIM and i need to replace.
SELECT gen, LENGTH(gen) AS byte_len, HEX(gen) AS hex_value
FROM bronze.erp_cust_az12
WHERE gen IS NOT NULL
LIMIT 10;

SELECT DISTINCT gen,
CASE
	WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
    WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
    ELSE 'n/a'
END gen2
FROM bronze.erp_cust_az12;


#Cleaning ERP_LOC_A101
SELECT *
FROM bronze.erp_loc_a101;

#cleaning cid from
SELECT REPLACE(cid,'-','') as ncid, cid, cntry
FROM bronze.erp_loc_a101;

#checking cntry 
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;

SELECT DISTINCT cntry, 
CASE
	WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
    WHEN UPPER(TRIM(cntry)) IN ('DE') THEN 'Germany'
    WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
    ELSE cntry
END cntr2
FROM bronze.erp_loc_a101;

SELECT DISTINCT cntry, LENGTH(cntry) AS byte_len, HEX(cntry) AS hex_value
FROM bronze.erp_loc_a101;



#CLEANING erp_px_cat_g1v2
SELECT *
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT cat, LENGTH(cat) AS byte_len, HEX(cat) AS hex_value
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat, LENGTH(subcat) AS byte_len, HEX(subcat) AS hex_value
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT maintenance, LENGTH(maintenance) AS byte_len, HEX(maintenance) AS hex_value
FROM bronze.erp_px_cat_g1v2;



