-- accounts-finance-drop.sql
--
-- @author Dekka Corp.
-- @cvs-id
--

Drop index qaf_file_id_key;
DROP index qaf_case_id_key;
DROP index qaf_case_log_case_id_key;
DROP index qaf_case_log_other_qaf_id_key;
DROP index qaf_initial_conditions_id_key;
DROP index qaf_model_id_key;
DROP index qaf_log_points_id_key;
DROP index qaf_post_calcs_id_key;
DROP index qaf_post_calc_log_id_key;
DROP index qaf_log_id_key;

DROP TABLE qaf_file;
DROP TABLE qaf_case;
DROP TABLE qaf_case_log;
DROP TABLE qaf_initial_conditions;
DROP TABLE qaf_model;
DROP TABLE qaf_log_points;
DROP TABLE qaf_post_calcs;
DROP TABLE qaf_post_calc_log;
DROP TABLE qaf_log;

DROP SEQUENCE qaf_id_seq;