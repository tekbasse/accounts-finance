ad_library {

    PRETTI routines used for Project Reporting Evaluation and Track Task Interpretation
    With Hints Of GANTT Activity Network Task Tracking (PRETTI WHO GANTT)
    Project Activity Network Evaluation By Reporting Low Float Paths In Fast Tracks
    @creation-date 11 Feb 2014
    @cvs-id $Id:
    @Copyright (c) 2014 Benjamin Brink
    @license GNU General Public License 3, see project home or http://www.gnu.org/licenses/gpl-3.0.en.html
    @project home: http://github.com/tekbasse/accounts-finance
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com

    Temporary comment about git commit comments: http://xkcd.com/1296/
}

namespace eval acc_fin {}

## acs-tcl/tcl/set-operation-procs.tcl 

ad_proc -private acc_fin::pretti_curve_time_multiply {
    factor_curve_lol
    tcurvenum 
    coefficient 
    scenario_id 
    user_id 
    instance_id
} {
    Returns the multiple of a time curve after applying any defined constraints. 
    max_overlap_pct, max_concurrent, max_run_time, max_tasks_per_run, activity must be defined in space called by this proc.
    Additionally, tasks_per_run and run_count are passed back for use with acc_fin::pretti_curve_cost_multiply
} {
    upvar 1 max_tasks_per_run max_tasks_per_run
    upvar 1 max_run_time max_run_time
    upvar 1 max_overlap_pct max_overlap_pct
    upvar 1 max_concurrent max_concurrent
    upvar 1 activity activity
    upvar 1 run_count run_count
    upvar 1 tasks_per_run tasks_per_run
    upvar 1 use_t_run_p use_t_run_p
    upvar 1 t_constrained_by_time_p t_constrained_by_time_p

    # time_clarr(tcurvenum) curve is not available in regression testing.
    if { $tcurvenum ne "" } {
        upvar 1 time_clarr time_clarr
    } else {
        # create a fake tcurvenum and time_clarr
        set tcurvenum 1
        set time_clarr($tcurvenum) $factor_curve_lol
    }
    
    set use_t_run_p 1
    # create new curve based on the one referenced 
    # parameters: max_concurrent max_run_time max_tasks_per_run max_overlap_pct
    #      max_overlap_pct  (as a percentage from 0 to 1, blank = 1)
    #      max_concurrent   (as a positive integer, blank = no limit)
    #      max_run_time (as a decimal, blank = no limit)
    #      max_tasks_per_run (as a postive integer, blank = no limit)


    # activity curve @tcurvenum
    # for each point t(pm) in curve time_clarr($_tCurveRef), max_overlap_pct, max_concurrent, coeffient c
    if { [qf_is_decimal $max_overlap_pct ] && $max_overlap_pct <= 1. && $max_overlap_pct >= 0. } {
        # validated
    } else {
        if { $user_id > 0 } {
            acc_fin::pretti_log_create $scenario_tid "max_overlap_pct" "#accounts-finance.value#" "max_overlap_pct '${max_overlap_pct}' #accounts-finance.Value_out_of_range_or_blank# #accounts-finance.Value_set_to# '1' (100%). (ref1520)" $user_id $instance_id
        }
        set max_overlap_pct 1.
    }
    if { [qf_is_decimal $max_concurrent ] &&  $max_concurrent >= 1 } {
        # validated. should be a natural number, so round off
        set max_concurrent [expr { round( $max_concurrent ) + 0. } ]
        # coef_p1 * max_concurrent + coef_p2 = $coefficient
        set block_count [expr { ceil( $coefficient / $max_concurrent ) + 0. } ]
        # coef_p2 should be at most 1 less than max_concurrent
        # max_trailing_pct = 1. - max_overlap_pct
    } else {
        if { $user_id > 0 } {
            acc_fin::pretti_log_create $scenario_tid "max_concurrent" "#accounts-finance.value#" "max_concurrent '$max_concurrent' #accounts-finance.Value_out_of_range_or_blank# #accounts-finance.Value_set_to# #accounts-finance.no_limit# (ref1525)" $user_id $instance_id
        }
        # max_concurrent is coeffcient
        set max_concurrent ""
        set block_count 1.
    }
    if { [qf_is_decimal $max_run_time ] && $max_run_time > 0. } {
        # validated
    } else {
        set max_run_time ""
    }
    if { [qf_is_decimal $max_tasks_per_run] && $max_tasks_per_run >= 1. } {
        # validated, but should be a natural number
        set max_tasks_per_run [expr { round( $max_tasks_per_run ) + 0. } ]
    } else {
        set max_tasks_per_run ""
    }

    ## $coefficient count of tasks
    ## a $block_count of tasks operates in up to $max_concurrent tasks per block
    ## a partial block occupies the same amount of scheduled time as a full block

    # a run is a contiguous period of time. A run can be measured in run_time or task count
    # or tpr_coef, where tpr_coef * task_time = run_time
    ## max_run_time = max duration of a run in units of time
    ## $tasks_per_run up to $max_tasks_per_run
    ## a batch is a multiple of run cycles

    # Calculate batch duration in units of task_count assuming no run limits
    # ie. first run is whole, subsequent runs are of length 1 - max_overlap
    set max_dedicated_pct [expr { 1. - $max_overlap_pct } ]
    set tasks_per_run $block_count
    set tpr_coef [expr { 1. * $tasks_per_run * $max_dedicated_pct + $max_overlap_pct } ]
    set run_count 1.

    if { $max_tasks_per_run ne "" && $max_tasks_per_run >= 1. } {
        # Calculate duration assuming max_tasks_per_run
        # adjust task_count and run_count?
        if { $tasks_per_run > $max_tasks_per_run } {
            set run_count [expr { ceil( $block_count / $max_tasks_per_run ) + 0. } ]
            set tasks_per_run $max_tasks_per_run
            set tpr_coef [expr { 1. * $tasks_per_run * $max_dedicated_pct + $max_overlap_pct } ]
        }
    } 
    #ns_log Notice "acc_fin::pretti_curve_time_multiply.119: max_run_time '${max_run_time}' max_overlap_pct '${max_overlap_pct}' max_tasks_per_run '${max_tasks_per_run}'"
    #ns_log Notice "acc_fin::pretti_curve_time_multiply.121: initial: block_count '${block_count}' max_dedicated_pct '${max_dedicated_pct}' tasks_per_run '${tasks_per_run}' run_count '${run_count}'"
    # create new dc based on old dc
    set curve_lol [list ]
    # add titles
    set title_list [lindex $time_clarr($tcurvenum) 0]
    set x_idx [lsearch -exact $title_list "x"]
    set y_idx [lsearch -exact $title_list "y"]
    set label_idx [lsearch -exact $title_list "label"]
    set title_new_list [list "y" "x"]
    if { $label_idx > -1 } {
        lappend title_new_list "label"
    }
    lappend curve_lol $title_new_list

    if { $max_run_time ne "" } {
        # Use a separate loop for scaling.

        foreach point [lrange $time_clarr($tcurvenum) 1 end] {
            # point: x y label
            set x [lindex $point $x_idx]
            set y [lindex $point $y_idx]
            if { $label_idx > -1 } {
                set label [lindex $point $label_idx]
            }
            # run_time is y * tpr_coef
            set tpr_coef [expr { 1. * $tasks_per_run * $max_dedicated_pct + $max_overlap_pct } ]
            set run_time [expr { $y * $tpr_coef } ]
            # y_new constrained by max_overlap_pct, max_concurrent, and max_tasks_per_run
            set y_new [expr { $run_time * $run_count } ]
            #ns_log Notice "acc_fin::pretti_curve_time_multiply.143: for point y $y tasks_per_run $tasks_per_run run_count $run_count run_time ${run_time} tpr_coef ${tpr_coef} y_new ${y_new}"            
            # constrain run_time by max_run_time?
            # is run_time (optimally set using max_tasks_per_run) too long?
            if { $run_time > $max_run_time && $y > 0. && $y < $max_run_time } {
                set t_constrained_by_time_p 1
                # max_run_time per run is exceeded for this probability moment (pm)
                # calculate new tasks_per_run for this pm.
                
                # How many tasks fit in max_run_time?
                if { $max_overlap_pct > 0. } {
                    set tasks_per_run_at_pm [expr { int( ( $max_run_time - $max_dedicated_pct * $y ) / ( $y * $max_overlap_pct ) ) } ]
                } else {
                    # no overlap
                    set tasks_per_run_at_pm [expr { int( $max_run_time / $y ) } ]
                }
                set run_count_at_pm [expr { ceil( $block_count / ( $tasks_per_run_at_pm + 0. ) ) } ]
                set tpr_coef_at_pm [expr { 1. * $tasks_per_run_at_pm * $max_dedicated_pct + $max_overlap_pct } ]
                if { $run_count_at_pm >= $run_count } {
                    ns_log Warning "acc_fin::pretti_curve_time_multiply.2600: scenario '$scenario_tid' run_count_at_pm ${run_count_at_pm} should never be more than run_count ${run_count} here. tasks_per_run_at_pm '${tasks_per_run_at_pm}' y '$y' run_time '${run_time}' max_run_time '${max_run_time}'"
                    set error_time 1
                }
                set y_new [expr { $y * $run_count_at_pm * $tpr_coef_at_pm } ]
                #ns_log Notice "acc_fin::pretti_curve_time_multiply.170: for point y $y tasks_per_run_at_pm ${tasks_per_run_at_pm} tpr_coef_at_pm ${tpr_coef_at_pm} y_new ${y_new}"
            } elseif { $run_time > $max_run_time } {
                set t_constrained_by_time_p 1
                # y == 0
                # warn user for out of bounds value of Y
                if { $user_id > 0 } {
                    acc_fin::pretti_log_create $scenario_tid "dc y=0" "#accounts-finance.value#" "activity '${activity}': y '${y}'; #accounts-finance.max_run_time_ignored_in_dc# #accounts-finance.in_dc_y_cannot_be_0# #accounts-finance.set_max_run_time_longer_or_blank# (ref2601)" $user_id $instance_id
                }
                
            } elseif { $y > $max_run_time } {
                # y duration is larger than max_run_time..
                if { $user_id > 0 } {
                    acc_fin::pretti_log_create $scenario_tid "dc y" "#accounts-finance.value#" "activity '${activity}': y '${y}'; #accounts-finance.in_dc_y_gt_max_run_time_ignored# #accounts-finance.set_max_run_time_longer_or_blank# (ref2602)" $user_id $instance_id
                }
            }
            set point_new [list $y_new $x]
            if { $label_idx > -1 } {
                lappend point_new $label
            }
            lappend curve_lol $point_new
        }
    } else {
        # max_run_time is unlimited
        ns_log Notice "acc_fin::pretti_curve_time_multiply.190: max_tasks_per_run $max_tasks_per_run max_overlap_pct $max_overlap_pct max_dedicated_pct $max_dedicated_pct"
        #set tpr_coef [expr { 1. * $tasks_per_run * $max_dedicated_pct + $max_overlap_pct } ]
        foreach point [lrange $time_clarr($tcurvenum) 1 end] {
            # point: x y label
            set x [lindex $point $x_idx]
            set y [lindex $point $y_idx]
            if { $label_idx > -1 } {
                set label [lindex $point $label_idx]
            }

            set y_new [expr { $y * $run_count * $tpr_coef } ]
            #ns_log Notice "acc_fin::pretti_curve_time_multiply.199: for point y $y tasks_per_run ${tasks_per_run} tpr_coef ${tpr_coef} y_new ${y_new}"
            #ns_log Notice "acc_fin::pretti_curve_time_multiply.2631: scenario '$scenario_tid' y $y run_count ${run_count} tasks_per_run ${tasks_per_run} max_overlap_pct ${max_overlap_pct} max_dedicated_pct ${max_dedicated_pct} y_new ${y_new}"
            set point_new [list $y_new $x]
            if { $label_idx > -1 } {
                lappend point_new $label
            }
            lappend curve_lol $point_new
        }
    }
    return $curve_lol
}

ad_proc -private acc_fin::pretti_curve_cost_multiply {
    factor_curve_lol
    ccurvenum 
    coefficient 
    scenario_id 
    user_id 
    instance_id
} {
    Returns the multiple of a time curve after applying any defined constraints.
    max_overlap_pct, max_concurrent, max_run_time, max_tasks_per_run, activity, run_count, tasks_per_run and use_t_run_p must be defined in space called by this proc.
} {
    upvar 1 max_tasks_per_run max_tasks_per_run
    upvar 1 max_run_time max_run_time
    upvar 1 max_overlap_pct max_overlap_pct
    upvar 1 max_concurrent max_concurrent
    upvar 1 max_discount_pct max_discount_pct
    upvar 1 activity activity
    upvar 1 run_count run_count
    upvar 1 tasks_per_run tasks_per_run
    upvar 1 use_t_run_p use_t_run_p
    upvar 1 t_constrained_by_time_p t_constrained_by_time_p
    # cost_clarr(tcurvenum) curve is not available in regression testing.
    if { $ccurvenum ne "" } {
        upvar 1 cost_clarr cost_clarr
    } else {
        # create a fake ccurvenum and cost_clarr
        set ccurvenum 1
        set cost_clarr($ccurvenum) $factor_curve_lol
    }

    # New curve is isn't affected by overlap or max_concurrent max_run_time max_tasks_per_run. 
    # New curve is simple multiplication of old and coefficient
    if { [qf_is_decimal $max_discount_pct ] && $max_discount_pct <= 1. && $max_discount_pct >= 0. } {
        # validated
    } else {
        if { $user_id > 0 } {
            acc_fin::pretti_log_create $scenario_tid "max_discount_pct" "#accounts-finance.value#" "max_discount_pct '${max_discount_pct}'; #accounts-finance.Value_out_of_range_or_blank# #accounts-finance.Value_set_to# '0'. (ref1620)" $user_id $instance_id
        }
        set max_discount_pct 0.
    }

    # Calculate batch duration in units of task_count assuming no run limits
    # ie. first run is whole, subsequent runs are of length 1 - max_overlap
    set max_batch_rate_pct [expr { 1. - $max_discount_pct } ]

    # cost calcs are not affected by time constraints, but must match any existing constraints
    if { $use_t_run_p && $t_constrained_by_time_p == 0 } {
        #tasks_per_run and run_count are already calculated. Use same here.
    } elseif { $use_t_run_p && $t_constrained_by_time_p } {
        # Curve calculations get complicated since tcurve is different than ccurve.
        # Assume the worse case. Ignore the discount.
        set tasks_per_run 1.
        set run_count $coefficient
    } else {
        if { [qf_is_decimal $max_concurrent ] &&  $max_concurrent >= 1 } {
            # validated. should be a natural number, so round off
            set max_concurrent [expr { round( $max_concurrent ) + 0. } ]
            # coef_p1 * max_concurrent + coef_p2 = $coefficient
            set block_count [expr { ceil( $coefficient / $max_concurrent ) + 0. } ]
            # coef_p2 should be at most 1 less than max_concurrent
            # max_trailing_pct = 1. - max_overlap_pct
        } else {
            if { $user_id > 0 } {
                acc_fin::pretti_log_create $scenario_tid "max_concurrent" "#accounts-finance.value#" "max_concurrent '$max_concurrent'; #accounts-finance.Value_out_of_range_or_blank# #accounts-finance.Value_set_to# #accounts-finance.no_limit# (ref1625)" $user_id $instance_id
            }
            # max_concurrent is coeffcient
            set max_concurrent ""
            set block_count 1.
        }
        
        set tasks_per_run [expr { 1. + ( $block_count - 1. ) * $max_batch_rate_pct } ]
        set run_count 1.
        
        if { $max_tasks_per_run ne "" && $max_tasks_per_run >= 1. } {
            # Calculate duration assuming max_tasks_per_run
            # adjust task_count and run_count?
            if { $tasks_per_run > $max_tasks_per_run } {
                set run_count [expr { ceil( $block_count / $max_tasks_per_run ) + 0. } ]
                set tasks_per_run $max_tasks_per_run
            }
        } 
    }


    # create new curve
    set curve_lol [list ]
    # add titles
    set title_list [lindex $cost_clarr($ccurvenum) 0]
    set x_idx [lsearch -exact $title_list "x"]
    set y_idx [lsearch -exact $title_list "y"]
    set label_idx [lsearch -exact $title_list "label"]
    set title_new_list [list "y" "x"]
    if { $label_idx > -1 } {
        lappend title_new_list "label"
    }
    lappend curve_lol $title_new_list
    foreach point [lrange $cost_clarr($ccurvenum) 1 end] {
        # point: x y label
        set x [lindex $point $x_idx]
        set y [lindex $point $y_idx]
        if { $label_idx > -1 } {
            set label [lindex $point $label_idx]
        }
        #set y_new [expr { $y * $coefficient } ]
        # max_batch_rate_pct was max_overlap_pct
        # max_discount_pct was max_dedicated_pct
        set y_new [expr { $y * $run_count * ( 1. * $tasks_per_run * $max_batch_rate_pct + $max_discount_pct ) } ]
        set point_new [list $y_new $x]
        if { $label_idx > -1 } {
            lappend point_new $label
        }
        lappend curve_lol $point_new
    }

    return $curve_lol
}


ad_proc -public acc_fin::pretti_color_chooser {
    on_cp_p
    on_a_sig_path_p
    odd_row_p
    popularity
    max_act_count_per_track
    cp_duration
    path_duration
    {color_cp_mask_idx "3"}
    {color_sig_mask_idx "5"}
    {row_contrast "-8"}
} {
    Returns an html color in hex value based on parameters. popularity is 0..1.
} {
    # create a list of cells from highest priority to lowest.
    # from acc_fin::pretti_table_to_html

    # build formatting colors

    set hex_list [list 0 1 2 3 4 5 6 7 8 9 a b c d e f]
    set bin_list [list 000 100 010 110 001 101 011 111]
    #set row_contrast -7
    set color_cp_mask [lindex $bin_list $color_cp_mask_idx]
    set color_cp_mask_list [split $color_cp_mask ""]
    set color_sig_mask [lindex $bin_list $color_sig_mask_idx]
    set color_sig_mask_list [split $color_sig_mask ""]

    set k2 [expr { 127. / ( $max_act_count_per_track + 0. ) } ]

    if { $on_cp_p > -1 } {
        # ..from acc_fin::pretti_table_to_html
        # intensity is 0 to 15.
        # subtract 1 for contrast variance
        # which leaves color variance 0 to 14
        if { $on_cp_p || $path_duration == $cp_duration } {
            set color_mask_list $color_cp_mask_list
            set c1 255
            set c0 127
        } else {
            set color_mask_list $color_sig_mask_list
            set dur_ratio_case [expr { round( 255 * $path_duration / ( $cp_duration + 0. ) ) } ]
            if { $on_a_sig_path_p } {
                set pop_case [expr { 127 + int( $popularity * $k2 + 1. ) } ]
                set max_case [f::max $pop_case $dur_ratio_case ]
                set c1 [f::max 0 [f::min 255 $max_case ]]
                set c0 127

            } else {
                set c0 127
                set pop_case [expr { int( $popularity * $k2 + 1. ) } ]
                set max_case [f::max $pop_case $dur_ratio_case ]
                set c1 [f::max 0 [f::min 255 $max_case ]]
            }
        }
#        set c0 [expr { 255 - $c1 } ]
        if { $odd_row_p } {
            incr c1 $row_contrast 
            # incr c0 [f::sum $color_mask_list]
        }
        # convert rgb to hexidecimal
        set c0e1 [expr { int( $c0 / 16. ) } ]
        set c0e0 [expr { $c0 - $c0e1 * 16 } ]
        set h(0) [lindex $hex_list [f::max 0 [f::min 15 $c0e1 ]]]
        append h(0) [lindex $hex_list [f::max 0 [f::min 15 $c0e0 ]]]
        set hex_arr($c0) $h(0)

        set c1e1 [expr { int( $c1 / 16. ) } ]
        set c1e0 [expr { $c1 - $c1e1 * 16 } ]
        set h(1) [lindex $hex_list [f::max 0 [f::min 15 $c1e1 ]]]
        append h(1) [lindex $hex_list [f::max 0 [f::min 15 $c1e0 ]]]
        set hex_arr($c1) $h(1)

        set colorhex ""
        foreach mask $color_mask_list {
            append colorhex $h($mask)
        }
        if { [string length $colorhex] != 6 } {
            ns_log Notice "acc_fin::pretti_color_chooser.914: issue colorhex '$colorhex' on_a_sig_path_p ${on_a_sig_path_p} popularity $popularity on_cp_p $on_cp_p c0 '$c0' c1 '$c1' h(0) $h(0) h(1) $h(1) color_mask_list '${color_mask_list}' odd_row_p '${odd_row_p}"
            set colorhex "ffffff"
        }
    } else {
        set colorhex "4f4f4f"
    }
    return $colorhex
}


ad_proc -public acc_fin::pretti_equation_vars {
} {
    Returns a list of value triplets, where each value pair consists of 1. a variable name used in pretti custom equation feature,  2. a human legible variable equivalent, and 3. a brief definition of the variable
} {
    set vars_lol [list [list 0 path_len "Number of different activities in path"] \
                      [list 1 path_len_w_coefs "Number of activities in path"] \
                      [list 2 act_cp_ratio "Ratio of activities in path that are also in Critical Path"] \
                      [list 3 cost_ratio "Cost ratio: cost of path / cost of project"] \
                      [list 4 on_critical_path_p "1 if path is Critical Path, otherwise 0"] \
                      [list 5 duration_ratio "Duration ratio: duration of path / duration of Critical Path"] \
                      [list 6 path_counter "A path's sequence number from Critical Path based on PRETTI index"] \
                      [list 7 act_count_median "Median count of unique activities on a path."] \
                      [list 8 act_count_max "Max count of unqiue activities on a path."] \
                      [list 9 paths_count "Count of all complete paths."] \
                      [list 10 a_sig_path_p "1 if path contains at least one activity that is above the median count (act_path_count_median), otherwise 0"] ]
    return $vars_lol
}

ad_proc -private acc_fin::pretti_log_create {
    table_tid
    action_code
    action_title
    entry_text
    {user_id ""}
    {instance_id ""}
} {
    Log an entry for a pretti process. Returns unique entry_id if successful, otherwise returns empty string.
} {
    set id ""
    set status [qf_is_natural_number $table_tid]
    if { $status } {
        if { $entry_text ne "" } {
            if { $instance_id eq "" } {
                ns_log Notice "acc_fin::pretti_log_create.451: instance_id ''"
                set instance_id [ad_conn package_id]
            }
            if { $user_id eq "" } {
                ns_log Notice "acc_fin::pretti_log_create.451: user_id ''"
                set user_id [ad_conn user_id]
            }
            set id [db_nextval qaf_id_seq]
            set trashed_p 0
            set nowts [dt_systime -gmt 1]
            set action_code [qf_abbreviate $action_code 38]
            set action_title [qf_abbreviate $action_title 78]
            db_dml qaf_process_log_create { insert into qaf_process_log
                (id,table_tid,instance_id,user_id,trashed_p,name,title,created,last_modified,log_entry)
                values (:id,:table_tid,:instance_id,:user_id,:trashed_p,:action_code,:action_title,:nowts,:nowts,:entry_text) }
            ns_log Notice "acc_fin::pretti_log_create.46: posting to qaf_process_log: action_code ${action_code} action_title ${action_title} '$entry_text'"
        } else {
            ns_log Warning "acc_fin::pretti_log_create.48: attempt to post an empty log message has been ignored."
        }
    } else {
        ns_log Warning "acc_fin::pretti_log_create.51: table_tid '$table_tid' is not a natural number reference. Log message '${entry_text}' ignored."
    }
    return $id
}

