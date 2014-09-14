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
# -- proc_args is just a log of values. Values actually come from qaf_sched_proc_args
#       proc_out text,
#       user_id integer,
#       instance_id integer,
#       priority integer,
#       order_time timestamptz,
#       started_time timestamptz,
#       completed_time timestamptz,
#       process_seconds integer

# TABLE qaf_sched_proc_args
#    stack_id integer
#    argNumber integer
#    argValue text


# set id [db_nextval qaf_sched_id_seq]

ad_proc -private acc_fin::schedule_do {
} { 
    Process any scheduled procedures. Future batches are suspended until this process reports batch complete.
} {
   if {  [catch { set _calc_value [eval $_line] } _this_err_text] } {
            append _err_text "ERROR calculate '${_line}' errored with: ${_err_this_text}."
            ns_log Warning "acc_fin::model_compute ref 896: calculate '${_line}' errored with: ${_err_this_text}."
            incr _err_state
        } else {
            lappend _output [list $_varname $_calc_value]
        }
# if do is idle, delete some (limit 100 or so) used args in qaf_sched_proc_args
}

ad_proc -private acc_fin::schedule_add {
    proc_name
    proc_args_list
    user_id
    instance_id
    priority
} {
    Adds a process to be "batched" in a process stack separate from page rendering.
} {
    set id [db_nextval qaf_sched_id_seq]
    db_transaction {
        set proc_args_txt [join $proc_args_list "\t"]
        set nowts [dt_systime -gmt 1]
        db_dml qaf_sched_proc_stack_create { insert into qaf_sched_proc_stack 
            (id, proc_name, proc_args, user_id, instance_id, priority, order_time)
            values (:id, :proc_name, :proc_args_txt, :user_id, :instance_id, :priority, :nowts)

        }
        set ii 0
        foreach proc_arg $proc_args_list {
            db_dml qaf_sched_proc_args_create {
                insert into qaf_sched_proc_args
                (stack_id, arg_number, arg_value)
                values (:id, :ii, :proc_arg)
            }
            incr ii
        }
    }


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
