----------------------------------UK Train Rides Database------------------

------------------------- Create Database------------------

create database Railway_DB

use Railway_DB

select * from railway


-----------------------------------------2-Add Columns and Calculating:----------------------------------

------------------------------ •	Journey Duration/hr and then change type------------------


alter table railway
add Journey_Duration_hr int

update railway
set Journey_Duration_hr = Datediff(hour , Departure_Time, Actual_Arrival_Time)

------------------------------ •	Delay Duration.minute and then change type---------------------


select * from railway

alter table railway
add Delay_Duration_min int

update railway
set Delay_Duration_min = Datediff(minute, Arrival_Time , Actual_Arrival_Time)

-------------------------•	Route [Departure Station]  →  [Arrival Destination] and then change type--------

alter table railway
add Route varchar (255)


UPDATE railway
set Route = CONCAT(Departure_Station, ' - ', [Arrival_Destination]);



----------------------------------------------------------------2-Extracting:------------------------------------------------

-----------------------------------------------------•	Hour of Purchase and renamed column-------------------


alter table railway
add Purchase_Hour int


update railway
set Purchase_Hour = datepart (hour,Time_of_Purchase)


--------------------------------------------------------------3-Creating Categories----------------------------------------

---------------------------------------------------•	Purchase Time Category and change type ------------------------------- 



select datepart (hour,(Time_of_Purchase)) as Purchase_Hour
from railway



select case 
          when Purchase_Hour >= 5 and Purchase_Hour < 12 then 'Morning'
		  when Purchase_Hour >= 12 and Purchase_Hour < 17 then 'Afternoon'
		  when Purchase_Hour >= 17 and Purchase_Hour < 21 then 'Evening'
		  else 'Night'
end as 'Time of day group'
from railway




---------------------------------------------•	Ticket type Category and change type------------------

select Ticket_Type , 
               case
			       when Purchase_Hour >= 6 and Purchase_Hour <= 8 then 'Morning Peak'
				   when Purchase_Hour >= 16 and Purchase_Hour <= 18 then 'Evining Peak'
				   else 'Off-Peak' 
end as 'Ticket_type_Category'
from railway

----------------------------------------•	Price Category and change type. Categorize Price Column---------------------------

				
select Format (Price , '0.0'),
               case
			       when Price < 10 then 'Budget (<£10)'
				   when Price >= 10 and Price < 50 then 'Standard (£10-50)'
				   else 'Premium (£50+)' 
end as 'Price_Category'
from railway			   
				  

------------------------------------------------------Measures for Key Metrics------------------------------------------


-------------------------------------------------------1. Total_Transaction:--------------------

select count (Transaction_ID) as 'Total Transactions' from railway

------------------------------------------------------2. Total Revenue:------------------------------

select sum (Price) as 'Total Revenue' from railway

------------------------------------------------------3. Total Reasons of Delay Count without N/A Values----------------------

select * from railway

select count (Reason_for_Delay) as 'Total Reasons Count' from railway


-------------------------------------------------------4. Refund Requests count (Yeas)(1)------------------


select count (Refund_Request) as 'Refund Request' from railway 
where Refund_Request = 1

--------------------------------------------------------------5. Refund Rate------------------------

select 
     format ((count (case 
	           when Refund_Request = 1 
			      then Transaction_ID 
				      end ) * 100 ) /
	 count (Transaction_ID ) ,'0.00') + '%' as 'Refund Rate' 
from railway 

----------------------------------------------------------6. On Time Trips---------------------------

select count (Transaction_ID) as 'On Time Trips' from Railway
where Journey_Status like 'On Time'

-----------------------------------------------------7.	On Time Rate --------------------------

select  
   format((count (case
                      when Journey_Status = 'On Time' 
		                 then Transaction_ID 
		                    end) * 100.0) /
   count (Transaction_ID),'0.00') + '%' as 'On Time Rate' 
from Railway   

--------------------------------------------------8. Delayed Trips:-------------------

select count (Transaction_ID) as 'Delayed Trips' from Railway
where Journey_Status like 'Delayed'

--------------------------------------------------9.	Delayed Rate -------------------------------------

select  
   format((count (case
                      when Journey_Status = 'Delayed' 
		                 then Transaction_ID 
		                    end) * 100.0) /
   count (Transaction_ID),'0.00') + '%' as 'Delayed Rate' 
from Railway


----------------------------------------------------10. Delayed Reason Count:----------------------

select * from railway

select Journey_Status , 
       Reason_for_Delay , 
	   count (Reason_for_Delay ) as 'Delay Reasons Count'