ad_proc -public acc_fin::pretti_log_read {
    table_tid
    {max_old "1"}
    {user_id ""}
    {instance_id ""}
} {
    Returns any new log entries as a list via util_user_message, otherwise returns most recent max_old number of log entries.
    Returns empty string if no entry exists.
} {
    set return_lol [list ]
    set alert_p 0
    set nowts [dt_systime -gmt 1]
    set valid1_p [qf_is_natural_number $table_tid] 
    set valid2_p [qf_is_natural_number $table_tid]
    if { $valid1_p && $valid2_p } {
        if { $instance_id eq "" } {
            set instance_id [ad_conn package_id]
            ns_log Notice "acc_fin::pretti_log_read.493: instance_id ''"
        }
        if { $user_id eq "" } {
            set user_id [ad_conn user_id]
            ns_log Notice "acc_fin::pretti_log_read.497: user_id ''"
        }
        set return_lol [list ]
        set last_viewed ""
        set alert_msg_count 0
        set viewing_history_p [db_0or1row qaf_process_log_viewed_last { select last_viewed from qaf_process_log_viewed where instance_id = :instance_id and table_tid = :table_tid and user_id = :user_id } ]
        # set new view history time
        if { $viewing_history_p } {

            set last_viewed [string range $last_viewed 0 18]
            if { $last_viewed ne "" } {
                
                set entries_lol [db_list_of_lists qaf_process_log_read_new { 
                    select id, name, title, log_entry, last_modified from qaf_process_log 
                    where instance_id = :instance_id and table_tid =:table_tid and last_modified > :last_viewed order by last_modified desc } ]
                
                ns_log Notice "acc_fin::pretti_log_read.80: last_viewed ${last_viewed}  entries_lol $entries_lol"
                
                if { [llength $entries_lol ] > 0 } {
                    set alert_p 1
                    set alert_msg_count [llength $entries_lol]
                    foreach row $entries_lol {
                        set message_txt "[lc_time_system_to_conn [string range [lindex $row 4] 0 18]] [lindex $row 3]"
                        set last_modified [lindex $row 4]
                        ns_log Notice "acc_fin::pretti_log_read.79: last_modified ${last_modified}"
                        util_user_message -message $message_txt
                        ns_log Notice "acc_fin::pretti_log_read.88: message '${message_txt}'"
                    }
                    set entries_lol [list ]
                } 
            }
            
            set max_old [expr { $max_old + $alert_msg_count } ]
            set entries_lol [db_list_of_lists qaf_process_log_read_one { 
                select id, name, title, log_entry, last_modified from qaf_process_log 
                where instance_id = :instance_id and table_tid =:table_tid order by last_modified desc limit :max_old } ]
            foreach row [lrange $entries_lol $alert_msg_count end] {
                set message_txt [lindex $row 2]
                append message_txt " ([lindex $row 1])"
                append message_txt " posted: [lc_time_system_to_conn [string range [lindex $row 4] 0 18]]\n "
                append message_txt [lindex $row 3]
                ns_log Notice "acc_fin::pretti_log_read.100: message '${message_txt}'"
                lappend return_lol $message_txt
            }
            
            # last_modified ne "", so update
            db_dml qaf_process_log_viewed_update { update qaf_process_log_viewed set last_viewed = :nowts where instance_id = :instance_id and table_tid = :table_tid and user_id = :user_id }
        } else {
            # create history
            set id [db_nextval qaf_id_seq]
            db_dml qaf_process_log_viewed_create { insert into qaf_process_log_viewed
                ( id, instance_id, user_id, table_tid, last_viewed )
                values ( :id, :instance_id, :user_id, :table_tid, :nowts ) }
        }
    }
    return $return_lol
}


ad_proc -public acc_fin::pert_omp_to_strict_dc {
    optimistic
    most_likely
    pessimistic
    {labels_p "0"}
} {
    Creates a curve in PRETTI table format representing strict characteristics of 
    a PERT expected time function (Te), where 
    Te = ( o + 4 * m + p ) / 6 and o = optimistic time, m = most likely time, and p = pessimistic time.
    This 3 point curve has lower limit (o), upper limit (p) and median (m). If labels_p is true, adds a labels column; Labels describe a little about each point.
} {
    if { $labels_p ne "0" && $labels_p ne "1" } {
        set labels_p "0"
    }
    #    ns_log Notice "acc_fin::pert_omp_to_strict_dc.24: optimistic $optimistic most_likely $most_likely pessimistic $pessimistic"
    # nomenclature of inputs  statistics:
    # set median $most_likely
    # set minimum $optimistic
    # set maximum $pessimistic
    set curve_lists [list ]
    if { $labels_p } {
        lappend curve_lists [list y x label]
        set one_sixth [expr { 1. / 6. } ]
        set point_list [list $optimistic $one_sixth "optimistic / minimum"]
        lappend curve_lists $point_list
        set point_list [list $most_likely [expr { 4. / 6. } ] "most likely / median"]
        lappend curve_lists $point_list
        set point_list [list $pessimistic $one_sixth "pessimistic / maximum"]
        lappend curve_lists $point_list
    } else {
        lappend curve_lists [list y x]
        set one_sixth [expr { 1. / 6. } ]
        set point_list [list $optimistic $one_sixth]
        lappend curve_lists $point_list
        set point_list [list $most_likely [expr { 4. / 6. } ] ]
        lappend curve_lists $point_list
        set point_list [list $pessimistic $one_sixth]
        lappend curve_lists $point_list
    }
    return $curve_lists
}

ad_proc -public acc_fin::pert_omp_to_normal_dc {
    optimistic
    most_likely
    pessimistic
    {n_points "24"}
    {labels_p "0"}
} {
    Creates a normal distribution curve in PRETTI table format representing characteristics of 
    a PERT expected time function (Te), where 
    Te = ( o + 4 * m + p ) / 6 and o = optimistic time, m = most likely time, and p = pessimistic time.
    The normal distribution curve has lower limit (o), upper limit (p) and median (m). 
    Regression tests at accounts-finance/tcl/test/pretti-test-procs.tcl suggests 24 points minimum for a practical representation of a curve.
    18 point is about the absolute minimum practical amount for passing a clear majority of regression tests to within 1%. 5 is lowest number of points accepted.
    See also acc_fin::pert_omp_to_stric_dc for a 3 point curve that matches project management representation of the Time expected curve.
} {
    if { $n_points eq "" } {
        set n_points "24"
    }
    set n_points [f::max [expr { int( $n_points ) } ] 5]
    if { $labels_p ne "0" && $labels_p ne "1" } {
        set labels_p "0"
    }

    ns_log Notice "acc_fin::pert_omp_to_normal_dc.23: starting"
    ns_log Notice "acc_fin::pert_omp_to_normal_dc.24: optimistic $optimistic most_likely $most_likely pessimistic $pessimistic n_points $n_points"
    # nomenclature of inputs  statistics:
    # set median $most_likely
    # set minimum $optimistic
    # set maximum $pessimistic
    set curve_lists [qaf_std_normal_distribution $n_points 2 $labels_p]
    ns_log Notice "acc_fin::pert_omp_to_normal_dc.305. llength $curve_lists $curve_lists] curve_lists $curve_lists"
    # for purposes of qaf DCs, x_dev is y, standard f(x) = y is used to calculate area
    # Therefore titles do not match variables used with standard equation.

    # change title rows to:
    #set title_row [list y f_of_x x a]
    # was         set title_row [list x_dev y x a]
    # except, y gets created/renamed in qaf_table_column_convert, so
    # no need need to change title here.
    #set curve_lists [lreplace $curve_lists $title_row 0 0]

    set y_min [lindex [lindex $curve_lists 1] 0]
    set y_max [lindex [lindex $curve_lists end] 0]
    #set bars_count [expr { [llength $curve_lists] - 1 } ]
    #set med_idx [expr { $bars_count / 2. + 1 } ]
    #set y_med [lindex [lindex $cure_lists $med_idx] ]
    # y_med is 0. for std_normal_distributions
    set y_med 0.
    set curve_lists [qaf_table_column_convert $curve_lists x_dev $y_min $y_med $y_max y $optimistic $most_likely $pessimistic]
    return $curve_lists
}


ad_proc -public acc_fin::pert_omp_to_normal_dc_old {
    optimistic
    most_likely
    pessimistic
    {n_points "24"}
    {labels_p "0"}
} {
    Creates a normal distribution curve in PRETTI table format representing characteristics of 
    a PERT expected time function (Te), where 
    Te = ( o + 4 * m + p ) / 6 and o = optimistic time, m = most likely time, and p = pessimistic time.
    The normal distribution curve has lower limit (o), upper limit (p) and median (m). 
    Regression tests at accounts-finance/tcl/test/pretti-test-procs.tcl suggests 24 points minimum for a practical representation of a curve.
    18 point is about the absolute minimum practical amount for passing a clear majority of regression tests to within 1%. 5 is lowest number of points accepted.
    See also acc_fin::pert_omp_to_stric_dc for a 3 point curve that matches project management representation of the Time expected curve.
} {
    if { $n_points eq "" } {
        set n_points "24"
    }
    if { $labels_p ne "0" && $labels_p ne "1" } {
        set labels_p "0"
    }

    ns_log Notice "acc_fin::pert_omp_to_normal_dc.23: starting"
    ns_log Notice "acc_fin::pert_omp_to_normal_dc.24: optimistic $optimistic most_likely $most_likely pessimistic $pessimistic n_points $n_points"
    # nomenclature of inputs  statistics:
    # set median $most_likely
    # set minimum $optimistic
    # set maximum $pessimistic
    set n_points [f::max [expr { int( $n_points ) } ] 5]
    set n_areas  [expr { int( $n_points - 1 ) } ]
    # eps = 2.22044604925e-016 = Smallest number such that 1+eps != 1  from: http://wiki.tcl.tk/15256
    set eps 2.22044604925e-016
    # Create a limit of largest single step area could possibly be, to avoid binary calc tangents
    set largest_a [expr { 0.5 - ( $eps * $n_areas ) } ]
    #set pi 3.14159265358979
    set pi [expr { atan2( 0. , -1. ) } ]
    #set e 2.718281828459  see exp()
    set sqrt_2pi [expr { sqrt( 2. * $pi ) } ]
    set sqrt_2 [expr { sqrt( 2. ) } ]
    set optimistic [expr { $optimistic + 0. } ]
    set most_likely [expr { $most_likely + 0. } ]
    set pessimistic [expr { $pessimistic + 0. } ]

    # Build a curve using Normal Distribution calculations as a base

    # Split the curve into two tails, in case med - min value does not equal max - med.

    # Symetric calculations use indexed arrays to swap between tails.
    # Index of:
    # 0 = left tail
    # 1 = right tail

    # Left tail represents minimum to median.
    # So, create a standard_deviation for left side by assuming curve is symmetric:
    # set std_dev_left [expr { sqrt( 2 * pow( $minimum - $median , 2) + 4 * pow( $median - $median , 2) ) } ]
    # resolves to:
    # set std_dev_left [expr { sqrt( 2 * pow( $minimum - $median , 2)  ) } ]
    # which further reduces to:

    set std_dev(0) [expr { $sqrt_2 * abs( $most_likely - $optimistic ) } ]
    #    set variance(0) [expr { pow( $std_dev(0) , 2. ) } ]
    #    set precision(0) [expr { 1. / $std_dev(0) } ]
    #    set precision2(0) [expr { 1. / pow( $std_dev(0) , 2. ) } ]
    set precision(0) 1.
    set precision2(0) [expr { pow( $precision(0) , 2. ) } ]

    # Right tail represents median to maximum.
    set std_dev(1) [expr { $sqrt_2 * abs( $pessimistic - $most_likely ) } ]
    #    set variance(1) [expr { 2. * pow( $std_dev(1) , 2. ) } ]
    #    set precision(1) [expr { 1. / $std_dev(1) } ]
    #    set precision2(1) [expr { 1. / pow( $std_dev(1) , 2. ) } ]
    set precision(1) 1.
    set precision2(1) [expr { pow( $precision(1) , 2. ) } ]

    #    ns_log Notice "acc_fin::pert_omp_to_normal_dc.42: std_dev_left $std_dev(0) std_dev_right $std_dev(1)"
    # f(x) is the normal distribution function. x = 0 at $median
    
    # for each section of the curve divided into p_count() ie ($n_areas /2) sections of approximately equal area.
    # since each tail has working area of circa 0.5 (std*2 = 0.4772 actually), delta_area is circa 0.5 / p_count()
    # given 2 points on curve f(x) = y, (x0,y0), (x1,y1) defines an approximate area, where 
    # delta_area = 0.5 * ( y0 + y1 ) ( x1 - x0 )   and
    # delta_area = 0.5 / p_count

    # given x0,y0, n_areas,  if y1 is estimated as y0 - y_range / p_count
    # x1 is approx 1 / ( n_areas * ( y0 + y1) ) 
    # if y1 is approximated equal to y0
    # x1 is approx 1 / (n_areas * 2 * y0 )
    
    # f(x) = k * pow( $e , -0.5 * pow( $x - $median , 2. ) )
    # where k = 1. / sqrt( 2. * $pi )
    # where x  is -2. * std_dev_left to 2. * std_dev_right
    # and value at x is :
    # if x < 0
    # $minimum + sigma f( $x from -2. * $std_dev_left to x = 0 ) * p_count()
    # if x => 0
    # $median + sigma f( $x from x = 0 to 2. * $std_dev_right ) * p_count()
    
    # Determine x points. Start with 0 to get critical area near distribution peak.

    # if there is an odd number of areas, use the extra one on the longer side
    if { $std_dev(0) > $std_dev(1) } {
        set p_count(1) [expr { int( $n_areas / 2. ) } ]
        set p_count(0) [expr { $n_areas - $p_count(1) } ]
    } else {
        set p_count(0) [expr { int( $n_areas / 2. ) } ]
        set p_count(1) [expr { $n_areas - $p_count(0) } ]
    }
    
    # create tails and their analogs
    #   ns_log Notice "acc_fin::pert_omp_to_normal_dc.83: n_areas $n_areas p_count(0) $p_count(0) p_count(1) $p_count(1)"
    # from median to double standard deviation to approximate OMP calculations

    # left tail, assume symmetric, but calculate to reduce error
    set y_range_arr(0) [expr { ( $most_likely - $optimistic ) } ]
    set fx_limit(0) $optimistic
    # right tail, assume symmetric
    set y_range_arr(1) [expr { ( $pessimistic - $most_likely ) } ]
    set fx_limit(1) $pessimistic

    foreach ii [list 0 1] {
        set x_larr($ii) [list ]
        set y_larr($ii) [list ]
        set a_larr($ii) [list ]
        set da_larr($ii) [list ]
        set fx_larr($ii) [list ]
        # standard deviation = sigma

        # range of x over f(x) is -2. * std_dev_left to 2. * std_dev_right
        # let's break the areas somewhat equally, or to increase with each iteration
        # x2 can be approximated all sorts of ways. 
        # A linear progression is used.
        # An integration eq over a partial derivative might be more appropriate later.
        
        set a 0.
        set a_prev $a
        
        set x1 0.
        #        set y1 [expr { exp( -0.5 * pow( $x1 , 2. ) ) / $sqrt_2pi } ] 
        #        set y1 [expr { exp( -0.5 * pow( $x1 , 2. ) / $variance($ii) ) / ( $std_dev($ii) * $sqrt_2pi ) } ] 
        #        set y1 [expr { exp( -0.5 * pow( $x1 , 2. ) / $variance($ii) ) / $sqrt_2pi } ] 
        set y1 [f::max $eps [expr { $precision($ii) * exp( -0.5 * $precision2($ii) * pow( $x1 , 2. ) ) / $sqrt_2pi } ]]

        # estimate delta_x and a:
        set block_count [lindex [qaf_triangular_numbers [expr { $p_count($ii) - 0 } ]] end]
        set numerator 0

        #        ns_log Notice "acc_fin::pert_omp_to_normal_dc.90: ii $ii p_count($ii) $p_count($ii) block_count $block_count numerator $numerator std_dev($ii) $std_dev($ii)" 

        # first point in tail:
        set step_021 [f::max $eps [expr { $numerator / $block_count } ]]
        lappend y_larr($ii) $y1
        lappend x_larr($ii) $x1

        # Calculations are from x = 0 to x = std_dev
        # Therefore, left tail needs flipped afterward

        # At the end of the loop, calculate the last point manually.
        # ns_log Notice "acc_fin::pert_omp_to_normal_dc.99: i '' x1 '$x1' delta_x '' y2 '' y1 '$y1' f_x '' numerator $numerator step_021 $step_021"
        for {set i 0 } { $i < $p_count($ii) } { incr i } {
            set numerator [expr { $numerator + 1. } ]

            set step_021 [expr { $numerator / $block_count + $step_021 } ]            
            set x2 [f::max $eps [expr { $std_dev($ii) * $step_021 } ]]
            set delta_x [f::max $eps [expr { $x2 - $x1 } ]]
            # Calculate y2 = f(x) = using the normal probability density function
            #            set y2 [expr { exp( -0.5 * pow( $x2 , 2. ) ) / $sqrt_2pi } ] 
            #            set y2 [expr { exp( -0.5 * pow( $x2 , 2. ) / $variance($ii) ) / ( $std_dev($ii) * $sqrt_2pi ) } ] 
            #            set y2 [expr { exp( -0.5 * pow( $x2 , 2. ) / $variance($ii) ) / $sqrt_2pi } ] 
            set y2 [f::max $eps [expr { $precision($ii) * exp( -0.5 * $precision2($ii) * pow( $x2 , 2. ) ) / $sqrt_2pi } ]]

            # Calculate area under normal distribution curve.
            set a [f::min $largest_a [expr { $a + $delta_x * ( $y2 + $y1 ) / 2. } ]]
            set delta_a [f::max $eps [expr { $a - $a_prev } ]]

            if { $ii } {
                # Right tail
                set f_x [expr { $most_likely + $y_range_arr(1) * $step_021 } ]
            } else {
                # Left tail
                set f_x [expr { $most_likely - $y_range_arr(0) * $step_021 } ]
            }
            # ns_log Notice "acc_fin::pert_omp_to_normal_dc.100: i $i x2 '$x2' x1 '$x1' delta_x '$delta_x' y2 '$y2' y1 '$y1' f_x '$f_x' numerator $numerator step_021 $step_021 a $a delta_a $delta_a"
            lappend x_larr($ii) $x2
            lappend y_larr($ii) $y2
            lappend a_larr($ii) $a
            lappend da_larr($ii) $delta_a
            lappend fx_larr($ii) $f_x
            set y1 $y2
            set x1 $x2
            set a_prev $a

        }
        # Test area under normal distribution curve.
        set a_arr($ii) [f::sum $da_larr($ii)]

    }

    # ns_log Notice "acc_fin::pert_omp_to_normal_dc.116: a_arr(0) $a_arr(0) a_arr(1) $a_arr(1)"
    # tail areas must be equal.
    if { $a_arr(1) != $a_arr(0) } {
        ns_log Notice "acc_fin::pert_omp_to_normal_dc.118: a_arr(0) of $a_arr(0) != a_arr(1) $a_arr(1)"
    }

    # build final curve

    # column titles
    set curve_lists [list ]
    if { $labels_p } {
        lappend curve_lists [list y x label]
    } else {
        lappend curve_lists [list y x]
    }
    # left tail, reverse order
    #### Here a point is subtracted, apparently because the last area is empty.. why??
    # p_count() is point length. minus 1 to count from 0 to one less than p_count
    set i_count [expr { $p_count(0) - 1 } ]
    set label "optimistic / minimum"
    for {set i $i_count} { $i > -1 } {incr i -1} {
        set f_x [lindex $fx_larr(0) $i]

        # Adjust for cases where x is too close to 0 to be fully recognized as nonzero by the system ie $eps.
        set delta_a [f::max $eps [lindex $da_larr(0) $i]]
        #        set a [expr { $a + $delta_a } ]

        set a [lindex $a_larr(0) $i]
        #       ns_log Notice "acc_fin::pert_omp_to_normal_dc.234: i '$i' delta_a '$delta_a' a '$a' f_x '$f_x'"

        set point_list [list $f_x $delta_a]
        if { $labels_p } {
            lappend point_list $label
            set label ""
        }
        lappend curve_lists $point_list
    }
    # last item this tail
    # mark index of this last point, because we will be modifying it 
    set median_range_idx [llength $curve_lists]
    incr median_range_idx -1

    # right tail, append
    # ref 1

    set i_next2last [expr { $p_count(1) - 2 } ]
    for {set i 0} { $i < $p_count(1) } {incr i } {
        set f_x [lindex $fx_larr(1) $i]

        # Adjust for cases where x is too close to 0 to be fully recognized as nonzero by the system ie $eps.
        set delta_a [f::max $eps [lindex $da_larr(1) $i]]
        #        set a [expr { $a + $delta_a } ]
        set a [lindex $a_larr(1) $i]
        #       ns_log Notice "acc_fin::pert_omp_to_normal_dc.243: i '$i' delta_a '$delta_a' a '$a' f_x '$f_x'"
        set point_list [list $f_x $delta_a]
        if { $labels_p } {
            lappend point_list $label
            if { $i == $i_next2last } {
                set label "pessimistic / maximum"
            } else {
                set label ""
            }
        }
        lappend curve_lists $point_list
    }

    # combine the tails at x = 0
    # a0 is median area
    #set a0 [expr { [lindex $a_larr(0) 0] + [lindex $a_larr(1) 0] } ]
    # combining these areas reduces curve area count by one too many. 
    set a0 [lindex $a_larr(0) 0]
    set a1 [lindex $a_larr(1) 0]
    # a_curve is area under curve
    set a_curve [expr { $a_arr(0) + $a_arr(1) } ]

    # Instead of adding the extra area from prior calculations,
    # create a more balanced a0 so area under each tail is as close as possible to 0.5
    # a0_test is guess at best, new a0. ie 1 - area_under_curve (ideally 1) + a0
    # this way, if 1 - a_curve  is greater than 0, the extra is added to a0
    set a0_test [expr { 1. - $a_curve + $a0 } ]
    if { $a0_test > 0. } {
        # straightforward adjustment
        set a_new $a0_test

    } else {
        # $a0_test is negative, apparently because a_curve > 1
        # Renormalize a0 to compensate and keep a0 in meridian area:
        # Determine which tail is larger..
        if { $a0 > $a1 } {
            set a_new [expr { $a0 - $a1 + $eps } ]
        } else {
            set a_new [expr { $a1 - $a0 + $eps } ]
        }

    }
    set median_list [list $most_likely $a_new]
    if { $labels_p } {
        lappend median_list "most likely / median"
    }
    #    set median_end_idx [expr { $median_range_idx } ]
    #    ns_log Notice "acc_fin::pert_omp_to_normal_dc.351: a0 $a0 a_curve $a_curve a0_test $a0_test a_new $a_new median_range_idx $median_range_idx median_end_idx $median_end_idx"
    #    set curve_lists [lreplace $curve_lists $median_range_idx $median_end_idx $median_list]
    # extra point has already been removed,
    set curve_lists [lreplace $curve_lists $median_range_idx $median_range_idx $median_list]


    # 
    #set f_x [lindex $fx_larr(1) $i]
    #    set f_x $pessimistic
    #    set delta_a [lindex $da_larr(1) $i_count]
    #    set a [expr { $a + $delta_a } ]
    #    ns_log Notice "acc_fin::pert_omp_to_normal_dc.246: i '$i' delta_a '$delta_a' a '$a' f_x '$f_x'"
    #    set point_list [list $f_x $delta_a]
    #    lappend curve_lists $point_list

    # remove header for point count
    # but add a point because each item is an area, and there are area_count + 1 points
    set points_count [expr { [llength $curve_lists] - 1 } ]
    if { $points_count != $n_areas } {
        ns_log Warning "acc_fin::pert_omp_to_normal_dc.288: curve has $points_count areas instead of requested $n_areas areas (add one for points ie area boundaries). curve_lists $curve_lists"
    } else {
        #      ns_log Notice "acc_fin::pert_omp_to_normal_dc.289: curve_lists $curve_lists"
    }
    return $curve_lists
}


ad_proc -public acc_fin::pretti_geom_avg_of_curve {
    curve_lol
    {correction "0"}
} {
    Given a curve with x and y columns, finds the geometric average determined by: (y1*x1 + y2*x2 .. yN*xN ) / sum(x1..xN). Correction is a value, usually -1, or +1 applied to a formula to adjust bias in a sample population as in N/(N - 1) or N/(N + 1).  n - 1 is sometimes referred to a Bessel's correction. Default is no correction. More about Bessel's correction at: http://en.wikipedia.org/wiki/Bessel%27s_correction
} {
    # This is a generalization of the PERT Time-expected function
    set constants_list [list y x]
    # get first row of titles
    set title_list [lindex $curve_lol 0]
    set y_idx [lsearch -exact $title_list "y"]
    set x_idx [lsearch -exact $title_list "x"]
    set geometric_avg ""
    if { $y_idx > -1 && $x_idx > -1 } {
        set x_list [list ]
        set numerator_list [list ]
        foreach point_list [lrange $curve_lol 1 end] {
            set x [lindex $point_list $x_idx]
            set y [lindex $point_list $y_idx]
            lappend x_list $x
            lappend  numerator_list [expr { $x * $y * 1. } ]
        }
        set x_sum [f::sum $x_list ]
        if { $x_sum != 0. } {
            set numerator [f::sum $numerator_list ]
            set geometric_avg [expr { $numerator / $x_sum } ]
            set n [expr { [llength $x_list] * 1. } ]
            set n_corr [expr { $n + $correction } ]
            if { $correction ne "0" && $n_corr != 0. } {
                ns_log Notice "acc_fin::pretti_geom_avg_of_curve.383: geometric_avg $geometric_avg"
                set geometric_avg [expr { $geometric_avg * $n / $n_corr } ]
                ns_log Notice "acc_fin::pretti_geom_avg_of_curve.385: new geometric_avg $geometric_avg"
            }
        } else {
            ns_log Notice "acc_fin::pretti_geom_avg_of_curve.170: divide by zero caught for x_sum. numerator $numerator"
        }
    } else {
        ns_log Notice "acc_fin::pretti_geom_avg_of_curve.178: y_idx $y_idx x_idx $x_idx"
    }

    return $geometric_avg
}


