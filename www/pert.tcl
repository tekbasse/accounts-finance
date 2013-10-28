# generic header for static .adp pages

set title "PERT program"
set context [list $title]

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set write_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege write]
set admin_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege admin]
set delete_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege delete]
# randmize rand with seed from clock for building a scenario from dist curves
expr { srand([clock clicks]) }

## change initial_conditions_lists columns from:
# sale_max revenue_target pct_pooled interpolate_last_band_p growth_curve_eq commissions_eq interval_start interval_size interval_count sales_curve_name sales_curve_tid
# to:
# activity_ref predecessors time_est_short time_est_median time_est_long cost_est_low cost_est_median cost_est_high time_dist_curv_eq cost_dist_curv_eq
# for report, add:
# seuqence_nbr expected track_ref

# c/initial_conditions/scenario/g
# c/sales_curve/dist_curve/g

# _curve_lists [list [list .7 .1 fast] [list 1 .15 median] [list 2 .1 delayed] [list 4 .375 hurdle] [list 10 .125 hurdles]]

# tid = table_id
array set input_array [list \
    dist_curve_tid ""\
    scenario_tid ""\
    scenario_lists [list [list activity_ref A] [list predecessors ""] [list time_est_short 1] [list time_est_median 2] [list time_est_long 4] [list cost_est_low 0] [list cost_est_median 1] [list cost_est_high 4] [list time_dist_curve_eq ""] [list cost_dist_curve_eq ""]]\
    scenario_text ""\
    dist_curve_lists [list [list .7 .1 fast] [list 1 .2 normal] [list 1.5 .25 interrupted] [list 2 .1 delayed] [list 4 .375 hurdle] [list 10 .125 hurdles]]\
    dist_curve_text ""\
    sample_rate 1\
    period_unit period\
    pct_pooled 1.\
    interpolate_last_band_p 0\
    act_name ""\
    act_title ""\
    act_comments ""\
    act_template_id ""\
    act_flags ""\
    dc_name ""\
    dc_title ""\
    dc_comments ""\
    dc_template_id ""\
    dc_flags ""\
    submit "" \
    reset "" \
    mode "p" \
    next_mode "p" \
			   ]

array set title_array [list \
    submit "Submit" \
    reset "Reset" \
			   ]

set user_message_list [list ]
set dist_curve_default [qss_lists_to_text $input_array(dist_curve_lists)]
set scenario_default [qss_lists_to_text $input_array(scenario_lists)]

# get previous form inputs if they exist
set form_posted [qf_get_inputs_as_array input_array]
set mode $input_array(mode)
set next_mode $input_array(next_mode)

