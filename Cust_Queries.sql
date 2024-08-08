---Customer's first Account Type opened
WITH AT_FIRST AS(
   SELECT  
      Customer_Id, 
      Account_Type, 
     ACCOUNT_OPEN_DT,
    DENSE_RANK() OVER (ORDER BY ACCOUNT_OPEN_DT) AS rank
    FROM PROD_TAB.CORE_AGREEMENT_EOM
   WHERE  Customer_Id='000005' --- and Account_type='CA'
 )
 SELECT 
   Customer_Id, 
   Account_Type, 
   ACCOUNT_OPEN_DT
 FROM AT_FIRST
 WHERE RANK=1



---Top 3 customers with highest balance in USD
WITH HIGHEST_BALANCE AS(

  SELECT TOP 10
    Customer_Id,
    Today_Date,
    SUM(Accounting_Bal) AS Accounting_Bal,
    CURRENCY_CD,
    DENSE_RANK() OVER (ORDER BY SUM(Accounting_Bal) DESC) as ranking
  FROM PROD_STG_CORE.CBK_ECL_AGREEMENT_EOM 
  WHERE  CURRENCY_CD = '840' AND 
         Accounting_Bal>0
  GROUP BY 
    Customer_Id,Today_Date,CURRENCY_CD

  ORDER BY SUM(Accounting_Bal) DESC
)
SELECT 
  Customer_Id,
  Today_Date,
  Accounting_Bal,
  CURRENCY_CD
FROM HIGHEST_BALANCE
WHERE ranking IN (1,2,3)


---Finding dupilcate customers
SELECT 
  Customer_Id,
  Today_Date,
  CURRENCY_CD,
  ACCOUNT_TYPE,
  FORMAT(Accounting_Bal,'N') Accounting_Bal,
  COUNT(*) AS number_of_rows
FROM PROD_STG_CORE.CBK_ECL_AGREEMENT_EOM
where Accounting_Bal <> 0 
GROUP BY   
  Customer_Id,
  Today_Date,
  CURRENCY_CD,
  ACCOUNT_TYPE,
  FORMAT(Accounting_Bal,'N') 
HAVING COUNT(*) > 1
order by Customer_Id

 
---Customer Running Total
SELECT x.Customer_Id, sum(x.Event_Amount), x.Event_Currency_Cd, x.Event_Posted_Date,
        ( SELECT    SUM(y.Event_Amount)
          FROM     prod_stg_core.MIS_EVENT_MONTH y
          WHERE    Customer_Id='88700' AND event_posted_date between '2024-05-31' and '2024-06-30' and Event_Currency_Cd='840' and
    y.Customer_Id = x.Customer_Id
                    AND y.Event_Posted_Date <= x.Event_Posted_Date
  
        ) AS RunningTotal
FROM   prod_stg_core.MIS_EVENT_MONTH as x
WHERE Customer_Id='088700' AND event_posted_date between '2024-05-31' and '2024-06-30' and Event_Currency_Cd='840'
group by x.Customer_Id, x.Event_Currency_Cd, x.Event_Posted_Date
ORDER BY x.Event_Posted_Date;

```