ad_proc -public acc_fin::pretti_type_flag {
    table_lists
} {
    Guesses which type of pretti table
} {
    #upvar $table_lists_name table_lists
    # page flags as pretti_types:
    #  p in positon 1 = PRETTI app specific
    #  p1  scenario
    #  p2  task network (unique tasks and their dependencies)
    #  p3  task types (can also have dependencies)
    #  dc distribution curve
    #  p4  PRETTI report (output)
    #  p5  PRETTI db report (output) (similar format to  p3, where each row represents a path, but in p5 all paths are represented)
    #  dc Estimated project duration distribution curve (can be used to create other projects)

    # get first row
    set title_list [lindex $table_lists 0]
    set type_return ""
    # check for type p1 separate from the other cases, because the table is specified differently from other cases.
    set p(p1) 0
    set name_idx [lsearch -exact $title_list "name" ]
    set value_idx [lsearch -exact $title_list "value" ]
    #    ns_log Notice "acc_fin::pretti_columns_list.390 name_idx $name_idx value_idx $value_idx title_list '$title_list'"
    if { $name_idx > -1 && $value_idx > -1 } {
        # get name column
        set name_list [list ]
        #        ns_log Notice "acc_fin::pretti_columns_list.400 table_lists '$table_lists'"
        foreach row [lrange $table_lists 1 end] {
            lappend name_list [lindex $row $name_idx]
        }
        #        ns_log Notice "acc_fin::pretti_columns_list.401 name_list '$name_list'"
        # check name_list against p1 required names. 
        # All required names need to be in list, but not all list names are required.
        set p(p1) 1
        # required names in check_list
        # p1 is special because it requires either activity_table_tid *or* activity_table_name
        #set check_list [acc_fin::pretti_columns_list "p1" 1 ]
        #        ns_log Notice "acc_fin::pretti_columns_list.402 check_list $check_list"
        # foreach check $check_list {
        #    if { [lsearch -exact $name_list $check] < 0 } {
        #        set p(p1) 0
        #    }
            #            ns_log Notice "acc_fin::pretti_columns_list.404 check $check p(p1) $p(p1)"
        #}
        set name_idx [lsearch -exact $name_list activity_table_name]
        set tid_idx [lsearch -exact $name_list activity_table_tid]
        if { $name_idx < 0 && $tid_idx < 0 } {
            set p(p1) 0
        }
    }
    if { $p(p1) } {
        set type_return "p1"
        #        ns_log Notice "acc_fin::pretti_columns_list.410 type = p1"
    } else {
        # filter other p table types by required minimums first
        set type_list [list "p2" "p3" "p4" "p5" "dc"]
        #        ns_log Notice "acc_fin::pretti_columns_list.414 type not p1. check for $type_list"
        foreach type $type_list {
            set p($type) 1
            set check_list [acc_fin::pretti_columns_list $type 1]
            #            ns_log Notice "acc_fin::pretti_type_flag.58: type $type check_list $check_list"
            foreach check $check_list {
                if { [lsearch -exact $title_list $check] < 0 } {
                    set p($type) 0
                }
                #                ns_log Notice "acc_fin::pretti_type_flag.60: check $check p($type) $p($type)"
            }
        }
        
        # how many types might this table be?
        set type1_p_list [list ]
        foreach type $type_list {
            if { $p($type) } {
                lappend type1_p_list $type
            }
        }
        #        ns_log Notice "acc_fin::pretti_type_flag.69: type1_p_list '${type1_p_list}'"
        set type_count [llength $type1_p_list]
        if { $type_count > 1 } {
            # choose one
            if { $p(p2) && $p(p3) && $type_count == 2 } {
                if { [lsearch -exact $title_list "aid_type" ] > -1 } {
                    set type_return "p2"
                } elseif { [lsearch -exact $title_list "type" ] > -1 } {
                    set type_return "p3"
                } 
            } else {
                set type3_list [list ]
                # Which type best meets full list of implemented column names?
                foreach type $type1_p_list {
                    set name_list [acc_fin::pretti_columns_list $type 0]
                    set name_list_count [llength $name_list]
                    set exists_count 0
                    foreach name $name_list {
                        if { [lsearch -exact $title_list $name] > -1 } {
                            incr exists_count
                        }
                    }
                    if { $name_list_count > 0 } {
                        set type_pct_list [list $type [expr { ( $exists_count * 1. ) / ( $name_list_count * 1. ) } ] ]
                        lappend type3_list $type_pct_list
                    } 
                }
                set type3_list [lsort -real -index 1 -decreasing $type3_list]
                #                ns_log Notice "acc_fin::pretti_type_flag.450: type1_p_list '${type1_p_list}'"
                #                ns_log Notice "acc_fin::pretti_type_flag.453: type3_list '$type3_list'"
                set type_return [lindex [lindex $type3_list 0] 0]
            }
        } else {
            # append is used here in case no type meets the criteria, an empty string is returned
            append type_return [lindex $type1_p_list 0]
        }
    }
    
    return $type_return
}

ad_proc -private acc_fin::pretti_columns_list {
    type
    {required_only_p "0"}
} {
    Returns a list of column names used by pretti table type. If required_only_p is 1, only returns the required columns for specified type. Reserved words are not included in the list.
} {
    set sref $type
    append sref $required_only_p
    switch -exact $sref {
        p10 {
            # p1 PRETTI Scenario
            # consists of a "name" and "value" column, with names of:
            #      activity_table_tid
            #      activity_table_name      name of table containing task network
            #      period_unit          measure of time used in task duration etc.
            #      time_dist_curve_name      a default distribution curve name when a task type doesn't reference one.
            #      time_dist_curve_tid      a default distribution curve table_id, dist_curve_name overrides dist_curve_dtid
            #      cost_dist_curve_name      a default distribution curve name when a task type doesn't reference one.
            #      cost_dist_curve_tid      a default distribution curve table_id, dist_curve_name overrides dist_curve_dtid
            #      with_factors_p  defaults to 1 (true). Set to 0 (false) if any factors in p3 are to be ignored.
            #                           This option is useful to intercede in auto factor expansion to add additional
            #                           variation in repeating task detail. (deprecated by auto expansion of nonexisting coefficients).
            #      time_probability_moment A percentage (0..1) along the (cumulative) distribution curve. defaults to 0.5
            #      cost_probability_moment A percentage (0..1) along the (cumulative) distribution curve. defaults to "", which defaults to same as time_probability_moment
            #set ret_list \[list name value\]
            set ret_list [list activity_table_tid activity_table_name task_types_tid task_types_name time_dist_curve_name time_dist_curve_tid cost_dist_curve_name cost_dist_curve_tid time_est_short time_est_median time_est_long time_probability_moment cost_est_low cost_est_median cost_est_high cost_probability_moment db_format index_equation precision tprecision cprecision eprecision pert_omp max_concurrent max_discount_pct max_run_time max_tasks_per_run max_overlap_pct eco2_high eco2_low eco2_median eco2_dist_curve_tid eco2_dist_curve_name]
        }
        p11 {
            #set ret_list \[list name value\]
            set ret_list [list activity_table_tid ]
        }
        p20 {
            # p2 Task Network
            #      activity_ref           reference for an activity, a unique task id, using "activity" to differentiate between table_id's tid 
            #                             An activity reference is essential a function as in f() with no attributes,
            #                             However, there is room to grow this by extending a function to include explicitly set paramemters
            #                             within the function, similar to how app-model handles functions aka vectors
            #                             The multiple of an activity is respresented by a whole number followed by an "*" 
            #                             with no spaces between (when spaces are used as an activity delimiter), or
            #                             with spaces allowed (when commas or another character is used as an activity delimiter.)
            #                
            #      aid_type               activity type from p3
            #      dependent_tasks        direct predecessors , activity_ref of activiites this activity depends on.
            #      name                   defaults to type's name (if exists else blank)
            #      description            defaults to type's description (if exists else blank)
            #      max_concurrent         defaults to type's max_concurrent 
            #      max_run_time           defaults to type's max_run_time or if blank (unlimited run time)
            #      max_tasks_per_run      defaults to types' max_tasks_per_run or if blank (unlimited tasks per run)
            #      max_overlap_pct        defaults to type's max_overlap_pct021
            
            #      time_est_short         estimated shortest duration. (Lowest statistical deviation value)
            #      time_est_median        estimated median duration. (Statistically, half of deviations are more or less than this.) 
            #      time_est_long          esimated longest duration. (Highest statistical deviation value.)
            #      time_actual            the acutal duration (time) once complete.
            #      time_dist_curve_tid Use this distribution curve instead of the time_est short, median and long values
            #                             Consider using a variation of task_type as a reference
            #      time_dist_curv_eq  Use this distribution curve equation instead.
            
            #      cost_est_low           estimated lowest cost. (Lowest statistical deviation value.)
            #      cost_est_median        estimated median cost. (Statistically, half of deviations are more or less than this.)
            #      cost_est_high          esimage highest cost. (Highest statistical deviation value.)
            #      cost_actual            the actual cost once complete.
            #      cost_dist_curve_tid Use this distribution curve instead of equation and value defaults
            #      cost_dist_curv_eq  Use this distribution curve equation. 
            #
            #      RESERVED columns:
            #      _tCurveRef             integer reference to time curve in time_clarr and   time duration estimate at time_probability_moment in t_est_arr
            #      _cCurveRef             integer reference to cost curve in cost_clarr and   cost duration estimate at cost_probability_moment in c_est_arr
            #      _coef                  integer coefficient for use with calculations that require remembering the coefficient when multiple of an activity is referenced.
            #      _tDcSource             source of time curve used from acc_fin::curve_import
            #      _cDcSource             source of cost curve used from acc_fin::curve_import

            # eco2_* uses cost_probability_moment
            set ret_list [list activity_ref dependent_tasks aid_type name description max_concurrent max_discount_pct max_run_time max_tasks_per_run max_overlap_pct time_est_short time_est_median time_est_long time_dist_curve_tid time_dist_curve_name time_probability_moment cost_est_low cost_est_median cost_est_high cost_dist_curve_tid cost_dist_curve_name cost_probability_moment time_actual cost_actual eco2_actual eco2_low eco2_high eco2_median eco2_dist_curve_tid eco2_dist_curve_name]

        }
        p21 {
            set ret_list [list activity_ref dependent_tasks]
        }
        p30 {
            # p3 Task Types:   
            #      type
            #      dependent_types      Other dependent types required by this type. (possible reference collisions. type_refs != activity_refs.)
            #
            #####                       dependent_types should be checked against activity_dependents' types 
            #                           to confirm that all dependencies are satisified.
            #      name
            #      description
            #      max_concurrent       (as a positive integer, blank = no limit)
            #      max_run_time         (decimal, blank = no limit)
            #      max_tasks_per_run    (as a positive integer, or blank = no limit)
            #      max_overlap_pct021  (as a percentage from 0 to 1, blank = 1)
            #
            #      RESERVED columns:
            #      _tCurveRef             integer reference to time curve in time_clarr and   time duration estimate at time_probability_moment in t_est_arr
            #      _cCurveRef             integer reference to cost curve in cost_clarr and   cost duration estimate at cost_probability_moment in c_est_arr
            #      _tDcSource             source of time curve used from acc_fin::curve_import
            #      _cDcSource             source of cost curve used from acc_fin::curve_import

            set ret_list [list type dependent_tasks dependent_types name description max_concurrent max_discount_pct max_run_time max_tasks_per_run max_overlap_pct time_dist_curve_name time_dist_curve_tid cost_dist_curve_name cost_dist_curve_tid time_est_short time_est_median time_est_long cost_est_low cost_est_median cost_est_high eco2_low eco2_high eco2_median eco2_dist_curve_tid eco2_dist_curve_name]
        }
        p31 {
            set ret_list [list type]
            # if changing p3 or p2 lists, see also constants_woc_list in this file.
        }
        p40 {
            # each column is path_{number} and generated by code so not used in this context

            # p4 Display modes
            #  
            #  tracks within n% of CP duration, n represented as %12100 or a duration of time as total lead slack
            #  tracks w/ n fixed count closest to CP duration. A n=1 shows CP track only.
            #  tracks that contain at least 1 CP track 
            set ret_list [list path_1]
        }
        p41 {
            # each column is path_{number} and generated by code so not used in this context
            set ret_list [list path_1]
        }
        p50 {
            # each row is a cell (ie activity on a path), in format of detailed PRETTI internal output. See code. 
            #set ret_list [list activity_ref path_act_counter path_counter dependencies_q cp_q significant_q popularity waypoint_duration activity_time direct_dependencies activity_cost waypoint_cost]
            set ret_list [list activity_ref activity_counter dependencies_q direct_dependencies dependencies_count count_on_cp_p on_a_sig_path_p act_freq_in_load_cp_alts popularity activity_time waypoint_duration t_dc_source activity_cost waypoint_cost c_dc_source activity_eco2 waypoint_eco2 e_dc_source act_coef max_concurrent max_run_time max_tasks_per_run max_overlap_pct max_discount_pct max_path_duration]
        }
        p51 {
            # each row is a cell (ie activity on a path), in format of detailed PRETTI internal output. See code. 
            # p5 was:
            #set ret_list [list activity_ref path_act_counter path_counter dependencies_q cp_q significant_q popularity waypoint_duration activity_time direct_dependencies activity_cost waypoint_cost path_col activity_seq dependents_count dep_act_seq ]
            set ret_list [list activity_ref activity_counter dependencies_q direct_dependencies dependencies_count count_on_cp_p on_a_sig_path_p act_freq_in_load_cp_alts popularity activity_time waypoint_duration t_dc_source activity_cost waypoint_cost c_dc_source activity_eco2 waypoint_eco2 e_dc_source act_coef max_concurrent max_run_time max_tasks_per_run max_overlap_pct max_discount_pct max_path_duration]
        }
        p60 {
            # each row is a path, in format of detailed PRETTI internal output. See code. All columns are required to reproduce output to p4 (including p4 comments).
            set ret_list [list path_idx path path_counter cp_q significant_q path_duration path_cost path_eco2 index_custom]
        }
        p61 {
            # each row is a path, in format of detailed PRETTI internal output. See code. All columns are required to reproduce output to p4 (including p4 comments).
            set ret_list [list path_idx path path_counter cp_q significant_q path_duration path_cost path_eco2 index_custom]
        }

        dc0 {
            # dc2 distribution curve table
            #                   Y         where Y = f(x) and f(x) is a 
            #                             probability mass function ie probability density function as a distribution
            #                             http://en.wikipedia.org/wiki/Probability_mass_function
            #                             http://en.wikipedia.org/wiki/Probability_density_function
            #                         aka http://en.wikipedia.org/wiki/Discrete_probability_distribution#Discrete_probability_distribution
            #                             The discrete values are the values of Y included in the table
            
            #                    X        Where X = the probability of Y.
            #                             These can be counts of a sample or a frequency.  When the table is saved,
            #                             the total area under the distribution is normalized to 1.
            
            #                   label     Where label represents the value of Y at x. This is a short phrase or reference
            #                             that identifies a boundary point in the distribution.
            # A three point (short/median/long or low/median/high) estimation curve can be respresented as
            # a discrete set of six points:  minimum median median median median maximum 
            # of standard bell curve probabilities (outliers + standard deviation).
            # Thereby allowing *_probability_moment variable to be used in estimates with lower statistical resolution.
            set ret_list [list y x label]
        }
        dc1 {
            set ret_list [list y x]
        }
        default {
            ns_log Notice "acc_fin::pretti_columns_list (242): bad reference sref '$sref'. Returning blank list."
            set ret_list [list ]
        }
    }
    return $ret_list
}


ad_proc -public acc_fin::pretti_table_to_html {
    pretti_lol
    comments
} {
    Interprets a saved p4 pretti output table into html table.
} {
    # process table by building columns in row per html TABLE TR TD tags
    # pretti_lol consists of first row:
    # path_1 path_2 path_3 ... path_N
    # subsequent rows:
    # cell_r1c1 cell_r1c2 cell_r1c3 ... cellr1cN
    # ...
    # cell_rMc1 cell_rMc2 cell_rMc3 ... cellrMcN
    # for N tracks of a maximum of M rows.
    # Each cell is an activity.
    # Each column is a track
    # Path_1 is CP

    # empty cells have empty string value.
    # other cells will contain comment format from acc_fin::scenario_prettify
    # "$activity "
    # "t:[lindex $path_list 7] "
    # "ts:[lindex $path_list 6] "
    # "c:[lindex $path_list 9] "
    # "cs:[lindex $path_list 10] "
    # "d:($depnc_larr(${activity})) "
    # "<!-- [lindex $path_list 4] [lindex $path_list 5] --> "

    set column_count [llength [lindex $pretti_lol 0]]
    set row_count [llength $pretti_lol]
    incr row_count -1
    set success_p 1

    # values to be extracted from comments:
    # max_act_count_per_track and cp_duration_at_pm 
    # Other parameters could be added to comments for changing color scheme/bias
    set color_sig_mask_idx ""
    regexp -- {[^a-z\_]?color_sig_mask_idx[\ \=\:]([0-7])[^0-7]} $comments scratch color_sig_mask_idx
    if { [ad_var_type_check_number_p $color_sig_mask_idx] && $color_sig_mask_idx > -1 && $color_sig_mask_idx < 8 } {
        # do nothing
    } else {
        # set default
        set color_sig_mask_idx 5
    }

    set color_cp_mask_idx ""
    regexp -- {[^a-z\_]?color_cp_mask_idx[\ \=\:]([0-7])[^0-7]} $comments scratch color_cp_mask_idx
    if { [ad_var_type_check_number_p $color_cp_mask_idx] && $color_cp_mask_idx > -1 && $color_cp_mask_idx < 8 } {
        # do nothing
    } else {
        # set default
        set color_cp_mask_idx 3
    }

    set colorswap_p ""
    regexp -- {[^a-z\_]?colorswap_p[\ \=\:]([0-1])[^0-1]} $comments scratch colorswap_p
    if { [ad_var_type_check_number_p $colorswap_p] && $colorswap_p > -1 && $colorswap_p < 2 } {
        # do nothing
    } else {
        # set default
        set colorswap_p 0
    }

    #ns_log Notice "acc_fin::pretti_table_to_html.836: color_sig_mask_idx $color_sig_mask_idx color_cp_mask_idx $color_cp_mask_idx colorswap_p $colorswap_p"
    set max_act_count_per_track $column_count
    # max_act_count_per_track is the max count of an activity on all paths ie. answers q: What is the maximum count of an activity on this table?
    regexp -- {[^a-z\_]?max_act_count_per_track[\ \=\:]([0-9]+)[^0-9]} $comments scratch max_act_count_per_track
    if { $max_act_count_per_track == 0 } {
        set max_act_count_per_track $column_count
    }

    regexp -- {[^a-z\_]?cp_duration_at_pm[\ \=\:]([0-9]+)[^0-9]} $comments scratch cp_duration_at_pm
    if { $cp_duration_at_pm == 0 } {
        # Calculate cp_duration_at_pm manually, using path_1 (cp track)
        foreach row [lrange $pretti_lol 1 end] {
            set cell [lindex $row 0]
            if { $cell ne "" } {
                regexp -- {ts:([0-9\.]+)[^0-9]} $cell scratch test_num
            }
        }
        if { [ad_var_type_check_number_p $test_num] && $test_num > 0 } {
            set cp_duration_at_pm $test_num
        }
    }

    #ns_log Notice "acc_fin::pretti_table_to_html.857: cp_duration_at_pm $cp_duration_at_pm max_act_count_per_track $max_act_count_per_track column_count $column_count row_count $row_count"
    # determine list of CP activities
    set cp_list [list ]
    foreach row [lrange $pretti_lol 1 end] {
        set cell [lindex $row 0]
        if { $cell ne "" } {
            # activity is not Title of activity, but activity_ref
            set first_space [string first " " $cell]
            incr first_space -1
            set activity [string trim [string range $cell 0 $first_space]]
            if { $first_space > -1 } {
                # added letter to nulify any octal issues
                lappend cp_list "z$activity"
            }
        }
    }
    if { [llength $cp_list] == 0 } {
        ns_log Warning "acc_fin::pretti_table_to_html.868: cp_list is blank. Not a valid p4 table, or regexp needs revising."
    }
    # Coloring and formatting will be interpreted 
    # based on values provided in comments, 
    # data from path_1 and table type (p4) for maximum flexibility.   
    
    # table cells need to indicate a relative time length in addition to dependency. check
    
    set title_formatting_list [list ]
    foreach title [lindex $pretti_lol 0] {
        lappend title_formatting_list [list style "font-style: bold;"]
    }
    set table_attribute_list [list ]
    set table_formatting_list [list ]
    lappend table_formatting_list $title_formatting_list
    
    # build formatting colors

    set hex_list [list 0 1 2 3 4 5 6 7 8 9 a b c d e f]
    set bin_list [list 000 100 010 110 001 101 011 111]
    
    set color_cp_mask [lindex $bin_list $color_cp_mask_idx]
    set color_cp_mask_list [split $color_cp_mask ""]
    set color_sig_mask [lindex $bin_list $color_sig_mask_idx]
    set color_sig_mask_list [split $color_sig_mask ""]

    set k1 [expr { $row_count / $cp_duration_at_pm } ]
    set k2 [expr {  7. / $max_act_count_per_track } ]
    ns_log Notice "acc_fin::pretti_table_to_html.845: k1 $k1 k2 $k2 color_sig_mask_list '${color_sig_mask_list}' color_cp_mask_list '${color_cp_mask_list}'"
    # add title column
    set row4html_list [list ]
    set row_formatting_list [list ]
    set pretti4html_lol [lrange $pretti_lol 0 0]
    set title_formatting ""
    foreach title_cell [lrange $pretti_lol 0 0] {
        lappend row_formatting_list $title_formatting
    }
    lappend table_formatting_lists $row_formatting_list
    #  red f00, green 0f0,   blue 00f
    # cyan 0ff,  pink f0f, yellow ff0

    # CP in highest contrast (yellow ff9) for the column: ff9 ee9 ff9 ee9 ff9
    # CP-alt means on_a_sig_path_p
    # CP-alt in alternating lt magenta to lt green: 99f .. 9f9 of lowering contrast to f77
    # others in alternating medium blue/green: 66f  .. 6f6 or pink/green f6f .. 66f 
    # contrast decreases on up to 50%
    # f becomes e for even rows..
    
    # to build cell color:
    # contrast_adj
    # color_mask_idx
    # 
    # c(0) is other
    # c(1) is primary
    
    # cell_nbr eq 0  is CP
    
    #set on_a_sig_path_p [expr { $on_a_sig_path_p || $on_cp_p } ]
    # 15 - 1 (leave 1 for contrast adjustment)
    #regexp -- {^([^\ ]+) t:} $cell scratch activity 
    
    # significant, base color pink f0f
    # see color_sig_mask
    # set color1 and color2 based on activity count, blue lots of count, green is less count
    # max $popularity is column_count
    # create 2 values to be used with masks, 1 is most significant, 0 less significant
    
    # other, base color green 0f0
    # see color_oth_mask
    
    # constrast_step is number from 1 to 7, with 7 being most popular, 1 least popular
    # create 2 values to be used with masks, 1 is most sig, 0 less significant
    set row_nbr 1
    foreach row_list [lrange $pretti_lol 1 end] {
        set row4html_list [list ]
        set row_formatting_list [list ]
        set odd_row_p [expr { ( $row_nbr / 2. ) != int( $row_nbr / 2 ) } ]

        set cell_nbr 1
        foreach cell $row_list {
            #set activity ""
            if { $cell ne "" } {
                set activity_time_expected ""
                set on_a_sig_path_p 0
                set popularity 0

                set row_size 1
                set first_space [string first " " $cell]
                incr first_space -1
                set activity [string range $cell 0 $first_space]
                if { $activity eq "" } {
                    ns_log Warning "acc_fin::pretti_table_to_html.916: activity '$activity' cell '$cell' bad code. activity not extracted."
                }

                set act_on_cp_p [expr { [lsearch -exact -ascii $cp_list "z$activity" ] > -1 } ]
                if { $cell_nbr == 1 || $act_on_cp_p } {
                    set on_cp_p 1
                } else {
                    set on_cp_p 0
                }
                
                if { [regexp -- {t:([0-9\.]+)[^0-9]} $cell scratch activity_time_expected ] } {
                    set row_size [f::max [expr { int( $activity_time_expected * $k1 ) } ] 1 ]
                } 

                # set on_a_sig_path_p and popularity
                if { ![regexp -- {<!--[^0-9]([0-9\.]+)[^0-9]([0-9\.]+)[^0-9]([0-9\.]+)[^0-9]-->} $cell scratch on_a_sig_path_p popularity path_duration] } {
                    ns_log Notice "acc_fin::pretti_table_to_html.928: regexp broken for row $row_nbr column $cell_nbr $row_cell cell '$cell'"
                } 
                
                set colorhex [acc_fin::pretti_color_chooser $on_cp_p $on_a_sig_path_p $odd_row_p $popularity $max_act_count_per_track $cp_duration_at_pm $path_duration]

            } else {
                set cell "&nbsp;"
                # pass on_cp_p as -1 when cell is inactive
                set colorhex [acc_fin::pretti_color_chooser -1 $on_a_sig_path_p $odd_row_p $popularity $max_act_count_per_track $cp_duration_at_pm $path_duration]
            }
            #append cell "row $row_nbr col $cell_nbr on_cp $on_cp_p on_sig $on_a_sig_path_p act_on_cp_p $act_on_cp_p <br>"
            set greycol [acc_fin::gray_from_color $colorhex]
            if { [string range $greycol 0 0] < 6 } {
                set reverse_color_css " color: #ffffff;"
            } else {
                set reverse_color_css ""
            }
            set cell_formatting [list style "vertical-align: top; background-color: #${colorhex};${reverse_color_css}"]
 
            lappend row4html_list $cell
            lappend row_formatting_list $cell_formatting
            incr cell_nbr
        }
        lappend pretti4html_lol $row4html_list
        lappend table_formatting_lists $row_formatting_list

        incr row_nbr
    }
    
    # html
    set pretti_html "<h3>Computation report</h3>"
    append pretti_html [qss_list_of_lists_to_html_table $pretti4html_lol $table_attribute_list $table_formatting_lists]
    return $pretti_html
}


