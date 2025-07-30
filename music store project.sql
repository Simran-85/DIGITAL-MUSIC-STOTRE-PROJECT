create  database music_store;

use music_store;
 
select * from album2;

-- Q1: who is the senoir most employee based on job title?;

select * from employee 
ORDER BY levels desc 
limit 1 

-- Q2: which countries have the most invoices?

select count(*) as c, billing_country from invoice
group by billing_country
order by c desc

-- Q3: what are top 3 values of total invoice?

select * from invoice 
order by total desc
limit 3

-- Q4: which city has the best customers?

select SUM(total) as invoice_total, billing_city from invoice
group by billing_city
order by invoice_total desc

-- Q5: who is the best customer?

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total 
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total desc
limit 1

-- Moderate
-- Q1: write query to return the email,first name ,last name, & genre of all rock music listeners 
-- return your list ordered alphabetically by email starting with A

select distinct email,first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
   select track_id from track
   join genre on track.genre_id = genre.genre_id
   where genre.name like 'Rock'
)
order by email;

-- Q2: lets invite the srtist who have writtem the most rock music in our dataset.
--  write a query that returns the artist name and total track count of the top 10 rock bands

select artist.artist_id, artist.name,count(artist.artist_id) as number_of_songs
from track
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like'Rock'
group by artist.artist_id, artist.name
order by number_of_songs desc
limit 10;

-- return all the track names that have a song length longer than the average song length .
-- return the  name and milliseconds for each track.
-- order by the song length with the longest songs listed first.

select name, milliseconds
from track
where milliseconds > (
   select avg(milliseconds) as avg_track_length
   from track
   )
order by milliseconds desc;

-- Advance
-- find how much amount spent by each customer on artist? 
-- write a query to return customer name, artist name and total spent. 

WITH best_selling_artist AS (
   SELECT 
       artist.artist_id AS artist_id, 
       artist.name AS artist_name,
       SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
   FROM invoice_line
   JOIN track ON track.track_id = invoice_line.track_id
   JOIN album2 ON album2.album_id = track.album_id
   JOIN artist ON artist.artist_id = album2.artist_id
   GROUP BY artist.artist_id, artist.name
   ORDER BY total_sales DESC
   LIMIT 1
)
SELECT 
   c.customer_id, 
   c.first_name, 
   c.last_name, 
   bsa.artist_name, 
   SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

-- we want to find out the most popular music genre for each country we determined the most popular genre with 
-- the highest amount of purchases .write a query that return each country along with the top genre 
-- for the countries where the maximum number of purchases is shared return all geners.alter

WITH popular_genre as
(
select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
Row_number() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
FROM invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by customer.country, genre.name, genre.genre_id
order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1

-- write a query that determines the customer that has spent the most on music for each country .
-- write a query that returns the country along on music for each country.
-- write a query that returns the country along with the top customer and how much they spent. for countries,
-- where the top amount spent is shared ,provide all customers who spent this amount

WITH customer_with_country as (
       select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
       row_number() over(partition by billing_country order by sum(total) desc) as RowNo
       from invoice
       join customer on customer.customer_id = invoice.customer_id
       group by customer.customer_id,first_name,last_name,billing_country
       order by 4 asc, 5 desc)
select * from  customer_with_country where RowNo <= 1 
       








