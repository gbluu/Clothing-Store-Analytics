-- 1. How many unique transaction were there?
select
	count(distinct txn_id) as unique_txn
from Clothing_store..sales;
-----------------------------------------------------------------

-- 2. What is the average unique products purchased in each transaction?
with transaction_product as(
select
	txn_id,
	count(distinct prod_id) as product_count
from Clothing_store..sales
group by txn_id
)

select 
	round(avg(product_count),0) as avg_transaction_product
from transaction_product;
-----------------------------------------------------------------

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
with transaction_revenue as (
select
	sum(qty * price) as revenue
from Clothing_store..sales
group by txn_id
) 
select 
	PERCENTILE_CONT(0.25) within group (order by revenue)
		OVER() as pct_25,
	PERCENTILE_CONT(0.5) within group (order by revenue) 
		OVER() as pct_50,
	PERCENTILE_CONT(0.75) within group (order by revenue) 
		OVER() as pct_75
from transaction_revenue;
-----------------------------------------------------------------

-- 4. What is the average discount value per transaction?
with transaction_discount as (
select 
	txn_id,
	sum(discount*qty*price)/100 as total_discount
from Clothing_store..sales
group by txn_id
)
select
	round(avg(total_discount),2) as avg_txn_discount
from transaction_discount
-----------------------------------------------------------------

-- 5. What is the percentage split of all transactions for members vs non-members?
select
	round(100*count(distinct case when member = 't' then txn_id end) / count(distinct txn_id),2) as member_transaction,
	(100 - round(100*count(distinct case when member = 't' then txn_id end) / count(distinct txn_id),2)) as member_transaction
from Clothing_store..sales;
-----------------------------------------------------------------

-- 6. What is the average revenue for member transactions and non-member transactions?
with member_revenue as (
select
	member,
	txn_id,
	sum(cast(price as float) * qty) as revenue
from Clothing_store..sales
group by 
	member,
	txn_id
)
select 
	member,
	round(avg(revenue),2) as avg_revenue
from member_revenue
group by member;