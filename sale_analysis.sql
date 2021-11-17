-- 1. What was the total quantity of products sold?
select 
	pd.product_name,
	sum(s.qty) as sale_count
from Clothing_store..sales as s
join Clothing_store..product_details as pd
on pd.product_id = s.prod_id
group by product_name
order by sale_count desc;
-------------------------------------------------------------------------------

-- 2. What is the total revenue for all products before discount?
select 
	pd.product_name,
	sum(s.qty * s.price) as nodis_revenue
from Clothing_store..sales as s
join Clothing_store..product_details as pd
on pd.product_id = s.prod_id
group by pd.product_name
order by nodis_revenue desc;
-------------------------------------------------------------------------------

-- 3. What was the total discount amount for all products?
select 
	sum(price * qty * discount)/100 as total_discount
from Clothing_store..sales