from railway
where Journey_Status = 'Delayed'
group by Journey_Status , Reason_for_Delay



-------------------------------------------------------11. Cancelled Trips------

select count (Transaction_ID) as 'Cancelled Trips' from Railway
where Journey_Status like 'Cancelled'


---------------------------------------------------------12. Cancelled Rate------------------------------

select  
   format((count (case
                      when Journey_Status = 'Cancelled' 
		                 then Transaction_ID 
		                    end) * 100.0) /
   count (Transaction_ID),'0.00') + '%' as 'Cancelletion Rate' 
from Railway 


------------------------------------------------13. Cancelled Reason Count------------------------------------

select Journey_Status , 
       Reason_for_Delay , 
	   count (Reason_for_Delay ) as 'Cancelletion Reasons'
from railway
where Journey_Status = 'Cancelled'
group by Journey_Status , Reason_for_Delay

-------------------------------------------------14. AVG.Ticket Price-----------------------------

select format (avg(Price) , '0.0') as 'AVG.Ticket Price' from Railway


---------------------------------------------15. Average Delay---------------------------------

select Datediff(minute, Arrival_Time , Actual_Arrival_Time) as 'Delay Duration.minute' 
from Railway


select avg (Datediff(minute, Arrival_Time , Actual_Arrival_Time)) as 'Average Delay'
from Railway


------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------Page 1 (Summary)----------------------------------------------

--- VIS 1 -------  routes with ticket type-----------------------

select [Route] , Ticket_Type from railway


----VIS 2 ------ Total Revenue by Purchase /hr

select format (sum (Price) , '0.0') as 'Total Revenue' , Purchase_Hour 
from railway
group by Purchase_Hour , Price



---------------------------------------------------Page 2 (Revenue Overview)----------------------------------------------

select * from railway

--- VIS 1 ----- Total revenue by Price Category-----

select format (sum (Price) , '0.0') as 'Total Revenue' , 
               case
			       when Price < 10 then 'Budget (<£10)'
				   when Price >= 10 and Price < 50 then 'Standard (£10-50)'
				   else 'Premium (£50+)' 
end as 'Price_Category'
from railway
group by Price

----VIS 2 ------ Total Transactions by Price-------


select count (Transaction_ID) as 'Total Transactions' , format (sum (Price) , '0.0') as 'Total Revenue'
from railway



---------------------------------------------------page 3 ( Tickets  Revenue )------------------------------------------------

------VIS 1 --------- Total Revenue by Ticket Class-------

select format (sum (Price) , '0.0') as 'Total Revenue' , Ticket_Class 
from railway
group by Price , Ticket_Class


-------VIS 2 -------------- Total  Revenue by Purchase Type-----

select format (sum (Price) , '0.0') as 'Total Revenue', Purchase_Type
from railway
group by Price , Purchase_Type

----VIS 3------ Total  Revenue by Ticket Type----------

select format (sum (Price) , '0.0') as 'Total Revenue', Ticket_Type
from railway
group by Price , Ticket_Type


---VIS 4 ------Revenue of Cancelled Trips and Delayed Trips by Reasons for Delay and cancelled------

SELECT 
    Reason_for_Delay, Journey_Status , format(sum(Price), '0.0') as 'Total_Revenue', 
	count (Transaction_ID) as Journey_Count
FROM Railway
WHERE Journey_Status IN ('Delayed', 'Cancelled')
GROUP BY Reason_for_Delay, Journey_Status


----VIS 5---- Total  Revenue by Journey Status------

select format (sum (Price) , '0.0') as 'Total Revenue' , Journey_Status
FROM Railway
group by Journey_Status


----VIS 6----Total  Revenue by Ticket Type Category and Time Category------

select format(sum(Price), '0.0') as Total_Revenue, 
       case
           when Purchase_Hour >= 6 and Purchase_Hour <= 8 then 'Morning Peak'
           when Purchase_Hour >= 16 and Purchase_Hour <= 18 then 'Evining Peak'
	       else 'Off-Peak' 
       end as 'Ticket_type_Category',
       case 
          when Purchase_Hour >= 5 and Purchase_Hour < 12 then 'Morning'
		  when Purchase_Hour >= 12 and Purchase_Hour < 17 then 'Afternoon'
		  when Purchase_Hour >= 17 and Purchase_Hour < 21 then 'Evening'
		  else 'Night'
       end as 'Time of day group'
from Railway
group by Purchase_Hour , Price