ad_proc -public acc_fin::larr_set {
    larr_name
    data_list
} {
    Assigns a data_list to an index in array larr_name 
    in a manner that minimizes memory footprint. 
    If the list already exists (exactly) in the array, 
    it returns the existing index, 
    otherwise it assignes a new index in array and 
    a new index of array is returned. 
    This procedure helps reduce memory overhead 
    for indexes with lots of list data.
} {
    upvar 1 ${larr_name} larr
    # If memory issues exist even after using this proc, one can further compress the array by applying a dictionary storage technique.
    # It may be possible to use the list as an index and gain from tcl internal handling for example.
    # hmm. Initial tests suggest this array(list) works, but might not be practical to store references..
    set indexes_list [array names larr]
    set icount [llength $indexes_list]
    # ns_log Notice "acc_fin::larr_ste.945: larr_name $larr_name indexes_list '$indexes_list' icount '$icount'"
    if { $icount > 0 } {
        # larr already has names. Check against existing names
        set i 0
        set index [lindex $indexes_list $i]
        set larr_ne_data_p 0
        # ns_log Notice "acc_fin::larr_ste.949: index '$index' i $i"
	    if { $larr($index) ne $data_list } {
            set larr_ne_data_p 1
	    }

	    while { $larr_ne_data_p } {
            incr i
            set index [lindex $indexes_list $i]
            # ns_log Notice "acc_fin::larr_ste.953: index '$index' i $i"
            set larr_ne_data_p 0
            if { $index ne "" } {
                if { $larr($index) ne $data_list } {
                    set larr_ne_data_p 1
                }
            }
	    }
        # ended because i == icount (ie out of range) or !larr_ne_data_p
        # ns_log Notice "acc_fin::larr_ste.955: index '$index' i $i"
        if { $index eq "" } {
            set index $icount
            set larr($icount) $data_list
        }
        # otherwise !larr_ne_data_p, so use index as return list
    } else {
        set index $icount
        set larr($icount) $data_list
    }
    if { [llength $data_list] == 0 } { 
        ns_log Warning "acc_fin::larr_set.956: empty data_list request in larr ${larr_name}."
    }
    #    ns_log Notice "acc_fin::larr_set.958: ${larr_name}\(${i}\) '$larr($i)' data_list '${data_list}'"
    return $index
}

ad_proc -private acc_fin::p_load_tid {
    constants_list
    constants_required_list
    p_larr_name
    tid
    {p3_larr_name ""}
    {instance_id ""}
    {user_id ""}
} {
    loads array_name with p2 or p3 style table for use with internal code
} {
    upvar 1 $p_larr_name p_larr
    upvar 1 time_clarr time_clarr
    upvar 1 cost_clarr cost_clarr
    upvar 1 type_t_curve_arr type_t_curve_arr
    upvar 1 type_c_curve_arr type_c_curve_arr
    upvar 1 scenario_tid scenario_tid
    # need to pass p1_arr defaults for p2 dc processing
    upvar 1 p1_arr p1_arr
    # to pass and share auxiliary variables:
    upvar 1 aux_col_names_list aux_col_names_list
    # following are not upvar'd because the cache is mainly useless after proc ends
    #    upvar 1 tc_cache_larr tc_cache_larr
    #    upvar 1 cc_cache_larr cc_cache_larr
    # following are not upvar'd because these are temporary arrays for loading list representations of curves
    #    upvar 1 tc_larr tc_larr
    #    upvar 1 cc_larr cc_larr

    if { $instance_id eq "" } {
        set instance_id [ad_conn package_id]
    }
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    set success_p 1
    set table_type "p3"
    set type_tcurve_list [list ]
    set type_ccurve_list [list ]
    if { $p3_larr_name ne ""} {
        upvar 1 $p3_larr_name p3_larr
        # p_larr must be a p2 table
        set table_type "p2"
    }

    # set table defaults
    foreach column $constants_list {
        set p_larr($column) [list ]
    }

    # load table into array of lists {{a b c} {1 2 3} {4 5 6}} becomes p_larr(a) {1 4}, p_larr(b) {2 5}, p_larr(c) {3 6}
    qss_tid_columns_to_array_of_lists $tid p_larr $constants_list $constants_required_list $instance_id $user_id
    #### setup auxiliary calculation columns
    ## p_larr_k_w_data_list   p_larr names having data.
    set p_larr_names_unfiltered_list [list ]
    foreach col [array names p_larr] {
        if { [llength $p_larr(${col}) > 0 ] } {
            lappend p_larr_names_unfiltered_list $col
        }
    }
    set p_larr_names_list [acc_fin::list_filter alphanum $p_larr_names_unfiltered_list ]
    set names_wo_reserved_list [set_difference $p_larr_names_list $constants_list ]
    # Are any names in names_wo_reserved_list auxiliary names?
    set aux_col_names_allowed_unfiltered_list [parameter::get -parameter AuxiliaryColumnNames -package_id $instance_id ]
    set aux_col_names_allowed_list [acc_fin::list_filter alphanum $aux_col_names_unfiltered_list ]
    set my_aux_col_names_list [set_intersection $aux_col_names_allowed_list $names_wo_reserved_list ]
    set remainder_names_list [set_difference $names_wo_reserved_list $my_aux_col_names_list ]
    set aux_col_name_max_len [parameter::get -parameter AuxiliaryColumnNameMaxLength -package_id $instance_id ]
    # Add any remaining names qualified by AuxiliaryColumnNameMaxLength
    if { $aux_col_name_max_len > 0 } {
        foreach name $remainder_names_list {
            set name_len [llength $name]
            if { $name_len <= $aux_col_name_max_len && $name_len > 0 } {
                lappend $my_aux_col_names_list $name
            }
        }
    }
    set aux_col_names_list [set_union $aux_col_names_list $my_aux_col_names_list]
    ## aux_col_names_list   is the list of auxiliary column names in p_larr to perform auxiliary calculations identical to cost

    ####
    set i_max -1
    set p2_types_exist_p 0
    set p2_type_column_exists_p 0
    set p3_types_exist_p 0
    set p3_type_column_exists_p 0

    if { $table_type eq "p3" } {
        # if 'type' column exists, then p_larr is a p3 table
        set p3_type_column_exists_p [info exists p_larr(type)]
        if { $p3_type_column_exists_p } {
            set i_max [llength $p_larr(type) ]
            set p3_types_exist_p [expr { [llength $p_larr(type)] > 0 } ]
        } 
    } elseif { $table_type eq "p2" } {
        # i_max is activity_ref length
        set p2_actref_column_exists_p [info exists p_larr(activity_ref)]
        if { $p2_actref_column_exists_p } {
            set i_max [llength $p_larr(activity_ref)]
        }       
        set p2_type_column_exists_p [info exists p_larr(aid_type)]
        if { $p2_type_column_exists_p } {
            set p2_types_exist_p [expr { [llength $p_larr(aid_type)] > 0 } ]
            if { $p1_arr(task_types_tid) eq "" && $p2_types_exist_p } {
                set success_p 0
                acc_fin::pretti_log_create $scenario_tid "p_load_tid" "#accounts-finance.value#" "#accounts-finance.error# #accounts-finance.task_types_tid_is_required_when# (ref1441)" $user_id $instance_id
            }
        } 
    }

    if { $p3_types_exist_p && $table_type eq "p2" } {
        ns_log Warning "acc_fin::p_load_tid.1005: table_type ${table_type} and p3_types_exist_p $p3_types_exist_p is an unexpected condition. Investigate."
        # Is there any reason why p3 rows cannot be defined in a p2 table?
        # Recall, p3 loads curves , whereas p2 possibly references existing curves from p3.
        # if okay to have p3 rows in a p2, then logic changes to (p2 || p3) vs. p3 for this proc.
    }
    
    # filter user input that is going to be used as references in arrays:
    if { $p3_type_column_exists_p } {
        set p_larr(type) [acc_fin::list_filter alphanum $p_larr(type) $p_larr_name "type"]
        if { [info exists p_larr(dependent_tasks) ] } {
            set p_larr(dependent_tasks) [acc_fin::list_filter factorlist $p_larr(dependent_tasks) $p_larr_name "dependent_tasks"]
        }
    }
    if { $p2_type_column_exists_p } {
        set p_larr(aid_type) [acc_fin::list_filter alphanum $p_larr(aid_type) $p_larr_name "type"]
    }
    
    
    # import curves referenced in the table
    set p_larr(_tCurveRef) [list ]
    set p_larr(_cCurveRef) [list ]
    set p_larr(_coef) [list ]
    set p_larr(_tDcSource) [list ]
    set p_larr(_cDcSource) [list ]
    set tcurvesource ""
    set ccurvesource ""

    if { $table_type eq "p3" && $p3_type_column_exists_p } {
        # table_type is p3
        set p3_t_dc_tid_exists_p [info exists p_larr(time_dist_curve_tid) ]
        set p3_t_dc_name_exists_p [info exists p_larr(time_dist_curve_name) ]
        set p3_t_est_short_exists_p [info exists p_larr(time_est_short) ]
        set p3_t_est_median_exists_p [info exists p_larr(time_est_median) ]
        set p3_t_est_long_exists_p [info exists p_larr(time_est_long) ]

        set p3_c_dc_tid_exists_p [info exists p_larr(cost_dist_curve_tid) ]
        set p3_c_dc_name_exists_p [info exists p_larr(cost_dist_curve_name) ]
        set p3_c_est_low_exists_p [info exists p_larr(cost_est_low) ]
        set p3_c_est_median_exists_p [info exists p_larr(cost_est_median) ]
        set p3_c_est_high_exists_p [info exists p_larr(cost_est_high) ]


        # load any referenced curves
        
        ns_log Notice "acc_fin::p_load_tid.1021: for ${p_larr_name} i_max ${i_max}"
        for {set i 0} {$i < $i_max} {incr i} {
            
            set type [lindex $p_larr(type) $i]
            
            # time curve
            set time_dist_curve_tid ""
            set time_dist_curve_name ""
            set time_est_short ""
            set time_est_median ""
            set time_est_long ""
            if { $p3_t_dc_name_exists_p } {
                set time_dist_curve_name [lindex $p_larr(time_dist_curve_name) $i]
                ns_log Notice "acc_fin::p_load_tid.1081: for ${p_larr_name} i $i q1"
            }
            if { $time_dist_curve_name ne "" } {
                set time_dist_curve_tid [qss_tid_from_name $time_dist_curve_name $instance_id $user_id]
                ns_log Notice "acc_fin::p_load_tid.1085: for ${p_larr_name} i $i q2"
            } 
            if { $p3_t_dc_tid_exists_p && $time_dist_curve_tid eq "" } {
                set time_dist_curve_tid [lindex $p_larr(time_dist_curve_tid) $i]
                ns_log Notice "acc_fin::p_load_tid.1089: for ${p_larr_name} i $i q3"
            }
            # set defaults
            set constants_list [acc_fin::pretti_columns_list dc]
            foreach constant $constants_list {
                set tc_larr($constant) ""
            }

            if { $time_dist_curve_tid ne "" } {
                if { ![info exists tc_cache_larr(x,${time_dist_curve_tid}) ] } {
                    set constants_required_list [acc_fin::pretti_columns_list dc 1]
                    qss_tid_columns_to_array_of_lists ${time_dist_curve_tid} tc_larr $constants_list $constants_required_list $instance_id $user_id
                    # add to temporary cache
                    foreach constant $constants_list {
                        set tc_cache_larr($constant,${time_dist_curve_tid}) $tc_larr($constant)
                    }
                }
                #tc_larr(x), tc_larr(y) and optionally tc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n
                foreach constant $constants_list {
                    set tc_larr($constant) $tc_cache_larr($constant,${time_dist_curve_tid})
                }
            }
            if { $p3_t_est_short_exists_p } {
                set time_est_short [lindex $p_larr(time_est_short) $i]
            }

            if { $p3_t_est_median_exists_p } {
                set time_est_median [lindex $p_larr(time_est_median) $i]
            }
            if { $p3_t_est_long_exists_p } {
                set time_est_long [lindex $p_larr(time_est_long) $i]
            }
            # import curve given all the available curve choices
            ns_log Notice "acc_fin::p_load_tid.1118: for ${p_larr_name} i $i time_est_short '${time_est_short}' time_est_median '${time_est_median}' time_est_long '${time_est_long}' type_tcurve_list '${type_tcurve_list}' tc_larr(x) '$tc_larr(x)' tc_larr(y) '$tc_larr(y)' tc_larr(label) '$tc_larr(label)'"
            set curve_list [acc_fin::curve_import $tc_larr(x) $tc_larr(y) $tc_larr(label) $type_tcurve_list $time_est_short $time_est_median $time_est_long $time_clarr($p1_arr(_tCurveRef)) tcurve_source]

            set tcurvenum [acc_fin::larr_set time_clarr $curve_list]
            if { $tcurvenum eq "" } {
                ns_log Notice "acc_fin::p_load_tid.1120: for ${p_larr_name} i $i type $type _tCurveRef is blank for curve_list '${curve_list}'."
            }

            # cost curve
            set cost_dist_curve_tid ""
            set cost_dist_curve_name ""
            set cost_est_low ""
            set cost_est_median ""
            set cost_est_high ""
            if { $p3_c_dc_name_exists_p } {
                set cost_dist_curve_name [lindex $p_larr(cost_dist_curve_name) $i]
            }
            if { $cost_dist_curve_name ne "" } {
                set cost_dist_curve_tid [qss_tid_from_name $cost_dist_curve_name $instance_id $user_id]
            } 
            if { $p3_c_dc_tid_exists_p && $cost_dist_curve_tid eq "" } {
                set cost_dist_curve_tid [lindex $p_larr(cost_dist_curve_tid) $i]
            }
            # set defaults
            foreach constant $constants_list {
                set cc_larr($constant) ""
            }

            if { $cost_dist_curve_tid ne "" } {
                set constants_list [acc_fin::pretti_columns_list dc]
                if { ![info exists cc_cache_larr(x,${cost_dist_curve_tid}) ] } {
                    set constants_required_list [acc_fin::pretti_columns_list dc 1]
                    qss_tid_columns_to_array_of_lists ${cost_dist_curve_tid} cc_larr $constants_list $constants_required_list $instance_id $user_id
                    # add to input tid cache
                    foreach constant $constants_list {
                        set cc_cache_larr($constant,${cost_dist_curve_tid}) $cc_larr($constant)
                    }
                }
                #cc_larr(x), cc_larr(y) and optionally cc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n                
                foreach constant $constants_list {
                    set cc_larr($constant) $cc_cache_larr($constant,${cost_dist_curve_tid})
                }
            }
            if { $p3_c_est_low_exists_p } {
                set cost_est_low [lindex $p_larr(cost_est_low) $i] 
            }
            if { $p3_c_est_median_exists_p } {
                set cost_est_median [lindex $p_larr(cost_est_median) $i] 
            }
            if { $p3_c_est_high_exists_p } {
                set cost_est_high [lindex $p_larr(cost_est_high) $i]
            }
            # import curve given all the available curve choices
            ns_log Notice "acc_fin::p_load_tid.1168: for ${p_larr_name} i $i cost_est_low '${cost_est_low}' cost_est_median '${cost_est_median}' cost_est_high '${cost_est_high}' type_ccurve_list '${type_ccurve_list}' cc_larr(x) '$cc_larr(x)' cc_larr(y) '$cc_larr(y)' cc_larr(label) '$cc_larr(label)'"
            set curve_list [acc_fin::curve_import $cc_larr(x) $cc_larr(y) $cc_larr(label) $type_ccurve_list $cost_est_low $cost_est_median $cost_est_high $cost_clarr($p1_arr(_cCurveRef)) ccurve_source ]
            set ccurvenum [acc_fin::larr_set cost_clarr $curve_list]
            if { $ccurvenum eq "" } {
                ns_log Notice "acc_fin::p_load_tid.1188: for ${p_larr_name} i $i type $type _cCurveRef is blank for curve_list '${curve_list}'."
            }


            # add curve references for both time and cost. 
            lappend p_larr(_tCurveRef) $tcurvenum
            lappend p_larr(_tDcSource) $tcurve_source
            lappend p_larr(_cCurveRef) $ccurvenum
            lappend p_larr(_cDcSource) $ccurve_source
            ns_log Notice "acc_fin::p_load_tid.1106: for ${p_larr_name} added: p_larr(_tCurveRef) $tcurvenum p_larr(_cCurveRef) $ccurvenum"
            # Since this is a p3_larr, create pointer arrays for use with p2_larr
            if { $type ne "" } {
                ns_log Notice "acc_fin::p_load_tid.1121: type_t_curve_arr($type) $tcurvenum"
                set type_t_curve_arr($type) $tcurvenum
                ns_log Notice "acc_fin::p_load_tid.1123: type_c_curve_arr($type) $ccurvenum"
                set type_c_curve_arr($type) $ccurvenum
            } 
            
        }
        # end for i, $i < $i_max
        
    } elseif { $table_type eq "p2" && $success_p } {
        # table_type is p2 
        # p2 defined curves are loaded in context of higher level of complexity
        
        
        # table_type is p2
        
        set p2_t_dc_tid_exists_p [info exists p_larr(time_dist_curve_tid) ]
        set p2_t_dc_name_exists_p [info exists p_larr(time_dist_curve_name) ]
        set p2_t_est_short_exists_p [info exists p_larr(time_est_short) ]
        set p2_t_est_median_exists_p [info exists p_larr(time_est_median) ]
        set p2_t_est_long_exists_p [info exists p_larr(time_est_long) ]
        
        set p2_c_dc_tid_exists_p [info exists p_larr(cost_dist_curve_tid) ]
        set p2_c_dc_name_exists_p [info exists p_larr(cost_dist_curve_name) ]
        set p2_c_est_low_exists_p [info exists p_larr(cost_est_low) ]
        set p2_c_est_median_exists_p [info exists p_larr(cost_est_median) ]
        set p2_c_est_high_exists_p [info exists p_larr(cost_est_high) ]
        
        ns_log Notice "acc_fin::p_load_tid.1227: for ${p_larr_name} i_max ${i_max}"
        for {set i 0} {$i < $i_max} {incr i} {
            
            # time curve
            set time_dist_curve_tid ""
            set time_dist_curve_name ""
            set time_est_short ""
            set time_est_median ""
            set time_est_long ""
            if { $p2_t_dc_name_exists_p } {
                set time_dist_curve_name [lindex $p_larr(time_dist_curve_name) $i]
                ns_log Notice "acc_fin::p_load_tid.1238: for ${p_larr_name} i $i q1"
            }
            if { $time_dist_curve_name ne "" } {
                set time_dist_curve_tid [qss_tid_from_name $time_dist_curve_name $instance_id $user_id]
                ns_log Notice "acc_fin::p_load_tid.1242: for ${p_larr_name} i $i q2"
            } 
            if { $p2_t_dc_tid_exists_p && $time_dist_curve_tid eq "" } {
                set time_dist_curve_tid [lindex $p_larr(time_dist_curve_tid) $i]
                ns_log Notice "acc_fin::p_load_tid.1246: for ${p_larr_name} i $i q3"
            }
            # set defaults
            set constants_list [acc_fin::pretti_columns_list dc]
            foreach constant $constants_list {
                set tc_larr($constant) ""
            }
            
            if { $time_dist_curve_tid ne "" } {
                if { ![info exists tc_cache_larr(x,${time_dist_curve_tid}) ] } {
                    set constants_required_list [acc_fin::pretti_columns_list dc 1]
                    qss_tid_columns_to_array_of_lists ${time_dist_curve_tid} tc_larr $constants_list $constants_required_list $instance_id $user_id
                    # add to temporary cache
                    foreach constant $constants_list {
                        set tc_cache_larr($constant,${time_dist_curve_tid}) $tc_larr($constant)
                    }
                }
                #tc_larr(x), tc_larr(y) and optionally tc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n
                foreach constant $constants_list {
                    set tc_larr($constant) $tc_cache_larr($constant,${time_dist_curve_tid})
                }
            }
            if { $p2_t_est_short_exists_p } {
                set time_est_short [lindex $p_larr(time_est_short) $i]
            }
            
            if { $p2_t_est_median_exists_p } {
                set time_est_median [lindex $p_larr(time_est_median) $i]
            }
            if { $p2_t_est_long_exists_p } {
                set time_est_long [lindex $p_larr(time_est_long) $i]
            }
            
            # import curve given all the available curve choices

            if { $p2_types_exist_p && $p2_type_column_exists_p } {
                # aid_type exists, so include option in curve_import   
                # load aid_type referenced curves here.              
                set aid_type [lindex $p_larr(aid_type) $i]
                if { $aid_type ne "" } {
                    if { [info exists type_t_curve_arr(${aid_type}) ] } {
                        set type_tcurve_list $time_clarr($type_t_curve_arr(${aid_type}))
                    } else {
                        set success_p 0
                        acc_fin::pretti_log_create $scenario_tid "p_load_tid" "#accounts-finance.value#" "aid_type: '${aid_type}'; #accounts-finance.error# #accounts-finance.aid_type_for_time_not_found# (ref1440)" $user_id $instance_id
                    }
                }
            }
            ns_log Notice "acc_fin::p_load_tid.1280: for ${p_larr_name} i $i time_est_short '${time_est_short}' time_est_median '${time_est_median}' time_est_long '${time_est_long}' type_tcurve_list '${type_tcurve_list}' tc_larr(x) '$tc_larr(x)' tc_larr(y) '$tc_larr(y)' tc_larr(label) '$tc_larr(label)'"
            set curve_list [acc_fin::curve_import $tc_larr(x) $tc_larr(y) $tc_larr(label) $type_tcurve_list $time_est_short $time_est_median $time_est_long $time_clarr($p1_arr(_tCurveRef)) curve_source ]
            set tcurvenum [acc_fin::larr_set time_clarr $curve_list]
            if { $tcurvenum eq "" } {
                ns_log Warning "acc_fin::p_load_tid.1284: for ${p_larr_name} i $i type $type _tCurveRef is blank for curve_list '${curve_list}'."
            } 
            
            lappend p_larr(_tCurveRef) $tcurvenum
            lappend p_larr(_tDcSource) $curve_source
            
            # cost curve
            set cost_dist_curve_tid ""
            set cost_dist_curve_name ""
            set cost_est_low ""
            set cost_est_median ""
            set cost_est_high ""
            if { $p2_c_dc_name_exists_p } {
                set cost_dist_curve_name [lindex $p_larr(cost_dist_curve_name) $i]
            }
            if { $cost_dist_curve_name ne "" } {
                set cost_dist_curve_tid [qss_tid_from_name $cost_dist_curve_name $instance_id $user_id]
            } 
            if { $p2_c_dc_tid_exists_p && $cost_dist_curve_tid eq "" } {
                set cost_dist_curve_tid [lindex $p_larr(cost_dist_curve_tid) $i]
            }
            # set defaults
            foreach constant $constants_list {
                set cc_larr($constant) ""
            }
            
            if { $cost_dist_curve_tid ne "" } {
                set constants_list [acc_fin::pretti_columns_list dc]
                if { ![info exists cc_cache_larr(x,${cost_dist_curve_tid}) ] } {
                    set constants_required_list [acc_fin::pretti_columns_list dc 1]
                    qss_tid_columns_to_array_of_lists ${cost_dist_curve_tid} cc_larr $constants_list $constants_required_list $instance_id $user_id
                    # add to input tid cache
                    foreach constant $constants_list {
                        set cc_cache_larr($constant,${cost_dist_curve_tid}) $cc_larr($constant)
                    }
                }
                #cc_larr(x), cc_larr(y) and optionally cc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n                
                foreach constant $constants_list {
                    set cc_larr($constant) $cc_cache_larr($constant,${cost_dist_curve_tid})
                }
            }
            if { $p2_c_est_low_exists_p } {
                set cost_est_low [lindex $p_larr(cost_est_low) $i] 
            }
            if { $p2_c_est_median_exists_p } {
                set cost_est_median [lindex $p_larr(cost_est_median) $i] 
            }
            if { $p2_c_est_high_exists_p } {
                set cost_est_high [lindex $p_larr(cost_est_high) $i]
            }

            # import curve given all the available curve choices

            if { $p2_types_exist_p && $p2_type_column_exists_p && $aid_type ne "" } {
                # aid_type exists, so include option in curve_import                
                set aid_type [lindex $p_larr(aid_type) $i]
                if { [info exists type_c_curve_arr(${aid_type}) ] } {
                    set type_ccurve_list $cost_clarr($type_c_curve_arr(${aid_type}))
                } else {
                    set success_p 0
                    acc_fin::pretti_log_create $scenario_tid "p_load_tid" "#accounts-finance.value#" "aid_type '${aid_type}'; #accounts-finance.error# #accounts-finance.aid_type_for_cost_not_found# (ref1540)" $user_id $instance_id
                }

            }
            ns_log Notice "acc_fin::p_load_tid.1352: for ${p_larr_name} i $i cost_est_low '${cost_est_low}' cost_est_median '${cost_est_median}' cost_est_high '${cost_est_high}' type_ccurve_list '${type_ccurve_list}' cc_larr(x) '$cc_larr(x)' cc_larr(y) '$cc_larr(y)' cc_larr(label) '$cc_larr(label)'"
            set curve_list [acc_fin::curve_import $cc_larr(x) $cc_larr(y) $cc_larr(label) $type_ccurve_list $cost_est_low $cost_est_median $cost_est_high $cost_clarr($p1_arr(_cCurveRef)) curve_source]
            set ccurvenum [acc_fin::larr_set cost_clarr $curve_list]

            if { $ccurvenum eq "" } {
                ns_log Warning "acc_fin::p_load_tid.1356: for ${p_larr_name} i $i type $type _cCurveRef is blank for curve_list '${curve_list}'."
            }
            lappend p_larr(_cCurveRef) $ccurvenum
            lappend p_larr(_cDcSource) $curve_source
            # add default coefficient
            lappend p_larr(_coef) 1
        }
    } else {
        ns_log Warning "acc_fin::p_load_tid.1361: for ${p_larr_name} not processed as either p2 or p3 table."
    }
    return $success_p
}

