-- 1. What are the top 3 products by total revenue before discount?
select
	pd.product_name,
	sum(s.price * s.qty) as nodis_revenue
from Clothing_store..sales as s
join Clothing_store..product_details as pd
on s.prod_id = pd.product_id
group by pd.product_name
order by nodis_revenue desc
OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY;
-----------------------------------------------------------------------

-- 2. What is the total quantity, revenue and discount for each segment?
select
	pd.segment_id,
	pd.segment_name,
	sum(s.qty) as total_quantity,
	sum(s.qty * s.price) as total_revenue,
	sum(s.qty * s.price * s.discount)/100 as total_discount
from Clothing_store..product_details as pd
join Clothing_store..sales as s
on pd.product_id = s.prod_id
group by 
	pd.segment_id,
	pd.segment_name
order by total_revenue desc;
-----------------------------------------------------------------------

-- 3. What is the top selling product for each segment?
select
	pd.segment_id,
	pd.segment_name,
	pd.product_id,
	pd.product_name,
	sum(s.qty) as product_quantity
from Clothing_store..product_details as pd
join Clothing_store..sales as s
on pd.product_id = s.prod_id
group by
	pd.segment_id,
	pd.segment_name,
	pd.product_id,
	pd.product_name
order by product_quantity desc
OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY;
-----------------------------------------------------------------------

-- 4. What is the total quantity, revenue and discount for each category?
select
	pd.category_id,
	pd.category_name,
	sum(s.qty) as total_quantity,
	sum(s.qty * s.price) as total_revenue,
	sum(s.qty * s.price * s.discount)/100 as total_discount
from Clothing_store..product_details as pd
join Clothing_store..sales as s
on pd.product_id = s.prod_id
group by 
	pd.category_id,
	pd.category_name
order by total_revenue desc;
-----------------------------------------------------------------------

-- 5. What is the top selling product for each category?
select
	pd.category_id,
	pd.category_name,
	pd.product_id,
	pd.product_name,
	sum(s.qty) as product_quantity
from Clothing_store..product_details as pd
join Clothing_store..sales as s
on pd.product_id = s.prod_id
group by
	pd.category_id,
	pd.category_name,
	pd.product_id,
	pd.product_name
order by product_quantity desc
OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY;
-----------------------------------------------------------------------

-- 6. What is the percentage split of revenue by product for each segment?
with product_revenue as (
select
	pd.segment_id,
    pd.segment_name,
    pd.product_id,
    pd.product_name,
	sum(s.qty * s.price) as product_revenue
from Clothing_store..product_details as pd
join Clothing_store..sales as s
on pd.product_id = s.prod_id
group by
	pd.segment_id,
    pd.segment_name,
    pd.product_id,
    pd.product_name
)
select
	segment_name,
	product_name,
	round(100*cast(product_revenue as float) / sum(product_revenue) over(partition by segment_id),2) as segment_product_percentage
from product_revenue
order by 
	segment_id,
	segment_product_percentage desc;
-----------------------------------------------------------------------

-- 7. What is the percentage split of revenue by segment for each category?
with product_revenue as (
select
	pd.category_id,
    pd.category_name,
	pd.segment_id,
    pd.segment_name,
	sum(s.qty * s.price) as product_revenue
from Clothing_store..product_details as pd
join Clothing_store..sales as s
on pd.product_id = s.prod_id
group by
	pd.segment_id,
    pd.segment_name,
    pd.category_id,
    pd.category_name
)
select
	category_name,
	segment_name,
	round(100*cast(product_revenue as float) / sum(product_revenue) over(partition by category_id),2) as segment_product_percentage
from product_revenue
order by 
	category_id,
	segment_product_percentage desc;
-----------------------------------------------------------------------

-- 8. What is the percentage split of total revenue by category?
select
	100*sum(case when pd.category_id = 1 then (s.qty * s.price) end) / sum(s.qty * s.price) as category_1,
	100-100*sum(case when pd.category_id = 1 then (s.qty * s.price) end) / sum(s.qty * s.price) as category_2
from Clothing_store..sales as s
join Clothing_store..product_details as pd
on s.prod_id = pd.product_id
-----------------------------------------------------------------------

-- 9. What is the total transaction “penetration” for each product?
with product_transaction as (
select
	distinct prod_id,
	count(distinct txn_id) as product_transaction_count
from Clothing_store..sales
group by prod_id
),
total_transactions as (
select 
	count(distinct txn_id) as total_transaction_count
from Clothing_store..sales
)
select 
	pt.prod_id,
	pd.product_name,
	round(100*cast(pt.product_transaction_count as float) / tt.total_transaction_count,2) as penetration_percentage

from product_transaction as pt
cross join total_transactions as tt
inner join Clothing_store..product_details as pd
on pd.product_id = pt.prod_id
order by penetration_percentage desc;
-----------------------------------------------------------------------