if { $form_posted } {
    if { [info exists input_array(x) ] } {
        unset input_array(x)
    }
    if { [info exists input_array(y) ] } {
        unset input_array(y)
    }

    set dist_curve_tid $input_array(dist_curve_tid)
    set scenario_tid $input_array(scenario_tid)
    set scenario_lists $input_array(scenario_lists)
    set dist_curve_lists $input_array(dist_curve_lists)
    set act_template_id $input_array(act_template_id)
    set act_flags $input_array(act_flags)
    set dc_template_id $input_array(dc_template_id)
    set dc_flags $input_array(dc_flags)
    # validate input
    # cleanse, validate mode
    # determine input completeness
    # form has modal inputs, so validation is a matter of cleansing data and verifying references
    set validated 0

    switch -exact -- $mode {
        e {
            ns_log Notice "pert.tcl:  validated for e"
            set validated 1
            if { ![ecds_is_natural_number $scenario_tid] && ![ecds_is_natural_number $dist_curve_tid] } {
                set mode "n"
                set next_mode ""
            } 
        }
        d {
            ns_log Notice "pert.tcl:  validated for d"
            set validated 1
            if { ( ![ecds_is_natural_number $scenario_tid] && ![ecds_is_natural_number $dist_curve_tid] ) || !$delete_p } {
                set mode "p"
                set next_mode ""
            } 
        }
        t {
            ns_log Notice "pert.tcl:  validated for t"
            set validated 1
            if { ![ecds_is_natural_number $scenario_tid] && ![ecds_is_natural_number $dist_curve_tid] } {
                set mode "p"
                set next_mode ""
            } 
        }
        c {
            ns_log Notice "pert.tcl:  validated for c"
            set validated 1
            if { ![ecds_is_natural_number $scenario_tid] } {
                lappend user_message_list "Table for Scenario has not been specified."
                set validated 0
                set mode "p"
                set next_mode ""
            } 
            # check for any form inputs?
            set interpolate_last_band_p $input_array(interpolate_last_band_p)
            set sample_rate $input_array(sample_rate)
            set period_unit $input_array(period_unit)
            set commissions_eq $input_array(commissions_eq)
        }
        w {
            set scenario_text $input_array(scenario_text)
            set dist_curve_text $input_array(dist_curve_text)
            set validated 1
            ns_log Notice "pert.tcl:  validated for w"
        }
        n {
            set validated 1
            ns_log Notice "pert.tcl:  validated for n"
        }
        r {
            set validated 1
            ns_log Notice "pert.tcl:  validated for r"
        }
        default {
            ns_log Notice "pert.tcl:  validated for v"
            if { [ecds_is_natural_number $scenario_tid] || [ecds_is_natural_number $dist_curve_tid] } {
                set validated 1
                set mode "v"
            } else {
                set mode "p"
                set next_mode ""
            } 
        }
        
    }
    # end switch

    if { $validated } {
        # execute validated input
        
        if { $mode eq "w" } {
            # write the data
            # a different user_id makes new context based on current context, otherwise modifies same context
            # or create a new context if no context provided.
            # given:
            # act_* is scenario_
            # dc_* is dist_curve_
            if { [string length $scenario_text] > 0 && $scenario_text ne $scenario_default } {
                # act_name  Table Name

                if { $input_array(act_name) eq "" && $scenario_tid eq "" } {
                    set act_name "act[clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(act_name) eq "" } {
                    set act_name "initCon${scenario_tid}"
                } else {
                    set act_name $input_array(act_name)
                }
                # act_title Table title
                if { $input_array(act_title) eq "" && $scenario_tid eq "" } {
                    set act_title "Scenario [clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(act_title) eq "" } {
                    set act_title "Scenario ${scenario_tid}"
                } else {
                    set act_title $input_array(act_title)
                }
                ns_log Notice "pert.tcl:  act_name '${act_name}' [string length $act_name]"
                # act_comments Comments
                set act_comments $input_array(act_comments)
                # scenario_text
           
                # convert tables from _text to _list
                set line_break "\n"
                set delimiter ","
                # linebreak_char delimiter rows_count columns_count 
                set act_text_stats [qss_txt_table_stats $scenario_text]
                ns_log Notice "pert.tcl: : act_text_stats $act_text_stats"
                set line_break [lindex $act_text_stats 0]
                set delimiter [lindex $act_text_stats 1]
                ns_log Notice "pert.tcl: : scenario_text ${scenario_text}"
                set act_lists [qss_txt_to_tcl_list_of_lists $scenario_text $line_break $delimiter]
                ns_log Notice "pert.tcl: : set act_lists ${act_lists}"
                # cleanup input
                set act_lists_new [list ]
                foreach condition_list $act_lists {
                    set row_new [list ]
                    foreach cell $condition_list {
                        set cell_new [string trim $cell]
                        regsub -all -- {[ ][ ]*} $cell_new { } cell_new
                        lappend row_new $cell_new
                        #ns_log Notice "pert.tcl:  new cell '$cell_new'"
                    }
                    if { [llength $row_new] > 0 } {
                        lappend act_lists_new $row_new
                    }
                }
                set act_lists $act_lists_new
                ns_log Notice "pert.tcl: : create/write table" 
                ns_log Notice "pert.tcl: : llength act_lists [llength $act_lists]"
                if { [ecds_is_natural_number $scenario_tid] } {
                    set table_stats [qss_table_stats $scenario_tid]
                    set name_old [lindex $table_stats 0]
                    set title_old [lindex $table_stats 1]
                    if { $name_old eq $act_name && $title_old eq $act_title } {
                        ns_log Notice "pert.tcl: : qss_table_write table_id ${scenario_tid}" 
                        qss_table_write $act_lists $act_name $act_title $act_comments $scenario_tid $act_template_id $act_flags $package_id $user_id
                    } else {
                        # changed name. assume this is a new table
                        ns_log Notice "pert.tcl: : qss_table_create new table scenario because name/title changed"
                        qss_table_create $act_lists $act_name $act_title $act_comments $act_template_id $act_flags $package_id $user_id

                    }
                } else {
                    ns_log Notice "pert.tcl: : qss_table_create new table scenario"
                    qss_table_create $act_lists $act_name $act_title $act_comments $act_template_id $act_flags $package_id $user_id
                }

            }
            if { [string length $dist_curve_text] > 0 && $dist_curve_text ne $dist_curve_default } {
                # dc_name  Table Name
                if { $input_array(dc_name) eq "" && $dist_curve_tid eq "" } {
                    set dc_name "sc[clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(dc_name) eq "" } {
                    set dc_name "Distribution Curve ${dist_curve_tid}"
                } else {
                    set dc_name $input_array(dc_name)
                }
                ns_log Notice "pert.tcl:  dc_name '${dc_name}' [string length $dc_name]"
                # dc_title Table title
                if { $input_array(dc_title) eq "" && $scenario_tid eq "" } {
                    set dc_title "Distribution Curve [clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(dc_title) eq "" } {
                    set dc_title "Distribution Curve ${dist_curve_tid}"
                } else {
                    set dc_title $input_array(dc_title)
                }
                # dc_comments Comments
                set dc_comments $input_array(dc_comments)
                # dist_curve_text

                # convert tables from _text to _list
                set line_break "\n"
                set delimiter ","
                # linebreak_char delimiter rows_count columns_count 
                set dc_text_stats [qss_txt_table_stats $dist_curve_text]
                set line_break [lindex $dc_text_stats 0]
                ns_log Notice "pert.tcl: : dist_curve_text ${dist_curve_text}"
                set dc_lists [qss_txt_to_tcl_list_of_lists $dist_curve_text $line_break $delimiter]
                ns_log Notice "pert.tcl: : set dc_lists ${dc_lists}"
                # cleanup input
                set dc_lists_new [list ]
                foreach curve_list $dc_lists {
                    set row_new [list ]
                    foreach cell $curve_list {
                        set cell_new [string trim $cell]
                        regsub -all -- {[ ][ ]*} $cell_new { } cell_new
                        lappend row_new $cell_new
                    }
                    if { [llength $row_new] > 0 } {
                        lappend dc_lists_new $row_new
                    }
                }
                set dc_lists $dc_lists_new
            
                set curve_pct_list [list ]
                foreach curve_list $dc_lists {
                    # area under curve aka probability is second item in list
                    lappend curve_pct_list [lindex $curve_list 1]
                }

                # normalize curve_pct_list curve. Total should equal 1. (100%)
                set rcp_total 0.
                set curve_error 0
                foreach curve_pct $curve_pct_list {
                    # curve_pct must be a number
                    if { [ad_var_type_check_number_p $curve_pct] } {
                        set rcp_total [expr { $rcp_total + $curve_pct } ]
                    } else {
                        set curve_error 1
                    }
                }
                if { $rcp_total > 0 } {
                    set adj_factor [expr { 1. / $rcp_total } ]
                
                    if { $adj_factor != 1. } {
                        # edit the probability values
                        set new_rcp_list [list ]
                        foreach curve_pct $curve_pct_list {
                            if { [ad_var_type_check_number_p $curve_pct] } {
                                set curve_pct_adj [expr { $adj_factor * $curve_pct } ]
                                lappend new_rcp_list $curve_pct_adj
                            } else {
                                lappend "${curve_pct} (ignored)"
                                set curve_error 1
                            }
                        }
                        set curve_pct_list $new_rcp_list
                        # now we need to add them back into dc_lists
                        set dc_lists_new [list ]
                        set row_nbr 0
                        foreach curve_list $dc_lists {
                            set row_new [lreplace $curve_list 1 1 [lindex $curve_pct_list $row_nbr]]
                            lappend dc_lists_new $row_new
                            incr row_nbr
                        }
                        set dc_lists $dc_lists_new
                        ns_log Notice "pert.tcl: : adjust probability value sum to 1: results"
                        ns_log Notice "pert.tcl: : set dc_lists ${dc_lists}"
                    }
                    # sort $price_list (and the cooresponding lists).
                    if { !$curve_error } {
                        set dc_lists [lsort -index 0 -real $dc_lists]
                    }
                } else {
                    ns_log Notice "pert.tcl: : dist_curve $dist_curve_tid cannot be normalized."
                    lappend user_message_list "Unable to normalize Distribution Curve. Saved as is."
                }
                ns_log Notice "pert.tcl: : sorted dc_lists. Results:"
                ns_log Notice "pert.tcl: : set dc_lists ${dc_lists}"

                ns_log Notice "pert.tcl: : create/write table" 
                ns_log Notice "pert.tcl: : length dc_lists [llength $dc_lists]"


                if { [ecds_is_natural_number $dist_curve_tid] } {
                    set table_stats [qss_table_stats $dist_curve_tid]
                    set name_old [lindex $table_stats 0]
                    set title_old [lindex $table_stats 1]
                    if { $name_old eq $dc_name && $title_old eq $dc_title } {
                        ns_log Notice "pert.tcl: : qss_table_write table_id ${dist_curve_tid}" 
                        qss_table_write $dc_lists $dc_name $dc_title $dc_comments $dist_curve_tid $dc_template_id $dc_flags $package_id $user_id
                    } else {
                        # changed name. assume this is a new table
                        ns_log Notice "pert.tcl: : qss_table_create new table dist_curve"
                        qss_table_create $dc_lists $dc_name $dc_title $dc_comments $dc_template_id $dc_flags $package_id $user_id
                    }
                } else {
                    ns_log Notice "pert.tcl: : qss_table_create new table dist_curve"
                    qss_table_create $dc_lists $dc_name $dc_title $dc_comments $dc_template_id $dc_flags $package_id $user_id
                }
            }

            set mode $next_mode
            set next_mode ""
        }
        if { $mode eq "d" } {
            #  delete.... removes context     
            ns_log Notice "pert.tcl:  mode = delete"
            #requires scenario_tid or dist_curve_tid
            # delete scenario_tid or dist_curve_tid or both, if both supplied
            if { [ecds_is_natural_number $dist_curve_tid] } {
                qss_table_delete $dist_curve_tid
            }
            if { [ecds_is_natural_number $scenario_tid] } {
                qss_table_delete $scenario_tid
            }
            set mode $next_mode
            set next_mode ""
        }
        if { $mode eq "t" } {
            #  trash
            ns_log Notice "pert.tcl:  mode = trash"
            #requires scenario_tid or dist_curve_tid
            # delete scenario_tid or dist_curve_tid or both, if both supplied
            if { [ecds_is_natural_number $dist_curve_tid] && $write_p } {
                set trashed_p [lindex [qss_table_stats $dist_curve_tid] 7]
                if { $trashed_p == 1 } {
                    set trash 0
                } else {
                    set trash 1
                }
                qss_table_trash $trash $dist_curve_tid
            }
            if { [ecds_is_natural_number $scenario_tid] && $write_p } {
                set trashed_p [lindex [qss_table_stats $scenario_tid] 7]
                if { $trashed_p == 1 } {
                    set trash 0
                } else {
                    set trash 1
                }
                qss_table_trash $trash $scenario_tid
            }
            set mode "p"
            set next_mode ""
        }
        
    }
    # end validated input if

}


