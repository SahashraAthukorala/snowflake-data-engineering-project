USE DATABASE cricket;
USE SCHEMA consumption;

SELECT m.match_type_number as match_id,
dd.date_id,
0 as referee_id
FROM clean.match_detail_clean m
JOIN consumption.date_dim dd
ON m.event_date = dd.full_dt
WHERE m.match_type_number = 4686

INSERT INTO cricket.consumption.match_fact 
SELECT
    m.match_type_number AS match_id,
    dd.date_id AS date_id,
    0 AS referee_id,
    ftd.team_id AS first_team_id,
    std.team_id AS second_team_id,
    mtd.match_type_id AS match_type_id,
    vd.venue_id AS venue_id,
    50 AS total_overs,
    6 AS balls_per_overs,
    MAX(CASE WHEN d.country = m.first_team THEN  d.over ELSE 0 END ) AS overs_played_by_team_a,
    SUM(CASE WHEN d.country = m.first_team THEN  1 ELSE 0 END ) AS balls_played_by_team_a,
    SUM(CASE WHEN d.country = m.first_team THEN  d.extras ELSE 0 END ) AS extra_balls_played_by_team_a,
    SUM(CASE WHEN d.country = m.first_team THEN  d.extra_runs ELSE 0 END ) AS extra_runs_scored_by_team_a,
    0 fours_by_team_a,
    0 sixes_by_team_a,
    (SUM(CASE WHEN d.country= m.first_team THEN  d.runs ELSE 0 END ) + SUM(CASE WHEN d.country = m.first_team THEN  d.extra_runs ELSE 0 END )) AS total_runs_scored_by_team_a,
    SUM(CASE WHEN d.country = m.first_team AND player_out IS NOT NULL THEN  1 ELSE 0 END ) AS wicket_lost_by_team_a,    
    MAX(CASE WHEN d.country = m.second_team THEN  d.over ELSE 0 END) AS overs_played_by_team_b,
    SUM(CASE WHEN d.country = m.second_team THEN  1 ELSE 0 END ) AS balls_played_by_team_b,
    SUM(CASE WHEN d.country = m.second_team THEN  d.extras ELSE 0 END ) AS extra_balls_played_by_team_b,
    SUM(CASE WHEN d.country = m.second_team THEN  d.extra_runs ELSE 0 END ) AS extra_runs_scored_by_team_b,
    0 fours_by_team_b,
    0 sixes_by_team_b,
    (SUM(CASE WHEN d.country = m.second_team THEN  d.runs else 0 end ) + sum(CASE WHEN d.country = m.second_team THEN d.extra_runs else 0 end ) ) as total_runs_scored_BY_TEAM_B,
    SUM(CASE WHEN d.country = m.second_team AND player_out IS NOT NULL THEN  1 ELSE 0 END) AS wicket_lost_by_team_b,
    tw.team_id AS toss_winner_team_id,
    m.toss_decision AS toss_decision,
    m.matach_result AS matach_result,
    mw.team_id AS winner_team_id
FROM
    cricket.clean.match_detail_clean m
    JOIN date_dim dd ON m.event_date = dd.full_dt
    JOIN team_dim ftd ON m.first_team = ftd.team_name 
    JOIN team_dim std ON m.second_team = std.team_name 
    JOIN match_type_dim mtd ON m.match_type = mtd.match_type
    JOIN venue_dim vd ON m.venue = vd.venue_name AND m.city = vd.city
    JOIN clean.delivery_clean d  ON d.match_type_number = m.match_type_number 
    JOIN team_dim tw ON m.toss_winner = tw.team_name 
    JOIN team_dim mw ON m.winner= mw.team_name 
    GROUP BY
        m.match_type_number,
        date_id,
        referee_id,
        first_team_id,
        second_team_id,
        match_type_id,
        venue_id,
        total_overs,
        toss_winner_team_id,
        toss_decision,
        matach_result,
        winner_team_id;


    CREATE TABLE delivery_fact (
    match_id INT ,
    team_id INT,
    bowler_id INT,
    batter_id INT,
    non_striker_id INT,
    over INT,
    runs INT,
    extra_runs INT,
    extra_type VARCHAR(255),
    player_out VARCHAR(255),
    player_out_kind VARCHAR(255),

    CONSTRAINT fk_del_match_id FOREIGN KEY (match_id) REFERENCES match_fact (match_id),
    CONSTRAINT fk_del_team_id FOREIGN KEY (team_id) REFERENCES team_dim (team_id),
    CONSTRAINT fk_bowler_id FOREIGN KEY (bowler_id) REFERENCES player_dim (player_id),
    CONSTRAINT fk_batter_id FOREIGN KEY (batter_id) REFERENCES player_dim (player_id),
    CONSTRAINT fk_stricker_id FOREIGN KEY (non_striker_id) REFERENCES player_dim (player_id)
);


INSERT INTO delivery_fact
SELECT 
    d.match_type_number AS match_id,
    td.team_id,
    bpd.player_id AS bower_id, 
    spd.player_id batter_id, 
    nspd.player_id AS non_stricker_id,
    d.over,
    d.runs,
    CASE WHEN d.extra_runs IS NULL THEN 0 ELSE d.extra_runs END AS extra_runs,
    CASE WHEN d.extra_type IS NULL THEN 'None' ELSE d.extra_type END AS extra_type,
    CASE WHEN d.player_out IS NULL THEN 'None' ELSE d.player_out END AS player_out,
    CASE WHEN d.player_out_kind IS NULL THEN 'None' ELSE d.player_out_kind END AS player_out_kind
    FROM clean.delivery_clean d
    JOIN team_dim td ON d.country = td.team_name
    JOIN player_dim bpd ON d.bowler = bpd.player_name
    JOIN player_dim spd ON d.batter = spd.player_name
    JOIN player_dim nspd ON d.non_striker = nspd.player_name;

    SELECT *
    FROM clean.delivery_clean d;

ALTER TABLE clean.delivery_clean RENAME COLUMN extra_ype TO extra_type



 