-- Which employee is most experienced 
SELECT * FROM employee
ORDER BY levels DESC 
LIMIT 1
-- Which country has highest invoices?
SELECT COUNT(*) AS FREQ,billing_country FROM invoice
GROUP BY billing_country
ORDER BY FREQ DESC 
LIMIT 1
-- what are the top 3 values of total invoice
select Invoice_id,total from invoice
ORDER BY total DESC
LIMIT 3
-- which city has the most freq? 
select COUNT(*) AS C,city from customer
group by city
order by C DESC

-- returns one city that has the highest sum of invoice totals
select SUM(total) AS SUM,billing_city
FROM invoice
group by billing_city
order by SUM DESC 

-- SELECT * FROM invoice

-- ques 5:-Write a query that returns the person who has spend the most money
SELECT * FROM customer
-- but customer table doesn't have any billing amount or invoice total so we have to join it with invoice table

SELECT c.customer_id,c.first_name,c.last_name,SUM(i.total) AS total from customer as c
INNER JOIN invoice as i
ON c.customer_id=i.customer_id
GROUP BY c.customer_id
ORDER BY total DESC
LIMIT 1

-- Ques 6:- Write a query to return the email,first name ,last name & genre of all rock music listeners.
-- Return your list ordered alphabetically by email starting with A
select DISTINCT email,first_name,last_name
from customer
JOIN invoice ON (customer.customer_id=invoice.customer_id) -- join customer to invoice
JOIN invoice_line ON (invoice.invoice_id=invoice_line.invoice_id)-- join invoice to invoice_line
WHERE track_id IN ( SELECT track_id FROM track
                     JOIN genre ON (track.genre_id=genre.genre_id)
					 WHERE genre.name='Rock')
order by email ASC


-- Ques 7:-Write a query that return the artist name and total track count of top10 rock bands


SELECT artist.name AS artist_name,COUNT(artist.artist_id) AS Track_count
FROM artist
JOIN album 
ON artist.artist_id=album.artist_id
JOIN track 
ON track.album_id=album.album_id
JOIN genre
ON genre.genre_id=track.genre_id
WHERE genre.name='Rock'
GROUP BY artist.name
ORDER BY Track_count DESC 
LIMIT 10

-- QUES8:- Return all the track names that have a song length longer than average song length.
           -- Return the name and milisecond for each track order by song length

SELECT name,milliseconds from track
WHERE milliseconds >(SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC

-- Ques 9:-find how much amount spend by each customer on artists?
           -- Write a query to return customer name,artist name and total spent
select DISTINCT c.first_name, c.last_name,ar.name,
SUM(il.unit_price*il.quantity) AS total_spent
FROM customer as c
JOIN invoice as i
ON c.customer_id=i.customer_id
JOIN invoice_line as il
ON i.invoice_id=il.invoice_id
JOIN track as tr
ON tr.track_id=il.track_id
JOIN album as al
ON tr.album_id=al.album_id
JOIN artist as ar
ON ar.artist_id=al.artist_id
GROUP BY c.first_name,c.last_name,ar.name
ORDER BY total_spent DESC

-- ques10:- We want to find out the most popular music genre
-- for each country.we determine the most popular genre as the genre 
-- with the highest purchases.
-- write the query that returns each country along with top genre
WITH popular_genre AS(	   
 SELECT g.name,c.country,COUNT(il.quantity) AS purchases,
 ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC ) AS Rowno
 FROM customer as c
 JOIN invoice as i
 ON c.customer_id=i.customer_id
  JOIN invoice_line as il
  ON i.invoice_id=il.invoice_id
  JOIN track as tr
  ON tr.track_id=il.track_id
  JOIN genre as g
  ON g.genre_id=tr.genre_id
  GROUP BY 1,2
  ORDER BY 3 DESC
)
SELECT * FROM popular_genre WHERE Rowno <=1


-- Q11:- write a query that returns customer 
-- spend most on music for each country.
WITH cust AS(
SELECT c.customer_id,first_name,last_name,billing_country,
SUM(total) AS total_spending,
ROW_NUMBER() OVER (partition by billing_country ORDER BY SUM(total) DESC) AS rowno
FROM invoice
JOIN customer as c
ON c.customer_id=invoice.customer_id
GROUP BY 1,2,3,4
ORDER BY 4 ASC,5 DESC
)
SELECT * FROM cust WHERE rowno<=1