set menu_list [list [list Pert ""]]

if { $write_p } {
    lappend menu_list [list new mode=n]
}

switch -exact -- $mode {
    e {
        #  edit...... edit/form mode of current context
        ns_log Notice "pert.tcl:  mode = edit"
        #requires scenario_tid, dist_curve_tid
        # make a form to edit 
        # get table from ID


        qf_form action pert method get id 20120531
        
        qf_input type hidden value w name mode label ""
        
        if { [ecds_is_natural_number $scenario_tid] } {
            set act_stats_list [qss_table_stats $scenario_tid]
            set act_name [lindex $act_stats_list 0]
            set act_title [lindex $act_stats_list 1]
            set act_comments [lindex $act_stats_list 2]
            set act_flags [lindex $act_stats_list 6]
            set act_template_id [lindex $act_stats_list 5]

            set scenario_lists [qss_table_read $scenario_tid]
            set scenario_text [qss_lists_to_text $scenario_lists]

            qf_input type hidden value $scenario_tid name scenario_tid label ""
            qf_input type hidden value $act_flags name act_flags label ""
            qf_input type hidden value $act_template_id name act_template_id label ""
            qf_append html "<h3>Scenario</h3>"
            qf_append html "<div style=\"width: 70%; text-align: right;\">"
            qf_input type text value $act_name name act_name label "Table name:" size 40 maxlength 40
            qf_append html "<br>"
            qf_input type text value $act_title name act_title label "Title:" size 40 maxlength 80
            qf_append html "<br>"
            qf_textarea value $act_comments cols 40 rows 3 name act_comments label "Comments:"
            qf_append html "<br>"
            qf_textarea value $scenario_text cols 40 rows 6 name scenario_text label "Table data:"
            qf_append html "</div>"
        }
        if { [ecds_is_natural_number $dist_curve_tid] } {
            # get table from ID
            set dc_stats_list [qss_table_stats $dist_curve_tid]
            set dc_name [lindex $dc_stats_list 0]
            set dc_title [lindex $dc_stats_list 1]
            set dc_comments [lindex $dc_stats_list 2]
            set dc_flags [lindex $dc_stats_list 6]
            set dc_template_id [lindex $dc_stats_list 5]

            set dist_curve_lists [qss_table_read $dist_curve_tid]
            set dist_curve_text [qss_lists_to_text $dist_curve_lists]
            
            qf_input type hidden value $dist_curve_tid name dist_curve_tid label ""
            qf_input type hidden value $dc_flags name dc_flags label ""
            qf_input type hidden value $dc_template_id name dc_template_id label ""
            qf_append html "<h3>Distribution curve</h3>"
            qf_append html "<div style=\"width: 70%; text-align: right;\">"
            qf_input type text value $dc_name name dc_name label "Table name:" size 40 maxlength 40
            qf_append html "<br>"
            qf_input type text value $dc_title name dc_title label "Title:" size 40 maxlength 80
            #        qf_append html "<br><div style=\"vertical-align: top; display: inline-block; border: 1px solid black;\">"
            qf_append html "<br>"
            qf_textarea value $dc_comments cols 40 rows 3 name dc_comments label "Comments:"
            #       qf_append html "</div><br>"
            qf_append html "<br><div style=\"clear: both;\">"
            qf_textarea value $dist_curve_text cols 40 rows 20 name dist_curve_text label "Table data:"
            qf_append html "</div>"
        }

        qf_input type submit value "Save"
        qf_close
        set form_html [qf_read]

    }
    w {
        #  save.....  (write) scenario_tid and dist_curve_tid
        # should already have been handled above
        ns_log Notice "pert.tcl:  mode = save THIS SHOULD NOT BE CALLED."
        # it's called in validation section.
    }
    n {
        #  new....... creates new, blank context (form)    
        ns_log Notice "pert.tcl:  mode = new"
        #requires no scenario_tid, dist_curve_tid
        set scenario_text [qss_lists_to_text $scenario_lists]
        set dist_curve_text [qss_lists_to_text $dist_curve_lists]

        # make a form with no existing scenario_tid and dist_curve_tid

        qf_form action pert method get id 20120530

        qf_input type hidden value w name mode label ""
        if { $scenario_tid > 0 && $dist_curve_tid > 0 } {
            ns_log Warning "mode n while scenario_tid and dist_curve_tid exist"
        }
        qf_append html "<h3>Scenario</h3>"
        qf_append html "<div style=\"width: 70%; text-align: right;\">"
        qf_input type text value "" name act_name label "Table name:" size 40 maxlength 40
        qf_append html "<br>"
        qf_input type text value "" name act_title label "Title:" size 40 maxlength 80
        qf_append html "<br>"
        qf_textarea value "" cols 40 rows 3 name act_comments label "Comments:"
        qf_append html "<br>"
        qf_textarea value $scenario_text cols 40 rows 6 name scenario_text label "Table data:"
        qf_append html "</div>"

        qf_append html "<h3>Distribution curve</h3>"
        qf_append html "<div style=\"width: 70%; text-align: right;\">"
        qf_input type text value "" name dc_name label "Table name:" size 40 maxlength 40
        qf_append html "<br>"
        qf_input type text value "" name dc_title label "Title:" size 40 maxlength 80
        #        qf_append html "<br><div style=\"vertical-align: top; display: inline-block; border: 1px solid black;\">"
        qf_append html "<br>"
        qf_textarea value "" cols 40 rows 3 name dc_comments label "Comments:"
 #       qf_append html "</div><br>"
        qf_append html "<br><div style=\"clear: both;\">"
        qf_textarea value $dist_curve_text cols 40 rows 20 name dist_curve_text label "Table data:"
        qf_append html "</div>"

        qf_input type submit value "Save"
        qf_close
        set form_html [qf_read]
    }
    c {
        #  compute... compute/process (and cache) output, present post_calc results
        ns_log Notice "pert.tcl:  mode = compute"
        #requires scenario_tid
        # given scenario_tid 
        # activity_table contains:
        # activity_ref predecessors time_est_short time_est_median time_est_long cost_est_low cost_est_median cost_est_high time_dist_curv_eq cost_dist_curv_eq
        set error_fail 0
        set scenario_lists [qss_table_read $scenario_tid]
        set constants_list [list scenario_tid activity_table_tid activity_table_name time_dist_curve_name time_dist_curve_tid cost_dist_curve_name cost_dist_curve_tid ]
        set constants_required_list [list scenario_tid]
        foreach condition_list $scenario_lists {
            set constant [lindex $condition_list 0]
            if { [lsearch -exact $constants_list $constant] > -1 } {
                set input_array($constant) [lindex $condition_list 1]
                set $constant $input_array($constant)
            }
        }
        if { [info exists activity_table_name] } {
            # set set activity_table_tid
            set table_ids_list [qss_tables $package_id]
            foreach table_id $table_ids_list {
                if { [lindex [qss_table_stats $table_id] 0] eq $activity_table_name } {
                    set activity_table_tid $table_id
                }
            }

        } 

        if { [info exists time_dist_curve_name] } {
            # set dist_curve_tid
            set table_ids_list [qss_tables $package_id]
            foreach table_id $table_ids_list {
                if { [lindex [qss_table_stats $table_id] 0] eq $time_dist_curve_name } {
                    set time_dist_curve_tid $table_id
                }
            }

        } 
        if { [info exists cost_dist_curve_name] } {
            # set dist_curve_tid
            set table_ids_list [qss_tables $package_id]
            foreach table_id $table_ids_list {
                if { [lindex [qss_table_stats $table_id] 0] eq $cost_dist_curve_name } {
                    set cost_dist_curve_tid $table_id
                }
            }

        } 
        if { [info exists activity_table_tid] } {
            set activity_table_name [lindex [qss_table_stats $activity_table_tid] 0]
        }
        if { [info exists time_dist_curve_tid] } {
            set time_dist_curve_name [lindex [qss_table_stats $time_dist_curve_tid] 0]
        }
        if { [info exists cost_dist_curve_tid] } {
            set cost_dist_curve_name [lindex [qss_table_stats $cost_dist_curve_tid] 0]
        }
        set constants_exist_p 1
        set compute_message_list [list ]
        foreach constant $constants_required_list {
            if { ![info exists $constant] || ( [info exists $constant] && [set $constant] eq "" ) } {
                set constants_exist_p 0
                lappend compute_message_list "Initial condition constant '${constant}' is required but does not exist."
                set error_fail 1
            }
        }
        
        # interpolate_last_band_p : interpolate last estimate item? choose this if you have a large estimate value that you want to vary over the value range

        # Make time_curve_data 
        set time_curve_data_lists [qss_table_read $time_dist_curve_tid]
        # make the distribution curve accessible as lists
        set time_task_list [list ]
        set time_probability_list [list ]
        set time_label_list [list ]
        set time_val_probability_lists [list ]
        foreach curve_band_list $time_curve_data_lists {
            lappend time_task_list [lindex $curve_band_list 0]
            lappend time_probability_list [lindex $curve_band_list 1]            
            lappend time_label_list [lindex $curve_band_list 2]
            lappend time_val_probability_lists [list $time_task_list $time_probability_list]
        }

        # Make cost_curve_data 
        set cost_curve_data_lists [qss_table_read $cost_dist_curve_tid]
        # make the distribution curve accessible as lists
        set cost_task_list [list ]
        set cost_probability_list [list ]
        set cost_label_list [list ]
        set cost_val_probability_lists [list ]
        foreach curve_band_list $cost_curve_data_lists {
            lappend cost_task_list [lindex $curve_band_list 0]
            lappend cost_probability_list [lindex $curve_band_list 1]            
            lappend cost_label_list [lindex $curve_band_list 2]
            lappend cost_val_probability_lists [list $cost_task_list $cost_probability_list]
        }

        # handy api ref
        # for { set ii 0 } { $ii < $last_row } { set ii $n } { #code }
        # lsort -integer -unique $rows_list
        # util_commify_number
        # format "% 8.2f" $num
        # f::sum $list
        # generate the data points
        # qaf_distribution_points_create
        # qaf_discrete_dist_report
        # qaf_harmonic_terms 
        # qaf_triangular_numbers
        # Naming conventions when creating interval calculations:
        #  s_arr - an array of scalar values
        #  list_arr - an arrary of lists
        #  html_arr - an array of html output

       ## # PERT calculations
        # create activity_list
        # create arrays of activity columns.

        
        # Build activity map table:
        # activity_ref predecessors 
        # add: time_est_short time_est_median time_est_long
        # add: cost_est_low cost_est_median cost_est_high 
        # if curves are blank, set expected value to (low + 4 * median + high) / 6.
        # add: time_expected cost_expected
        
        # build array of activity_ref sequence_num
        # default for each acitivity_ref 1
        ## assign an activity_ref one more than the max sequence_num of its dependencies
# defaults, inputs
#set act_depnc_list [list a "" b e,c,a c e,f d b,f,c e a f ""]
#set act_depnc_list [list a "" b a c "" d a e b f ""]
set act_depnc_list [list a "" b "" c "a" d a e "b,c" f d g e]
set act_time_est_list [list [list a 2 4 6] [list b 3 5 9] [list c 4 5 7] [list d 4 6 10] [list e 4 5 7] [list f 3 4 8] [list g 3 5 8] ]

set act_list [list ]
foreach {act_unfiltered depnc_unfiltered} $act_depnc_list {
    regsub -all -nocase -- {[^a-z0-9,]+} $depnc_unfiltered {} depnc
    regsub -all -nocase -- {[^a-z0-9,]+} $act_unfiltered {} act
    # depnc: comma list of dependencies
    # act: activity
    lappend act_list $act
    # depnc_arr() list of dependencies
    set depnc_arr($act) [split $depnc ,]
    # calcd_p_arr($act) Q: relative sequence number for $act been calculated?
    set calcd_p_arr($act) 0
    # act_seq_num_arr relative sequence number of an activity
    set sequence_1 0
    set act_seq_num_arr($act) $sequence_1
}

# time_expected_arr()
# time_est_arr() is a list of short, median, long
foreach act_t_list $act_time_est_list {
    set act [lindex $act_t_list 0]
    set time_est_arr($act) [lrange $act_t_list 1 3]
    set short [lindex $act_t_list 1]
    set med [lindex $act_t_list 2]
    set long [lindex $act_t_list 3]
    set time_expected_arr($act) [expr { ( $short + 4 * $med + $long ) / 6. } ]
    set path_dur_arr($act) $time_expected_arr($act)
}

# Calculate paths in the main loop to save resouces.
#  Each path is a list of numbers referenced by array, where array is path.
#  set path_segment_ends_in_lists($act) 
#         so future segments can quickly reference it to build theirs.
# This keeps path making nearly linear. There are as many path references as there are activities..
# Some of the references are incomplete paths, but these can be filtered as needed.
# All paths must be assessed in order to handle all possibilities
# Paths are used to determine critical path and fast crawl a single path.

# An activity cannot start until the longest dependent segment has completed.

# for strict critical path, create a list of lists, where 
# each list is a list of dependencies from start to finish (aka path)  + the longest duraction path of activity including dependencies.
# sum the duration for each list. The longest duration is the strict defintion of critical path.

# create dependency check equations
# depnc_eq_arr() is equation that answers question: Are dependencies met for $act?
foreach act $act_list {
    set eq "1 &&"
    foreach dep $depnc_arr($act) {
	append eq " calcd_p_arr($dep) &&"
    }
    set eq [string range $eq 0 end-3]
    regsub -all -- {calcd} $eq {$calcd} depnc_eq_arr($act)
}
# main process looping
set all_calced_p 0
set activity_count [llength $act_list]
set i 0
set act_seq_list_arr($sequence_1) [list ]
set act_count_of_seq_arr($sequence_1) 0
set path_seg_dur_list [list ]
# act_seq_max is the current maximum path length
# act_count_of_seq_arr($seq_num) is the count of activities in sequence_num
while { !$all_calced_p && $activity_count > $i } {
    set all_calcd_p 1
    foreach act $act_list {
        set dependencies_met_p [expr $depnc_eq_arr($act) ]
        set act_seq_max $sequence_1
        if { $dependencies_met_p && !$calcd_p_arr($act) } {

            # max_num: maximum relative sequence number for activity dependencies
            set max_num 0
            foreach test_act $depnc_arr($act) {
                set test $act_seq_num_arr($test_act)
                if { $max_num < $test } {
                    set max_num $test
                }
            }
            # Add activity's relative sequence number: act_seq_num_arr
            set act_seq_nbr [expr { $max_num + 1 } ]
            set act_seq_num_arr($act) $act_seq_nbr
            set calcd_p_arr($act) 1
            # increment act_seq_max and set defaults for a new max seq number?
            if { $act_seq_nbr > $act_seq_max } {
                set act_seq_max $act_seq_nbr
                set act_seq_list_arr($act_seq_max) [list ]
                set act_count_of_seq_arr($act_seq_max) 0
            }
            # add activity to the network for this sequence number
            lappend act_seq_list_arr($act_seq_nbr) $act
            incr act_count_of_seq_arr($act_seq_nbr)

            # Analize prior path segments here.
            # path_duration(path) is the min. path duration to complete dependent paths
            set path_duration 0
            # set duration_new to the longest dependent segment.
            foreach dep_act $depnc_arr($act) {
                if { $path_dur_arr($dep_act) > $path_duration } {
                    set path_duration $path_dur_arr($dep_act)
                }
            }
            set duration_arr($act) [expr { $path_duration + $time_expected_arr($act) } ]
            set path_seg_list_arr($act) [list ]
            #bad referencing here: separate duration from rest.
            foreach dep_act $depnc_arr($act) {
                foreach path_list $path_seg_list_arr($dep_act) {
                    set path_new $path_list
                    lappend path_new $act
                    lappend path_seg_list_arr($act) $path_new
                    lappend path_seg_dur_list [list $path_new $duration_arr($act)]
                }
            }
            if { [llength $path_seg_list_arr($act)] eq 0 } {
                lappend path_seg_list_arr($act) $act
                lappend path_seg_dur_list [list $act $duration_arr($act)]
            }
        }
        set all_calcd_p [expr { $all_calcd_p && $calcd_p_arr($act) } ]
    }
    incr i
}
set dep_met_p 1
ns_log Notice "pert.tcl: path_seg_dur_list $path_seg_dur_list"
foreach act $act_list {
    set $dep_met_p [expr $depnc_eq_arr($act) && $dep_met_p ]
#            ns_log Notice "pert.tcl: act $act act_seq_num_arr '$act_seq_num_arr($act)'"
            if { [info exists act_seq_list_arr($act_seq_num_arr($act)) ] } {
#                ns_log Notice "pert.tcl: act_seq_list_arr '$act_seq_list_arr($act_seq_num_arr($act))' $act_count_of_seq_arr($act_seq_num_arr($act))"
            }
#    ns_log Notice "pert.tcl: act $act act_seq_num_arr $act_seq_num_arr($act)"
}
ns_log Notice "pert.tcl: dep_met_p $dep_met_p"

# sort by path duration
# critical path is the longest path. Float is the difference between CP and next longest CP.
# create an array of paths from longest to shortest to help build base table
set path_seg_dur_sort1_list [lsort -decreasing -real -index 1 $path_seg_dur_list]
# Critical Path (CP) is 
set cp_list [lindex [lindex $path_seg_dur_sort1_list 0] 0]
#ns_log Notice "pert.tcl: path_seg_dur_sort1_list $path_seg_dur_sort1_list"

# Extract most significant CP alternates for a focused table
# by counting the number of times an act is used in the largest proportion (first half) of paths in path_set_dur_sort1_list
set path_count [llength $path_seg_dur_sort1_list]
set extract_limit [expr { $path_count / 2 + 1 } ]
set extractv1_list [lrange $path_seg_dur_sort1_list 0 ${extract_limit}] 
# act_freq_in_load_cp_alts_arr counts the number of times an activity is in a path  for the most significant CP alternates
set max_act_count_per_seq 0
foreach act $act_list {
    set act_freq_in_load_cp_alts_arr($act) 0
    if { $act_count_of_seq_arr($act) > $max_act_count_per_seq } {
        set max_act_count_per_seq $act_count_of_seq_arr($act)
    }
}
foreach path_seg_list $extractv1_list {
    set path2_list [lindex $path_seg_list 0]
    foreach act $path2_list {
        incr act_freq_in_load_cp_alts_arr($act)
    }
}
set act_sig_list [list ]
foreach act $act_list {
    lappend act_sig_list [list $act $act_freq_in_load_cp_alts_arr($act)]
}
set act_sig_sorted_list [lsort -decreasing -integer -index 1 $act_sig_list]
set act_max_count [lindex [lindex $act_sig_sorted_list 0] 1]
set act_sig_median_pos [expr { $extract_limit / 2 } + 1 ]
set act_median_count [lindex [lindex $act_sig_sorted_list $act_sig_median_pos] 1]

# build base table
# Table width should be limited to max count of acivities per sequence.

# activity_ref act_seq_num_arr has_direct_dependency_p time_expected direct_dependencies_list
set base_lists [list ]

foreach act $act_list {
    set has_direct_dependency_p [expr { [llength $depnc_arr($act)] > 0 } ]
    set on_critical_path_p [expr { [lsearch -exact $cp_list $act] > -1 } ]
    set on_a_sig_path_p [expr { $act_freq_in_load_cp_alts_arr($act) > $act_median_count } ]
    set activity_list [list $act $act_seq_num_arr($act) $has_direct_dependency_p $on_critical_path_p $on_a_sig_path_p $act_freq_in_load_cp_alts_arr($act)  $duration_arr($act) $time_expected_arr($act) $depnc_arr($act) ]
    lappend base_lists $activity_list
}

# act_count_of_seq_arr( sequence_number) is the count of activities at this sequence number
# max_act_count_per_seq is the maximum number of activities in a sequence number.

ns_log Notice "pert.tcl: base_lists $base_lists"
# critical path is the longest expexted duration of dependent activities..
# so:
# primary sort is act_seq_num_arr ascending
# secondary sort is part_of_critical_path_p descending
# third sort is has_direct_dependency_p descending (1 = true, 0 false)
# fourth sort is path duraction descending

set fourth_sort [lsort -decreasing -real -index 6 $base_lists]
set third_sort [lsort -decreasing -integer -index 2 $fourth_sort]
set second_sort [lsort -decreasing -integer -index 3 $third_sort]
set primary_sort [lsort -increasing -integer -index 1 $second_sort]

ns_log Notice "pert.tcl: primary_sort $primary_sort"



        # build unique list of dependencies

        # Build Network Breakdown Table: activity vs. path
        # 
        # activity_ref predecessors
        # add: sequence_num time_expected cost_expected
        # add:

        
        # the_time Time calculation completed
        set s_arr(the_time) [clock format [clock seconds] -format "%Y %b %d %H:%M:%S"]

        # html
        set html_arr(apt) "<h3>Computation report</h3>"

        append html_arr(apt) [qss_list_of_lists_to_html_table $stat_list $table_attribute_list $stat_format_list]
        append html_arr(apt) "Completed $s_arr(the_time)"
        append computation_report_html $html_arr(apt)
        
    }
    r {
        #  review.... show computed output 
        ns_log Notice "pert.tcl:  mode = review"
        #requires scenario_tid, dist_curve_tid

        # option not used for this app. No Calcs saved.
    }
    v {
        #  view table(s) (standard, html page document/report)
        ns_log Notice "pert.tcl:  mode = $mode ie. view table"
        if { [ecds_is_natural_number $scenario_tid] && [ecds_is_natural_number $dist_curve_tid] && $write_p } {
            lappend menu_list [list edit "scenario_tid=${scenario_tid}&dist_curve_tid=${dist_curve_tid}&mode=e"]
            set menu_e_p 1
        } else {
            set menu_e_p 0
        }
        if { [ecds_is_natural_number $scenario_tid] } {
            set act_stats_list [qss_table_stats $scenario_tid]
            set act_name [lindex $act_stats_list 0]
            set act_title [lindex $act_stats_list 1]
            set act_comments [lindex $act_stats_list 2]
            set scenario_html "<h3>${act_title} (${act_name})</h3>\n"
            set act_lists [qss_table_read $scenario_tid]
            set act_text [qss_lists_to_text $act_lists]
            set table_tag_atts_list [list border 1 cellpadding 3 cellspacing 0]
            append scenario_html [qss_list_of_lists_to_html_table $act_lists $table_tag_atts_list]
            append scenario_html "<p>${act_comments}</p>"
            if { ![ecds_is_natural_number $dist_curve_tid] } {
                # can dist_curve_tid be extracted from scenario?
                set constants_list [list dist_curve_tid]
                foreach condition_list $act_lists {
                    set constant [lindex $condition_list 0]
                    if { [lsearch -exact $constants_list $constant] > -1 } {
                        set input_array($constant) [lindex $condition_list 1]
                        set $constant $input_array($constant)
                        ns_log Notice "pert.tcl: : constant $constant set to $input_array($constant)"
                    }
                }
            }
            if { !$menu_e_p && $write_p } {

                lappend menu_list [list edit "scenario_tid=${scenario_tid}&mode=e"]
            }
        }
        if { [ecds_is_natural_number $dist_curve_tid] } {
            set dc_stats_list [qss_table_stats $dist_curve_tid]
            set dc_name [lindex $dc_stats_list 0]
            set dc_title [lindex $dc_stats_list 1]
            set dc_comments [lindex $dc_stats_list 2]
            set dist_curve_html "<h3>${dc_title} (${dc_name})</h3>\n"

            # get table from ID
            set dc_lists [qss_table_read $dist_curve_tid]
            set dc_text [qss_lists_to_text $dist_curve_lists]
            set table_tag_atts_list [list border 1 cellpadding 3 cellspacing 0]
            append dist_curve_html [qss_list_of_lists_to_html_table $dc_lists $table_tag_atts_list]
            append dist_curve_html "<p>${dc_comments}</p>"
            if { !$menu_e_p && ![ecds_is_natural_number $scenario_tid] && $write_p } {
                lappend menu_list [list edit "dist_curve_tid=${dist_curve_tid}&mode=e"]
            }
        }
        if { [ecds_is_natural_number $scenario_tid] && [ecds_is_natural_number $dist_curve_tid] } {
            lappend menu_list [list compute "scenario_tid=${scenario_tid}&dist_curve_tid=${dist_curve_tid}&mode=c"]
        }
    }
    default {
        # default includes v,p

        #  present...... presents a list of contexts/scenarios to choose from
        ns_log Notice "pert.tcl:  mode = $mode ie. default"


        # show scenario, dist_curve  tables
        # sort by template_id, columns

        set table_ids_list [qss_tables $package_id]
        set table_stats_lists [list ]
        set table_trashed_lists [list ]
        set cell_formating_list [list ]
        set tables_stats_lists [list ]
        # we get the entire list, to sort it before processing
        foreach table_id $table_ids_list {

            set stats_mod_list [list $table_id]
            set stats_orig_list [qss_table_stats $table_id]
            foreach stat $stats_orig_list {
                lappend stats_mod_list $stat
            }
            # table_id, name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id
            lappend tables_stats_lists $stats_mod_list
        }
        set tables_stats_lists [lsort -index 6 -real $tables_stats_lists]

        foreach stats_orig_list $tables_stats_lists {
            set stats_list [lrange $stats_orig_list 0 5]
            set table_id [lindex $stats_list 0]
            set name [lindex $stats_list 1]
            set template_id [lindex $stats_orig_list 6]
            set table_user_id [lindex $stats_orig_list 12]
            set trashed_p [lindex $stats_orig_list 8]
            # adding average col. length
            set denominator [expr { [lindex $stats_list 5] } ]
            if { $denominator > 0 } {
                set col_length [expr { [lindex $stats_list 4] / ( [lindex $stats_list 5] * 1. ) } ]
            } else {
                set col_length 0.
            }
            lappend stats_list $col_length

            # convert table row for use with html
            # change name to an active link
            if { $col_length != 3 || $template_id == 10040 } {
                set table_ref_name scenario_tid

            } else { 
                set table_ref_name dist_curve_tid
            }

            set active_link "<a\ href=\"pert?${table_ref_name}=${table_id}\">$name</a>"

            if { ( $admin_p || $table_user_id == $user_id ) && $trashed_p == 1 } {
                set trash_label "untrash"
                append active_link " \[<a href=\"pert?${table_ref_name}=${table_id}&mode=t\">${trash_label}</a>\]"
            } elseif { $table_user_id == $user_id || $admin_p } {
                set trash_label "trash"
                append active_link " \[<a href=\"pert?${table_ref_name}=${table_id}&mode=t\">${trash_label}</a>\]"
            } 
            if { $delete_p && $trashed_p == 1 } {
                append active_link " \[<a href=\"pert?${table_ref_name}=${table_id}&mode=d\">delete</a>\]"
            } 
            set stats_list [lreplace $stats_list 0 1 $active_link]
            if { $trashed_p == 1 } {
                lappend table_trashed_lists $stats_list
            } else {
                lappend table_stats_lists $stats_list
            }

        }
        # sort for now. Later, just get scenario_tables with same template_id
        set table_stats_sorted_lists $table_stats_lists
        set table_stats_sorted_lists [linsert $table_stats_sorted_lists 0 [list Name Title Comments "Cell count" "Row count" "Columns (avg)"] ]
        set table_tag_atts_list [list border 1 cellspacing 0 cellpadding 3]
        set table_stats_html [qss_list_of_lists_to_html_table $table_stats_sorted_lists $table_tag_atts_list $cell_formating_list]
        # trashed
        if { [llength $table_trashed_lists] > 0 && $write_p } {
            set table_trashed_sorted_lists $table_trashed_lists
            set table_trashed_sorted_lists [linsert $table_trashed_sorted_lists 0 [list Name Title Comments "Cell count" "Row count" "Columns (avg)"] ]
            set table_tag_atts_list [list border 1 cellspacing 0 cellpadding 3]

            set table_trashed_html "<h3>Trashed tables</h3>\n"
            append table_trashed_html [qss_list_of_lists_to_html_table $table_trashed_sorted_lists $table_tag_atts_list $cell_formating_list]
            append table_stats_html $table_trashed_html
        }
    }
}
# end of switches

set menu_html ""
foreach item_list $menu_list {
    set label [lindex $item_list 0]
    set url [lindex $item_list 1]
    append menu_html "<a href=\"pert?${url}\">${label}</a>&nbsp;"
}

set user_message_html ""
foreach user_message $user_message_list {
    append user_message_html "<li>${user_message}</li>"
}
