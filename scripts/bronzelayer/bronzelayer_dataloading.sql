/*

========================================================================================
BRONZE LAYER DATA LOADING
========================================================================================
PURPOSE --> This script will load the data from raw csv files into bronze layer tables. 
This script will perform following actions:
    Will trucate the table if exist
    Then load the data into corresponding table. It will perform BULK INSERT 

========================================================================================
*/




#SERVER SIDE Run this query first while working with mysql workbench
SET GLOBAL local_infile = 1;

#Then after follow below step it is important to do from client side.
#Click your connec tion's wrench/edit icon
#Go to Advanced tab
#In the "Others" box, add: OPT_LOCAL_INFILE=1
#Reconnect

#Now checking this will gonna show you
SHOW VARIABLES LIKE 'local_infile';
SET @total_start_time = NOW(3);
SET @start_time = NOW(3);
TRUNCATE TABLE bronze.crm_cust_info;

LOAD DATA LOCAL INFILE '/Users/darshilparikh/Desktop/SQL DATAWAREHOUSE PROJECT/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET @end_time = NOW(3);
SELECT CONCAT('bronze.crm_cust_info :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;
#This is just to check whether the data has been properly loaded or not
-- SELECT count(*) 
-- FROM crm_cust_info;


SET @start_time = NOW(3);
TRUNCATE TABLE bronze.crm_prd_info;

LOAD DATA LOCAL INFILE '/Users/darshilparikh/Desktop/SQL DATAWAREHOUSE PROJECT/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT CONCAT('bronze.crm_prd_info :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;


#This is just to check whether the data has been properly loaded or not
-- SELECT count(*) 
-- FROM crm_prd_info;

SET @start_time = NOW(3);
TRUNCATE TABLE bronze.crm_sales_details;

LOAD DATA LOCAL INFILE '/Users/darshilparikh/Desktop/SQL DATAWAREHOUSE PROJECT/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT CONCAT('bronze.crm_sales_details :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;

#This is just to check whether the data has been properly loaded or not
-- SELECT count(*) 
-- FROM crm_sales_details;

SET @start_time = NOW(3);
TRUNCATE TABLE bronze.erp_cust_az12;

LOAD DATA LOCAL INFILE '/Users/darshilparikh/Desktop/SQL DATAWAREHOUSE PROJECT/source_erp/cust_az12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT CONCAT('bronze.erp_cust_az12:',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;


#This is just to check whether the data has been properly loaded or not
-- SELECT count(*) 
-- FROM erp_cust_az12;

SET @start_time = NOW(3);
TRUNCATE TABLE bronze.erp_loc_a101;

LOAD DATA LOCAL INFILE '/Users/darshilparikh/Desktop/SQL DATAWAREHOUSE PROJECT/source_erp/loc_a101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT CONCAT('bronze.erp_loc_a101 :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;

#This is just to check whether the data has been properly loaded or not
-- SELECT count(*) 
-- FROM erp_loc_a101;

SET @start_time = NOW(3);
TRUNCATE TABLE bronze.erp_px_cat_g1v2;

LOAD DATA LOCAL INFILE '/Users/darshilparikh/Desktop/SQL DATAWAREHOUSE PROJECT/source_erp/px_cat_g1v2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT CONCAT('bronze.erp_px_cat_g1v2 :',TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time)/1000000,'seconds') AS load_duration;

SET @total_end_time = NOW(3);
SELECT CONCAT('TOTAL TIME TO LOAD BRONZE LAYER :',TIMESTAMPDIFF(MICROSECOND, @total_start_time, @total_end_time)/1000000,'seconds') AS total_load_duration;

#This is just to check whether the data has been properly loaded or not
-- SELECT count(*) 
-- FROM erp_px_cat_g1v2;
