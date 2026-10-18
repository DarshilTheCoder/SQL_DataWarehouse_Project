# Define Project Naming Conventions

Epics: Project Initialization (https://app.notion.com/p/Project-Initialization-406ce59e7504839689378188861d4925?pvs=21)
Status: Yes

Naming Conventions

Set of Rules or Guidelines for naming anything in the project

Database / Schema / Tables / Store Procedures

# General Principles

- Naming Convention - Use snake_cases for defining the name of the tables or anything
- Language - kindly use English for all conversation
- Avoid Reserve Words - Don’t use SQL reserve keywords for object naming

# Table Naming Convention

**Bronze Layer Rules**

- All names must start with the source system name and table names must match original names without renaming
- <sourcesystem>_<entity>
    - <sourcesystem> —> Name of the source (e.g CRM or ERP)
    - <entity> —> Exact table name from source system with cols name

**Silver Layer Rules (everything is similar to bronze as we are not creating any data model)**

- All names must start with the source system name and table names must match original names without renaming
- <sourcesystem>_<entity>
    - <sourcesystem> —> Name of the source (e.g CRM or ERP)
    - <entity> —> Exact table name from source system

**Gold Layer Rules** 

- All names must use meaningful, business-aligned names for tables, starting with category prefix.
- <category>_<entity>
    - <category> —> This describes the role of the table such as dim (dimension) or fact (fact table)
    - <entity> —> This should be the descriptive name of the table which aligned with business logic like customers, products, etc.
    - Examples
        - <dim_customers> , <fact_sales>

# Column Naming Convention

**Surrogate Keys**

- All primary keys in dimension tables must use the suffix _key
- <table_name>_key
    - <table_name> —> refers to the name of the table or entity the key belongs to
    - _key —> suffix indicating that this column is a surrogate keys
    - Example —> customer_key — is the surrogate key in dim_customers

**Technical Columns (this are the columns created by Data Engineer while working and it is specifically for them to understand or contains metadata for use)**

- All technical columns must start with dwh_. followed by descriptive name indicating the columns purpose
- dwh_<column_name>
    - dwh —> prefix exclusively for system-generated metadata
    - <column_name> —> descriptive name indicating columns purpose
    - Example — dwh_load_date

**Stored Procedure**

- All stored procedure used for loading the data into layers must follow below naming convention
- load_<layer_name>
    - <layer> —> Represents the layer that being loaded
    - Example — load_bronze  —> stored procedure for loading the data into bronze layer