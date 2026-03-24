USE DATABASE cricket;
USE SCHEMA clean;

SELECT *
FROM cricket.clean.match_detail_clean
WHERE match_type_number = 4686

SELECT country,batter,sum(runs)
FROM cricket.clean.delivery_clean
WHERE match_type_number = 4686
GROUP BY country,batter

SELECT country,sum(runs) + sum(extra_runs)
FROM cricket.clean.delivery_clean
WHERE match_type_number = 4686
GROUP BY country
