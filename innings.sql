USE DATABASE cricket;
USE SCHEMA clean;

SELECT 
m.info:match_type_number::INT AS match_type_number,
i.value:team::TEXT AS team_name,
i.*
FROM raw.match_raw_tbl m,
LATERAL FLATTEN(input => m.innings) i;

SELECT 
m.info:match_type_number::INT AS match_type_number,
i.value:team::TEXT AS team_name,
o.*
FROM raw.match_raw_tbl m,
LATERAL FLATTEN(input => m.innings) i,
LATERAL FLATTEN(input => i.value:overs) o;

SELECT 
m.info:match_type_number::INT AS match_type_number,
i.value:team::TEXT AS team_name,
d.*
FROM raw.match_raw_tbl m,
LATERAL FLATTEN(input => m.innings) i,
LATERAL FLATTEN(input => i.value:overs) o,
LATERAL FLATTEN(input => o.value:deliveries) d;

SELECT 
    m.info:match_type_number::INT AS match_type_number, 
    i.value:team::TEXT AS country,
    o.value:over::INT AS over,
    d.value:bowler::TEXT AS bowler,
    d.value:batter::TEXT AS batter,
    d.value:non_striker::TEXT AS non_striker,
    d.value:runs.batter::TEXT AS runs,
    d.value:runs.extras::TEXT AS extras,
    d.value:runs.total::TEXT AS total
FROM cricket.raw.match_raw_tbl m,
LATERAL FLATTEN(input => m.innings) i,
LATERAL FLATTEN(input => i.value:overs) o,
LATERAL FLATTEN(input => o.value:deliveries) d;

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
    e.value::NUMBER AS extra_runs
FROM cricket.raw.match_raw_tbl m,
LATERAL FLATTEN(input => m.innings) i,
LATERAL FLATTEN(input => i.value:overs) o,
LATERAL FLATTEN(input => o.value:deliveries) d,
LATERAL FLATTEN(input => d.value:extras,outer => True) e;


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
