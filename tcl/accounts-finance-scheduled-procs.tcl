# accounts-finance/tcl/accounts-finance-scheduled-procs.tcl
ad_library {

  Scheduled procedures for accounts-finance package.
  @creation-date 2014-09-12

}

namespace eval acc_fin {}

#TABLE qaf_sched_proc_stack
#       id integer primary key,
#       -- assumes procedure is only scheduled/called once
#       proc_name varchar(40),
#       proc_args text,
#       proc_out text,
#       user_id integer,
#       instance_id integer,
#       priority integer,
#       order_time timestamptz,
#       started_time timestamptz,
#       completed_time timestamptz,
#       process_seconds integer

# set id [db_nextval qaf_sched_id_seq]
ad_proc -private acc_fin::schedule_do {
} { 
    Process any scheduled procedures. Future batches are suspended until this process reports batch complete.
} {

}

ad_proc -private acc_fin::schedule_add {

} {
    Adds a process to be "batched" in a process stack separate from page rendering.
} {

}

ad_proc -private acc_fin::schedule_delete {

} {
    Deletes a process from the process stack by noting it as completed.
} {
    # noting a process as completed in the stack keeps the proc api simple
}

ad_proc -private acc_fin::schedule_read {
    {processed_p "0"}
} {
    Reads processes in stack.
} {

}
