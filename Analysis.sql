select * from df_orders

--find the top 10 highest revenue generating products
select top 10 product_id, sum(sale_price) as sales from df_orders
group by product_id
order by sales desc

--find the top 5 highest selling products in each region
with cte as(
select region,
product_id, sum(sale_price) as sales
from df_orders
group by product_id,region)

select * from (
select region,product_id,sales,
rank() over(partition by region order by sales desc) as rn
from cte) A
where rn <=5

--find the month over month growth comparison for 2022 and 2023 sakes eg: jan 2022 vs jan 2023
with cte as (
select year(order_date) as year,month(sale_price) as month,sum(sale_price) as sales
from df_orders
group by year(order_date),month(sale_price))

select month,
sum(case when year = 2022 then sales else 0 end) as sales_2022,
sum(case when year = 2023 then sales else 0 end) as sales_2023
from cte
group by month
order by month asc


--for each category which month has highest sales
with cte as (
select category, sum(sale_price) as sales,format(order_date,'yyyyMM') as date 
from df_orders
group by category,format(order_date,'yyyyMM'))

select * from (
select *, rank() over(partition by category order by sales desc) as rn
from cte
) A
where rn = 1
order by sales desc

--which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as year,sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)),

cte2 as (
select sub_category,
sum(case when year = 2022 then sales else 0 end) as sales_2022,
sum(case when year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category)

select top 1 *,(sales_2023 - sales_2022)*100/sales_2022 as growth
from cte2 
order by (sales_2023 - sales_2022)*100/sales_2022 desc