use pizzahut;

# Total Orders Count.
select count(order_id)
from orders; 

# Revenue Calculation.
select round(sum(od.quantity*p.price),2) as 'total revenue'
from order_details as od join pizzas as p
on od.pizza_id=p.pizza_id;

# Most Expensive Pizza.
select *
from pizzas
order by price desc
limit 1;

# Most Ordered Pizza Size.
select p.size,sum(od.quantity) as 'total_ordered'
from order_details as od join pizzas as p
on od.pizza_id=p.pizza_id
group by p.size
order by total_ordered DESC
limit 1;

# Top 5 Popular Pizzas.
select pt.name as pizza_name, sum(od.quantity) as total_ordered
from order_details as od 
join pizzas as p on od.pizza_id=p.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by total_ordered DESC
limit 5;

# Pizza Quantity by Category.
select category, sum(od.quantity) as total_quantity
from order_details as od
join pizzas as p on od.pizza_id=p.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id
group by category
order by total_quantity DESC;

# Order Trends by Hour.
select * from orders;
select count(order_id) as total_ordered, extract(hour from order_time) as order_hour
from orders
group by order_hour
order by order_hour;

# Average Daily Pizza Orders.
select avg(daily_total) as avg_daily_pizza
from (select o.order_date,sum(od.quantity) as daily_total
	  from orders as o 
      join order_details as od
      on o.order_id = od.order_id
      group by o.order_date
)as daily_orders;

# Top Pizza Types by Revenue.
select pt.name as pizza_type,
       sum(od.quantity * p.price) as total_revenue
from order_details as od
join pizzas as p
     on od.pizza_id = p.pizza_id
join pizza_types as pt
     on p.pizza_type_id= pt.pizza_type_id
group by pt.name
order by total_revenue desc
limit 3;

# Revenue Contribution by Pizza Type.
select pt.name as pizza_type,
       round(sum(od.quantity * p.price),0)as total_revenue,
       round(
			 sum(od.quantity * p.price)/
             (select sum(od2.quantity * p2.price) as total_revenue
              from order_details as od2 join pizzas as p2
			  on od2.pizza_id = p2.pizza_id) * 100,2) as revenue_percentage
from order_details as od
join pizzas as p
     on od.pizza_id = p.pizza_id
join pizza_types as pt
     on p.pizza_type_id= pt.pizza_type_id
group by pt.name
order by total_revenue desc;

#Cumulative Revenue Over Time.
select 
    o.order_date,
    round(SUM(od.quantity * p.price),0) as daily_revenue,
    round(SUM(SUM(od.quantity * p.price)) 
        OVER (order by o.order_date),0) as cumulative_revenue
from orders as o
join order_details as od
    on o.order_id = od.order_id
join pizzas as p
    on od.pizza_id = p.pizza_id
group by o.order_date
order by o.order_date;

# Top 3 Pizza Types by Revenue in Each Category.
with pizza_revenue as(
     select 
           pt.category,
           pt.name as pizza_name,
           sum(od.quantity * p.price) as total_revenue,
           rank() over(partition by pt.category order by sum(od.quantity * p.price)desc) as revenue_rank
	from order_details as od
    join pizzas as p  
         on od.pizza_id = p.pizza_id
	join pizza_types as pt
         on p.pizza_type_id = pt.pizza_type_id
	group by pt.category, pt.name
)
select category, pizza_name, total_revenue
from pizza_revenue
where revenue_rank<=3
order by category, total_revenue desc;