--------------------------------------------------------Page 4 (Routes Revenue)-------------------------------------------------

----VIS---1 ------- Total Revenue and Count of Ticket Class by Departure Station--------

select format(sum(Price), '0.0') as Total_Revenue,count (Ticket_Class) as 'Count of Ticket', Departure_Station
from Railway
group by Departure_Station


-----VIS 2 -------- Top 10 Route by Total Revenue-----------------

select top 10 [Route] , format(sum(Price), '0.0') as Total_Revenue
from Railway
group by [Route]

---------------------------------------------------Page 5 (Customer Insights)------------------------------------------

-------VIS 1----- Total Transactions by Purchase Type-------

select [Purchase_Type], count([Transaction_ID]) as 'Transactions Count' from Railway
group by [Purchase_Type]


--------VIS 2 ----- Total transactions by PurchaseTime/hr--------

select * from railway


select  count([Transaction_ID]) as 'Transactions Count' , 
        Purchase_Hour 
from railway
group by Purchase_Hour

------VIS 3 ------Total Transactions by Payment Method--------

select  count([Transaction_ID]) as 'Transactions Count' , [Payment_Method]
from railway 
group by [Payment_Method]


------VIS 4------ -	Total Transactions by Railcard----------

select  count([Transaction_ID]) as 'Transactions Count',[Railcard]
from railway 
group by [Railcard]


--------------------------------------------------------------Page 6 (Reasons of Delayed Insights)--------------------------------------

---VIS 1 ------ Total Transactions & AVG Delay.min by Reason for Delay-------------


select avg(Delay_Duration_min) as 'Delay_Durationmin' , count([Transaction_ID]) as 'Transactions Count',
[Reason_for_Delay]
from Railway
group by [Reason_for_Delay]

----VIS 2 ---- Cancelled Trips and Delayed Trips by Reasons for Delay and cancelled--------


select [Reason_for_Delay], Journey_Status, count ([Transaction_ID]) as 'Total Transactions'
FROM Railway
WHERE Journey_Status IN ('Delayed', 'Cancelled')
GROUP BY Reason_for_Delay, Journey_Status


---------------------------------------------Page 7 ( Operational Metrics )------------------------------


-----VIS 1----------- Delayed Trips by Time Category-------

SELECT 
    CASE 
        WHEN Purchase_Hour >= 5 AND Purchase_Hour < 12 THEN 'Morning'
        WHEN Purchase_Hour >= 12 AND Purchase_Hour < 17 THEN 'Afternoon'
        WHEN Purchase_Hour >= 17 AND Purchase_Hour < 21 THEN 'Evening'
        ELSE 'Night'
    END AS Time_of_Day_Group,
    COUNT(Transaction_ID) AS Delayed_Trips
FROM Railway
WHERE Journey_Status = 'Delayed'
GROUP BY 
    CASE 
        WHEN Purchase_Hour >= 5 AND Purchase_Hour < 12 THEN 'Morning'
        WHEN Purchase_Hour >= 12 AND Purchase_Hour < 17 THEN 'Afternoon'
        WHEN Purchase_Hour >= 17 AND Purchase_Hour < 21 THEN 'Evening'
        ELSE 'Night'
    END;


---VIS 2 --------Cancelled Trips by Departure Time-----------

SELECT [Departure_Time], COUNT(Transaction_ID) AS 'Canceleed Trips'
FROM Railway
WHERE Journey_Status = 'Cancelled'
GROUP BY [Departure_Time]


----VIS 3 -------- Cancelled Trips by Route

SELECT [Route], COUNT(Transaction_ID) AS 'Canceleed Trips'
FROM Railway
WHERE Journey_Status = 'Cancelled'
GROUP BY [Route]



-------------------------------------------------Page 8 (Refund Insights)-------------------------------


---VIS 1------- Total Refund Request & Total Revenue by Journey Status------
select [Journey_Status], format(sum(Price), '0.0') as Total_Revenue ,count (Refund_Request) as 'Total Refund Request' 
from railway
where Refund_Request=1
group by [Journey_Status]


---VIS 2------ Total Refund Request by Journey Status------

select [Journey_Status], count (Refund_Request) as 'Total Refund Request' 
from railway
where Refund_Request=1
group by [Journey_Status]


---VIS 3 ------Refund Requests by Reason for Delay and Journey Status------

select [Journey_Status], [Reason_for_Delay], count (Refund_Request) as 'Total Refund Request' 
from railway
where Refund_Request=1
group by [Journey_Status] ,[Reason_for_Delay]







































