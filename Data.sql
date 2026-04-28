-- ============================================================
-- DATABASE INITIALIZATION
-- ============================================================

CREATE DATABASE TelcoChurnDB;
USE TelcoChurnDB;

-- ============================================================
-- RAW DATA TABLE (Staging Layer)
-- ============================================================

CREATE TABLE churn_raw (
    CustomerID VARCHAR(20),
    Gender VARCHAR(20),
    Age INT,
    Geography VARCHAR(50),
    Tenure INT,
    Contract VARCHAR(50),
    InternetService VARCHAR(50),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges VARCHAR(20),  -- VARCHAR initially due to mixed data
    TechSupport VARCHAR(20),
    StreamingTV VARCHAR(20),
    OnlineSecurity VARCHAR(20),
    Churn VARCHAR(20)
);


-- Verify load
SELECT COUNT(*) as total_records FROM churn_raw;
SELECT * FROM churn_raw LIMIT 10;


SELECT 
    CustomerID,
    COUNT(*) as duplicate_count
FROM churn_raw
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


SELECT 
    'CustomerID' as column_name,
    COUNT(*) - COUNT(CustomerID) as null_count,
    ROUND((COUNT(*) - COUNT(CustomerID)) * 100.0 / COUNT(*), 2) as null_percentage
FROM churn_raw
UNION ALL
SELECT 'Gender', COUNT(*) - COUNT(Gender), ROUND((COUNT(*) - COUNT(Gender)) * 100.0 / COUNT(*), 2) FROM churn_raw
UNION ALL
SELECT 'Age', COUNT(*) - COUNT(Age), ROUND((COUNT(*) - COUNT(Age)) * 100.0 / COUNT(*), 2) FROM churn_raw
UNION ALL
SELECT 'Geography', COUNT(*) - COUNT(Geography), ROUND((COUNT(*) - COUNT(Geography)) * 100.0 / COUNT(*), 2) FROM churn_raw
UNION ALL
SELECT 'Contract', COUNT(*) - COUNT(Contract), ROUND((COUNT(*) - COUNT(Contract)) * 100.0 / COUNT(*), 2) FROM churn_raw
UNION ALL
SELECT 'TechSupport', COUNT(*) - COUNT(TechSupport), ROUND((COUNT(*) - COUNT(TechSupport)) * 100.0 / COUNT(*), 2) FROM churn_raw
UNION ALL
SELECT 'Churn', COUNT(*) - COUNT(Churn), ROUND((COUNT(*) - COUNT(Churn)) * 100.0 / COUNT(*), 2) FROM churn_raw;


SELECT 'Gender' as column_name, Gender as value, COUNT(*) as count
FROM churn_raw
GROUP BY Gender
UNION ALL
SELECT 'Contract', Contract, COUNT(*) FROM churn_raw GROUP BY Contract
UNION ALL
SELECT 'Churn', Churn, COUNT(*) FROM churn_raw GROUP BY Churn
ORDER BY column_name, count DESC;


SELECT 
    'Age' as metric,
    MIN(Age) as min_value,
    MAX(Age) as max_value,
    AVG(Age) as avg_value,
    COUNT(CASE WHEN Age < 18 OR Age > 100 THEN 1 END) as outlier_count
FROM churn_raw
UNION ALL
SELECT 
    'MonthlyCharges',
    MIN(MonthlyCharges),
    MAX(MonthlyCharges),
    AVG(MonthlyCharges),
    COUNT(CASE WHEN MonthlyCharges < 0 OR MonthlyCharges > 200 THEN 1 END)
FROM churn_raw;

