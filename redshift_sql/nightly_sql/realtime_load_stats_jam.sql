update {{ dw_schema_name }}.stage_jam_{{ batchIdValue }}  set elt_run_id={{ batchIdValue }};

--DROP TABLE IF EXISTS {{ elt_schema_name }}.elt_run_stats_realtime; -- Comment out this line in production
CREATE TABLE IF NOT EXISTS {{ elt_schema_name }}.elt_run_stats_realtime
(
  ELT_RUN_ID VARCHAR(50) ENCODE zstd,
  TABLE_ID    SMALLINT ENCODE zstd,
  TABLE_NAME VARCHAR(50) ENCODE zstd,
  INGESTED_ROWS           INT ENCODE zstd,
  ELT_LOAD_TIME  TIMESTAMP WITHOUT TIME ZONE ENCODE delta32k
  )
DISTSTYLE ALL
SORTKEY ( ELT_RUN_ID );

--DROP TABLE IF EXISTS elt_waze.elt_run_state_stats_realtime; -- Comment out this line in production
CREATE TABLE IF NOT EXISTS {{ elt_schema_name }}.elt_run_state_stats_realtime
( ELT_RUN_ID VARCHAR(50) ENCODE zstd,
  TABLE_ID SMALLINT ENCODE zstd,
  TABLE_NAME VARCHAR(50) ENCODE zstd,
  STATE VARCHAR(10) ENCODE zstd,
  INGESTED_ROWS           INT ENCODE zstd,
  ELT_LOAD_TIME  TIMESTAMP WITHOUT TIME ZONE ENCODE delta32k
  )
DISTSTYLE ALL
SORTKEY ( ELT_RUN_ID );

--Update elt_run_stats_realtime
INSERT INTO {{ elt_schema_name }}.elt_run_stats_realtime
SELECT stg.elt_run_id, 
       ( 
              SELECT table_id 
              FROM   {{ elt_schema_name }}.dw_tbl_info 
              WHERE  table_name ilike 'jam') table_id, 
       'jam' AS TABLE_NAME,
       stg.ingested_rows
FROM   ( 
                SELECT   elt_run_id, 
                         count(*) ingested_rows 
                FROM     {{ dw_schema_name }}.stage_jam_{{ batchIdValue }} tfi 
                GROUP BY elt_run_id) stg;


--Update elt_run_state_stats_realtime
INSERT INTO {{ elt_schema_name }}.elt_run_state_stats_realtime
SELECT stg.elt_run_id, 
       (select table_id from {{ elt_schema_name }}.DW_TBL_INFO where TABLE_NAME ilike 'jam') table_id,
       'jam' AS TABLE_NAME,
       stg.state, 
       stg.ingested_rows
FROM   (SELECT elt_run_id, 
               state, 
               Count(*) INGESTED_ROWS 
        FROM   {{ dw_schema_name }}.stage_jam_{{ batchIdValue }} tfi 
        GROUP  BY elt_run_id, 
                  state) stg;

commit;