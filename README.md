# Fabric_ETL_Hotel
This project will create an ETL from scratch using a Lakehouse, notebooks, and a warehouse, based on the following architecture:  
<img width="1037" height="572" alt="image" src="https://github.com/user-attachments/assets/c52cc799-2fb8-4581-9c99-dc7bbe1d5c40" />

---
## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from a CSV File into a Delta Table.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---
## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating a semantic model which can be used to design reports and dashboards for actionable insights.

🎯 This repository aims to showcase expertise in:
- SQL Development
- Data Architect
- Data Engineering  
- ETL Pipeline Developer  
- Data Modeling  
- Data Analytics  

---

## 🛠️ Important Links & Tools:
- **[Microsoft Learn](https://learn.microsoft.com/en-us/training/modules/use-dataflow-gen-2-fabric/):** Explain the Gen2 tool that makes possible the ingestion process in the project.
- **[DrawIO](https://www.drawio.com/):** Design data architecture, models, flows, and diagrams.
---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern data warehouse using Microsoft Fabric to consolidate logistics data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from a hotel company provided as CSV file.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Transformation**: Build a dimensional model using the file from the Silver layer.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Booking Performance**
- **Deposit Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making. 
## 📂 Repository Structure
```
Fabric_ETL_Gen2/
│
├── 0.DataSource/                       # Raw dataset used for the project
│
├── 1.BronceLayer/                      # Explains the bronce layer
│   ├── Flow.md                         # This file shows the processes developed in the Bronce stage
├── 2.SilverLayer/                      # Explains the silver layer
│   ├── Flow.md                           # This file shows the processes developed in the Silver stage
│   ├── DW_Silver.sql                      # This file shows the SQL code used in this phase
├── 3.GoldLayer/                        # Explains the gold layer
│   ├── Flow.md                           # This file shows the processes developed in the Gold stage
│   ├── DW_Gold.sql                      # This file shows the SQL code used in this phase
├── 4.SemanticModel/                    # Explains the semantic model
│   ├── DimensionalModel.md               # This file shows the processes involved to create the semantic model
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories to be ignored by Git
```
---


## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.

## 🌟 About Me

Hi there! I'm **John**. I’m a Data professional on a mission to create business solutions!
