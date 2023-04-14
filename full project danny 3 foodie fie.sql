# displaying different customer ids
select distinct customer_id
from subscriptions ;

# no.of customers organisation is having
select count(distinct customer_id)
from subscriptions ;

# Analysis of some 8 customers choosing them randomly
# analysis of customer 1
select *
from subscriptions
where customer_id=1 ;

# analysis of customer 101
select *
from subscriptions as s
join plans as p
on s.plan_id=p.plan_id
where customer_id=101 ;

# total money spent by customer 104
select sum(p.price)
from subscriptions as s
join plans as p
on s.plan_id=p.plan_id
where customer_id=104 ;

# total revenue organisation earned from each plan
select p.plan_name,p.plan_id, sum(price)
from subscriptions as s
join plans as p
on s.plan_id=p.plan_id
group by p.plan_id ;

# How many plans each customer bought
select s.customer_id,count(*) as total_plans
from subscriptions as s
join plans as p
on s.plan_id=p.plan_id
group by s.customer_id
order by total_plans desc ;

# which customer bought maximum plans
with cte1 as(select *,count(s.customer_id) as total_plans
from subscriptions as s
group by s.customer_id
order by total_plans desc)
select customer_id,total_plans
from cte1
where total_plans=4 ;

# What is the monthly distribution of trial plan start_date values for our dataset
# - use the start of the month as the group by value
select plan_id,extract(MONTH from start_date) as months ,count(plan_id)
from subscriptions
where plan_id = 0
group by months
order by months asc ;

# What is the monthly distribution of trial plan start_date values for our dataset using joins, showing plan name
select s.plan_id,extract(MONTH from start_date) as months ,count(p.plan_id) ,plan_name
from subscriptions as s
join plans as p
on s.plan_id=p.plan_id
where s.plan_id = 0
group by months
order by months asc ;

# What plan start_date values occur after the year 2020 for our dataset?
# Show the breakdown by count of events for each plan_name
select plan_id,count(*)
from subscriptions
where year(start_date) > 2020
group by plan_id ;

# customers having churn plan
select *,count(*)
from subscriptions as s
join plans as p
on s.plan_id=p.plan_id
where p.plan_name = 'churn'
group by s.customer_id ;

# What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
with cte1 as(select count(distinct customer_id) as total_customers from subscriptions),
cte2 as(select *,count(distinct customer_id) as total_churned_customers from subscriptions as s
 where s.plan_id= 4)
select total_customers,total_churned_customers, (cte2.total_churned_customers/cte1.total_customers) * 100
from cte1,cte2 ;
#group by s.customer_id ;


# How many customers have churned straight after their initial free trial - 
#what percentage is this rounded to the nearest whole number?
select *
from subscriptions
;

# What is the number and percentage of customer plans after their initial free trial?
select *
from subscriptions
where plan_id <> 0 ;

# What is the monthly distribution of basic monthly plan start_date values for our dataset 
#- use the start of the month as the group by value
select *,count(*) 
from subscriptions as s
join plans as p
on p.plan_id=s.plan_id
where p.plan_id = 1
group by customer_id ;

# What plan start_date values occur after the year 2020 for our dataset? 
# Show the breakdown by count of events for each plan_id
select plan_id,count(*) as total_customers_2021
from subscriptions
where year(start_date) > 2020
group by plan_id ;

# What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
with cte1 as(select count( distinct customer_id) as total_customers from subscriptions ) ,
cte2 as(
select count(*) as churned_customers 
from subscriptions as s
where s.plan_id = 4 )
select cte2.churned_customers ,cte1.total_customers ,
 round(((cte2.churned_customers / cte1.total_customers) * 100),1)
from cte1,cte2 ;


# How many customers have churned straight after their initial free trial 
with cte_next_plan as(
select * , lead(plan_id,1) over(partition by customer_id order by plan_id asc ) as next_plan
from subscriptions)
select count(*) as churned_after_free_trial
from cte_next_plan
where next_plan=4 and plan_id = 0 ;


# How many customers have churned straight after their initial free trial 
# - what percentage is this rounded to the nearest whole number?
with cte_next_plan as(
select *, lead(plan_id,1) over(partition by customer_id order by plan_id asc ) as next_plan
from subscriptions) ,
cte_total_churned as(
select *, count(*) as churned_after_free_trial
from cte_next_plan
where next_plan=4 and plan_id = 0 ) ,
cte3 as( select count(distinct customer_id) as total_cust from subscriptions) 

select churned_after_free_trial,total_cust, 
round((churned_after_free_trial / total_cust) * 100) as percentage_churned
from  cte_total_churned,cte3 ;
#rder by total_cust limit 1 ;


# What is the number of customer plans after their initial free trial?
with next_plan_cte as(select *,lead(plan_id,1) over(partition by customer_id order by plan_id asc) as next_plan 
from subscriptions)
select next_plan,count(*) 
from next_plan_cte
where plan_id=0
group by next_plan
order by next_plan asc ;


# # What is the number and percentage of customer plans after their initial free trial?
with next_plan_cte as( select *,lead(plan_id,1) over(partition by customer_id order by plan_id asc) as next_plan 
from subscriptions) ,
cte2 as(select count(distinct customer_id) as total_customers from next_plan_cte ) ,
cte3 as (
select *, count(*) as total_cust_after_trial 
from next_plan_cte
where plan_id =0 
group by next_plan 
order by next_plan )
select  next_plan,total_cust_after_trial,(total_cust_after_trial/total_customers) * 100
from cte2,cte3 ;


# What is the customer count of all 5 plan_name values at 2020-12-31?
select plan_id,count(distinct customer_id) 
from subscriptions 
where start_date <= '2020-12-31'
group by plan_id ;


# # What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
with total_cust_cte as( select count(distinct customer_id) as total_cust from subscriptions) ,
each_plan_total_cust_cte as(
select *,count(distinct customer_id) as each_plan_total_cust
from subscriptions 
where start_date <= '2020-12-31'
group by plan_id )
select plan_id , each_plan_total_cust, round((each_plan_total_cust/total_cust) * 100)
from total_cust_cte , each_plan_total_cust_cte ;


# How many customers have upgraded to an annual plan in 2020?
select  p.plan_name, count(*) as 'total customers'
from subscriptions as s
join plans as p
on p.plan_id = s.plan_id
where p.plan_name like 'pro annual' and year(start_date) = 2020 ;


# How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with cte1 as(select * 
from subscriptions 
where plan_id = 0),
cte2 as(select *
from subscriptions
where plan_id = 3)
#cte3 as(select extract(MONTH from start_date) as months from subscriptions)
select  avg(timestampdiff(DAY , cte1.start_date , cte2.start_date)) as average_time_for_annualplan 
from cte1 join cte2 
on cte1.customer_id = cte2.customer_id ; 


# Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)








# How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
with cte1 as(select *,lag(plan_id,1) over(partition by customer_id order by plan_id asc) as prev_plan 
from subscriptions)
select count(distinct customer_id)
from cte1
where prev_plan = 2 and plan_id = 1 ;


# Most popular plan after trial plan
with cte1 as(select *, count(*) as total
from subscriptions
group by plan_id 
order by total desc)
select plan_id ,max(total)
from cte1
where plan_id <> 0