ad_proc -private acc_fin::list_filter {
    type
    user_input_list
    {table_name ""}
    {list_name ""}
} {
    filters input as a list to meet basic word or reference requirements. type can be alphanum decimal natnum alphanumlist factorlist. If decimal or natural number (natnum) does not pass filter, value is replaced with blank. if table_name and list_name is specified and an input value doesn't pass, procedure logs an error to the server and notifies user of count of filtered changes via pretti_log_create
} {
    set type_errors_count 0
    switch -exact $type {
        alphanumlist {
            # some table columns contain lists of items..
            set filtered_list [list ]
            foreach input_row_unfiltered $user_input_list {
                set filtered_row_list [list ]
                foreach input_unfiltered $input_row_unfiltered {
                    # added dash and underscore, because these are often used in alpha/text references
                    regsub -all -nocase -- {[^a-z0-9,\.\-\_]+} $input_unfiltered {} input_filtered
                    lappend filtered_row_list $input_filtered
                }
                lappend filtered_list $filtered_row_list
            }
        }
        factorlist {
            # some table columns contain lists of items..
            set filtered_list [list ]
            foreach input_row_unfiltered $user_input_list {
                set filtered_row_list [list ]
                foreach input_unfiltered $input_row_unfiltered {
                    # added dash and underscore, because these are often used in alpha/text references
                    regsub -all -nocase -- {[^a-z0-9,\.\-\_\*]+} $input_unfiltered {} input_filtered
                    lappend filtered_row_list $input_filtered
                }
                lappend filtered_list $filtered_row_list
            }
        }
        alphanum {
            set filtered_list [list ]
            foreach input_unfiltered $user_input_list {
                    # added dash and underscore, because these are often used in alpha/text references
                regsub -all -nocase -- {[^a-z0-9,\.\-\_]+} $input_unfiltered {} input_filtered
                lappend filtered_list $input_filtered
            }
        }
        decimal {
            set filtered_list [list ]
            foreach input_unfiltered $user_input_list {
                if { $input_unfiltered ne "" && ![qf_is_decimal $input_unfiltered] } {
                    incr type_errors_count
                    ns_log Notice "acc_fin::list_filter.1152: val '${val}' in '${table_name}.${list_name}' is not a decimal number."
                    lappend filtered_list ""
                } else {
                    lappend filtered_list $input_unfiltered
                }
            }
        }
        natnum {
            set filtered_list [list ]
            foreach input_unfiltered $user_input_list {
                if { $input_unfiltered ne "" && ![qf_is_natural_number $input_unfiltered] } {
                    incr type_errors_count
                    ns_log Notice "acc_fin::list_filter.1164: val '${val}' in '${table_name}.${list_name}' is not a natural number."
                    lappend filtered_list ""
                } else {
                    lappend filtered_list $input_unfiltered
                }
            }
        }
    }
    if { $type_errors_count > 0 } {
        acc_fin::pretti_log_create $scenario_tid $table_name "#accounts-finance.value#" "#accounts-finance.table_name# '${table_name}'; #accounts-finance.set_name# '${list_name}'; #accounts-finance.unacceptable_values_in_set# #accounts-finance.count#: ${type_errors_count}" $user_id $instance_id
        set type_errors_count 0
        set type_errors_p 1
    }

    return $filtered_list
}

ad_proc -public acc_fin::table_type {
    table_id
    {instance_id ""}
    {user_id ""}
} {
    returns table flags.
} {
    set stats_list [qss_table_stats $table_id $instance_id $user_id]
    # stats: name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id.
    set flags [string trim [lindex $stats_list 6]]
    return $flags
}


ad_proc -private acc_fin::curve_import {
    c_x_list
    c_y_list
    c_label_list
    curve_lists
    minimum
    median
    maximum
    default_lists
    {case_var_name ""}
} {
    Returns curve data to standard representation for PRETTI processing. 
    Expects column labels in arbitrary order in row lists, but no titles with c_*_list.
    Distribution curve format is a spreadsheet table format with labeled columns 'x' and 'y' (and optionally 'label').
    Returns columns in order of x,y (,label) for minimizing memory footprint when used with acc_fin::larr_set.
    1. If a curve exists in c_x_list, c_y_list (, c_label_list), use it.
    2. If a curve exists in curve_lists where each element is a list of x, followed by list of y ( and perhaps followed by label), use it.
    3. If a minimum, median, and maximum is available, make a curve of it. 
    4. if an median value is available, make a curve of it, 
    5. if an ordered list of lists x,y,label exists, use it as a fallback default, otherwise 
    6. return a representation of a normalized curve as a list of lists similar to curve_lists 
} {
    upvar 1 p1_arr p1_arr
    if { $case_var_name ne "" } {
        upvar 1 $case_var_name case_var
    }
    # In persuit of making curve_data
    #     local curves are represented as a list of lists
    #     with each list a triplet set x, y, label, with the first row consisting of title names

    #     local 3-point (min,median,max) represented as a list of 3 elements
    #     local median represented as a single element
    #     default curve represented as a list of lists
    #     if no default available, create one based on a normalized standard.

    set c_lists [list ]

    # 1. If a curve exists in c_x_list, c_y_list (, c_label_list), use it.
    set c_x_list_len [llength $c_x_list]
    set c_y_list_len [llength $c_y_list]
    set c_label_list_len [llength $c_label_list]
    set list_len 0
    if { $c_x_list_len > 0 && $c_x_list_len < $c_y_list_len } {
        set list_len $c_x_list_len
    } elseif { $c_y_list_len > 0 } {
        set list_len $c_y_list_len
    }
    if { $list_len > 0 } {
        if { $c_label_list_len > 0 } {
            # x, y and label
            lappend c_lists [list x y label]
            set case_var 1
            ns_log Notice "acc_fin::curve_import.1237 case 1. building list from x, y and label "
            for {set i 0} {$i < $list_len} {incr i} {
                set row [list [lindex $c_x_list $i] [lindex $c_y_list $i] [lindex $c_label_list $i] ]
                lappend c_lists $row
            }
        } else {
            # x and y only
            lappend c_lists [list x y]
            set case_var 1
            ns_log Notice "acc_fin::curve_import.1244 case 1. building list from x and y "
            for {set i 0} {$i < $list_len} {incr i} {
                set row [list [lindex $c_x_list $i] [lindex $c_y_list $i] ]
                lappend c_lists $row
            }
        }
    } 

    # 2. If a curve exists in curve_lists where each element is a list of x,y(,label), use it.
    set curve_lists_len [llength $curve_lists]
    if { [llength $c_lists] == 0 && $curve_lists_len > 0 } {
        set title_list [lindex $curve_lists 0]
        set y_idx [lsearch -exact $title_list "y"]
        set x_idx [lsearch -exact $title_list "x"]
        set label_idx [lsearch -exact $title_list "label"]
        if { $label_idx > -1 } {
            set label_exists_p 1
        } else {
            set label_exists_p 0
        }
        ns_log Notice "acc_fin::curve_import.1255 case 2. building curve_lists "
        # curve exists. 
        set point_len [llength [lindex $curve_lists 0] ]
        if { $point_len > 1 } {
            # Reorder columns?
            if { $x_idx == 0 && $y_idx == 1 } {
                set c_lists $curve_lists
            } else {
                # Reorder columns for output
                foreach point_list $curve_lists {
                    set x [lindex $point_list $x_idx]
                    set y [lindex $point_list $y_idx]
                    if { $label_exists_p } {
                        set label [lindex $point_list $label_idx]
                        set point_new_list [list $x $y $label]
                    } else {
                        set point_new_list [list $x $y]
                    }
                    lappend c_lists $point_new_list
                }
            }
            set case_var 2
        }
        
    }
    
    # 3. If a minimum, median, and maximum is available, make a curve of it. 
    # or
    if { [llength $c_lists] == 0 && $minimum ne "" && $median ne "" && $maximum ne "" } {
        ns_log Notice "acc_fin::curve_import.1272 case 3. building curve from min/med/max points "
        # min,med,max values available
        # Geometric median requires all three values
        
        # time_expected = ( time_optimistic + 4 * time_most_likely + time_pessimistic ) / 6.
        # per http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique
        if { [info exists p1_arr(pert_omp) ] && $p1_arr(pert_omp) eq "strict" } {
            set c_lists [acc_fin::pert_omp_to_strict_dc $minimum $median $maximum ]
            set case_var 3.1
        } else {
            set c_lists [acc_fin::pert_omp_to_normal_dc $minimum $median $maximum ]
            set case_var 3.0
        }

    }

    # 4. if an median value is available, make a curve of it, 
    #set standard_deviation 0.682689492137 
    #set std_dev_parts [expr { $standard_deviation / 4. } ]
    #set outliers [expr { 0.317310507863 / 2. } ]
    if { [llength $c_lists] == 0 && $median ne "" } {
        ns_log Notice "acc_fin::curve_import.1272 case 4. building curve from med and maybe min or max points "
        set med_label "med"
        if { $minimum eq "" } {
            set minimum $median
            set min_label $med_label
        } else {
            set min_label "min"
        }
        if { $maximum eq "" } {
            set maximum $median
            set max_label $med_label
        } else {
            set max_label "max"
        }

        # min,med,max values available
        # Geometric median requires all three values
        
        # time_expected = ( time_optimistic + 4 * time_most_likely + time_pessimistic ) / 6.
        # per http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique
        if { [info exists p1_arr(pert_omp) ] && $p1_arr(pert_omp) eq "strict" } {
            set c_lists [acc_fin::pert_omp_to_strict_dc $minimum $median $maximum ]
            set case_var 4.1

        } else {
            set c_lists [acc_fin::pert_omp_to_normal_dc $minimum $median $maximum ]
            set case_var 4.0
        }
    }
    
    # 5. if an ordered list of lists x,y,label exists, use it as a fallback default
    if { [llength $c_lists] == 0 && [llength $default_lists] > 0 && [llength [lindex $default_lists 0] ] > 1 } {
        ns_log Notice "acc_fin::curve_import.1298 case 5. building curve_lists from default_lists "
        set c_lists $default_lists
        set case_var 5
    }

    # 6. return a representation of a normalized curve as a list of lists similar to curve_lists 
    if { [llength $c_lists] == 0 } {
        ns_log Notice "acc_fin::curve_import.1304 case 6. building curve_lists from blanks"
        # No time defaults.
        # following is essentially the same as acc_fin::pert_omp_to_normal_dc
        # set duration to 1 for limited block feedback.
        #set tc_larr(y) [list $outliers $std_dev_parts $std_dev_parts $std_dev_parts $std_dev_parts $outliers]
        set minimum 0.5
        set median 1.
        set maximum 2.
        set tc_larr(y) [list y $minimum $median $median $median $median $maximum]
        # using approximate cumulative distribution y values for standard deviation of 1.
        set portion [expr { 1. / 6. } ]
        set tc_larr(x) [list x $portion $portion $portion $portion $portion $portion ]
        set tc_larr(label) [list label "outlier" "standard deviation 2" "standard deviation 1" "standard deviation 1" "standard deviation 2" "outlier" ]

        set c_lists [list ]
        for {set i 0} {$i < 7} {incr i} {
            lappend c_lists [list [lindex $tc_larr(x) $i] [lindex $tc_larr(y) $i] [lindex $tc_larr(label) $i]]
        }
        set case_var 6
    }
    if { [llength $c_lists] == 0 } {
        set case_var 0
        # This shouldn't happen.. for the most part.
        ns_log Notice "acc_fin::curve_import.1312: len c_list 0 "
        ns_log Notice "acc_fin::curve_import.1312: c_x_list $c_x_list "
        ns_log Notice "acc_fin::curve_import.1312: c_y_list $c_y_list "
        ns_log Notice "acc_fin::curve_import.1312: c_label_list $c_label_list "
        ns_log Notice "acc_fin::curve_import.1312: curve_lists $curve_lists "
        ns_log Notice "acc_fin::curve_import.1312: minimum $minimum median $median maximum $maxium "
        ns_log Notice "acc_fin::curve_import.1312: default_lists $default_lists "
    }
    # Return an ordered list of lists representing a curve
    ns_log Notice "acc_fin::curve_import.1639: c_lists '$c_lists'"
    return $c_lists
}

