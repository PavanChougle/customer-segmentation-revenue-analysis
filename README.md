# customer-segmentation-revenue-analysis

# 📊 Customer Churn Intelligence System

## 📌 Objective
Built an end-to-end churn analysis system to identify high-risk customers, understand churn drivers, and estimate revenue impact using SQL and Power BI.


## 🧠 Business Problem
Customer churn directly impacts revenue and growth.  
This project analyzes customer behavior to:
- Identify why customers leave
- Detect high-risk segments
- Recommend retention strategies

## ⚙️ Tech Stack
- SQL (MySQL) – Data cleaning & analysis  
- Power BI – Dashboard & visualization  
- Excel – Initial data inspection  
- GitHub – Version control  


## 🔧 Data Preparation
Handled real-world messy data:

- Removed duplicate records  
- Standardized inconsistent values (Yes/No, casing issues)  
- Handled missing values  
- Fixed data type issues (e.g., TotalCharges as numeric)  
- Removed invalid entries (negative charges, extreme outliers)  


## 🧮 Feature Engineering

### 🔹 Risk Score Model
Customers scored based on:
- Contract type (Month-to-month)
- Tenure (<12 months)
- Payment method (Electronic check)
- No Tech Support
- High Monthly Charges

→ Used to classify:
- High Risk  
- Medium Risk  
- Low Risk  


### 🔹 Customer Segmentation
- High Value  
- Medium Value  
- Low Value  
- New Customers  


### 🔹 Service Adoption Index
Measured number of services used per customer  
→ Higher adoption = lower churn risk  


## 📊 Key Insights

- Month-to-month customers show highest churn (~38%+)  
- First-year customers have highest churn (~50%)  
- Electronic check users are more likely to churn  
- Customers with no services have ~44% churn  
- Customers using 2+ services show ~70% lower churn  


## 💰 Business Impact

- Identified high-risk customers contributing to major revenue loss  
- Estimated potential revenue recovery through retention strategies  
- Highlighted key segments for targeted interventions  


## 🎯 Recommendations

- Convert customers to long-term contracts  
- Offer onboarding programs for new customers  
- Promote service bundles  
- Provide free or discounted tech support  
- Shift customers to auto-pay systems  


## 📊 Dashboard Features

### 🔹 Executive Overview
- Churn rate, revenue loss, customer count  

### 🔹 Segmentation Analysis
- Churn by tenure, contract, geography  

### 🔹 Retention Intelligence
- High-risk customer identification  
- Recommended actions for retention  

## 📁 Project Structure
customer-segmentation-revenue-analysis/

data/
   raw_data.csv

sql/
   Data.sql
   clean.sql
   A
   nalysis.sql

powerbi/
   dashboard.pbix

README.md
