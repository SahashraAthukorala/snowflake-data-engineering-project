USE DATABASE cricket;
USE SCHEMA raw;

CREATE TRANSIENT TABLE cricket.raw.match_raw_tbl (
    meta object not null,
    info variant not null,
    innings ARRAY not null,
    stg_file_name text not null,
    stg_file_row_number int not null,
    stg_file_hashkey text not null,
    stg_modified_ts timestamp not null
)
comment = 'This is raw table to store all the json data file with root elements extracted';

COPY INTO cricket.raw.match_raw_tbl 
FROM 
    (
    SELECT 
        t.$1:meta::object AS meta, 
        t.$1:info::variant AS info, 
        t.$1:innings::array AS innings, 
        --
        metadata$filename,
        metadata$file_row_number,
        metadata$file_content_key,
        metadata$file_last_modified
    FROM @cricket.land.my_stg/cricket/json (file_format => 'cricket.land.my_json_format') t
    )
    on_error = continue;

    SELECT *
    FROM cricket.raw.match_raw_tbl;