USE DATABASE cricket;
USE SCHEMA consumption;

CREATE TABLE date_dim(
date_id INT PRIMARY KEY AUTOINCREMENT,
full_dt DATE,
day INT,
month INT,
year INT,
quarter INT,
dayofweek INT,
dayofmonth INT,
dayofyear INT,
dayofweekname VARCHAR(3),
isweekend BOOLEAN
);

CREATE TABLE referee_dim (
    referee_id INT PRIMARY KEY AUTOINCREMENT,
    referee_name TEXT NOT NULL,
    referee_type TEXT NOT NULL
);

CREATE TABLE team_dim (
    team_id INT PRIMARY KEY AUTOINCREMENT,
    team_name TEXT NOT NULL
);

CREATE TABLE player_dim (
    player_id INT PRIMARY KEY AUTOINCREMENT,
    team_id INT NOT NULL,
    player_name TEXT NOT NULL
);

ALTER TABLE player_dim ADD CONSTRAINT fk_team_player_id FOREIGN KEY (team_id) REFERENCES team_dim(team_id);

CREATE TABLE venue_dim (
    venue_id INT PRIMARY KEY AUTOINCREMENT,
    venue_name TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT,
    country TEXT,
    continent TEXT,
    end_Names TEXT,
    capacity NUMBER,
    pitch TEXT,
    flood_light BOOLEAN,
    established_dt DATE,
    playing_area TEXT,
    other_sports TEXT,
    curator TEXT,
    lattitude NUMBER(10,6),
    longitude NUMBER(10,6)
);

CREATE TABLE match_type_dim (
    match_type_id INT PRIMARY KEY AUTOINCREMENT,
    match_type TEXT NOT NULL
);


CREATE TABLE match_fact (
    match_id INT PRIMARY KEY,
    date_id INT NOT NULL,
    referee_id INT NOT NULL,
    team_a_id INT NOT NULL,
    team_b_id INT NOT NULL,
    match_type_id INT NOT NULL,
    venue_id INT NOT NULL,
    total_overs NUMBER(3),
    balls_per_over NUMBER(1),
    overs_played_by_team_a NUMBER(2),
    bowls_played_by_team_a NUMBER(3),
    extra_bowls_played_by_team_a NUMBER(3),
    extra_runs_scored_by_team_a NUMBER(3),
    fours_by_team_a NUMBER(3),
    sixes_by_team_a NUMBER(3),
    total_score_by_team_a NUMBER(3),
    wicket_lost_by_team_a NUMBER(2),
    overs_played_by_team_b number(2),
    bowls_played_by_team_b number(3),
    extra_bowls_played_by_team_b NUMBER(3),
    extra_runs_scored_by_team_b NUMBER(3),
    fours_by_team_b NUMBER(3),
    sixes_by_team_b NUMBER(3),
    total_score_by_team_b NUMBER(3),
    wicket_lost_by_team_b NUMBER(2),
    toss_winner_team_id INT NOT NULL, 
    toss_decision TEXT NOT NULL, 
    match_result TEXT NOT NULL, 
    winner_team_id INT NOT NULL,

    CONSTRAINT fk_date_id FOREIGN KEY(date_id) REFERENCES date_dim(date_id),
    CONSTRAINT fk_referee_id FOREIGN KEY(referee_id) REFERENCES referee_dim(referee_id),
    CONSTRAINT fk_team_id1 FOREIGN KEY(team_a_id) REFERENCES team_dim(team_id),
    CONSTRAINT fk_team_id2 FOREIGN KEY(team_b_id) REFERENCES team_dim(team_id), 
    CONSTRAINT fk_match_type_id FOREIGN KEY(match_type_id) REFERENCES match_type_dim(match_type_id),
    CONSTRAINT fk_venue_id FOREIGN KEY(venue_id) REFERENCES venue_dim(venue_id),
    CONSTRAINT fk_toss_winner_team FOREIGN KEY (toss_winner_team_id) REFERENCES team_dim(team_id),
    CONSTRAINT fk_winner_team FOREIGN KEY (winner_team_id) REFERENCES team_dim(team_id)
    );

    SELECT DISTINCT team_name FROM (SELECT first_team AS team_name FROM clean.match_detail_clean
    UNION ALL
    SELECT second_team AS team_name FROM clean.match_detail_clean);

    INSERT INTO team_dim(team_name)
    SELECT DISTINCT team_name
    FROM ( SELECT first_team AS team_name FROM clean.match_detail_clean
    UNION ALL
    SELECT second_team AS team_name FROM clean.match_detail_clean)
    ORDER BY team_name;

    SELECT * FROM team_dim;

    SELECT a.country,a.player_name, b.team_id FROM clean.player_clean a
    JOIN  consumption.team_dim b
    ON a.country = b.team_name
    GROUP BY a.country, a.player_name, b.team_id;

    INSERT INTO player_dim(team_id,player_name)
    SELECT b.team_id,a.player_name,  FROM clean.player_clean a
    JOIN  consumption.team_dim b
    ON a.country = b.team_name
    GROUP BY b.team_id,a.player_name;

    SELECT * FROM player_dim;

