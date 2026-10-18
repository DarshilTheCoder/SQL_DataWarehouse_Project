/*
================================================================================================
 DDL SCRIPT -- CREATE BRONZE TABLE
 ================================================================================================
PURPOSE -- This script will create table inside the bronze schema or database by dropping the current table if exsit as
            as a part of bronze layer.
================================================================================================
*/


DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);

DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
	prd_id INT,
    prd_key varchar(50),
    prd_nm varchar(50), 
    prd_cost int,
    prd_line varchar(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);


DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
	sls_ord_num varchar(50),
    sls_prd_key varchar(50),
    sls_cust_id INT, 
    sls_order_dt INT,
    sls_ship_dt int,
    sls_due_dt INT,
    sls_sales INT, 
    sls_quantity INT, 
    sls_price INT
);

DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
	cid varchar(50),
	bdate DATE,
    gen varchar(50)
);

DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
	cid varchar(50),
    cntry varchar(50)
);

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
	id varchar(50),
    cat varchar(50),
    subcat varchar(50),
    maintenance varchar(50)
)
