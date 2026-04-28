CREATE TABLE churn_cleaned (
    CustomerID VARCHAR(20) PRIMARY KEY,
    Gender VARCHAR(10),
    Age INT,
    Geography VARCHAR(50),
    Tenure INT,
    Contract VARCHAR(20),
    InternetService VARCHAR(20),
    PaymentMethod VARCHAR(30),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    TechSupport VARCHAR(3),
    StreamingTV VARCHAR(3),
    OnlineSecurity VARCHAR(3),
    Churn VARCHAR(3),
    DataQualityFlag VARCHAR(50),
    LoadDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO churn_cleaned (
    CustomerID, Gender, Age, Geography, Tenure, Contract, 
    InternetService, PaymentMethod, MonthlyCharges, TotalCharges, 
    TechSupport, StreamingTV, OnlineSecurity, Churn, DataQualityFlag
)
WITH UniqueCustomers AS (
    SELECT 
        CustomerID,
        Gender,
        Age,
        Geography,
        Tenure,
        Contract,
        InternetService,
        PaymentMethod,
        MonthlyCharges,
        TotalCharges,
        TechSupport,
        StreamingTV,
        OnlineSecurity,
        Churn,
        -- Create a rank for duplicates (1 = keep, 2+ = duplicate)
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY Tenure DESC) as rn
    FROM churn_raw
    WHERE CustomerID IS NOT NULL
)
SELECT 
    CustomerID,
    -- Gender: Standardize
    CASE 
        WHEN UPPER(TRIM(Gender)) IN ('MALE', 'M') THEN 'Male'
        WHEN UPPER(TRIM(Gender)) IN ('FEMALE', 'F') THEN 'Female'
        ELSE 'Unknown'
    END,
    -- Age: Fix outliers using AVG (MySQL compatible)
    CASE 
        WHEN Age < 18 OR Age > 100 OR Age IS NULL 
        THEN (SELECT AVG(Age) FROM churn_raw WHERE Age BETWEEN 18 AND 100)
        ELSE Age
    END,
    -- Geography: Standardize casing
    CASE 
        WHEN Geography IS NULL OR TRIM(Geography) = '' THEN 'Unknown'
        ELSE CONCAT(UPPER(LEFT(TRIM(Geography), 1)), LOWER(SUBSTRING(TRIM(Geography), 2)))
    END,
    COALESCE(Tenure, 0),
    -- Contract: Standardize
    CASE 
        WHEN UPPER(TRIM(Contract)) LIKE '%MONTH%' THEN 'Month-to-month'
        WHEN UPPER(TRIM(Contract)) LIKE '%ONE%' THEN 'One year'
        WHEN UPPER(TRIM(Contract)) LIKE '%TWO%' THEN 'Two year'
        ELSE 'Unknown'
    END,
    -- InternetService: Standardize
    CASE 
        WHEN UPPER(TRIM(InternetService)) LIKE '%FIBER%' THEN 'Fiber optic'
        WHEN UPPER(TRIM(InternetService)) = 'DSL' THEN 'DSL'
        ELSE 'No'
    END,
    -- PaymentMethod: Standardize
    CASE 
        WHEN UPPER(TRIM(PaymentMethod)) REGEXP 'ELECTRONIC|E-CHECK' THEN 'Electronic check'
        WHEN UPPER(TRIM(PaymentMethod)) LIKE '%MAIL%' THEN 'Mailed check'
        WHEN UPPER(TRIM(PaymentMethod)) LIKE '%BANK%' THEN 'Bank transfer'
        ELSE 'Credit card'
    END,
    -- MonthlyCharges
    CASE 
        WHEN MonthlyCharges < 0 OR MonthlyCharges > 200 
        THEN (SELECT AVG(MonthlyCharges) FROM churn_raw WHERE MonthlyCharges BETWEEN 0 AND 200)
        ELSE MonthlyCharges
    END,
    -- TotalCharges: Regex and Numeric Cast
    CASE 
        WHEN TotalCharges IS NULL OR TRIM(TotalCharges) = '' THEN 0
        WHEN TRIM(TotalCharges) REGEXP '^[0-9]+(\\.[0-9]*)?$' THEN CAST(TRIM(TotalCharges) AS DECIMAL(10,2))
        ELSE 0
    END,
    -- TechSupport/Streaming/Security/Churn
    IF(UPPER(TRIM(TechSupport)) IN ('YES','Y','1'), 'Yes', 'No'),
    IF(UPPER(TRIM(StreamingTV)) IN ('YES','Y','1'), 'Yes', 'No'),
    IF(UPPER(TRIM(OnlineSecurity)) IN ('YES','Y','1'), 'Yes', 'No'),
    IF(UPPER(TRIM(Churn)) IN ('YES','Y','1'), 'Yes', 'No'),
    -- Data Quality Flag
    CASE 
        WHEN Age < 18 OR Age > 100 THEN 'Age_Imputed'
        WHEN MonthlyCharges < 0 OR MonthlyCharges > 200 THEN 'Charges_Imputed'
        ELSE 'Clean'
    END
