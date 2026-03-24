USE DATABASE cricket;
USE SCHEMA clean;

SELECT 
meta['data_version']::TEXT AS data_version,
meta['created']::DATE AS created,
meta['revision']::NUMBER AS revision
FROM cricket.raw.match_raw_tbl;


SELECT
info:match_type_number::INT AS match_type_number,
info:match_type::TEXT AS match_type,
info:season::TEXT AS season,
info:team_type::TEXT AS team_type,
info:overs::TEXT AS overs,
info:city::TEXT AS city,
info:venue::TEXT AS venue
FROM cricket.raw.match_raw_tbl;


CREATE TRANSIENT TABLE cricket.clean.match_detail_clean AS
SELECT
    info:match_type_number::INT AS match_type_number, 
    info:event.name::TEXT AS event_name,
    CASE
    WHEN
        info:event.match_number::TEXT IS NOT NULL THEN info:event.match_number::TEXT
    WHEN
        info:event.stage::TEXT IS NOT NULL THEN info:event.stage::TEXT
    ELSE
        'NA'
    END AS match_stage,   
    info:dates[0]::DATE AS event_date,
    date_part('year',info:dates[0]::DATE) AS event_year,
    date_part('month',info:dates[0]::DATE) AS event_month,
    date_part('day',info:dates[0]::DATE) AS event_day,
    info:match_type::TEXT AS match_type,
    info:season::TEXT AS season,
    info:team_type::TEXT AS team_type,
    info:overs::TEXT AS overs,
    info:city::TEXT AS city,
    info:venue::TEXT AS venue, 
    info:gender::TEXT AS gender,
    info:teams[0]::TEXT AS first_team,
    info:teams[1]::TEXT AS second_team,
    CASE
        WHEN info:outcome.winner IS NOT NULL THEN 'Result Declared'
        WHEN info:outcome.result = 'tie' THEN 'Tie'
        WHEN info:outcome.result = 'no result' THEN 'No Result'
        ELSE info:outcome.result
    END AS matach_result,
    CASE 
        WHEN info:outcome.winner IS NOT NULL THEN info:outcome.winner
        ELSE 'NA'
    END AS winner,   
    info:toss.winner::TEXT AS toss_winner,
    initcap(info:toss.decision::TEXT) AS toss_decision,
    --
    stg_file_name ,
    stg_file_row_number,
    stg_file_hashkey,
    stg_modified_ts
    FROM cricket.raw.match_raw_tbl;

    SELECT 
    info:match_type_number::INT AS match_type_number,
    info:players,
    info:teams
    FROM cricket.raw.match_raw_tbl;

    SELECT 
info:match_type_number::INT AS match_type_number,
p.key::TEXT AS country,
FROM cricket.raw.match_raw_tbl,
LATERAL FLATTEN(input => info:players) p;

SELECT 
info:match_type_number::INT AS match_type_number,
p.key::TEXT as country,
team.value::TEXT AS player_name
FROM cricket.raw.match_raw_tbl,
LATERAL FLATTEN(input =>info:players) p,
LATERAL FLATTEN(input =>p.value) team;


CREATE TABLE cricket.clean.player_clean AS
SELECT
info:match_type_number::INT AS match_type_number,
p.key::TEXT as country,
team.value::TEXT AS player_name,
stg_file_name ,
stg_file_row_number,
stg_file_hashkey,
stg_modified_ts
FROM cricket.raw.match_raw_tbl,
LATERAL FLATTEN(input =>info:players) p,
LATERAL FLATTEN(input =>p.value) team;

SELECT *
FROM clean.player_clean;

DESC TABLE clean.player_clean;

ALTER TABLE clean.player_clean
MODIFY COLUMN match_type_number SET NOT NULL;

ALTER TABLE clean.player_clean
MODIFY COLUMN country SET NOT NULL;

ALTER TABLE clean.player_clean
MODIFY COLUMN player_name SET NOT NULL;

ALTER TABLE clean.match_detail_clean
ADD CONSTRAINT pk_match_type_number PRIMARY KEY(match_type_number);

ALTER TABLE clean.player_clean
ADD CONSTRAINT fk_match_id FOREIGN KEY(match_type_number) REFERENCES clean.match_detail_clean(match_type_number);


SELECT GET_DDL('table','clean.player_clean');
    

SELECT 
info:match_type_number::INT AS match_type_number,
innings
FROM raw.match_raw_tbl


CREATE TRANSIENT TABLE cricket.clean.delivery_clean AS
SELECT 
    m.info:match_type_number::INT AS match_type_number, 
    i.value:team::TEXT AS country,
    o.value:over::INT+1 AS over,
    d.value:bowler::TEXT AS bowler,
    d.value:batter::TEXT AS batter,
    d.value:non_striker::TEXT AS non_striker,
    d.value:runs.batter::TEXT AS runs,
    d.value:runs.extras::TEXT AS extras,
    d.value:runs.total::TEXT AS total,
    e.key::TEXT AS extra_ype,
    e.value::NUMBER AS extra_runs,
    w.value:player_out::TEXT AS player_out,
    w.value:kind::TEXT AS player_out_kind,
    w.value:fielders::VARIANT AS player_out_fielders,
FROM cricket.raw.match_raw_tbl m,
LATERAL FLATTEN(input => m.innings) i,
LATERAL FLATTEN(input => i.value:overs) o,
LATERAL FLATTEN(input => o.value:deliveries) d,
LATERAL FLATTEN(input => d.value:extras,outer => True) e,
LATERAL FLATTEN(input => d.value:wickets,outer => True) w;

DESC TABLE clean.delivery_clean;

ALTER TABLE clean.delivery_clean
MODIFY COLUMN match_type_number SET NOT NULL;

ALTER TABLE clean.delivery_clean
MODIFY COLUMN country SET NOT NULL;

ALTER TABLE clean.delivery_clean
MODIFY COLUMN over SET NOT NULL;

ALTER TABLE clean.delivery_clean
MODIFY COLUMN bowler SET NOT NULL;

ALTER TABLE clean.delivery_clean
MODIFY COLUMN batter SET NOT NULL;

ALTER TABLE clean.delivery_clean
MODIFY COLUMN non_striker SET NOT NULL;

ALTER TABLE clean.delivery_clean
ADD CONSTRAINT fk_delivery_match_id FOREIGN KEY (match_type_number)
REFERENCES clean.match_detail_clean (match_type_number);

SELECT GET_DDL('table','clean.delivery_clean')

