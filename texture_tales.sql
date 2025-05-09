create database texture_tales;
use texture_tales;
show tables;
select * from product_details;
select * from product_hierarchy;
select * from product_prices;
select * from sales;

-- Check for duplicate transactions --
select prod_id, txn_id, count(*) from sales group by prod_id, txn_id having count(*) > 1;

-- Check for null values --
select count(*) from sales where prod_id is null or qty is null or price is null;
select count(*) from product_details where product_id is null;

-- What was the total quantity sold for all products? --
select details.product_name, 
       sum(sales.qty) as sale_counts
from sales 
inner join product_details as details
on sales.prod_id = details.product_id
group by details.product_name
order by sale_counts desc;

-- What is the total generated revenue for all products before discounts? --
select sum(qty * price) as total_revenue_before_discount 
from sales;

-- What was the total discount amount for all products? --
select sum(qty * discount) as total_discount_amount 
from sales;

-- How many unique transactions were there? --
select count(distinct txn_id) as unique_transactions 
from sales;

-- What are the top 3 products by total revenue before discount? --
select prod_id, sum(qty * price) as total_revenue 
from sales 
group by prod_id 
order by total_revenue desc
limit 3;

-- What are the total quantity, revenue and discount for each segment? --
select pd.segment_name, 
       sum(s.qty) as total_qty,
       sum(s.qty * s.price) as total_revenue,
       sum(s.qty * s.discount) as total_discount 
from sales s 
join product_details pd on s.prod_id = pd.product_id 
group by pd.segment_name
order by total_revenue desc;

-- What are the total quantity, revenue and discount for each category? --
select pd.category_name, 
       sum(s.qty) as total_qty,
       sum(s.qty * s.price) as total_revenue,
       sum(s.qty * s.discount) as total_discount 
from sales s 
join product_details pd on s.prod_id = pd.product_id 
group by pd.category_name
order by total_revenue desc;

-- What are the average unique products purchased in each transaction? --
select avg(product_count) as avg_unique_products_per_transaction
from(
      select txn_id, count(distinct prod_id) as product_count 
      from sales 
      group by txn_id
 ) AS product_counts_per_txn;

--  What is the average discount value per transaction? --
select avg(total_discount) as avg_discount_per_transaction 
from(
     select txn_id, sum(qty * discount) AS total_discount
     from sales
     group by txn_id) AS discounts_per_txn;

-- What is the top selling product for each category? --
select category_name, product_id, product_name, total_qty 
from (
     select pd.category_name, s.prod_id as product_id, pd.product_name,
     sum(s.qty) as total_qty, 
     row_number() over (partition by pd.category_name order by SUM(s.qty) desc)as rank_order 
from sales s 
join product_details pd on s.prod_id = pd.product_id 
group by pd.category_name, s.prod_id, pd.product_name
) as ranked_products_per_category
where rank_order = 1;

-- What is the average revenue for member transactions and non-member transactions --
select member, avg(total_revenue) as avg_revenue 
from (
     select txn_id, member, sum(qty * price) as total_revenue 
     from sales 
     group by txn_id, member
) as transaction_revenue
group by member;

-- What is the top selling product for each segment? --
select segment_name, product_id, product_name, total_qty 
from(
    select pd.segment_name, s.prod_id AS product_id, pd.product_name,
    sum(s.qty) as total_qty,
    row_number() over (partition by pd.segment_name order by sum(s.qty) desc) as rank_order
from sales s 
join product_details pd on s.prod_id = pd.product_id
group by pd.segment_name, s.prod_id, pd.product_name
 ) as ranked_products_per_segment 
 where rank_order = 1;





