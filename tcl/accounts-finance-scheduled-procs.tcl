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
    # check proc_name against allowd ones.
    set session_package_id [ad_conn package_id]
    set allowed_procs [parameter::get -parameter ScheduledProcsAllowed -package_id $session_package_id]
    # added comma and period to "split" to screen external/private references and poorly formatted lists
    set allowed_procs_list [split $allowed_procs " ,."]
    set success_p [expr { [lsearch -exact $allowed_procs_list $proc_name] > -1 } ]
    if { $success_p } { 
        set id [db_nextval qaf_sched_id_seq]
        set ii 0
        db_transaction {
            set proc_args_txt [join $proc_args_list "\t"]
            set nowts [dt_systime -gmt 1]
            db_dml qaf_sched_proc_stack_create { insert into qaf_sched_proc_stack 
                (id, proc_name, proc_args, user_id, instance_id, priority, order_time)
                values (:id, :proc_name, :proc_args_txt, :user_id, :instance_id, :priority, :nowts)
                
            }
            foreach proc_arg $proc_args_list {
                db_dml qaf_sched_proc_args_create {
                    insert into qaf_sched_proc_args
                    (stack_id, arg_number, arg_value)
                    values (:id, :ii, :proc_arg)
                }
                incr ii
            }
        } on_error {
            set success_p 0
            ns_log Warning "acc_fin::schedule_add failed for id '$id' ii '$ii' user_id ${user_id} instance_id ${instance_id} proc_name '${proc_name}' with message: ${errmsg}"
        }        
    }
    return $success_p
}

ad_proc -private acc_fin::schedule_trash {
    sched_id
    user_id
    instance_id
} {
    Removes an incomplete process from the process stack by noting it as completed.
} {
    # noting a process as completed in the stack keeps the proc api simple
    # Theoretically, one could create an untrash (reschedule) proc for this also..
    set session_user_id [ad_conn user_id]
    set session_package_id [ad_conn package_id]
    set success_p 0
    #set create_p [permission::permission_p -party_id $session_user_id -object_id $session_package_id -privilege create]
    #set write_p [permission::permission_p -party_id $session_user_id -object_id $session_package_id -privilege write]
    # keep permissions simple for now
    set admin_p [permission::permission_p -party_id $session_user_id -object_id $session_package_id -privilege admin]
    # always allows a user to stop their own processes.
    if { ( $session_user_id eq $user_id && $session_package_id eq $instance_id ) || $admin_p } {
        set nowts [dt_systime -gmt 1]
        set proc_out "Process unscheduled by user_id $session_user_id."
        set success_p [db_dml qaf_sched_proc_stack_trash { update qaf_sched_proc_stack
            set proc_out=:proc_out, started_time=:nowts, completed_time=:nowts where sched_id=:sched_id and user_id=:user_id and instance_id=:instance_id and proc_out is null and started_time is null and completed_time is null } ]
    }
    return $success_p
}

ad_proc -private acc_fin::schedule_read {
    sched_id
    user_id
    instance_id
} {
    Returns a list containing process status and results, if any.
} {

}

ad_proc -private acc_fin::schedule_list {
    {processed_p "0"}
} {
    Reads processes in stack.
} {

}