SELECT venue,city
FROM clean.match_detail_clean
GROUP BY venue,city;

INSERT INTO venue_dim(venue_name,city)
SELECT venue,CASE WHEN city IS NULL THEN 'N/A'
ELSE city END AS city,
FROM clean.match_detail_clean
GROUP BY venue,city;

SELECT match_type FROM clean.match_detail_clean GROUP BY match_type;

INSERT INTO match_type_dim(match_type)
SELECT match_type FROM clean.match_detail_clean GROUP BY match_type;

SELECT MIN(event_date), MAX(event_date)
FROM clean.match_detail_clean;

CREATE TRANSIENT TABLE cricket.consumption.date_range (Date DATE);
INSERT INTO cricket.consumption.date_range (date)
VALUES
('2023-10-01'), ('2023-10-02'), ('2023-10-03'), ('2023-10-04'), ('2023-10-05'), ('2023-10-06'), ('2023-10-07'), ('2023-10-08'), ('2023-10-09'), ('2023-10-10'), ('2023-10-11'), ('2023-10-12'), ('2023-10-13'), ('2023-10-14'), ('2023-10-15'), ('2023-10-16'), ('2023-10-17'), ('2023-10-18'), ('2023-10-19'), ('2023-10-20'), ('2023-10-21'), ('2023-10-22'), ('2023-10-23'), ('2023-10-24'), ('2023-10-25'), ('2023-10-26'), ('2023-10-27'), ('2023-10-28'), ('2023-10-29'), ('2023-10-30'), ('2023-10-31'), ('2023-11-01'), ('2023-11-02'), ('2023-11-03'), ('2023-11-04'), ('2023-11-05'), ('2023-11-06'), ('2023-11-07'), ('2023-11-08'), ('2023-11-09'), ('2023-11-10'), ('2023-11-11'), ('2023-11-12'), ('2023-11-13'), ('2023-11-14'), ('2023-11-15'), ('2023-11-16'), ('2023-11-17'), ('2023-11-18'), ('2023-11-19'), ('2023-11-20'), ('2023-11-21'), ('2023-11-22'), ('2023-11-23'), ('2023-11-24'), ('2023-11-25'), ('2023-11-26'), ('2023-11-27'), ('2023-11-28'), ('2023-11-29'), ('2023-11-30'), ('2023-12-01'), ('2023-12-02'), ('2023-12-03'), ('2023-12-04'), ('2023-12-05'), ('2023-12-06'), ('2023-12-07'), ('2023-12-08'), ('2023-12-09'), ('2023-12-10'), ('2023-12-11'), ('2023-12-12'), ('2023-12-13'), ('2023-12-14'), ('2023-12-15'), ('2023-12-16'), ('2023-12-17'), ('2023-12-18'), ('2023-12-19'), ('2023-12-20'), ('2023-12-21'), ('2023-12-22'), ('2023-12-23'), ('2023-12-24'), ('2023-12-25'), ('2023-12-26'), ('2023-12-27'), ('2023-12-28'), ('2023-12-29'), ('2023-12-30'), ('2023-12-31');


INSERT INTO cricket.consumption.date_dim (Date_ID, Full_Dt, Day, Month, Year, Quarter, DayOfWeek, DayOfMonth, DayOfYear, DayOfWeekName, IsWeekend)
SELECT
    ROW_NUMBER() OVER (ORDER BY Date) AS DateID,
    Date AS FullDate,
    EXTRACT(DAY FROM Date) AS Day,
    EXTRACT(MONTH FROM Date) AS Month,
    EXTRACT(YEAR FROM Date) AS Year,
    CASE WHEN EXTRACT(QUARTER FROM Date) IN (1, 2, 3, 4) THEN EXTRACT(QUARTER FROM Date) END AS Quarter,
    DAYOFWEEKISO(Date) AS DayOfWeek,
    EXTRACT(DAY FROM Date) AS DayOfMonth,
    DAYOFYEAR(Date) AS DayOfYear,
    DAYNAME(Date) AS DayOfWeekName,
    CASE When DAYNAME(Date) IN ('Sat', 'Sun') THEN 1 ELSE 0 END AS IsWeekend
FROM cricket.consumption.date_range;


SELECT * FROM cricket.consumption.date_dim;

