# PL-SQL
Automatation using PL/SQL

This project aims to automate the analysis of the stock market with PL-SQL
between 2015 and 2017 for 7 large industries in the technology sector:

-Apple Inc(AAPL)
-Amazon.com Inc(AMZN)
-Cisco Systmes Inc(CSCO)
-International Business Machines(IBM)
-Intel Corporation(INTC)
-Microsoft Corporation(MSFT)
-Oracle Corporation(ORCL)

* In the file "_CompanyTIC_2015_2017.csv", there is the information to be analyzed that was downloaded
from "finance.yahoo.com" which has 5295 data in total.

* The objective is to analyze this information by year and quarter for each company.
In the file "_TALLER_PL_1_2024.XLSX", the way in which the summary should be carried out is displayed;
In this case it exemplifies it for the year 2016.

- In "Data" the averages are calculated for each column grouped by quartiles of the year
- In "Aspect" It is the final result of analyzing in each quaterio for each of the companies, this table
This is what should be generated with PL-SQL, through a procedure that uses the year as the parameter "SUMMARY_BOLSA(year)"

* "Informe Package Bolsa Valores.pdf" details the entire ETL process, from the import of the information to the
treatment with stored procedures and functions to reach the result of the summary table.
