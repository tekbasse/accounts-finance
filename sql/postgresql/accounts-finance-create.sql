-- accounts-finance-create.sql
--
-- @author Dekka Corp.
-- @cvs-id
--

CREATE SEQUENCE qaf_id_seq start 10000;
SELECT nextval ('qaf_id_seq');

-- For general qaf app delayed process logs
CREATE TABLE qaf_process_log (
    id integer not null primary key,
    instance_id integer,
    user_id integer,
    table_tid integer,
    trashed_p varchar(1) default '0',
    name varchar(40),
    title varchar(80),
    created timestamptz default now(),
    last_modified timestamptz,
    log_entry text
);

create index qaf_process_log_id_idx on qaf_process_log (id);
create index qaf_process_log_instance_id_idx on qaf_process_log (instance_id);
create index qaf_process_log_user_id_idx on qaf_process_log (user_id);
create index qaf_process_log_table_tid_idx on qaf_process_log (table_tid);
create index qaf_process_log_trashed_idx on qaf_process_log (trashed);

CREATE TABLE qaf_process_log_viewed (
     id integer not null,
     instance_id integer,
     user_id integer,
     table_tid integer, 
     last_viewed timestamptz
);

create index qaf_process_log_viewed_id_idx on qaf_process_log_viewed (id);
create index qaf_process_log_viewed_instance_id_idx on qaf_process_log_viewed (instance_id);
create index qaf_process_log_viewed_user_id_idx on qaf_process_log_viewed (user_id);
create index qaf_process_log_viewed_table_tid_idx on qaf_process_log_viewed (table_tid);

-- model output is separate from case, even though it is one-to-one
-- for easier abstractions of output without associating case for 
-- multple case processing, such as double blind study simulations, using outputs for 
-- other case inputs etc etc.
-- think calculator wiki with revisions

CREATE TABLE qaf_file (
    id integer primary key,  
    title varchar(60)
);



-- this table associates old ids with cases
-- multiple cases may be associated with various ids
-- no type is set for old id, since this will likely be joined with
-- another table
CREATE TABLE qaf_case_log (
    case_id integer,
    other_qaf_id integer
 -- log ids, old case model init_condition log_points post_calcs ids
);


CREATE TABLE qaf_initial_conditions (
    id integer primary key,  
    code varchar(30),
    title varchar(30),
    user_id integer not null,
    time_created timestamptz not null DEFAULT now(),
    trashed_p boolean default 'f',
    description text
);

CREATE TABLE qaf_model (
    id integer primary key,  
    code varchar(30),
    title varchar(30),
    user_id integer not null,
    time_created timestamptz not null DEFAULT now(),
    trashed_p boolean default 'f',
    description text,
    program text
);


CREATE TABLE qaf_log_points (
    id integer primary key,  
    code varchar(30),
    title varchar(30),
    user_id integer not null,
    time_created timestamptz not null DEFAULT now(),
    trashed_p boolean default 'f',
    description text
);

CREATE TABLE qaf_post_calcs (
    id integer primary key,  
    log_id integer,
        -- id of qaf_log_point associated with process
    code varchar(30),
    title varchar(30),
    user_id integer not null,
    time_created timestamptz not null DEFAULT now(),
    trashed_p boolean default 'f',
    calculations text
);


CREATE TABLE qaf_case (
    id integer primary key,  
    file_id integer,  
    -- file_id does not change when case_id changes
    code varchar(30),
    title varchar(30),
    description text,
    -- create a new case when changing any of the following ids
    init_condition_id integer not null,
    model_id integer not null,
    log_points_id integer not null,
    post_calcs_id integer not null,
    -- most recent results of calculations for this case at
    log_id integer,
    post_calc_log_id integer,
     -- following are attributes for utility use
    instance_id integer,
        -- object_id of mounted instance (context_id)
    user_id integer not null,
    time_created timestamptz not null DEFAULT now(),
    last_modified timestamptz not null DEFAULT now(),
    trashed_p boolean default 'f',
    time_closed timestamptz not null DEFAULT now()
);


-- qaf_log.compute_log will contain a tcl list of lists
-- until we can reference a spreadsheet table, and
-- insert there.
CREATE TABLE qaf_log (
    id integer primary key,
    code varchar(30),
    title varchar(30),
    user_id integer not null,
    time_created timestamptz not null DEFAULT now(),
    iterations_requested integer,
    iterations_completed integer,
    trashed_p boolean default 'f',
    description text,
    compute_log text,
    notes text
);

-- whereas log_points tracks model variables
-- post_calc_log automatically tracks all post_calc_variables
-- post_calc_variables can be filtered when aggregated into
-- another case using log_points
CREATE TABLE qaf_post_calc_log (
    id integer primary key,
    code varchar(30),
    title varchar(30),
    user_id integer not null,
    time_created timestamptz not null DEFAULT now(),
    trashed_p boolean default 'f',
    description text,
    compute_log text,
    notes text
);

CREATE index qaf_file_id_key on qaf_file(id);
CREATE index qaf_case_id_key on qaf_case(id);
CREATE index qaf_case_log_case_id_key on qaf_case_log(case_id);
CREATE index qaf_case_log_other_qaf_id_key on qaf_case_log(other_qaf_id);
CREATE index qaf_initial_conditions_id_key on qaf_initial_conditions(id);
CREATE index qaf_model_id_key on qaf_model(id);
CREATE index qaf_log_points_id_key on qaf_log_points(id);
CREATE index qaf_post_calcs_id_key on qaf_post_calcs(id);
CREATE index qaf_log_id_key on qaf_log(id);
CREATE index qaf_post_calc_log_id_key on qaf_post_calc_log(id);