FROM UniqueCustomers
WHERE rn = 1; 


SELECT 
    COUNT(*) as total_clean_records,
    COUNT(DISTINCT CustomerID) as unique_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM churn_cleaned;


CREATE TABLE churn_analytics AS
SELECT 
    CustomerID,
    Gender,
    Age,
    Geography,
    Tenure,
    Contract,
    InternetService,
    PaymentMethod,
    MonthlyCharges,
    TotalCharges,
    TechSupport,
    StreamingTV,
    OnlineSecurity,
    Churn,
    

    CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END as ChurnFlag,
    

    CASE 
        WHEN Tenure <= 12 THEN '0-12 months'
        WHEN Tenure <= 24 THEN '13-24 months'
        WHEN Tenure <= 48 THEN '25-48 months'
        WHEN Tenure <= 60 THEN '49-60 months'
        ELSE '60+ months'
    END as TenureGroup,
    

    CASE 
        WHEN Age < 30 THEN '18-29'
        WHEN Age < 40 THEN '30-39'
        WHEN Age < 50 THEN '40-49'
        WHEN Age < 60 THEN '50-59'
        ELSE '60+'
    END as AgeGroup,
    

    CASE 
        WHEN MonthlyCharges < 30 THEN 'Low (<$30)'
        WHEN MonthlyCharges < 60 THEN 'Medium ($30-$60)'
        WHEN MonthlyCharges < 90 THEN 'High ($60-$90)'
        ELSE 'Premium ($90+)'
    END as ChargeCategory,
    

    (CASE WHEN Contract = 'Month-to-month' THEN 30 ELSE 0 END +
     CASE WHEN Tenure < 12 THEN 25 ELSE 0 END +
     CASE WHEN PaymentMethod = 'Electronic check' THEN 15 ELSE 0 END +
     CASE WHEN TechSupport = 'No' THEN 10 ELSE 0 END +
     CASE WHEN MonthlyCharges > 80 THEN 10 ELSE 0 END +
     CASE WHEN OnlineSecurity = 'No' THEN 10 ELSE 0 END) as RiskScore,
    

    CASE 
        WHEN TotalCharges >= 4000 THEN 'High Value'
        WHEN TotalCharges >= 2000 THEN 'Medium Value'
        WHEN TotalCharges >= 500 THEN 'Low Value'
        ELSE 'New Customer'
    END as CustomerValueSegment,
    

    (CASE WHEN TechSupport = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN StreamingTV = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN OnlineSecurity = 'Yes' THEN 1 ELSE 0 END) as ServiceAdoptionCount,
    

    CASE 
        WHEN Tenure > 0 THEN ROUND(TotalCharges / Tenure, 2)
        ELSE MonthlyCharges
    END as AvgMonthlyRevenue,
    

    CASE 
        WHEN (CASE WHEN Contract = 'Month-to-month' THEN 30 ELSE 0 END +
              CASE WHEN Tenure < 12 THEN 25 ELSE 0 END +
              CASE WHEN PaymentMethod = 'Electronic check' THEN 15 ELSE 0 END +
              CASE WHEN TechSupport = 'No' THEN 10 ELSE 0 END +
              CASE WHEN MonthlyCharges > 80 THEN 10 ELSE 0 END +
              CASE WHEN OnlineSecurity = 'No' THEN 10 ELSE 0 END) >= 60 THEN 'High Risk'
        WHEN (CASE WHEN Contract = 'Month-to-month' THEN 30 ELSE 0 END +
              CASE WHEN Tenure < 12 THEN 25 ELSE 0 END +
              CASE WHEN PaymentMethod = 'Electronic check' THEN 15 ELSE 0 END +
              CASE WHEN TechSupport = 'No' THEN 10 ELSE 0 END +
              CASE WHEN MonthlyCharges > 80 THEN 10 ELSE 0 END +
              CASE WHEN OnlineSecurity = 'No' THEN 10 ELSE 0 END) >= 30 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as RiskCategory

FROM churn_cleaned;


CREATE INDEX idx_churn_flag ON churn_analytics(ChurnFlag);
CREATE INDEX idx_risk_category ON churn_analytics(RiskCategory);
CREATE INDEX idx_contract ON churn_analytics(Contract);
CREATE INDEX idx_tenure_group ON churn_analytics(TenureGroup);
