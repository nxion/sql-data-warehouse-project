/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' only if it does not already exist. 
    If the database exists, the script stops execution immediately and does not modify anything. 
*/

USE master;
GO

-- Check if the 'DataWarehouse' database exists 
IF DB_ID('DataWarehouse') IS NOT NULL
BEGIN
    PRINT 'Database already exists. Script execution stopped.';
    RAISERROR ('Database already exists. Script execution stopped.', 16, 1);
    RETURN;
END
GO

-- Create database only if it does not exist
CREATE DATABASE DataWarehouse;
GO

-- Switch to the new database
USE DataWarehouse;
GO

-- Ensure schemas are only created if they do not already exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
END
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
END
GO
