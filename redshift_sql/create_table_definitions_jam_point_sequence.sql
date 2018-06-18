-------------------------------------
--Jam point sequence DDL
-------------------------------------
DROP TABLE IF EXISTS  dw_waze.stage_jam_point_sequence_{{ batchIdValue }};
CREATE TABLE IF NOT EXISTS dw_waze.stage_jam_point_sequence_{{ batchIdValue }}
(
	jam_id VARCHAR(50)   ENCODE zstd
	,location_x VARCHAR(50)   ENCODE zstd
	,location_y VARCHAR(50)   ENCODE zstd
	,sequence_order SMALLINT   ENCODE zstd
	,etl_run_id VARCHAR(50)   ENCODE zstd
)
DISTSTYLE ALL
;

--DROP TABLE dw_waze.stage_jam_point_sequence;
CREATE TABLE IF NOT EXISTS dw_waze.jam_point_sequence
(
	jam_id VARCHAR(50)   ENCODE zstd
	,location_x VARCHAR(50)   ENCODE zstd
	,location_y VARCHAR(50)   ENCODE zstd
	,sequence_order SMALLINT   ENCODE zstd
)
DISTSTYLE ALL
;
commit;