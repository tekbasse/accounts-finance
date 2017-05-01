-- accounts-finance-drop.sql
--
-- @author
-- @cvs-id
--
DROP index qaf_sched_proc_args_stack_id;

DROP TABLE qaf_sched_proc_args;

DROP index qaf_sched_proc_stack_started_time_key;
DROP index qaf_sched_proc_stack_priority_key;
DROP index qaf_sched_proc_stack_id_key;

DROP TABLE qaf_sched_proc_stack;

DROP index qaf_file_id_key;
DROP index qaf_case_id_key;
DROP index qaf_case_log_case_id_key;
DROP index qaf_case_log_other_qaf_id_key;
DROP index qaf_initial_conditions_id_key;
DROP index qaf_model_id_key;
DROP index qaf_log_points_id_key;
DROP index qaf_post_calcs_id_key;
DROP index qaf_post_calc_log_id_key;
DROP index qaf_log_id_key;
DROP index qaf_process_log_id_idx;
DROP index qaf_process_log_instance_id_idx;
DROP index qaf_process_log_user_id_idx;
DROP index qaf_process_log_table_tid_idx;
DROP index qaf_process_log_trashed_p_idx;
DROP index qaf_process_log_viewed_id_idx;
DROP index qaf_process_log_viewed_instance_id_idx;
DROP index qaf_process_log_viewed_user_id_idx;
DROP index qaf_process_log_viewed_table_tid_idx;

DROP TABLE qaf_file;
DROP TABLE qaf_case;
DROP TABLE qaf_case_log;
DROP TABLE qaf_initial_conditions;
DROP TABLE qaf_model;
DROP TABLE qaf_log_points;
DROP TABLE qaf_post_calcs;
DROP TABLE qaf_post_calc_log;
DROP TABLE qaf_log;
DROP TABLE qaf_process_log;
DROP TABLE qaf_process_log_viewed;

DROP SEQUENCE qaf_sched_id_seq;
DROP SEQUENCE qaf_id_seq;
