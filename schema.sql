USE WAREHOUSE COMPUTE_WH

CREATE DATABASE cricket;

USE DATABASE cricket;

CREATE SCHEMA land;
CREATE SCHEMA raw;
CREATE SCHEMA clean;
CREATE SCHEMA consumption;

SHOW SCHEMAS IN DATABASE cricket;

USE SCHEMA cricket.land

CREATE OR REPLACE FILE FORMAT my_json_format
TYPE = json
NULL_IF = ('\\n','null','')
strip_outer_array = true
comment = 'Json File Format with outer stip array flag true';

CREATE STAGE cricket.land.my_stg;

LIST @cricket.land.my_stg;

