-- Q1 Who is the senior most employee based on job title?
select * from employee
Order by levels Desc 
limit 1
--Madan Mohan

--Q2 Which country has the most Invoice ?
Select Count(*) as c, billing_country
from invoice
group by billing_country
order by c desc
-- USA

--Q3 What are top 3 values of total invoices?
select total from invoice
order by total desc
limit 3
-- 23.75, 19.8, 19.8

--Q4 Which city has the best customers? We would like to throw a promotional Music Festival in the city 
--we made the most money. Write a query that returns one city we made the most money. write a qurey that 
--returns one city that has the highest sum of invoices totals. 
--Return both the city name and sum of all invoice totals

Select  billing_city, Sum(total) as invoice_total 
from invoice
group by billing_city 
order by invoice_total desc
-- Prague, 273.240

--Q5 Who is the best customer? The customer who has spent the most money will be declared has the best
--customer. Write a query that retuens the person who has spent the most money?

Select customer.customer_id, customer.first_name, customer.last_name, Sum(invoice.total) as total
from customer
Join invoice ON customer.customer_id = invoice.customer_id
Group by customer.customer_id
order by total desc
limit 1
-- R Madhav.

--Q6 Write a query to return the email, first name, last name and genre of all music listners. Return
--your list, ordered alphabetically by email starting with A

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
		select track_id from track
		join genre on track.genre_id = genre.genre_id
		where genre.name like 'Rock'
)
order by email;

--Q7 Let's invite the artists who have written the most rock music in dataset. Write a query that returns
--the artist name and total track count of the top 10 rock bands.

Select artist.artist_id, artist.name,Count(artist.artist_id) As number_of_songs
From track
Join album On album.album_id = track.album_id
Join artist On artist.artist_id = album.artist_id
Join genre On genre.genre_id = track.genre_id
Where genre.name like 'Rock'
Group By artist.artist_id
Order By number_of_songs DESC
Limit 10;
--Led Zeppelin, U2

--Q8 Retrun all the track names that have a song lenght longer than the average song lenght. Retrun the 
--name and Millseconds for each tracks. Order by song length with the longest songs listed first.

Select name, milliseconds
From track
Where milliseconds > (
	Select Avg(milliseconds) As avg_track_lenght
	From track)
Order by milliseconds Desc;
-- Occupation / Precipice - 5286953

--Q9 Find how much amount spent by each customer on artist? Write a query to return customer name, artist
--name and total spent

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--Q10 We want to find out the most popular music Genre for each country. We determine the most popular 
--genre as the genre with the highest amount of purchases. Write a query that returns each country 
--along with the top Genre. For countries where the maximum number of purchases is shared return all 
--Genres.

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

--Q11 Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;