ad_proc -public acc_fin::scenario_prettify {
    scenario_tid
    {instance_id ""}
    {user_id ""}
} {
    Processes PRETTI scenario. Returns resulting PRETTI table as a list of lists. 
} {
    # General notes:

    # Can create a projected completion curve by stepping through the range of all 
    # the performance curves N times for N point curve --instead of Monte Carlo simm.

    # About output table:
    # Vertical represents time. All tasks are rounded up to quantized time_unit.
    # Smallest task duration is the number of quantized time_units that result in 1 line of text.
    # To find smallest task duration, repeat PRETTI scenario on tracks with CP tasks by task type, 
    # then increment by quantized time_unit (row), tracking overages
    # amount to extend CP duration: 
    # collision_count / task_type * ( row_counts / ( time_quanta per task_type_duration ) + 1 )

    # Represents task bottlenecks --limits in parallel activity of same type
    # Parallel limits represented by using:
    # concurrency_limit: count of tasks of same type that can operate in parallel
    # overlap_limit: a percentage representing amount of overlap allowed.
    #                overlap_limit, in effect, creates progressions of activity

    # Since PRETTI does not schedule, don't manipulate task positioning,
    # just increase duration of task(s) to account for any overages.

    # Activities: 
    # Represent multiple dependencies of same task for example 99 cartwheels using * as in 99*cartwheels


    set setup_start [clock seconds]
    if { $instance_id eq "" } {
        # Added warning for diagnostics if called via schedule proc
        ns_log Warning "acc_fin::scenario_prettify.2364 instance_id not previously set."
        set instance_id [ad_conn package_id]
    }
    if { $user_id eq "" } {
        # Added warning for diagnostics if called via schedule proc
        ns_log Warning "acc_fin::scenario_prettify.2368 instance_id not previously set."
        set user_id [ad_conn user_id]
    }
    ## error_fail is set to 1 if there has been an error that prevents continued processing
    ## error_cost is set to 1 if there has been an error that prevents continued processing of costing aspects
    ## error_time is set to 1 if there has been an error that prevents continued processing of time aspects
    set error_fail 0
    set error_cost 0
    set error_time 0
    set index_eq ""
    # # # load scenario values -- requires scenario_tid
    
    # activity_table contains:
    # activity_ref predecessors time_est_short time_est_median time_est_long cost_est_low cost_est_median cost_est_high time_dist_curv_eq cost_dist_curv_eq


    # # # load p1
    ns_log Notice "acc_fin::scenario_prettify.1306: scenario '$scenario_tid' start. Load p1 table"

    # get scenario into array p1_arr
    set constants_list [acc_fin::pretti_columns_list p1]
    foreach constant $constants_list {
        set p1_arr($constant) ""
    }
    # preload p1 defaults

    set p1_arr(time_probability_moment) "0.5"
    # set p1_arr(max_overlap_pct) "" defaults to 1
    # set p1_arr(max_concurrent) "" defaults to no limit.
    # set p1_arr(max_run_time) "" defaults no limit
    # set p1_arr(max_tasks_per_run) "" defaults to no limit
    # # # identify table ids to process
    set constants_required_list [acc_fin::pretti_columns_list p1 1]
    qss_tid_scalars_to_array $scenario_tid p1_arr $constants_list $constants_required_list $instance_id $user_id

    if { $p1_arr(activity_table_name) ne "" } {
        # set activity_table_tid
        set p1_arr(activity_table_tid) [qss_tid_from_name $p1_arr(activity_table_name) $instance_id $user_id]
        if { $p1_arr(activity_table_tid) eq "" } {
            acc_fin::pretti_log_create $scenario_tid "activity_table_name" "#accounts-finance.value#" "activity_table_name #accounts-finance.unknown_reference#" $user_id $instance_id
        }
    } 
    if { $p1_arr(task_types_name) ne "" } {
        # set task_types_tid
        set p1_arr(task_types_tid) [qss_tid_from_name $p1_arr(task_types_name) $instance_id $user_id]
        if { $p1_arr(task_types_tid) eq "" } {
            acc_fin::pretti_log_create $scenario_tid "task_types_name" "#accounts-finance.value#" "task_types_name #accounts-finance.unknown_reference#" $user_id $instance_id
        }
    } 
    if { $p1_arr(time_dist_curve_name) ne "" } {
        # set dist_curve_tid
        set p1_arr(time_dist_curve_tid) [qss_tid_from_name $p1_arr(time_dist_curve_name) $instance_id $user_id]
        if { $p1_arr(time_dist_curve_tid) eq "" } {
            acc_fin::pretti_log_create $scenario_tid "time_dist_curve_name" "#accounts-finance.value#" "time_dist_curve_name #accounts-finance.unknown_reference#" $user_id $instance_id
        }

    }
    if { $p1_arr(cost_dist_curve_name) ne "" } {
        # set dist_curve_tid
        set p1_arr(cost_dist_curve_tid) [qss_tid_from_name $p1_arr(cost_dist_curve_name) $instance_id $user_id ]
        if { $p1_arr(cost_dist_curve_tid) eq "" } {
            acc_fin::pretti_log_create $scenario_tid "cost_dist_curve_name" "#accounts-finance.value#" "cost_dist_curve_name #accounts-finance.unknown_reference#" $user_id $instance_id
        }
    }
    
    
    set constants_exist_p 1
    set compute_message_list [list ]
    foreach constant $constants_required_list {
        if { $p1_arr($constant) eq "" } {
            set constants_exist_p 0
            lappend compute_message_list "Initial condition constant '${constant}'; #accounts-finance.unknown_reference# #accounts-finance.reference_is_required#"
            acc_fin::pretti_log_create $scenario_tid "${constant}" "#accounts-finance.value#" "${constant}; #accounts-finance.unknown_reference# #accounts-finance.reference_is_required#" $user_id $instance_id
            # This may be triggered by code/permissions unable to find p1 table. Report more info?

            set error_fail 1
        }
    }


    # # # set defaults specified in p1
    ns_log Notice "acc_fin::scenario_prettify.1369: scenario '$scenario_tid' set defaults specified in p1 table."


    # # # Make time_curve_data defaults
    ns_log Notice "acc_fin::scenario_prettify.1382: scenario '$scenario_tid' make time_curve_data defaults from p1."

    # These are the default values unless more specific data is specified in a task list.
    # The most specific information is used for each activity.
    # Median (most likely) point is assumed along the (cumulative) distribution curve, unless
    # a time_probability_moment is specified.  time_probability_moment is only available as a general term.
    #     local curve
    #     local 3-point (min,median,max)
    #     general curve (normalized to local 1 point median ); local 1 point median is minimum time data requirement
    #     general 3-point (normalized to local median)    
    set constants_list [acc_fin::pretti_columns_list dc]
    foreach constant $constants_list {
        set tc_larr($constant) [list ]
    }
    
    if { $p1_arr(time_dist_curve_tid) ne "" } {
        set table_stats_list [qss_table_stats $p1_arr(time_dist_curve_tid) $instance_id $user_id]
        set trashed_p [lindex $table_stats_list 7]
        if { [llength $table_stats_list] > 1 && !$trashed_p } {
            # get time curve into array tc_larr
            set constants_required_list [acc_fin::pretti_columns_list dc 1]
            qss_tid_columns_to_array_of_lists $p1_arr(time_dist_curve_tid) tc_larr $constants_list $constants_required_list $instance_id $user_id
            #tc_larr(x), tc_larr(y) and optionally tc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n
            ns_log Notice "acc_fin::scenario_prettify.1392: scenario '$scenario_tid' tc_larr(x) '$tc_larr(x)' tc_larr(y) '$tc_larr(y)'"
            # validate x and y values before importing
            set type_errors_count 0
            set type_errors_p 0
            set column_ck_list [list x y]
            foreach col $column_ck_list {
                set filtered_list [acc_fin::list_filter decimal $tc_larr($col) "time_dist_curve_tid: $p1_arr(time_dist_curve_tid)" $col]
                if { $filtered_list ne $tc_larr($col) } {
                    set type_errors_p 1
                }
            }
            if { $type_errors_p } {
                # undo data expansion
                set tc_larr(x) [list ]
                set tc_larr(y) [list ]
                if { [info exists tc_larr(label)] } {
                    set tc_larr(label) [list ]
                }
            }

        } else {
            acc_fin::pretti_log_create $scenario_tid "time_dist_curve_tid" "#accounts-finance.value#" "time_dist_curve #accounts-finance.unknown_reference#" $user_id $instance_id
        }
    } 
    set tc_lists [acc_fin::curve_import $tc_larr(x) $tc_larr(y) $tc_larr(label) [list ] $p1_arr(time_est_short) $p1_arr(time_est_median) $p1_arr(time_est_long) [list ] tcurve_source ]


    # # # Make cost_curve_data defaults
    ns_log Notice "acc_fin::scenario_prettify.1401 :scenario '$scenario_tid' make cost_curve_data defaults from p1."

    set constants_list [acc_fin::pretti_columns_list dc]
    foreach constant $constants_list {
        set cc_larr($constant) [list ]
    }
    if { $p1_arr(cost_dist_curve_tid) ne "" } {
        set table_stats_list [qss_table_stats $p1_arr(cost_dist_curve_tid) $instance_id $user_id]
        set trashed_p [lindex $table_stats_list 7]
        if { [llength $table_stats_list] > 1 && !$trashed_p } {
            set constants_required_list [acc_fin::pretti_columns_list dc 1]
            qss_tid_columns_to_array_of_lists $p1_arr(cost_dist_curve_tid) cc_larr $constants_list $constants_required_list $instance_id $user_id
            #cc_larr(x), cc_larr(y) and optionally cc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n
            ns_log Notice "acc_fin::scenario_prettify.1404: scenario '$scenario_tid' cc_larr(x) '$cc_larr(x)' cc_larr(y) '$cc_larr(y)'"
            # validate x and y values before importing
            set type_errors_count 0
            set type_errors_p 0
            set column_ck_list [list x y]
            foreach col $column_ck_list {
                set filtered_list [acc_fin::list_filter decimal $cc_larr($col) "cost_dist_curve_tid: $p1_arr(cost_dist_curve_tid)" $col]
                if { $filtered_list ne $cc_larr($col) } {
                    set type_errors_p 1
                }
            }
            if { $type_errors_p } {
                # undo data expansion
                set cc_larr(x) [list ]
                set cc_larr(y) [list ]
                if { [info exists cc_larr(label)] } {
                    set cc_larr(label) [list ]
                }
            }

        } else {
            acc_fin::pretti_log_create $scenario_tid "cost_dist_curve_tid" "#accounts-finance.value#" "cost_dist_curve #accounts-finance.unknown_reference#" $user_id $instance_id
        }
    }
    ns_log Notice "acc_fin::scenario_prettify.1422: scenario '$scenario_tid' cc_larr(x) '$cc_larr(x)' cc_larr(y) '$cc_larr(y)'"
    set cc_lists [acc_fin::curve_import $cc_larr(x) $cc_larr(y) $cc_larr(label) [list ] $p1_arr(cost_est_low) $p1_arr(cost_est_median) $p1_arr(cost_est_high) [list ] ccurve_source ]
    
    # curves_larr ie *_c_larr has 2 versions: time as t_c_larr and cost as c_c_larr
    # index 0 is default
    set p1_arr(_tCurveRef) [acc_fin::larr_set time_clarr $tc_lists]
    set p1_arr(_tDcSource) $tcurve_source
    #   set time_clarr(0) $tc_lists
    set p1_arr(_cCurveRef) [acc_fin::larr_set cost_clarr $cc_lists]
    set p1_arr(_cDcSource) $ccurve_source
    #    set cost_clarr(0) $cc_lists
    ns_log Notice "acc_fin::scenario_prettify.1426: scenario '$scenario_tid' default t curve: time_clarr($p1_arr(_tCurveRef)) '$tc_lists'"
    ns_log Notice "acc_fin::scenario_prettify.1427: scenario '$scenario_tid' default c curve: cost_clarr($p1_arr(_cCurveRef)) '$cc_lists'"
    
    # # # import task_types table p3
    ns_log Notice "acc_fin::scenario_prettify.1432: scenario '$scenario_tid' import task_types table p3, if any."

    # set defaults
    set constants_list [acc_fin::pretti_columns_list p3]
    foreach constant $constants_list {
        set p3_larr($constant) [list ]
    }
    # declare auxiliary variables list
    ## aux_col_names_list   is the list of auxiliary column names in p2_larr to perform auxiliary calculations identical to cost
    set aux_col_names_list [list ]

    if { $p1_arr(task_types_tid) ne "" } {
        set table_stats_list [qss_table_stats $p1_arr(task_types_tid) $instance_id $user_id]
        set trashed_p [lindex $table_stats_list 7]
        if { [llength $table_stats_list] > 1 && !$trashed_p } {
            set constants_required_list [acc_fin::pretti_columns_list p3 1]
            ns_log Notice "acc_fin::scenario_prettify.1459: scenario '$scenario_tid' import task_types from '$p1_arr(task_types_tid)'."
            if { $error_fail == 0 } {
                if { [acc_fin::p_load_tid $constants_list $constants_required_list p3_larr $p1_arr(task_types_tid) "" $instance_id $user_id] } {
                    ns_log Notice "acc_fin::scenario_prettify.1460: scenario '$scenario_tid' p3_larr '[array get p3_larr]'"
                    
                    # validate decimal values before importing
                    set type_errors_count 0
                    set type_errors_p 0
                    set column_maybe_ck_list [list max_concurrent max_discount_pct max_run_time max_tasks_per_run max_overlap_pct time_dist_curve_tid cost_dist_curve_tid time_est_short time_est_median time_est_long cost_est_low cost_est_median cost_est_high]
                    set column_ck_list [list ]
                    set titles_list [array names p3_larr]
                    # collect titles that are in p3_larr that should be checked
                    foreach col $column_maybe_ck_list {
                        if { [lsearch -exact $titles_list $col] > -1 } {
                            lappend column_ck_list $col
                        }
                    }
                    # check data for each column
                    foreach col $column_ck_list {
                        if { [string range $col end-3 end] eq "_tid" } {
                            set filtered_list [acc_fin::list_filter natnum $p3_larr($col) p3 $col]
                        } else {
                            set filtered_list [acc_fin::list_filter decimal $p3_larr($col) p3 $col]
                        }
                        if { $filtered_list ne $p3_larr($col) } {
                            set type_errors_p 1
                        }
                    }
                    set index_eq ""
                    if { $p1_arr(index_equation) ne "" } {
                        # validate equation or set empty
                        # only allow + - / * $, logical comparisions > < == != and numbers.  $number converts to one of the available row numbers that returns a number from in p4 
                        regsub -nocase -all -- {[^\$\/\+\-\*\(\)\.\<\>\=\!\ 0-9]+} $p1_arr(index_equation) "" index_eq
                        # add extra spaces to help expr avoid misinterpretations, but can't assume that for negative numbers vs. minus sign
                        regsub -nocase -all -- {([\/\+\*\(\)])} $index_eq " \1 " index_eq
                        # get rid of extra spaces
                        regsub -nocase -all -- {[ ]+} $index_eq " " index_eq
                        set vars_list [list ]
                        foreach {var0 var1 scratch} [acc_fin::pretti_equation_vars ] {
                            set var2 " $"
                            append var2 $var0
                            set var3 " \[qaf_fp ${"
                            append var3 $var1
                            append var3 "} \] "
                            regsub -nocase -all -- $var2 $index_eq $var3 index_eq
                        }
                        # unqoute the brackets
                        regsub -nocase -all -- {[\\]} $index_eq {} index_eq
                        
                    }
                    if { $type_errors_p } {
                        # undo data expansion
                        foreach title $titles_list {
                            set p3_larr($title) [list ]
                        }
                    }
                } else {
                    set error_fail 1
                    acc_fin::pretti_log_create $scenario_tid "p_load_tid" "operation" "#accounts-finance.error# 'type_table'; #accounts-finance.table_load_error# (ref1390)" $user_id $instance_id
                }
            }
        } else {
            acc_fin::pretti_log_create $scenario_tid "task_types_tid" "#accounts-finance.value#" "task_types_tid #accounts-finance.unknown_reference#" $user_id $instance_id
            set error_fail 1
        }
    }
    # The multi-layered aspect of curve data storage needs a double-pointer to be efficient for projects with large memory footprints
    # act_curve_arr($act) => curve_ref
    # type_t_curve_arr($type) => curve_ref
    # type_c_curve_arr($type) => curve_ref
    # tid_curve_arr($tid) => curve_ref
    # where curve_ref is index of curves_lol
    # where curve_ref = 0 is default
    # so, add a p2_larr(_cCurveRef) and p2_larr(_tCurveRef) column which references curves_lol
    #  similarly, add a p3_larr(_cCurveRef) and p3_larr(_tCurveRef) column
    if { $error_fail == 0 } {
        # # # import activity table p2
        ns_log Notice "acc_fin::scenario_prettify.1465: scenario '$scenario_tid' import activity table p2 (required)."


        #### Use lsearch -glob or -regexp to screen alt columns and create list for custom summary feature. [a-z][0-9]
        #### ..connected to cost_probability_moment.. so columns represent curve IDs..
        #### Use [lsearch -regexp {[a-z][0-9]s} -all -inline $x_list] to screen alt time columns and create list for a scheduling feature.
        #### also ta,twa,tna for time_actual, time_waypoint_actual time_node_actual etc.  
        # set defaults
        set constants_list [acc_fin::pretti_columns_list p2]
        foreach constant $constants_list {
            set p2_larr($constant) [list ]
        }

        if { $p1_arr(activity_table_tid) ne "" } {
            set table_stats_list [qss_table_stats $p1_arr(activity_table_tid) $instance_id $user_id]
            set trashed_p [lindex $table_stats_list 7]
            #        ns_log Notice "acc_fin::scenario_prettify.1443: llength table_stats_list [llength $table_stats_list] '$table_stats_list'"
            if { [llength $table_stats_list] > 1 && !$trashed_p && $error_fail == 0 } {
                # load activity table
                set constants_required_list [acc_fin::pretti_columns_list p2 1]
                ns_log Notice "acc_fin::scenario_prettify.1495: scenario '$scenario_tid' import activity_table_tid from '$p1_arr(activity_table_tid)'."
                if { $error_fail == 0 } {
                    if { [acc_fin::p_load_tid $constants_list $constants_required_list p2_larr $p1_arr(activity_table_tid) p3_larr $instance_id $user_id] } {
                        #### aux_col_names_list is now complete. Set an error flag for each in aux_error_p_arr()
                        foreach nam $aux_col_names_list {
                            set aux_error_p_arr($nam) 0
                        }
                        # filter user input
                        set p2_larr(activity_ref) [acc_fin::list_filter alphanum $p2_larr(activity_ref) "p2" "activity_ref"]
                        set p2_larr(dependent_tasks) [acc_fin::list_filter factorlist $p2_larr(dependent_tasks) "p2" "dependent_tasks"]
                    } else {
                        set error_fail 1
                        acc_fin::pretti_log_create $scenario_tid "activity_table_tid" "#accounts-finance.value#" "#accounts-finance.error# 'activity_table' #accounts-finance.table_load_error# (ref1490)" $user_id $instance_id
                    }
                }
            } else {
                acc_fin::pretti_log_create $scenario_tid "activity_table_tid" "#accounts-finance.value#" "activity_table_tid #accounts-finance.unknown_reference# #accounts-finance.reference_is_required# (ref1450)" $user_id $instance_id
                set error_fail 1
            }
        } else {
            acc_fin::pretti_log_create $scenario_tid "activity_table_tid" "#accounts-finance.value#" "activity_table_tid #accounts-finance.unknown_reference# #accounts-finance.reference_is_required# (ref1453)" $user_id $instance_id
            set error_fail 1
        }
    }    
    # Substitute task_type data (p3_larr) into activity data (p2_larr) when p2_larr data is less detailed or missing.
    # Curve data has already been substituted in p_load_tid
    # Other substitutions when a p2_larr field is blank.
    
    if { $error_fail == 0 } {
        # Effectively, p2 imports parts of p3 that are more detailed than p2, to build the final p2 activity table
        # p3 includes default modifiers from p1 as well.
        
        set constants_woc_list [list name description max_concurrent max_discount_pct max_run_time max_tasks_per_run max_overlap_pct ]
        # _woc_ = without curve data (or columns)
        # Removed dependent_tasks from task_type substitution, 
        # because dependent_tasks creates a level of complexity significant enough to be avoided
        # through program set-up at this time.
        set p3_type_list $p3_larr(type)
        set p2_task_type_list $p2_larr(aid_type)
        ## activities_list  list of activities to process
        set activities_list $p2_larr(activity_ref)
        ns_log Notice "acc_fin::scenario_prettify.1500: scenario '$scenario_tid' activities_list '${activities_list}'"     
        foreach constant $constants_woc_list {
            if { [llength $p2_larr(aid_type) ] > 0 && [llength $p3_larr($constant)] > 0 } {
                set i 0
                set p2_col_list $p2_larr($constant)
                set p2_col_list_len [llength $p2_larr($constant) ]
                foreach act $activities_list {
                    set p2_value [lindex $p2_col_list $i]
                    if { $p2_value eq "" } {
                        # if p2 value is blank, try to get value from p3 table
                        set ii [lsearch -exact $p3_type_list [lindex $p2_task_type_list $i]]
                        if { $ii > -1 && $i < $p2_col_list_len } {
                            set p2_col_list [lreplace $p2_col_list $i $i [lindex $p3_larr($constant) $ii] ]
                        }  else {
                            # warn that value is blank in p2 and p3 tables?  No.
                            # Just "name" or "description" so no need to warn..
                        }
                    }
                    incr i
                }
                set p2_larr($constant) $p2_col_list
            }
        }
        
        # # # Confirm that dependent activities exist as activities.
        ns_log Notice "acc_fin::scenario_prettify.1527: scenario '$scenario_tid' Confirm p2 dependents exist as activities, expand dependents with coefficients."
    }

    
    if { $error_fail == 0 } {
        #  Expand p2_larr to include dependent activities with coefficients.
        #  by appending new definitions of tasks that don't yet have defined coefficients.
        
        
        ns_log Notice "acc_fin::scenario_prettify.1529: scenario '$scenario_tid' activities_list '${activities_list}'"     
        ns_log Notice "acc_fin::scenario_prettify.1531: scenario '$scenario_tid' p2_larr(dependent_tasks) '$p2_larr(dependent_tasks)'"   
        set row_nbr 0
        foreach dependencies_list $p2_larr(dependent_tasks) {
            ns_log Notice "acc_fin::scenario_prettify.1533: scenario '$scenario_tid' dependencies_list '${dependencies_list}'"     
            set base_activity [lindex $activities_list $row_nbr]
            foreach activity $dependencies_list {
                ns_log Notice "acc_fin::scenario_prettify.1535: scenario '$scenario_tid' activity '${activity}'"
                if { $activity eq $base_activity } {
                    # activity is dependent on itself. Throw an error.
                    set error_fail 1
                    acc_fin::pretti_log_create $scenario_tid $activity "#accounts-finance.value#" "Activity '${activity}'; #accounts-finance.dependent_circular_reference. (ref2188)" $user_id $instance_id
                }
                if { [lsearch -exact $activities_list $activity] == -1 } {
                    # A dependent activity doesn't exist..
                    ns_log Notice "acc_fin::scenario_prettify.1619: scenario '$scenario_tid' activity '$activity' doesn't exist on direct search."
                    set term ""
                    set coefficient ""
                    # Is $activity an existing activity, but referenced with a coeffient?
                    set scratch ""
                    
                    if { [regexp -- {^([0-9]+)[\*]([^\*]+)} $activity scratch coefficient term] } {
                        ns_log Notice "acc_fin::scenario_prettify.1624: scenario '$scenario_tid' activity '$activity' is part coefficient '$coefficient' and part term '$term'"
                        # If $term is a defined activity, get index
                        set term_idx [lsearch -exact $activities_list $term]
                        if { $term_idx > -1 } {
                            # Requirements met: There is a coefficient and an existing activity.
                            ns_log Notice "acc_fin::scenario_prettify.1632: scenario '$scenario_tid' term '$term' exists as an activity, so creating new activity with coefficient '${activity}'."
                            # Generate a new activity with coeffient for this run.
                            set larr_len [expr { [llength $activities_list] - 2 } ]
                            foreach constant $constants_list {
                                ns_log Notice "acc_fin::scenario_prettify.1639: scenario '$scenario_tid' larr_len $larr_len term_idx $term_idx constant $constant"
                                if { [llength $p2_larr($constant) ] > $larr_len } {
                                    lappend p2_larr($constant) [lindex $p2_larr($constant) $term_idx]
                                }

                            }
                            lappend p2_larr(_coef) $coefficient
                            lappend activities_list $activity
                            set use_t_run_p 0
                            set t_constrained_by_time_p 0
                            # create new tCurves and cCurves and references to them.
                            set tcurvenum [lindex $p2_larr(_tCurveRef) $term_idx]

                            
                            if { $tcurvenum ne "" && $error_time == 0 } {

                                set max_overlap_pct_idx [lsearch -exact $constants_list "max_overlap_pct"]
                                set max_overlap_pct $p1_arr(max_overlap_pct)
                                if { $max_overlap_pct_idx > -1 && [llength $p2_larr(max_overlap_pct)] > 0 } {
                                    set test [lindex $p2_larr(max_overlap_pct) $term_idx]
                                    if { $test ne "" } {
                                        set max_overlap_pct $test
                                    }
                                }

                                set max_concurrent_idx [lsearch -exact $constants_list "max_concurrent"]
                                set max_concurrent $p1_arr(max_concurrent)
                                if { $max_concurrent_idx > -1 && [llength $p2_larr(max_concurrent)] > 0 } {
                                    set test [lindex $p2_larr(max_concurrent) $term_idx]
                                    if { $test ne "" } {
                                        set max_concurrent $test
                                    }
                                }

                                set max_run_time_idx [lsearch -exact $constants_list "max_run_time"]
                                set max_run_time $p1_arr(max_run_time)
                                if { $max_run_time_idx > -1 && [llength $p2_larr(max_run_time)] > 0 } {
                                    set test [lindex $p2_larr(max_run_time) $term_idx]
                                    if { $test ne "" } {
                                        set max_run_time $test
                                    }
                                }

                                set max_tasks_per_run_idx [lsearch -exact $constants_list "max_tasks_per_run"]
                                set max_tasks_per_run $p1_arr(max_tasks_per_run)
                                if { $max_tasks_per_run_idx > -1 && [llength $p2_larr(max_tasks_per_run)] > 0 } {
                                    set test [lindex $p2_larr(max_tasks_per_run) $term_idx]
                                    if { $test ne "" } {
                                        set max_tasks_per_run $test
                                    }
                                }


                                set curve_lol [acc_fin::pretti_curve_time_multiply "" $tcurvenum $coefficient $scenario_id $user_id $instance_id ]

                                # These are run time constraints for multiples of an activity, passed back from acc_fin::pretti_curve_time_multiply
                                set act_maxtpr_arr(${activity}) $max_tasks_per_run
                                set act_maxrt_arr(${activity}) $max_run_time
                                set act_maxol_arr(${activity}) $max_overlap_pct
                                set act_maxcc_arr(${activity}) $max_concurrent

                                # save new curve
                                
                                set tcurvenum [acc_fin::larr_set time_clarr $curve_lol]
                                # save new reference
                                lappend p2_larr(_tCurveRef) $tcurvenum
                                set act_tcref($activity) [lindex $p2_larr(_tCurveRef) $i]

                                lappend p2_larr(_tDcSource) 7
                                ns_log Notice "acc_fin::scenario_prettify.1674: scenario '$scenario_tid' new t curve: time_clarr($tcurvenum) '$curve_lol'"
                            } else {
                                lappend p2_larr(_tCurveRef) ""
                                lappend p2_larr(_tDcSource) ""
                                set act_tcref($activity) ""
                                ns_log Warning "acc_fin::scenario_prettify.1676: scenario '$scenario_tid' NO tcurvenum for '$curve_lol'"
                            }

                            set ccurvenum [lindex $p2_larr(_cCurveRef) $term_idx]
                            if { [lindex $p2_larr(_cCurveRef) $term_idx] ne "" && $error_cost == 0 } {

                                set curve_lol [acc_fin::pretti_curve_cost_multiply "" $ccurvenum $coefficient $scenario_id $user_id $instance_id ]
                                set act_maxd_arr(${activity}) $max_discount_pct

                                # save new curve
                                set ccurvenum [acc_fin::larr_set cost_clarr $curve_lol]
                                # save new reference
                                lappend p2_larr(_cCurveRef) $ccurvenum
                                set act_ccref($activity) [lindex $p2_larr(_cCurveRef) $i]
                                lappend p2_larr(_cDcSource) 7
                                ns_log Notice "acc_fin::scenario_prettify.1694: scenario '$scenario_tid' new c curve: cost_clarr($ccurvenum) '$curve_lol'"
                            } else {
                                lappend p2_larr(_cCurveRef) ""
                                lappend p2_larr(_cDcSource) ""
                                set act_ccref($activity) ""
                            }
                            ns_log Notice "acc_fin::scenario_prettify.1700: scenario '$scenario_tid' term '$term' tcurvenum '$tcurvenum' ccurvenum '$ccurvenum'"
                        } else {
                            # No activity defined for this factor (term with coefficient), flag an error --missing dependency.
                            lappend compute_message_list "Dependency '${term}' is undefined, referenced in: '${activity}'."
                            acc_fin::pretti_log_create $scenario_tid "${term}" "#accounts-finance.value#" "#accounts-finance.dependent# '${term}'; #accounts-finance.activity# '${activity}'; #accounts-finance.unknown_reference# (ref1576)" $user_id $instance_id
                            set error_fail 1
                        }
                    } else {
                        # No activity defined for this factor (term with coefficient), flag an error --missing dependency.
                        lappend compute_message_list "Dependency '${activity}' is an undefined activity."
                        acc_fin::pretti_log_create $scenario_tid "${activity}" "#accounts-finance.value#" "#accounts-finanace.dependent# #accounts-finance.activity# '${activity}'; #accounts-finance.unknown_reference#  (ref1582)" $user_id $instance_id
                        set error_fail 1
                    }
                }
                # else, an activity for the dependency exists. Do nothing.
            }
            incr row_nbr
        }
    }
    
    if { $error_fail == 0 } {
        # # # Multiple probability_moments allowed
        set t_moment_list [split $p1_arr(time_probability_moment)]
        if { $p1_arr(cost_probability_moment) ne "" } {
            set c_moment_list [split $p1_arr(cost_probability_moment)]
            set c_moment_blank_p 0
            ns_log Notice "acc_fin::scenario_prettify.1733: scenario '$scenario_tid' prepare p1 time '${t_moment_list}'and cost '${c_moment_list}' probability_moment loops."
        } else {
            set c_moment_blank_p 1
        }
        ns_log Notice "acc_fin::scenario_prettify.1750: scenario '$scenario_tid' prepare p1 time '${t_moment_list}'and c_moment_blank_p ${c_moment_blank_p}."
        
        
        # Be sure any new values are nullified between each loop
        set setup_end [clock seconds]
        set time_start [clock seconds]
        foreach t_moment $t_moment_list {
            
            # Calculate base durations for time_probability_moment. These work for activities and task types.
            array unset t_est_arr
            if { $p1_arr(pert_omp) eq "strict" && $t_moment == .5 } {
                # use PERT expected value (O + 4M + P )/6/
                foreach tCurve [array names time_clarr] {
                    set o [qaf_y_of_x_dist_curve 0. $time_clarr($tCurve) ]
                    set m [qaf_y_of_x_dist_curve .5 $time_clarr($tCurve) ]
                    set p [qaf_y_of_x_dist_curve 1. $time_clarr($tCurve) ]
                    set t_est_arr($tCurve) [expr { ( $o + 4. * $m + $p ) / 6. } ]
                    ns_log Notice "acc_fin::scenario_prettify.1754: scenario '$scenario_tid' tCurve '$tCurve' t_est_arr($tCurve) '$t_est_arr($tCurve)' ."
                }
            } else {
                foreach tCurve [array names time_clarr] {
                    set t_est_arr($tCurve) [qaf_y_of_x_dist_curve $t_moment $time_clarr($tCurve) ]
                    ns_log Notice "acc_fin::scenario_prettify.1756: scenario '$scenario_tid' tCurve '$tCurve' t_est_arr($tCurve) '$t_est_arr($tCurve)' ."
                }
            }
            if { $c_moment_blank_p } {
                # if cost_probability_moment is blank, loop 1:1 using time_probability_moment values
                set c_moment_list [list $t_moment]
            }
            foreach c_moment $c_moment_list {
                # Calculate base costs for cost_probability_moment. These work for activities and task types.
                array unset c_est_arr
                foreach cCurve [array names cost_clarr] {
                    set c_est_arr($cCurve) [qaf_y_of_x_dist_curve $c_moment $cost_clarr($cCurve) ]
                }
                # Create activity time estimate and cost estimate arrays for repeated use in main loop
                # These arrays vary in values by t_moment and c_moment
                set i 0
                array unset act_time_expected_arr
                array unset act_cost_expected_arr
                array unset cw_arr
                array unset depnc_eq_arr
                
                foreach act $activities_list {
                    # first paths are single activities, so following line of code doesn't seem significant.
                    # It's just here so that internal representation is consistent.
                    set act_list [list $act]
                    # use this loop to intialize empty array:
                    set path_idxs_in_act_larr($act) [list ]

                    # the first paths are single activities, subsequently time expected and duration are same values
                    set tref [lindex $p2_larr(_tCurveRef) $i]
                    if { $tref ne "" } {
                        set time_expected $t_est_arr($tref)
                        ## act_time_expected_arr(act) is the time expected to complete an activity
                        set act_time_expected_arr($act) $time_expected
                        ## tn_arr(act) is the time expected to complete an activity and its dependents
                        set tn_arr($act) $time_expected
                    } else {
                        ns_log Warning "acc_fin::scenario_prettify.1763: scenario '$scenario_tid' act '$act' tref '${tref}' p2_larr(_tCurveRef) '$p2_larr(_tCurveRef)'"
                        acc_fin::pretti_log_create $scenario_tid "${act}" "#accounts-finance.value#" "#accounts-finance.activity# '${act}'; #accounts-finance.duration# #accounts-finance.unknown_reference# (ref1763)" $user_id $instance_id
                        set error_time 1
                    }

                    # the first paths are single activities, subsequently cost expected and path segment costs are same values
                    set cref [lindex $p2_larr(_cCurveRef) $i]
                    if { $cref ne "" } {
                        set cost_expected $c_est_arr($cref)
                        ## act_cost_expected_arr(act) is the cost expected to complete an activity
                        set act_cost_expected_arr($act) $cost_expected
                        ## cn_arr(act) is the cost expected to complete an activity and its dependents
                        set cn_arr($act) $cost_expected
                    } else {
                        ns_log Warning "acc_fin::scenario_prettify.1773: scenario '$scenario_tid' act '$act' cref '${cref}' p2_larr(_cCurveRef) '$p2_larr(_cCurveRef)'"
                        acc_fin::pretti_log_create $scenario_tid "${act}" "#accounts-finance.value#" "#accounts-finance.activity# '${act}'; #accounts-finance.cost# #accounts-finance.unknown_reference# (ref1773)" $user_id $instance_id
                        set error_cost 1
                    }

                    ##### add aux_col_name calcs here that reflect cost ones.
                    ## ref i , create aux_act_cost_expected_arr(act),  aux_cn_arr(act) from lindex p2_larr(aux_col) i

                    incr i
                }
                
                # handy api ref
                # util_commify_number
                # format "% 8.2f" $num
                
                # PERTTI calculations
                
                # Build activity dependent map
                ns_log Notice "acc_fin::scenario_prettify.1783: scenario '$scenario_tid' build activity dependents map and sequences for t_moment '${t_moment}' c_moment '${c_moment}'"
                #  activity map table:  depnc_larr($activity_ref) dependent_tasks_list
                #  array of activity_ref sequence_num: act_seq_num_arr($activity_ref) sequence_number
                
                # An activity_ref's sequence is one more than the max sequence_num of its dependencies
                set i 0
                set sequence_1 0
                array unset act_seq_num_arr
                array unset dependencies_larr
                array unset act_calculated_p_larr

                if { $error_fail == 0 } {
                    foreach act $activities_list {
                        #   depnc: comma list of activity's dependencies
                        set depnc [lindex $p2_larr(dependent_tasks) $i]
                        ## t_dc_source_arr(act) answers Q: what is source of time distribution curve?
                        set t_dc_source_arr($act) [lindex $p2_larr(_tDcSource) $i ]
                        ## c_dc_source_arr(act) answers Q: what is source of cost distribution curve?
                        set c_dc_source_arr($act) [lindex $p2_larr(_cDcSource) $i ]
                        
                        # Filter out any blanks
                        set scratch_list [split $depnc ";, "]
                        set scratch2_list [list ]
                        foreach dep $scratch_list {
                            if { $dep ne "" } {
                                lappend scratch2_list $dep
                            }
                        }
                        ##   dependencies_larr() is a list of direct dependencies for each activity
                        set dependencies_larr($act) $scratch2_list
                        set act_calculated_p_larr($act) 0
                        ns_log Notice "acc_fin::scenario_prettify.1793: scenario '$scenario_tid' set act_calculated_p_larr($act) 0 len \$act [string length $act]"

                        ##   act_seq_num_arr is relative sequence number of an activity in it's path. 
                        set act_seq_num_arr($act) $sequence_1
                        ## act_coef(act) is the coefficient of an activity. If activity is defined as a multiple of another activity, it is an integer greater than 1 otherwise 1.
                        set act_coef($act) [lindex $p2_larr(_coef) $i]
                        set act_tcref($act) [lindex $p2_larr(_tCurveRef) $i]
                        set act_ccref($act) [lindex $p2_larr(_cCurveRef) $i]
                        incr i
                    }
                }

                
                # Calculate paths in the main loop to save resources.
                #  Each path is a list of numbers referenced by array, where 
                #  array indexes last path activity (of a dependency track).
                #  set path_segment_ends_in_lists($act) 
                #  so future segments can quickly reference it to build theirs.
                
                # a ptrack (partial track) is an incomplete path
                
                # This keeps path making nearly linear. There are up to as many path tree references as there are activities..
                
                # Since some activities depend on others, some of the references are ptracks.
                
                # All paths must be assessed in order to handle all possibilities
                # Paths are used to determine critical path and fast crawl a single path.
                
                # An activity cannot start until the longest dependent segment (branch) has completed.
                
                # For strict critical path, create a list of lists, where 
                # each list is a list of activity and dependencies from start to finish (aka path). 
                # The longest duration path is the strict defintion of critical path.

                # create dependency check equations
                ns_log Notice "acc_fin::scenario_prettify.1797: scenario '$scenario_tid' create equations for checking if dependencies are met."
                
                # # # main process looping
                ns_log Notice "acc_fin::scenario_prettify.2284: scenario '$scenario_tid' begin main process"
                
                array unset act_seq_list_arr
                array unset act_count_of_seq_arr
                #array unset tn_arr
                #array unset cn_arr
                array unset subtrees_larr
                array unset path_tree_p_arr
                set all_paths_calculated_p 0
                ## activity_count is length activities_list
                set activity_count [llength $activities_list]
                set i 0
                set act_seq_list_arr(${sequence_1}) [list ]
                ##   act_count_of_seq_arr( sequence_number) is the count of activities at this sequence number across all paths, 0 is first sequence number
                set act_count_of_seq_arr(${sequence_1}) 0
                set tree_seg_dur_lists [list ]
                if { $error_fail == 0 } {                    
                    while { $all_paths_calculated_p == 0 && $i < $activity_count } {
                        ns_log Notice "acc_fin::scenario_prettify.2300: scenario '$scenario_tid' new calc loop"
                        set all_paths_calculated_p 1
                        foreach act $activities_list {
                            ##   act_seq_max is the maximum path length in context of sequence_number
                            set act_seq_max $sequence_1
                            ns_log Notice "acc_fin::scenario_prettify.2304: scenario '$scenario_tid' act $act act_seq_max ${act_seq_max}"

                            # Are dependencies met for this activity?
                            set dependencies_met_p 1
                            foreach dep $dependencies_larr($act) {
                                ns_log Notice "acc_fin::scenario_prettify.2308: scenario '$scenario_tid' act $act dep $dep act_calculated_p_larr($dep) '$act_calculated_p_larr($dep)' len \$dep [string length $dep]"
                                if { $act_calculated_p_larr($dep) == 0 } {
                                    set dependencies_met_p 0
                                }
                            }

                            if { $dependencies_met_p && $act_calculated_p_larr($act) == 0 } {
                                # Calc max_num: maximum relative sequence number for activity dependencies
                                set max_num 0
                                foreach test_act $dependencies_larr($act) {
                                    set test $act_seq_num_arr(${test_act})
                                    if { $max_num < $test } {
                                        set max_num $test
                                    }
                                }
                                
                                # Add activity's relative sequence number: act_seq_num_arr
                                set act_seq_nbr [expr { $max_num + 1 } ]
                                set act_seq_num_arr($act) $act_seq_nbr
                                
                                # increment act_seq_max and set defaults for a new max seq number?
                                if { $act_seq_nbr > $act_seq_max } {
                                    set act_seq_max $act_seq_nbr
                                    set act_seq_list_arr(${act_seq_max}) [list ]
                                    set act_count_of_seq_arr(${act_seq_max}) 0
                                }
                                # add activity to the network for this sequence number
                                lappend act_seq_list_arr(${act_seq_nbr}) $act
                                incr act_count_of_seq_arr(${act_seq_nbr})
                                
                                # Calculations including dependents
                                if { !$error_time } {
                                    # branches_duration_max is the min. path duration to complete dependent paths
                                    # set branches_duration_max to the longest duration of dependent segments.
                                    set branches_duration_max 0.
                                    foreach dep_act $dependencies_larr($act) {
                                        if { $tn_arr(${dep_act}) > $branches_duration_max } {
                                            set branches_duration_max $tn_arr(${dep_act})
                                        }
                                    }
                                    ##   tn_arr(act) is duration of ptrack up to (and including) activity.
                                    set tn_arr($act) [expr { $branches_duration_max + $act_time_expected_arr($act) } ]
                                    ns_log Notice "acc_fin::scenario_prettify.2384: scenario '$scenario_tid' act $act tn_arr($act) $tn_arr($act)"
                                }
                                if { !$error_cost } {
                                    set paths_cost_sum 0.
                                    foreach dep_act $dependencies_larr($act) {
                                        #   paths_cost_sum is sum of costs for each dependent ptrack
                                        #was set paths_cost_sum [expr { $paths_cost_sum + $act_cost_expected_arr(${dep_act}) } ]
                                        ns_log Notice "acc_fin::scenario_prettify.2392: scenario '$scenario_tid' act $act cn_arr($act) $cn_arr($act) paths_cost_sum $paths_cost_sum + cn_arr({$dep_act}) $cn_arr(${dep_act})"
                                        set paths_cost_sum [expr { $paths_cost_sum + $cn_arr(${dep_act}) } ]
                                    }
                                    ##   cn_arr is cost of all dependent ptrack plus cost of activity
                                    set cn_arr($act) [expr { $paths_cost_sum + $act_cost_expected_arr($act) } ]
                                    ns_log Notice "acc_fin::scenario_prettify.2394: scenario '$scenario_tid' act $act cn_arr($act) $cn_arr($act)"
                                }
                                
                                # subtrees_larr(activity) is an array of list of ptracks ending with trunk activity
                                #   paths (or ptracks) represented as a list of activity lists in chronological order (last acitivty last).
                                #   For example, if A depends on B and C, and C depends on D, and A depends on F then:
                                #   subtrees_larr(A) == (list (list B A) (list D C A ) (list F A) )
                                set subtrees_larr($act) [list ]
                                set dependents_count_arr($act) 0
                                foreach dep_act $dependencies_larr($act) {
                                    foreach path_list $subtrees_larr(${dep_act}) {
                                        # Mark which tracks are complete (not partial track segments), 
                                        # so that total program cost calculations don't include duplicate, incomplete ptracks
                                        ## path_tree_p_arr answers question: is this tree of ptracks complete (ie not a subset of another track or tree)?
                                        set path_tree_p_arr($dep_act) 0
                                        set path_tree_p_arr($act) 1
                                        set path_new_list $path_list
                                        lappend path_new_list $act
                                        lappend subtrees_larr($act) $path_new_list
                                    }
                                    ## dependents_count_arr(act) is count number of activities in each subtree, not including the activity itself.
                                    set dependents_count_arr($act) [expr { $dependents_count_arr($act) + $dependents_count_arr($dep_act) + 1 } ]
                                }
                                if { [llength $subtrees_larr($act)] eq 0 } {
                                    lappend subtrees_larr($act) $act
                                    set path_tree_p_arr($act) 1
                                }

                                # activity calculated
                                set act_calculated_p_larr($act) 1
                            }

                            if { $dependencies_met_p == 0 } {
                                set all_paths_calculated_p 0
                            }
                        }
                        incr i
                    }
                    # end while all_paths_calculated_p == 0
                    
                    # # # Curve calculations complete for t_moment and c_moment.
                    ns_log Notice "acc_fin::scenario_prettify.2402: scenario '$scenario_tid' Curve calculations completed for t_moment and c_moment. "
                    
                    
                    set all_deps_met_p 1
                    foreach act $activities_list {
                        set dependencies_met_p 1
                        foreach dep $dependencies_larr($act) {
                            ns_log Notice "acc_fin::scenario_prettify.2409: scenario '$scenario_tid' dep $dep act_calculated_p_larr($dep) '$act_calculated_p_larr($dep)' len \$dep [string length $dep]"
                            if { $act_calculated_p_larr($dep) == 0 } {
                                set dependencies_met_p 0
                            }
                        }
                        if { $dependencies_met_p == 0 } {
                            set all_deps_met_p 0
                        }
                        # ns_log Notice "acc_fin::scenario_prettify: act $act act_seq_num_arr '$act_seq_num_arr($act)'"
                        # ns_log Notice "acc_fin::scenario_prettify: act_seq_list_arr '$act_seq_list_arr($act_seq_num_arr($act))' $act_count_of_seq_arr($act_seq_num_arr($act))"
                    }
                    ns_log Notice "acc_fin::scenario_prettify.2416: scenario '$scenario_tid' All dependencies met? 1 = yes. all_deps_met_p $all_deps_met_p"
                    if { $all_deps_met_p == 0 } {
                        set hint "Hint: activities "
                        set separator ""
                        foreach act $activities_list {
                            # act_seq_num_arr in next check may be redundant.
                            if { $act_calculated_p_larr($act) == 0 && $act_seq_num_arr($act) == 0 } {
                                append hint $separator $act
                                set separator ", "
                            }
                        }
                        append hint "."
                        set error_fail 1
                        acc_fin::pretti_log_create $scenario_tid "all_deps_met_p" "#accounts-finance.value#" "#accounts-finance.dependencies_not_met_error# (ref2609) #accounts-finance.hint# $hint" $user_id $instance_id
                        
                    }

                }
                # # # compile results for report
                ns_log Notice "acc_fin::scenario_prettify.2431: scenario '$scenario_tid' compile results for report."
                if { $error_fail == 0 } {
                    
                    #   paths_lists is a list of (full paths, subtotal duration, subtotal cost)
                    set paths_lists [list ]
                    set path_idx 0
                    set act_count_max 0
                    foreach act $activities_list {
                        # Remove partial tracks from subtrees by placing only paths in paths_lists
                        ns_log Notice "acc_fin::scenario_prettify.2485: scenario '$scenario_tid' path_tree_p_arr($act) '$path_tree_p_arr($act)' "

                        if { $path_tree_p_arr($act) } {
                            # subtrees_larr($act) is a tree of full paths here.
                            # Expand path trees to a list of paths
                            foreach path_list $subtrees_larr($act) {
                                # build a sortable list
                                set row_list [list ]
                                
                                # paths_lists 0
                                lappend row_list $path_idx
                                
                                set paths_arr(${path_idx}) $path_list

                                # create a reverse lookup array for every activity so that path properties can be referenced from an activity:
                                foreach acty $path_list {
                                    lappend path_idxs_in_act_larr(${acty}) $path_idx
                                }

                                if { !$error_time } {
                                    # calculate no-float, no-lag duration for each path
                                    set path_duration  0.
                                    set ptrack_list [list ]
                                    foreach pa $path_list {
                                        lappend ptrack_list $pa
                                        # subtotal
                                        set path_duration [expr { $path_duration + $act_time_expected_arr($pa) } ]
                                        set ptrack_dur_arr($ptrack_list) $path_duration
                                        set tw_arr(${path_idx},$pa) $path_duration
                                    }
                                    # save this for later reporting
                                    # set path_dur_arr($path_list) $path_duration
                                    # duplicative. ptrack_dur_arr($ptrack_list) = path_dur_arr($path_list) here
                                } else {
                                    set path_duration ""
                                }
                                # paths_lists 1
                                set path_duration_arr(${path_idx}) $path_duration
                                lappend row_list $path_duration
                                
                                if { !$error_cost } {
                                    # calculate cost for each path. 
                                    set path_cost 0.
                                    set ptrack_list [list ]
                                    # Since paths share activities, some costs are duplicative and so do not total these between paths
                                    foreach pa $path_list {
                                        lappend ptrack_list $pa
                                        # subtotal
                                        set path_cost [expr { $path_cost + $act_cost_expected_arr($pa) } ]
                                        set cw_arr(${path_idx},$pa) $path_cost
                                    }
                                    # save this for later reporting
                                    ###set cn_arr($path_list) $path_cost
                                    #### duplicative. see above.
                                } else {
                                    set path_cost ""
                                }
                                # paths_lists 2
                                set cw_arr(${path_idx}) $path_cost
                                lappend row_list $path_cost
                                
                                # if duration and cost are unavailable, list will be sorted by longest path..
                                # paths_lists 3
                                set path_len [llength $path_list ]
                                ## path_len_arr(path_idx) is length of path list
                                set path_len_arr(${path_idx}) $path_len
                                lappend row_list $path_len
                                
                                # max of path_len is same as act_count_max
                                if { $path_len > $act_count_max } {
                                    set act_count_max $path_len
                                }
                                
                                set path_len_w_coef 0
                                foreach pa $path_list {
                                    incr path_len_w_coef $act_coef($pa)
                                }
                                # paths_lists 4
                                ## path_len_w_coef_arr is total number of activities in a path (with coefficients)
                                set path_len_w_coef_arr(${path_idx}) $path_len_w_coef
                                lappend row_list $path_len_w_coef
                                # adding empty list incase of index_custom later
                                lappend row_list ""
                                lappend paths_lists $row_list
                                incr path_idx
                            }
                        }
                    }
                    ## paths_count is the number of paths ie length of paths_list
                    set paths_count [expr { $path_idx - 1 } ]
                    ## paths_list: (list path_arr_idx duration cost length length_w_coefs )
                    
                    if { !$error_time } {
                        # sort by path duration
                        # critical path is the longest path. Float is the difference between CP and next longest CP.
                        # create an array of paths from longest to shortest duration to help build base table
                        set paths_sort1_lists [lsort -decreasing -real -index 1 $paths_lists]
                        
                        
                    } elseif { !$error_cost } {
                        
                        # make something useful for cost biased table, critical_path is most costly.. etc.
                        # sort by path cost
                        # critical path is the longest path. Float is the difference between CP and next longest CP.
                        # create an array of paths from longest to shortest duration to help build base table
                        set paths_sort1_lists [lsort -decreasing -real -index 2 $paths_lists]
                        
                    } else {
                        
                        # make something that doesn't break the final table build. critical_path is largest count of activities..
                        # sort by number of activities per path
                        # critical path is the longest path. 
                        # create an array of paths from longest to shortest number of activities
                        set paths_sort1_lists [lsort -decreasing -integer -index 4 $paths_lists]
                        
                    }
                    ns_log Notice "acc_fin::scenario_prettify.2588: scenario '$scenario_tid' paths_lists '${paths_lists}' paths_sort1_lists '${paths_sort1_lists}' "
                    ## paths_sort1_lists is paths_list sorted by index used to calc CP
                    
                    # Extract most significant CP alternates for a focused table
                    # by counting the number of times an act is used in the largest proportion (first half) of paths in path_set_dur_sort1_list
                    
                    ## act_freq_in_load_cp_alts_arr(act) counts number of times an activity appears in all paths combined (including coefficients)
                    # determine act_freq_in_load_cp_alts_arr(activity)
                    foreach act $activities_list {
                        set act_freq_in_load_cp_alts_arr($act) 0
                    }
                    foreach path_list $paths_lists {
                        set path_idx [lindex $path_list 0]
                        foreach act $paths_arr($path_idx) {
                            incr act_freq_in_load_cp_alts_arr($act) $act_coef($act)
                        }
                    }
                    # Still need to include activity with coefficients into ones without coefficients.
                    # For example, 8*a in a. If a were 5 and 8*a were 16 (2 times 8), a should be 16 + 5 = 21
                    set coefs_list [lsearch -regex -all -inline $activities_list {[^\*]+[\*][^\*]+} ]
                    foreach coef $coefs_list {
                        set act_idx [string first "*" $coef]
                        incr act_idx
                        set act [string range $coef $act_idx end]
                        incr act_freq_in_load_cp_alts_arr($act) $act_coef($coef)
                    }
                    
                    # Make a list of activities sorted by popularity (appearing in the most paths)
                    set act_count_list [list ]
                    foreach act $activities_list {
                        lappend act_count_list [list $act $act_freq_in_load_cp_alts_arr($act)]
                        # initialize this variable where values defined in the next loop using activities_list
                        set count_on_cp_p_arr($act) 0
                    }
                    set activities_popular_sort_list [lsort -decreasing -integer -index 1 $act_count_list]
                    set act_count_median_pos [expr { int( $paths_count / 2. } + 1. ) ]
                    ## path_sig_list is a list of activities that are above the median count
                    set path_sig_list [list ]
                    for {set i 0} {$i < $act_count_median_pos} {incr i} {
                        lappend path_sig_list [lindex [lindex $activities_popular_sort_list $i] 0]
                    }
                    
                    ## act_count_max is max count of unique activities on a path
                    # This doesn't work for all cases: set act_count_max [lindex [lindex $activities_popular_sort_list 0] 1]
                    
                    ## act_count_median is median count of unique activities on a path
                    set act_count_median [lindex [lindex $activities_popular_sort_list $act_count_median_pos] 1]
                    
                    # Critical Path (CP) is: 
                    set cp_row_list [lindex $paths_sort1_lists 0]
                    
                    set cp_path_idx [lindex $cp_row_list 0]
                    ns_log Notice "acc_fin::scenario_prettify.2636: scenario '$scenario_tid' cp_path_idx '$cp_path_idx' cp_row_list '$cp_row_list' "
                    set cp_list $paths_arr(${cp_path_idx})
                    set cp_duration [lindex $cp_row_list 1]
                    set cp_cost [lindex $cp_row_list 2]
                    set cp_len [lindex $cp_row_list 3]
                    
                    foreach act $activities_list {
                        set on_critical_path_p_arr($act) [expr { [lsearch -exact $cp_list $act] > -1 } ]
                        set count_on_cp_arr($act) [llength [lsearch -exact -all $cp_list $act]]
                        # adjustment required for count_on_cp_p_arr, if this activity has a coefficient
                        set ac_idx [string first "*" $act]
                        ns_log Notice "acc_fin::scenario_prettify.3118: scenario '$scenario_tid' ac_idx '${ac_idx}'"
                        if { $ac_idx > 0 } {
                            incr ac_idx 1
                            set ac [string range $act $ac_idx end]
                        ns_log Notice "acc_fin::scenario_prettify.3118: scenario '$scenario_tid' ac_idx '${ac_idx}' ac '$ac' act '$act'"
                            # if activity has a coefficient, then root activity gets coefs, but activity counts 1 ie. swap coef values for this case
                            set count_on_cp_p_arr($ac) [expr { $on_critical_path_p_arr($ac) * $act_coef($act) + $count_on_cp_p_arr($ac) } ]
                            set count_on_cp_p_arr($act) [expr { $on_critical_path_p_arr($act) * $act_coef($ac) + $count_on_cp_p_arr($act) } ]
                        } else {
                            set count_on_cp_p_arr($act) [expr { $on_critical_path_p_arr($act) * $act_coef($act) + $count_on_cp_p_arr($act) } ]
                        }
                        # set defaults for popularity_arr()
                        ## popularity_arr(act) is the count of paths that an activity is in.
                        set popularity_arr($act) 0
                    }
                    ## count_on_cp_p_arr(act) is the count of this activity on the critical path. coef activities are also accumulated as activity to handle expansions either way
                    
                    # path comparison calculations
                    set path_counter 0
                    foreach path_idx_dur_cost_len_list $paths_sort1_lists {
                        set path_idx [lindex $path_idx_dur_cost_len_list 0]
                        set path_list $paths_arr(${path_idx})
                        set path_len [lindex $path_idx_dur_cost_len_list 3]
                        set path_len_w_coefs [lindex $path_idx_dur_cost_len_list 4]
                        set act_count_on_cp 0
                        
                        set term 1
                        set multiple_act_p [regexp {^([^\*]+)[\*]([^\*]+)} $act scratch term base_act]
                        if { !$multiple_act_p } {
                            set base_act $act
                        }
                        foreach act $path_list {
                            incr act_count_on_cp $count_on_cp_arr($act)
                            set a_sig_path_p 0
                            set sig_idx [lsearch -exact $path_sig_list $act]
                            if { $sig_idx > -1 } {
                                set a_sig_path_p 1
                            } 
                            set pop_idx [lsearch -exact $path_list $base_act]
                            if { $pop_idx > -1 } {
                                incr popularity_arr(${base_act})
                                if { $multiple_act_p } {
                                    # increment the case with coeffient as well
                                    incr popularity_arr($act)
                                }
                            }
                        }
                        set a_sig_path_p_arr(${path_idx}) $a_sig_path_p
                        
                        set act_cp_ratio [expr { $act_count_on_cp / ( $cp_len + 0. ) } ]
                        set act_cp_ratio_arr(${path_idx}) $act_cp_ratio
                        
                        if { !$error_time } {
                            set duration_ratio_arr(${path_idx}) [expr { $path_duration_arr(${path_idx}) / ( $cp_duration + 0. ) } ]
                        } 
                        if { !$error_cost } {
                            set cost_ratio_arr(${path_idx}) [expr { $cw_arr(${path_idx}) / ( $cp_cost + 0. ) } ]
                        }
                        set path_counter_arr(${path_idx}) $path_counter
                        incr path_counter
                    }
                }
                
                if { $error_fail == 0 && $index_eq ne "" } {
                    # resort paths_sort1_lists using index_custom
                    # calculate custom equation for custom sort?
                    ## index_custom is value of custom index equation index_eq, or empty string
                    set path2_lists [list ]
                    
                    foreach path_idx_dur_cost_len_list $paths_sort1_lists {
                        # variables available for use with custom index equation:
                        #  activity_count                    is length activities_list ie count of all activities
                        #  paths_count                   is the number of paths ie length of paths_list
                        #  act_count_max is max count of unique activities on a path
                        #  act_count_median is median count of unique activities on a path
                        #  path_counter  CP is 0
                        # calculate:
                        #  on_critical_path_p
                        #  a_sig_path_p
                        #  act_cp_ratio
                        #  cost_ratio
                        #  duration_ratio
                        
                        set path_idx [lindex $path_idx_dur_cost_len_list 0]
                        set path_list $paths_arr(${path_idx})
                        set row_list [lrange $path_list 0 4]
                        set path_len [lindex $path_idx_dur_cost_len_list 3]
                        set path_len_w_coefs [lindex $path_idx_dur_cost_len_list 4]
                        set path_counter $path_counter_arr(${path_idx})
                        set a_sig_path_p $a_sig_path_p_arr(${path_idx})
                        set act_cp_ratio $act_cp_ratio_arr(${path_idx})
                        set duration_ratio ""
                        if { !$error_time } {
                            set duration_ratio $path_duration_arr(${path_idx})
                        }
                        set cost_ratio ""
                        if { !$error_cost } {
                            set cost_ratio $cw_arr(${path_idx})
                        }
                        set on_critical_path_p [expr { $path_counter_arr(${path_idx}) == 0 } ]
                        set index_custom ""
                        if { [catch {
                            set index_custom [expr { $index_eq } ]
                        } _error_text] } {
                            set error_fail 1
                            ns_log Warning "acc_fin::scenario_prettify.2646: scenario '$scenario_tid' act '$act' index_eq '${index_eq}'"
                            acc_fin::pretti_log_create $scenario_tid "${act}" "#accounts-finance.calculation#" "#accounts-finance.error# PRETTI '${index_eq}' (ref2646). #accounts-finance.hint# '${_error_text}'" $user_id $instance_id
                        }
                        
                        # paths_lists 5
                        # set index_custom_arr(${path_idx})
                        lappend row_list $index_custom
                    }
                    if { $error_fail == 0 } {
                        # sort by custom created index
                        set paths_sort1_lists [lsort -decreasing -real -index 5 $path2_lists]
                    }
                    unset path2_lists
                }
                if { $error_fail == 0 } {
                    # # # build base table
                    ns_log Notice "acc_fin::scenario_prettify.2468: scenario '$scenario_tid' Build base report table."
                    
                    
                    # Cells need this info for presentation: 
                    #   activity_time_expected, time_start (branches_duration_max - time_expected),time_finish (branches_duration_max)
                    #   activity_cost_expected, path_costs to complete activity
                    #   direct dependencies
                    
                    # variables available at this point include:
                    
                    # constant per project or run:
                    
                    ## activities_list                   list of activities to process
                    ## activity_count                    is length activities_list
                    ## paths_count                   is the number of paths ie length of paths_list
                    ## error_fail                        is set to 1 if there has been an error that prevents continued processing
                    ## error_cost                        is set to 1 if there has been an error that prevents continued processing of costing aspects
                    ## error_time                        is set to 1 if there has been an error that prevents continued processing of time aspects
                    ## paths_sort1_lists                 is paths_list sorted by index used to calc CP
                    
                    # constant per path:
                    
                    ## path_len_arr(path_idx)            is length of a path in paths_lists with path_idx
                    ## path_len_w_coef_arr(path_idx)     is total number of activities in a path (with coefficients)
                    ## paths_list:                       (list path_arr_idx duration cost length length_w_coefs index_custom)
                    ## index_custom                      is value of custom index equation index_eq, or empty string
                    ## path_counter_arr(path_idx)
                    ## a_sig_path_p_arr(path_idx)
                    ## act_cp_ratio(path_idx)
                    
                    # constant per activity: activity_ref from activities_list
                    
                    ## act_seq_num_arr(act)              is relative sequence number of an activity in it's path. First activity is 0
                    ## dependencies_larr(act)            is a list of direct dependencies for each activity
                    ## dependents_count_arr(act)         is count number of activities in each subtree, not including the activity itself.
                    ## count_on_cp_p_arr(act)            Answers Q: How many of this activity is on the critical path. coef activities are also accumulated as activity to handle expansions either way
                    ## act_freq_in_load_cp_alts_arr(act) counts number of times an activity appears in all paths (including coefficients)
                    ## act_time_expected_arr(act)        is the time expected to complete an activity
                    ## tw_arr(path_idx,act)           is duration of ptrack up to (and including) activity.
                    ## t_dc_source_arr(act)              answers Q: what is source of time distribution curve?
                    ## act_cost_expected_arr(act)        is the cost expected to complete an activity
                    ## cw_arr(path_idx,act)               is cost of all dependent ptrack plus cost of activity
                    ## c_dc_source_arr(act)              answers Q: what is source of cost distribution curve?
                    ## act_coef(act)                     is the coefficient of an activity. If activity is defined as a multiple of another activity, it is an integer greater than 1 otherwise 1.
                    ## popularity_arr(act)                   is the count of paths that an activity is in.
                    
                    ## path_tree_p_arr(act)              answers question: is this tree of ptracks complete (ie not a subset of another track or tree)?
                    ## tn_arr(activity) is the time expected to complete an activity and its dependents
                    ## cn_arr(activity)      is the cost expected to complete an activity and its dependents

                    
                    # other
                    ## max_act_path_dur(activity) the maximum path duration that an activity is in. (helps with prioritization)                    
                    ## act_count_of_seq_arr(sequence no) is the count of activities at this sequence number across all paths, 0 is first sequence number
                    ## act_seq_max                       is the maximum path length in context of sequence_number

                    
                    
                    # # # PRETTI p5_lists built 
                    # Build an audit/feedback table list of lists, where each row is an activity
                    # p5 are activities, and p6 are paths. a path key is shared between p5 and p6 tables
                    set p5_lists [list ]
                    set p5_titles_list [acc_fin::pretti_columns_list p5 1]
                    # *_dc_ref references cache reference
                    lappend p5_titles_list "t_dc"
                    lappend p5_titles_list "c_dc"
                    lappend p5_lists $p5_titles_list
                    set activity_counter 0
                    foreach act $activities_list {
                        #set tree_act_cost_arr($act) $cn_arr($act)
                        incr activity_counter
                        incr act_count_on_cp $count_on_cp_arr($act)
                        set has_direct_dependency_p [expr { [llength $dependencies_larr($act)] > 0 } ]
                        set on_a_sig_path_p [expr { $act_freq_in_load_cp_alts_arr($act) > $act_count_median } ]
                        set act_maxcc ""
                        set act_maxol ""
                        set act_maxtpr ""
                        set act_maxrt ""
                        set act_maxd ""
                        if { [info exists act_maxcc_arr($act) ] } {
                            set act_maxcc $act_maxcc_arr($act)
                        }
                        if { [info exists act_maxol_arr($act) ] } {
                            set act_maxol $act_maxol_arr($act)
                        }
                        if { [info exists act_maxtpr_arr($act) ] } {
                            set act_maxtpr $act_maxtpr_arr($act)
                        }
                        if { [info exists act_maxrt_arr($act) ] } {
                            set act_maxrt $act_maxrt_arr($act)
                        }
                        if { [info exists act_maxd_arr($act) ] } {
                            set act_maxd $act_maxd_arr($act)
                        }
                        # determine max duration of paths for this activity
                        set max_path_duration 0
                        # there should be at least one p_idx per act..
                        if { [llength $path_idxs_in_act_larr($act) ] > 0 } { 
                            foreach p_idx $path_idxs_in_act_larr($act) {
                                if { $path_duration_arr(${p_idx}) > $max_path_duration } {
                                    set max_path_duration $path_duration_arr(${p_idx})
                                }
                            }
                        } else {
                            ns_log Warning "acc_fin::scenario_prettify.3638: path_idxs_in_act_larr(${act}) is empty. This should not happen. Investigate. path_idxs_in_act_larr '[array get path_idxs_in_act_larr]'"
                        }
                        if { $max_path_duration != 0 } {
                            set max_act_path_dur_arr($act) $max_path_duration
                        } else {
                            ns_log Warning "acc_fin::scenario_prettify.3643: max_path_duration '0' for ${act}. This should not happen. Investigate. path_duration_arr '[array get path_duration_arr]' "
                        }
                        # base for p5
                        # Note that last two columns are appended ie not part of official p5 definition in acc_fin::pretti_columns_list
                        set activity_list [list $act $activity_counter $has_direct_dependency_p [join $dependencies_larr($act) " "] [llength $dependencies_larr($act)] $on_critical_path_p_arr($act) $on_a_sig_path_p $act_freq_in_load_cp_alts_arr($act) $popularity_arr($act) $act_time_expected_arr($act) $tn_arr($act) $t_dc_source_arr($act) $act_cost_expected_arr($act) $cn_arr($act) $c_dc_source_arr($act) $act_coef($act) $act_maxcc $act_maxrt $act_maxtpr $act_maxol $act_maxd $max_path_duration $act_tcref($act) $act_ccref($act) ]
                        lappend p5_lists $activity_list
                    }
                    
                    set p6_lists [list ]
                    set p6_titles_list [acc_fin::pretti_columns_list p6 1]
                    lappend p6_titles_list "path_len"
                    lappend p6_titles_list "path_len_w_coefs"
                    lappend p6_lists $p6_titles_list
                    
                    foreach path_idx_dur_cost_len_list $paths_sort1_lists {
                        set path_idx [lindex $path_idx_dur_cost_len_list 0]
                        set path_list $paths_arr(${path_idx})
                        set path_counter $path_counter_arr(${path_idx})
                        set a_sig_path_p $a_sig_path_p_arr(${path_idx})
                        set act_cp_ratio $act_cp_ratio_arr(${path_idx})
                        #                    set index_custom $index_custom_arr(${path_idx})
                        set path_duration [lindex $path_idx_dur_cost_len_list 1]
                        set path_cost [lindex $path_idx_dur_cost_len_list 2]
                        set path_len [lindex $path_idx_dur_cost_len_list 3]
                        set path_len_w_coefs [lindex $path_idx_dur_cost_len_list 4]
                        set index_custom [lindex $path_idx_dur_cost_len_list 5]
                        set activity_counter 0
                        set act_count_on_cp 0
                        # base for p6
                        #            set ret_list [list path_idx path path_counter cp_q significant_q path_duration path_cost index_custom]
                        set cp_q [expr { $path_counter == 0 } ]
                        set path_list [list $path_idx [join $path_list "."] $path_counter $cp_q $a_sig_path_p $path_duration $path_cost $index_custom $path_len $path_len_w_coefs ]
                        lappend p6_lists $path_list
                    }                
                    
                    set scenario_stats_list [qss_table_stats $scenario_tid $instance_id $user_id]
                    set scenario_name [lindex $scenario_stats_list 0]
                    if { [llength $t_moment_list ] > 1 } {
                        set t_moment_len_list [list ]
                        foreach moment $t_moment_list {
                            lappend t_moment_len_list [string length $moment]
                        }
                        set t_moment_format "%1.f"
                        append t_moment_format [expr { [f::lmax $t_moment_len_list] - 2 } ]
                        lappend " t=[format ${t_moment_format} ${t_moment}]"
                    }
                    if { [llength $c_moment_list ] > 1 } {
                        set c_moment_len_list [list ]
                        foreach moment $c_moment_list {
                            lappend c_moment_len_list [string length $moment]
                        }
                        set c_moment_format "%1.f"
                        append c_moment_format [expr { [f::lmax $t_moment_len_list] - 2 } ]
                        lappend " c=[format ${c_moment_format} ${c_moment}]"
                    }
                    set scenario_title [lindex $scenario_stats_list 1]
                    
                    set time_end [clock seconds]
                    set time_diff_secs [expr { $time_end - $time_start } ]
                    set setup_diff_secs [expr { $setup_end - $setup_start } ]
                    # the_time Time calculation completed
                    set p1_arr(the_time) [clock format [clock seconds] -format "%Y %b %d %H:%M:%S"]
                    # comments should include cp_duration, cp_cost, max_act_count_per_track 
                    # time_probability_moment, cost_probability_moment, 
                    # scenario_name, processing_time, time/date finished processing
                    set comments "Scenario report for ${scenario_title}: "
                    append comments "scenario_name ${scenario_name} , cp_duration_at_pm ${cp_duration} , cp_cost_pm ${cp_cost} , "
                    append comments "max_act_count_per_track ${act_count_max} , time_probability_moment ${t_moment} , cost_probability_moment ${c_moment} , "
                    append comments "setup_time ${setup_diff_secs} , main_processing_time ${time_diff_secs} seconds , time/date finished processing $p1_arr(the_time) , "
                    append comments "_tDcSource $p1_arr(_tDcSource) , _cDcSource $p1_arr(_cDcSource) , "
                    
                    
                    if { $p1_arr(db_format) ne "" } {
                        qss_table_create $p5_lists "${scenario_name}.p5" "${scenario_title}.p5" $comments "" p5 $instance_id $user_id
                        qss_table_create $p6_lists "${scenario_name}.p6" "${scenario_title}.p6" $comments "" p6 $instance_id $user_id
                    }
                    set precision ""
                    if { [qf_is_decimal $p1_arr(precision) ] } {
                        set precision $p1_arr(precision)
                    } 
                    if { [qf_is_decimal $p1_arr(tprecision) ] } {
                        set tprecision $p1_arr(tprecision)
                    } else {
                        set tprecision $precision
                    }
                    if { [qf_is_decimal $p1_arr(cprecision) ] } {
                        set cprecision $p1_arr(cprecision)
                    } else {
                        set cprecision $precision
                    }
                    append comments "precision $precision , tprecision $tprecision , cprecision $cprecision , "
                    # # # build p4
                    
                    # save as a new table of type p4
                    append comments "color_mask_sig_idx 3 , color_mask_oth_idx 5 , colorswap_p 0"
                    
                    # p4_lol consists of first row (a list item):
                    # (list path_1 path_2 path_3 ... path_N )
                    # subsequent rows (list items):
                    # (list cell_r1c1 cell_r1c2 cell_r1c3 ... cellr1cN )
                    # ...
                    # (list cell_rMc1 cell_rMc2 cell_rMc3 ... cellrMcN )
                    # for N paths of a maximum of M rows.
                    # Each cell is an activity.
                    # Each column is a path
                    # Path_1 is CP
                    
                    # empty cells have empty string value.
                    # other cells will contain comment format from acc_fin::scenario_prettify
                    # "$activity "
                    # "t:[lindex $path_list 7] "
                    # "ts:[lindex $path_list 6] " s is for sequence or plural
                    # "c:[lindex $path_list 9] "
                    # "cs:[lindex $path_list 10] " s is for sequence or plural
                    # "d:($depnc_larr(${activity})) "
                    # "<!-- [lindex $path_list 4] [lindex $path_list 5] --> "
                    #####################        


                    # Need to convert into rows ie.. transpose rows of each column to a path with column names: path_(1..N). path_1 is CP
                    # trac_1 path_2 path_3 ... path_N
                    
                    set p4_lists [list ]
                    set title_row_list [list ]
                    set path_num 1

                    # in p4 PRETTI table, each path is a column, so each row is built from each column, each column lappends each row..
                    # store each row in: row_larr()
                    for {set i 0} {$i < $act_count_max} {incr i} {
                        set row_larr($i) [list ]
                    }
                    
                    foreach path_idx_dur_cost_len_list $paths_sort1_lists {
                        set path_idx [lindex $path_idx_dur_cost_len_list 0]
                        set path_list $paths_arr(${path_idx})
                        set path_counter $path_counter_arr(${path_idx})
                        set a_sig_path_p $a_sig_path_p_arr(${path_idx})
                        set act_cp_ratio $act_cp_ratio_arr(${path_idx})
                        #                    set index_custom $index_custom_arr(${path_idx})
                        set path_duration [lindex $path_idx_dur_cost_len_list 1]
                        set path_cost [lindex $path_idx_dur_cost_len_list 2]
                        set path_len [lindex $path_idx_dur_cost_len_list 3]
                        set path_len_w_coefs [lindex $path_idx_dur_cost_len_list 4]
                        set index_custom [lindex $path_idx_dur_cost_len_list 5]

                        set path_name "path_${path_num}"
                        lappend title_row_list $path_name
                        set ptrack_list [list ]
                        # fill in rows for this column
                        for {set i 0} {$i < $act_count_max} {incr i} {
                            set activity [lindex $path_list $i]
                            if { $activity ne "" } {
                                # cell should contain this info: "$act t:${time_expected} T:${branches_duration_max} D:${dependencies} "
                                lappend ptrack_list $activity
                                set cell $activity
                                append cell " <br> "
                                append cell " t:"
                                if { $act_time_expected_arr($activity) ne "" } {
                                    if { $tprecision eq "" } {
                                        append cell $act_time_expected_arr($activity)
                                    } else {
                                        append cell [qaf_round_to_precision $act_time_expected_arr($activity) $tprecision ]
                                    }
                                } 
                                append cell " <br> "
                                append cell "tw:"
                                if { $tw_arr(${path_idx},$activity) ne "" } {
                                    if { $tprecision eq "" } {
                                        append cell $tw_arr(${path_idx},$activity)
                                    } else {
                                        append cell [qaf_round_to_precision $tw_arr(${path_idx},$activity) $tprecision ]
                                    }
                                }
                                append cell " <br> "
                                append cell "tn:"
                                if { $tn_arr($activity) ne "" } {
                                    if { $tprecision eq "" } {
                                        append cell $tn_arr($activity) 
                                    } else {
                                        append cell [qaf_round_to_precision $tn_arr($activity) $tprecision ]
                                    }
                                }
                                append cell " <br> "
                                append cell "fw:"
                                if { $tn_arr($activity) ne "" && $tw_arr($path_idx,$activity) ne "" } {
                                    if { $tprecision eq "" } {
                                        append cell [expr { $tn_arr($activity) - $tw_arr(${path_idx},$activity) } ]
                                    } else {
                                        append cell [qaf_round_to_precision [expr { $tn_arr($activity) - $tw_arr(${path_idx},$activity) } ] $tprecision ]
                                    }
                                }
                                append cell " <br> "
                                append cell "&nbsp;c:"
                                if { $act_cost_expected_arr($activity) ne "" } {
                                    if { $cprecision eq "" } {
                                        append cell $act_cost_expected_arr($activity)
                                    } else {
                                        append cell [qaf_round_to_precision $act_cost_expected_arr($activity) $cprecision ]
                                    }
                                }
                                append cell " <br> "
                                append cell "cw:"
                                if { $cw_arr(${path_idx},$activity) ne "" } {
                                    if { $cprecision eq "" } {
                                        append cell $cw_arr(${path_idx},$activity)
                                    } else {
                                        append cell [qaf_round_to_precision $cw_arr(${path_idx},$activity) $cprecision ]
                                    }
                                }
                                append cell " <br> "
                                append cell "cn:"
                                if { $cn_arr($activity) ne "" } {
                                    if { $cprecision eq "" } {
                                        append cell $cn_arr($activity)
                                    } else {
                                        append cell [qaf_round_to_precision $cn_arr($activity) $cprecision ]
                                    }
                                }
                                append cell " <br> "
                                append cell "d:("
                                append cell [join $dependencies_larr(${activity}) " "]
                                append cell ") <br> "
                                #                            set popularity $popularity_arr($activity)
                                set popularity $act_freq_in_load_cp_alts_arr($activity)
                                set on_a_sig_path_p [expr { $act_freq_in_load_cp_alts_arr($activity) > $act_count_median } ]
                                set max_path_duration $max_act_path_dur_arr($activity)
                                # this calced in p4 html generator: set on_cp_p [expr { $count_on_cp_p_arr($activity) > 0 } ]
                                append cell "<!-- ${on_a_sig_path_p} ${popularity} ${max_path_duration} --> "
                                lappend row_larr($i) $cell
                            } else {
                                lappend row_larr($i) ""
                            }
                        }
                        incr path_num
                    }                    
                    # combine the rows
                    lappend p4_lists $title_row_list
                    for {set i 0} {$i < $act_count_max} {incr i} {
                        lappend p4_lists $row_larr($i)
                    }
                    set sname "${scenario_name}.p4"
                    set stitle "${scenario_title}.p4"
                    if { $t_moment ne "" } {
                        append sname "t${t_moment}"
                        append stitle " t=${t_moment}"
                    }
                    if { $c_moment ne "" } {
                        append sname "c${c_moment}"
                        append stitle " c=${t_moment}"
                    }
                    qss_table_create $p4_lists $sname $stitle $comments "" p4 $instance_id $user_id
                    # Comments data will be interpreted for determining standard deviation for determining cell highlighting
                }
            }
            # next c_moment
        }
        # next t_moment
    }
    ns_log Notice "acc_fin::scenario_prettify.2639: scenario '$scenario_tid' done."
    set success_p [expr { abs( $error_fail - 1 ) } ]
    return $success_p
}


