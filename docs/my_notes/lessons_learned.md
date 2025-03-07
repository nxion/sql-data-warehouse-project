# Creating the bronze layer

This project keeps everything simple. It recommends using SQL Server Express since its free and very simple to setup. A plus is the data never leaves your system. I decided to take a different approach and instead of using a local SQL Server Express install, I decided to set SQL Server Express on a separate system in my homelab to simulate what a real working business environment would be. Because I have never worked with SQL servers before this was adding complexity to this project but I felt I was up to the task.

Installation and configuration were simple on a separate machine as it was to be installed locally. What I didn’t anticipate was at the steps in the project where you bulk insert your data into the tables, that’s where I ran into issues. The error I got when trying to insert said I didn’t have permissions to the file:

```sql
Msg 4860, Level 16, State 1, Line 1
Cannot bulk load. The file "C:\Users\me\source\sql-data-warehouse-project\datasets\source_crm\cust_info.csv" does not exist or you don't have file access rights.
```

This stumped me for a bit because I know I have access to that file, its my fine on my local system, what do you mean I can't access it. After some googling and asking Claude, I learn that its wasn’t myself or my Windows account didn’t have access to the files, it was the <em>SQL Server account</em> that I was logged in as that didn’t have access to the files. 

I'm still trying to find a way that I can upload from my local machine but until then the fix was to place the dataset files on the SQL server itself in ```/var/opt/mssql/data/```. Now I know that this is not normal practice but like I said, I'm still working thru a way around this so I can use my own account.

#### Types of data transformations done
None, this layer is loading the data AS IS. Transformations and clean up is done in the silver layer

---
# Clean data and load to Silver Layer
Its obvious to check the data to ensure its quality before we created the silver lay for this project. That goes without saying you need to have clean data if you want clear results. Some helpful queries that are worth noting and I will use again. are below.

* #### Null checks
    ```sql
    -- Check for nulls or duplicate in primary key
    -- Expectation: No Results
    SELECT cust_id, COUNT(*)
    FROM bronze.crm_cust_info
    GROUP BY cst_id
    HAVING COUNT(*) > 1 or cst_id IS NULL
    ```

* #### Check for unwanted spaces
    ```sql
    -- Check for unwanted spaces
    -- Expectation: No Resuts
    SELECT cst_lastname
    FROM bronze.crm_cust_info
    WHERE cst_lastname != TRIM(cst_lastname)
    ``` 

* #### Data standardatiozation & consistency
    ```sql
    /*
    We want to have all the data in a standard format
    for example, M = Male, F = Female. It makes reading 
    the data much easier. Less ambuquity
    */ 
    SELECT DISTINCT cst_gndr
    FROM bronze.cst_cust_info
    ```

* #### For complex transformations. 
    Work with business partners and experts with the data to come up with a solution. In the example given, we hda the stat and end date in the product tables that didint match and over lapped. The solution was to use ```LEAD``` function to shift the data so it makes sense. Here is an example:
    ```sql
    LEAD(prd_start_dt) OVER (PARTITION by prd_key ORDER BY prd_start_dt)-1 AS prd_start_dt
    ```

#### Business rules
Most if not all of the time, you will ahve business rules that need to be followed when building the silver lay to ensure calculations are done correctly. There are two solutions to this:

1. Data issues will be fixed in source system
2. Data issues has to be fixed in the data warehouse

More likly then not, in my experience, the second solution is what the customer will go with. Especially if it comes down to budget concers and no one wanted to go back to edit the data.Since that is the case, we have some business rules that we need to apply to this data:
* If Sales is negitive, zero, or null, derive it using  Quantity and Price
* If Price  is zero or null, calculate it using  Sales and Quantity
* If Price is negitive, convert it to  a positive value
```sql
 -- Check Data Consistonsity: Between  Sales, Quanity, and Price
 -- >> Sales = Quanity * Price
 -- >> Values must not be null, zero, or negitive.
 SELECT DISTINCT
 sls_sales AS old_sls_sales,
 sls_quanity,
 sls_price as old_sls_price,
 CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quanity * ABS(sls_price)
        THEN sls_quanity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL  OR sls_price <=0
```

#### Types of data transformation done
* **Derived columns:** Create columns based on calculations or transformations of existing ones. Good when we need our own colums for analytics or other calculations down the line. This is easier then ging back and asking for new columns of data to be added to the initial data. With these, we can add on the fly as needed.
* **Data normilazation:** Removing nulls and makeing all the fieilds more readable for analytics down the line.
* **Data Type Casting:** Simple as converting a data type from one to another. In this case from. ```DateTime``` to ```Date```
* **Data Enrichment:** Add new, relevent data to enhance the dataset for analysis.

---
# Creating the Gold layer
