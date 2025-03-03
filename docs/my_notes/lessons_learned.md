# Creating the bronze layer

This project keeps everything simple. It recommends using SQL Server Express since its free and very simple to setup. A plus is the data never leaves your system. I decided to take a different approach and instead of using a local SQL Server Express install, I decided to set SQL Server Express on a separate system in my homelab to simulate what a real working business environment would be. Because I have never worked with SQL servers before this was adding complexity to this project but I felt I was up to the task.

Installation and configuration were simple on a separate machine as it was to be installed locally. What I didn’t anticipate was at the steps in the project where you bulk insert your data into the tables, that’s where I ran into issues. The error I got when trying to insert said I didn’t have permissions to the file:

```sql
Msg 4860, Level 16, State 1, Line 1
Cannot bulk load. The file "C:\Users\me\source\sql-data-warehouse-project\datasets\source_crm\cust_info.csv" does not exist or you don't have file access rights.
```

This stumped me for a bit because I know I have access to that file, its my fine on my local system, what do you mean I can't access it. After some googling and asking Claude, I learn that its wasn’t myself or my Windows account didn’t have access to the files, it was the <em>SQL Server account</em> that I was logged in as that didn’t have access to the files. 

I'm still trying to find a way that I can upload from my local machine but until then the fix was to place the dataset files on the SQL server itself in ```/var/opt/mssql/data/```. Now I know that this is not normal practice but like I said, I'm still working thru a way around this so I can use my own account.