ad_proc -public acc_fin::table_sort_y_asc {
    table_tid
    {instance_id ""}
    {user_id ""}
} {
    Creates a copy of a distribution curve (table) sorted by column Y in ascending order. Returns table_id or empty string if error.
} {
    if { $instance_id eq "" } {
        set instance_id [ad_conn package_id]
    }
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    set read_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege read]
    set table_id_new ""
    if { $read_p } {
        set create_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege create]
        if { !$create_p } {
            set write_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege write]
        }
        if { $create_p || $write_p } {
            set table_stats_list [qss_table_stats $table_tid $instance_id $user_id]
            # name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id.
            set trashed_p [lindex $table_stats_list 7]
            set table_flags [lindex $table_stats_list 6]
            set tid_user_id [lindex $table_stats_list 11]
            if { $table_flags eq "dc" && !$trashed_p } {
                set table_lists [qss_table_read $table_tid ]
                set title_row [lindex $table_lists 0]
                set y_idx [lsearch -exact $title_row "y"]
                if { $y_idx > -1 } {
                    set table_sorted_lists [lsort -index $y_idx -real [lrange $table_lists 1 end]]
                    set table_sorted_lists [linsert $table_sorted_lists 0 $title_row]
                    set table_stats [qss_table_stats $table_tid $instance_id $user_id]
                    # name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id.
                    set table_name [lindex $table_stats 0]
                    set table_title [lindex $table_stats 1]
                    set table_comments [lindex $table_stats 2]
                    append table_comments " Sorted by Y on [lc_time_system_to_conn [clock format [clock seconds] -format "%Y-%m-%d %r"]]"
                    set table_template_id [lindex $table_stats 5]
                    set table_flags [lindex $table_stats_list 6]
                    set table_id_new [qss_table_create $table_sorted_lists $table_name $table_title $table_comments $table_template_id $table_flags $instance_id $user_id]
                }
            }
        }
    } 
    return $table_id_new
}
