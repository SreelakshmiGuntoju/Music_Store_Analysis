 /*Easy*/
 /*1. Who is the senior most employee based on job title?*/

 Select employee_id, last_name, first_name 
 From employee
 order By levels Desc
 Limit 1;
 
  /*2. Which countries have the most Invoices? */
 
 Select count(*), billing_country
 From invoice
 Group By 2
 order BY 1 Desc;
 
  /*3. What are top 3 values of total invoice*/
 Select total
 From invoice
 Order By 1 Desc
 Limit 3;
 
 
  /*4. Which city has the best customers? we would like to throw a promotional Music Fetival in the city 
  we made the most money. Write a query that returns one city that has the highest sum of invoice totals.alter
  Return both the city name & sum of all invoices totals */
  
 Select billing_city, sum(total) as Invoice_Totals
 From invoice
 Group By 1
 Order by 2 Desc
 Limit 1;

   /*5. Who is the best customer? the customer who has spent the most money will be declared the best customer.
		Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id,2,3
ORDER BY total_spending DESC
LIMIT 1;

    /* Moderate*/
   /*1. Write a query to return the email, first name, last name, & Genre of all Rock music listeners.
	  Return your list ordered alphabetically by email starting with A*/

Select distinct(c.email)as email,c.first_name, c.last_name
From customer c
Join invoice i
ON c.customer_id = i.customer_id
Join invoice_line il
ON il.invoice_id = i.invoice_id
Where track_id in (Select track_id From track t
                   Join genre g on t.genre_id = g.genre_id
				   Where g.name Like 'Rock')
Order By email;	

 /*2. Let's invite the artists who have written the most rock music in our dataset.
	  Write a query that returns the artist name and total track count of the top 10 rock bands*/
    
Select ar.artist_id, ar.name, count(ar.artist_id) as number_of_songs
From artist ar
Join album2 al
On ar.artist_id = al.artist_id
Join track t	
on al.album_id = t.album_id
join genre g
on t.genre_id = g.genre_id
Where g.name Like 'Rock'
Group By 1,2
Order By 3 Desc
Limit 10;


 /*3. Return all the track names that have a song length longer than the average song length.
	  Return the name and milliseconds for each track . Order by the song length with the longest 
      songs listed first.*/

Select name, milliseconds
From track
Where milliseconds >(Select avg(milliseconds) as avg_track_length
					 From track)
Order By milliseconds Desc;   


   /*Advance*/
   /* 1. Find how much amount spent by each customer on artists? 
         Write a query to return customer name, artist name and total spent.*/

With best_selling_artist as
 (
          select ar.artist_id, ar.name as artist_name, sum(il.unit_price*il.quantity) as total_sales
          From artist ar
          Join album2 al
          on ar.artist_id = al.artist_id
          Join track t
          on t.album_id = al.album_id
          Join invoice_line il
          on il.track_id = t.track_id
          Group By 1,2
          Order By total_sales Desc
          Limit 1
 )         

Select c.customer_id,c.first_name,c.last_name, bsa.artist_name,
sum(il.unit_price*quantity) as total_spent
From customer c
Join invoice i
on c.customer_id = i.customer_id
Join invoice_line il
on i.invoice_id = il.invoice_id
Join track t
on t.track_id = il.track_id
Join album2 al
on al.album_id = t.album_id
join best_selling_artist bsa
on bsa.artist_id = al.artist_id
Group By 1,2,3,4
Order By 5 Desc;

 /*2. We want to find out the most popular music genre for each country.
      We determine the most popular genre as the genre with the highest amount of purchases.
      Write a query that returns each country along with the top genre. For countries where the
      maximum number of purcgases is shared return all genres*/
      
With popular_genre as
(
    select count(il.quantity) as purchases, c.country, g.name as genre_name,g.genre_id,
    Row_number() over (partition by c.country order by count(il.quantity) Desc) as row_num
    From customer c
    Join invoice i
    on i.customer_id = c.customer_id
    Join invoice_line il
    on il.invoice_id = i.invoice_id
    join track t
    on t.track_id = il.track_id
    Join genre g
    on g.genre_id = t.genre_id
    Group By 2,3,4
    Order By 2 asc , 1 desc
)
Select *
From popular_genre
Where row_num<=1;

 /* 3. Write a query that determines the customer that has spent the most on music for each country.
	   Write a query that returns the country along with the top customer and how much they spent .
       For countries where the top amount spent is shared, provide all customers who spent this amount.*/

With customer_with_country as
(
      Select c.customer_id,c.first_name, c.last_name, i.billing_country, sum(total) as total,
      Row_Number () over (partition by i.billing_country order by sum(total) desc ) row_num
      From customer c
      Join invoice i
      On c.customer_id = i.customer_id
      Group By 1,2,3,4
      Order By 4 asc , 5 desc
  )
  Select *
  From customer_with_country
  Where row_num <=1;
      








                 