select * from test_data;
select * from test_data2;
select * from test_data3;
select * from test_data4;
select * from test_data5;
select * from test_data6;
select * from test_data7;


1) Identify the museums which are open on both sundays and mondays. Also display their name

select m.name as museum_name,m.city
from test_data4 mh1
join test_data5 m on m.museum_id=mh1.museum_id
where day='Sunday'
and exists (select 1 from test_data4 mh2
		    where mh2.museum_id = mh1.museum_id
		    and mh2.day = 'Monday')
		   
		  
2) Which museum is open for the longest during a day. Display museum name, state and hours open and which day?

select * from (
     select m.name as museum_name, m.state, mh.day
     , to_timestamp(open, 'HH:MI:AM') AS open_time
	 , to_timestamp(close, 'HH:MI:AM') AS close_time
	 , to_timestamp(close, 'HH:MI:AM') - to_timestamp(open, 'HH:MI:AM') AS duration
	 , rank() over(order by(to_timestamp(close, 'HH:MI:PM') - to_timestamp(open, 'HH:MI:AM')) desc)
	 from test_data4 mh
	 join test_data5 m on m.museum_id=mh.museum_id) x
where x.rank=1;




3)  Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.

WITH museum_counts AS (
    SELECT
        country,
        city,
        COUNT(*) AS num_museums
    FROM
        test_data5
    GROUP BY
        country,
        city
),
max_museum_count AS (
    SELECT
        MAX(num_museums) AS max_num_museums
    FROM
        museum_counts
)
SELECT
    STRING_AGG(city, ', ') AS cities,
    country
FROM
    museum_counts
WHERE
    num_museums = (SELECT max_num_museums FROM max_museum_count)
GROUP BY
    country;

4) Which country has the 5th highest no of paintings?

WITH country_paintings AS (
    SELECT
        country,
        COUNT(*) AS num_paintings
    FROM
        test_data5
    GROUP BY
        country
),
ranked_countries AS (
    SELECT
        country,
        num_paintings,
        ROW_NUMBER() OVER (ORDER BY num_paintings DESC) AS country_rank
    FROM
        country_paintings
)
SELECT
    country
FROM
    ranked_countries
WHERE
    country_rank = 5;

5) Which canva size costs the most?

SELECT
    *
FROM
    test_data6
ORDER BY
    regular_price DESC
LIMIT 1;

6) Fetch the top 10 most famous painting subject

SELECT
    subject,
    COUNT(*) AS num_paintings
FROM
    test_data7
GROUP BY
    subject
ORDER BY
    num_paintings DESC
LIMIT 10;

7) How many paintings have an asking price of more than their regular price?

SELECT
    COUNT(*) AS num_paintings
FROM
    test_data6
WHERE
    sale_price > regular_price;

8) Delete duplicate records from work, product_size, subject and image_link tables

DELETE FROM test_data6
WHERE (work_id, size_id, sale_price, regular_price) NOT IN (
    SELECT MIN(work_id), MIN(size_id), MIN(sale_price), MIN(regular_price)
    FROM test_data6
    GROUP BY work_id, size_id, sale_price, regular_price
);

DELETE FROM test_data7
WHERE (work_id, subject) NOT IN (
    SELECT MIN(work_id), MIN(subject)
    FROM test_data7
    GROUP BY work_id, subject
);


DELETE FROM test_data3
WHERE (work_id, url, thumbnail_small_url, thumbnail_large_url) NOT IN (
    SELECT MIN(work_id), MIN(url), MIN(thumbnail_small_url), MIN(thumbnail_large_url)
    FROM test_data3
    GROUP BY work_id, url, thumbnail_small_url, thumbnail_large_url
);

9) Identify the museums with invalid city information in the given dataset

SELECT
    museum_id,
    name AS museum_name,
    city,
    country
FROM
    test_data5
WHERE
    city IS NULL
    OR city = ''
    OR city ~ '[0-9]' -- Check for cities that contain numbers
    OR length(city) < 2 -- Check for cities that are too short
    OR length(city) > 50; -- Check for cities that are too long

10) Museum_Hours table has 1 invalid entry. Identify it and remove it.

SELECT *
FROM test_data4
WHERE CAST(open AS time) > CAST(close AS time);

DELETE FROM test_data4
WHERE open > close;
