SELECT 
    COUNT(*) as TotalCustomers,
    SUM(ChurnFlag) as ChurnedCustomers,
    COUNT(*) - SUM(ChurnFlag) as RetainedCustomers,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(*), 2) as ChurnRate,
    ROUND(SUM(MonthlyCharges), 2) as TotalMonthlyRevenue,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges ELSE 0 END), 2) as MonthlyRevenueLost,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges ELSE 0 END) * 12, 2) as AnnualRevenueLost,
    ROUND(AVG(MonthlyCharges), 2) as AvgRevenuePerCustomer,
    ROUND(AVG(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges END), 2) as AvgRevenueChurned,
    ROUND(AVG(Tenure), 1) as AvgTenureMonths
FROM churn_analytics;


SELECT 
    Contract,
    COUNT(*) as CustomerCount,
    SUM(ChurnFlag) as ChurnedCount,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(*), 2) as ChurnRate,
    ROUND(SUM(MonthlyCharges), 2) as TotalRevenue,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges ELSE 0 END) * 12, 2) as AnnualRevenueLoss,
    ROUND(AVG(Tenure), 1) as AvgTenure,
    ROUND(AVG(MonthlyCharges), 2) as AvgMonthlyCharge
FROM churn_analytics
GROUP BY Contract
ORDER BY ChurnRate DESC;


SELECT 
    TenureGroup,
    COUNT(*) as CustomerCount,
    SUM(ChurnFlag) as ChurnedCount,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(*), 2) as ChurnRate,
    ROUND(AVG(MonthlyCharges), 2) as AvgMonthlyCharge,
    ROUND(SUM(TotalCharges), 2) as TotalLifetimeValue,
    ROUND(AVG(CASE WHEN ChurnFlag = 1 THEN TotalCharges END), 2) as AvgLTVLost
FROM churn_analytics
GROUP BY TenureGroup
ORDER BY 
    CASE TenureGroup
        WHEN '0-12 months' THEN 1
        WHEN '13-24 months' THEN 2
        WHEN '25-48 months' THEN 3
        WHEN '49-60 months' THEN 4
        ELSE 5
    END;


SELECT 
    Geography,
    InternetService,
    COUNT(*) as Customers,
    SUM(ChurnFlag) as Churned,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(*), 2) as ChurnRate,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges ELSE 0 END), 2) as MonthlyRevenueLost,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges ELSE 0 END) * 12, 2) as AnnualRevenueLost,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN TotalCharges END), 2) as LifetimeValueLost
FROM churn_analytics
GROUP BY Geography, InternetService
HAVING SUM(ChurnFlag) > 0
ORDER BY AnnualRevenueLost DESC
LIMIT 15;


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
    RiskScore,
    RiskCategory,
    ServiceAdoptionCount,
    Churn as ActualChurn
FROM churn_analytics
WHERE RiskCategory = 'High Risk' 
  AND ChurnFlag = 0  -- Not yet churned
ORDER BY RiskScore DESC, MonthlyCharges DESC
LIMIT 100;


SELECT 
    PaymentMethod,
    COUNT(*) as CustomerCount,
    SUM(ChurnFlag) as ChurnedCount,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(*), 2) as ChurnRate,
    ROUND(AVG(MonthlyCharges), 2) as AvgMonthlyRevenue,
    ROUND(AVG(Tenure), 1) as AvgTenure,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges * 12 END), 2) as AnnualRevenueLost
FROM churn_analytics
GROUP BY PaymentMethod
ORDER BY ChurnRate DESC;

SELECT 
    ServiceAdoptionCount,
    COUNT(*) as CustomerCount,
    SUM(ChurnFlag) as ChurnedCount,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(*), 2) as ChurnRate,
    ROUND(AVG(MonthlyCharges), 2) as AvgMonthlyCharge,
    ROUND(AVG(Tenure), 1) as AvgTenure
FROM churn_analytics
GROUP BY ServiceAdoptionCount
ORDER BY ServiceAdoptionCount;


SELECT 
    TenureGroup,
    ChargeCategory,
    COUNT(*) as CustomerCount,
    SUM(ChurnFlag) as ChurnedCount,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(*), 2) as ChurnRate,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges * 12 END), 2) as AnnualRevenueLoss
FROM churn_analytics
GROUP BY TenureGroup, ChargeCategory
ORDER BY TenureGroup, ChargeCategory;


SELECT 
    Geography,
    COUNT(*) as TotalCustomers,
    SUM(ChurnFlag) as ChurnedCustomers,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(*), 2) as ChurnRate,
    ROUND(AVG(MonthlyCharges), 2) as AvgMonthlyRevenue,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges * 12 END), 2) as AnnualRevenueLost,
    ROUND(AVG(CASE WHEN ChurnFlag = 0 THEN Tenure END), 1) as AvgRetainedTenure
FROM churn_analytics
GROUP BY Geography
ORDER BY ChurnRate DESC;


SELECT 
    InternetService,
    Contract,
    COUNT(*) as CustomerCount,
    SUM(ChurnFlag) as ChurnedCount,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(*), 2) as ChurnRate,
    ROUND(AVG(MonthlyCharges), 2) as AvgMonthlyRevenue,
    ROUND(SUM(TotalCharges), 2) as TotalLifetimeValue,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges * 12 END), 2) as AnnualRevenueLoss
FROM churn_analytics
WHERE InternetService != 'Unknown'
GROUP BY InternetService, Contract
ORDER BY InternetService, ChurnRate DESC;


SELECT 
    CustomerValueSegment,
    RiskCategory,
    COUNT(*) as CustomerCount,
    SUM(ChurnFlag) as ChurnedCount,
    ROUND(SUM(ChurnFlag) * 100.0 / COUNT(*), 2) as ChurnRate,
    ROUND(AVG(TotalCharges), 2) as AvgLifetimeValue,
    ROUND(SUM(CASE WHEN ChurnFlag = 1 THEN TotalCharges END), 2) as TotalLTVLost
FROM churn_analytics
GROUP BY CustomerValueSegment, RiskCategory
ORDER BY CustomerValueSegment, RiskCategory;



CREATE VIEW vw_retention_priority AS
SELECT 
    CustomerID,
    Gender,
    Age,
    Geography,
    Tenure,
    Contract,
    InternetService,
    MonthlyCharges,
    TotalCharges,
    RiskScore,
    RiskCategory,
    CustomerValueSegment,
    ServiceAdoptionCount,
    PaymentMethod,
 
    (RiskScore * 0.4 + 
     MonthlyCharges * 0.3 + 
     (CASE WHEN CustomerValueSegment = 'High Value' THEN 30
           WHEN CustomerValueSegment = 'Medium Value' THEN 20
           ELSE 10 END) * 0.3) as RetentionPriority,

    CASE 
        WHEN Contract = 'Month-to-month' AND MonthlyCharges > 70 
            THEN 'Offer annual contract with 15% discount'
        WHEN ServiceAdoptionCount = 0 AND Tenure < 12 
            THEN 'Free premium service trial (TechSupport/Security)'
        WHEN PaymentMethod = 'Electronic check' 
            THEN 'Switch to auto-pay with $5/month discount'
        WHEN Tenure < 6 
            THEN 'Early engagement - satisfaction survey + loyalty bonus'
        ELSE 'General retention outreach'
    END as RecommendedAction
FROM churn_analytics
WHERE ChurnFlag = 0  -- Active customers only
  AND RiskCategory IN ('High Risk', 'Medium Risk')
ORDER BY RetentionPriority DESC;

-- Top 200 priority customers
SELECT * FROM vw_retention_priority LIMIT 200;