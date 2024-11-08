-- creating table

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
	show_id VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(15),
	duration VARCHAR(25),
	listed_in VARCHAR(130),
	description VARCHAR(250)
)

SELECT * FROM netflix;

SELECT COUNT(*) as total_contents FROM netflix;

SELECT DISTINCT type from netflix;

       ---------------

-- Soltions for Bussiness questions

--?-- 1. Count the number of Movies vs TV Shows

SELECT type,
count(*) as count_type
from netflix
group by type;

--ans-- There are 6131 Movies and 2676 TV Shows in this dataset

--?-- 2. Find the most common rating for Movies and TV Shows

select type, rating, ranking from
(
	select type, rating,
	count(*),
	rank() over(partition by type order by count(*) desc) as ranking
	from netflix
	group by 1, 2
	--order by 1, 3 DESC;
) as t1
where ranking = 1;

--?--3. list all movies released in a specific year (eg 2020)

select title,type, release_year from
(select title, type, release_year from netflix
where type = 'Movie') as t2
where release_year = 2020;

select * from netflix
where type = 'Movie' and release_year = 2020;


--?--4. find the top 5 countries with most content on netflix

select country, count(show_id) as total_content from netflix
group by country
order by count(*) desc;

---

select unnest(string_to_array(country, ','))as new_country, count(*) as total_content from netflix
group by new_country
order by count(*) desc
limit 5;

        ---

--?--5. Identify the longest movies

select * from netflix where type = 'Movie'
and duration = (select max(duration) from netflix);


--?--6. Find the contents that added in the last five years

select * from netflix
where to_date(date_added, 'Month DD, YYYY') >=
current_date - interval '5 years';


--?--7. find all Movies/TV Shows directed by 'Rajiv Chilaka'

select * from netflix
where director ilike '%Rajiv Chilaka%';


--?-- 8.list all tv shows with 5 or more than 5 seasons

--select split_part('apple, orange, banana', ',', -1)
select *
from netflix
where type = 'TV Show'
and
split_part(duration, ' ', 1)::numeric >= '5';


--?-- 9.count the no of contents in each genre

select unnest(string_to_array(listed_in, ',')) as genre,
count(*) as no_of_contents from netflix
group by genre
order by no_of_contents desc;


--?-- 10. Find each year, the average numbers of content released by india on netflix.
-- return top 5 years with max average content releases

SELECT * FROM netflix;

select 
Extract(year from to_date(date_added, 'Month DD, YYYY')) AS date_year,
count(*),
ROUND(
count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric*100
,2) as average
from netflix
where country = 'India'
group by date_year
order by average desc
limit 5;


--?-- 11. List all the contents that are documentary

select * from netflix
where listed_in ilike '%Documentaries%'


--?-- 12. List all the contents without director

select * from netflix
where director is null;


--?-- 13.Find in how many movies the actor "Salman Khan" appeared for the last 10 years

select * from netflix
where release_year > EXTRACT(YEAR FROM current_date) - 10 and
casts ilike '%salman Khan%' 


--?-- 14. Find the top 10 actors who appeared in most number of movies in india

select unnest(string_to_array(casts, ',')) as casts_individual, count(*) from netflix
where country ilike '%india%' and type = 'Movie'
group by casts_individual
order by count(*) desc
limit 10;


--?-- 15. Categorise the content based on the presence of keywords 'kill' and 'violence'
--        in the description. Label contents containing these keywords as 'Bad' and all other 
--        contents as 'Good'. Find how many contents fall into each of the categories.

with new_table
as
(
select *,
case 
	when 
		description ilike '%kill%'
		or description ilike '%violen%'
		then 'Bad Content'
	else 'Good Content'
end category
from netflix
)
select count(*), category from new_table
group by category