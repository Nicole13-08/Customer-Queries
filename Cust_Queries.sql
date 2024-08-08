---Customer's first Account Type opened
WITH AT_FIRST AS(
   SELECT  
      Customer_Id, 
      Account_Type, 
     ACCOUNT_OPEN_DT,
    DENSE_RANK() OVER (ORDER BY ACCOUNT_OPEN_DT) AS rank
    FROM Customer_Data_TBL
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
    Date,
    SUM(Balance) AS Balance,
    CURRENCY,
    DENSE_RANK() OVER (ORDER BY SUM(Balance) DESC) as ranking
  FROM Customer_Data_TBL
  WHERE  CURRENCY = '840' AND 
         Balance>0
  GROUP BY 
    Customer_Id,Date,CURRENCY

  ORDER BY SUM(Balance) DESC
)
SELECT 
  Customer_Id,
  Date,
  Balance,
  CURRENCY
FROM HIGHEST_BALANCE
WHERE ranking IN (1,2,3)


---Finding dupilcate customers
SELECT 
  Customer_Id,
  Date,
  CURRENCY,
  ACCOUNT_TYPE,
  FORMAT(Balance,'N') Balance,
  COUNT(*) AS number_of_rows
FROM Customer_Data_TBL
where FORMAT(Balance,'N') <> 0 
GROUP BY   
  Customer_Id,
  Date,
  CURRENCY,
  ACCOUNT_TYPE,
  FORMAT(Balance,'N') 
HAVING COUNT(*) > 1
order by Customer_Id

 
---Customer Running Total
SELECT x.Customer_Id, sum(x.Amount), x.Currency_Cd, x.Event_Date,
        ( SELECT    SUM(y.Amount)
          FROM     Customer_Transaction_TBL y
          WHERE    Customer_Id='6677' AND Event_Date between '2024-05-31' and '2024-06-30' and Currency_Cd='840' and
    y.Customer_Id = x.Customer_Id
                    AND y.Event_Date <= x.Event_Date
  
        ) AS RunningTotal
FROM   Customer_Transaction_TBL as x
WHERE Customer_Id='6677' AND Event_Date between '2024-05-31' and '2024-06-30' and Currency_Cd='840'
group by x.Customer_Id, x.Currency_Cd, x.Event_Date
ORDER BY x.Event_Date;

```
