with RFM_cal as
(select
	customerid,
	datediff(day,max(Purchase_Date), '2022-09-01') as recency,
	count(customerid)*1.0/datediff(year,max(created_date), '2022-09-01')as frequency,
	sum(GMV)/datediff(year,max(created_date), '2022-09-01') as monetary,
	row_number() over (order by datediff(day,max(Purchase_Date), '2022-09-01')) as R_rank,
	row_number() over (order by count(customerid)/datediff(year,max(created_date), '2022-09-01')) as F_rank,
	row_number() over (order by sum(GMV)/datediff(year,max(created_date), '2022-09-01')) as M_rank
from Customer_Transaction ct 
join Customer_Registered cr on ct.CustomerID = cr.ID 
where customerid != 0
group by customerid),
RFM_rank as
(
  select *,
  case
    when R_rank < (select count(*)*0.25 from RFM_cal) then '4'
    when R_rank >= (select count(*)*0.25 from RFM_cal) and  
   		 R_rank	< (select count(*)*0.5 from RFM_cal) then '3'
   	when R_rank >= (select count(*)*0.5 from RFM_cal) and  
   		 R_rank	< (select count(*)*0.75 from RFM_cal) then '2'
   	else '1'
  end as R,
  case
    when F_rank < (select count(*)*0.25 from RFM_cal) then '1'
    when F_rank >= (select count(*)*0.25 from RFM_cal) and  
   		 F_rank	< (select count(*)*0.5 from RFM_cal) then '2'
   	when F_rank >= (select count(*)*0.5 from RFM_cal) and  
   		 F_rank	< (select count(*)*0.75 from RFM_cal) then '3'
   	else '4'
   	end as 'F',
  case
    when M_rank < (select count(*)*0.25 from RFM_cal) then '1'
	when M_rank >= (select count(*)*0.25 from RFM_cal) and  
   		 M_rank	< (select count(*)*0.5 from RFM_cal) then '2'
   	when M_rank >= (select count(*)*0.5 from RFM_cal) and  
   		 M_rank	< (select count(*)*0.75 from RFM_cal) then '3'
   	else '4'
  end as M
  from RFM_cal )
  select *,
  		concat(R,F,M) as RFM,
  		case
  			when concat(R,F,M) in ('343','344', '443', '444', '434') then 'VIP'
  			when concat(R,F,M) in ('433', '233', '234', '333', '334', '243', '244') then 'Potetial Customer'
  			when concat(R,F,M) in ('341', '342', '441', '442', '431', '432', '332', '331') then 'Loyal Customer'
  			when concat(R,F,M) in ('311', '312', '313', '314', '411', '412','413','414','321','322','323','324','421','422','423','424') then 'New Customer'
  			when concat(R,F,M) in ('211','221','231','241','212','222','232','242','213','223','214','224') then 'About to sleep'
  			when concat(R,F,M) in ('111','112','113','114','121','122','123','124','131','132','133','134','141','142','143','144') then 'Lost'
  		end as segmentation	
  from RFM_rank
 
  