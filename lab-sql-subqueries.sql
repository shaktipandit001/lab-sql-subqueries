use Sakila;
-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?

-- first we check how inventory table is organized
select * from sakila.inventory;

-- second we filter 'Hunchback Impossible' film_id 
select film_id, title from sakila.film
where title like 'Hunchback Impossible';

-- lastly we count how many copies of the mentioned movie has using the previous subquerry to filter out what to count
select count(*) as 'number_of_copies' from sakila.inventory
where film_id = (select film_id from sakila.film
				where title like 'Hunchback Impossible');
          
          
-- 2. List all films whose length is longer than the average of all the films.

-- first we get the average length for all films
select avg(length) from sakila.film;

-- lastly we filter only the movies whose length is longer then the average calcultated in the previous querry, using it as a subquerry
select * from sakila.film
where length > (select avg(length) from sakila.film)
order by length;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

-- First we retrieve the film_id of 'Alone Trip'
select film_id, title from sakila.film
where title like 'Alone Trip';

-- Lastly we filter only the actors that appear in the movie filtered on the previous querry
select fa.film_id, a.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name from sakila.actor a
join sakila.film_actor fa
on a.actor_id = fa.actor_id
where fa.film_id = (select film_id from sakila.film
					where title like 'Alone Trip');

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

-- First we retrive the 'Family' category category_id
select category_id, name from sakila.category
where name like 'Family';

-- Lastly we list the films whose category_id equals the one fetched in the previous querry
select * from sakila.film f
join sakila.film_category fc
on f.film_id = fc.film_id
where fc.category_id = (select category_id from sakila.category
						where name like 'Family');
                        
-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

-- First we fetch Canada's country_id
select country_id, country from sakila.country
where country like 'Canada';

--
select concat(c.first_name, ' ', c.last_name) as customer_name, c.email
from sakila.customer c
join sakila.address a
on c.address_id = a.address_id
join sakila.city ct
on a.city_id = ct.city_id
where ct.country_id = (select country_id from sakila.country
						where country like 'Canada');
                        
-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

-- Firt we count the number of films per actor
select actor_id, count(film_id) as film_count from sakila.film_actor
group by actor_id
order by count(film_id) desc;

-- Second, we filter the most prolific actor only
select actor_id, count(film_id) as film_count from sakila.film_actor
group by actor_id
order by count(film_id) desc
limit 1;

select actor_id from sakila.film_actor
group by actor_id
order by count(film_id) desc
limit 1;
                    
-- Lastly we list all the films where the actor 107 starred in, using the previous querry
select f.film_id, f.title, fa.actor_id
from sakila.film f
join sakila.film_actor fa
on f.film_id = fa.film_id
where fa.actor_id = (select actor_id from sakila.film_actor
					group by actor_id
					order by count(film_id) desc
					limit 1);
                    
-- 7. Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

-- First we list the sum of payments for each customer
select customer_id, sum(amount) as sum_payment from sakila.payment
group by customer_id
order by sum(amount) desc;

-- Second, we filter only the most profitable customer
select customer_id, sum(amount) as sum_payment from sakila.payment
group by customer_id
order by sum(amount) desc
limit 1;

select customer_id from sakila.payment
group by customer_id
order by sum(amount) desc
limit 1;

-- Lastly we list all the films he/she has rented using the previous querry
select f.film_id, f.title
from sakila.film f
join sakila.inventory i
on f.film_id = i.film_id
join sakila.rental r
on i.inventory_id = r.inventory_id
where r.customer_id = (select customer_id from sakila.payment
						group by customer_id
						order by sum(amount) desc
						limit 1);
                        

-- 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

-- First we calculate the average of the total_amount spent by each client
create temporary table customer_sum_payment
select customer_id, sum(amount) as sum_payment from sakila.payment
group by customer_id;

select avg(sum_payment) as 'average_total_amount' from customer_sum_payment;

select avg(sum_payment) as 'average_total_amount' 
from (select customer_id, sum(amount) as sum_payment from sakila.payment
		group by customer_id) as sub1;

-- List the customers that spent more than the average calculated in the previous querry
select customer_id, sum(amount) as sum_payment from sakila.payment
group by customer_id
having sum_payment > (select avg(sum_payment) as 'average_total_amount' 
					from 
						(select customer_id, sum(amount) as sum_payment from sakila.payment
					group by customer_id) 
                    as sub1)
order by sum_payment desc;
