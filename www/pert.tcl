# generic header for static .adp pages

set title "PRETTI"
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
    table_tid ""\
    table_text ""\
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

    # following is part of dynamic menu processing using form tags instead of url/GET..
    set input_array_idx_list [array names input_array]
    set modes_idx [lsearch -regexp $input_array_idx_list {z[vprnwctde][vc]?}]
    if { $modes_idx > -1 && $mode eq "p" } {
        set modes [lindex $input_array_idx_list $modes_idx]
        # modes 0 0 is z
        set mode [string range $modes 1 1]
        set next_mode [string range $modes 2 2]
    }

    set table_tid $input_array(table_tid)
    # validate input
    # cleanse, validate mode
    # determine input completeness
    # form has modal inputs, so validation is a matter of cleansing data and verifying references
    set validated 0

    switch -exact -- $mode {
        e {
            ns_log Notice "pert.tcl:  validated for e"
            set validated 1
            if { ![qf_is_natural_number $table_tid] } {
                set mode "n"
                set next_mode ""
            } 
        }
        d {
            ns_log Notice "pert.tcl:  validated for d"
            set validated 1
            if { ( ![qf_is_natural_number $table_tid] ) || !$delete_p } {
                set mode "p"
                set next_mode ""
            } 
        }
        t {
            ns_log Notice "pert.tcl:  validated for t"
            set validated 1
            if { ![qf_is_natural_number $table_tid] } {
                set mode "p"
                set next_mode ""
            } 
        }
        c {
            ns_log Notice "pert.tcl:  validated for c"
            set validated 1
            if { ![qf_is_natural_number $table_tid] } {
                lappend user_message_list "Table for Scenario has not been specified."
                set validated 0
                set mode "p"
                set next_mode ""
            } 
            # check for any form inputs?
        }
        w {
            set table_text $input_array(table_text)
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
            if { [qf_is_natural_number $table_tid] } {
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
            # determine table type P1..5
####

            # write the data
            # a different user_id makes new context based on current context, otherwise modifies same context
            # or create a new context if no context provided.
            # given:
            # act_* is table_
            # dc_* is dist_curve_
            if { [string length $table_text] > 0 && $table_text ne $table_default } {
                # act_name  Table Name

                if { $input_array(act_name) eq "" && $table_tid eq "" } {
                    set act_name "act[clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(act_name) eq "" } {
                    set act_name "initCon${table_tid}"
                } else {
                    set act_name $input_array(act_name)
                }
                # act_title Table title
                if { $input_array(act_title) eq "" && $table_tid eq "" } {
                    set act_title "Scenario [clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(act_title) eq "" } {
                    set act_title "Scenario ${table_tid}"
                } else {
                    set act_title $input_array(act_title)
                }
                ns_log Notice "pert.tcl:  act_name '${act_name}' [string length $act_name]"
                # act_comments Comments
                set act_comments $input_array(act_comments)
                # table_text
           
                # convert tables from _text to _list
                set line_break "\n"
                set delimiter ","
                # linebreak_char delimiter rows_count columns_count 
                set act_text_stats [qss_txt_table_stats $table_text]
                ns_log Notice "pert.tcl: : act_text_stats $act_text_stats"
                set line_break [lindex $act_text_stats 0]
                set delimiter [lindex $act_text_stats 1]
                ns_log Notice "pert.tcl: : table_text ${table_text}"
                set act_lists [qss_txt_to_tcl_list_of_lists $table_text $line_break $delimiter]
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
                if { [qf_is_natural_number $table_tid] } {
                    set table_stats [qss_table_stats $table_tid]
                    set name_old [lindex $table_stats 0]
                    set title_old [lindex $table_stats 1]
                    if { $name_old eq $act_name && $title_old eq $act_title } {
                        ns_log Notice "pert.tcl: : qss_table_write table_id ${table_tid}" 
                        qss_table_write $act_lists $act_name $act_title $act_comments $table_tid $act_template_id $act_flags $package_id $user_id
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


            set mode $next_mode
            set next_mode ""
        }
        if { $mode eq "d" } {
            #  delete.... removes context     
            ns_log Notice "pert.tcl:  mode = delete"
            #requires table_tid
            # delete table_tid 
            if { [qf_is_natural_number $table_tid] } {
                qss_table_delete $table_tid
            }
            set mode $next_mode
            set next_mode ""
        }
        if { $mode eq "t" } {
            #  trash
            ns_log Notice "pert.tcl:  mode = trash"
            #requires table_tid
            # delete table_tid 
            if { [qf_is_natural_number $table_tid] && $write_p } {
                set trashed_p [lindex [qss_table_stats $table_tid] 7]
                if { $trashed_p == 1 } {
                    set trash 0
                } else {
                    set trash 1
                }
                qss_table_trash $trash $table_tid
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
        #requires table_tid, dist_curve_tid
        # make a form to edit 
        # get table from ID


        set form_id [qf_form action pert method get id 20120531]
        
        qf_input type hidden value w name mode label ""
        
        if { [qf_is_natural_number $table_tid] } {
            set act_stats_list [qss_table_stats $table_tid]
            set act_name [lindex $act_stats_list 0]
            set act_title [lindex $act_stats_list 1]
            set act_comments [lindex $act_stats_list 2]
            set act_flags [lindex $act_stats_list 6]
            set act_template_id [lindex $act_stats_list 5]

            set table_lists [qss_table_read $table_tid]
            set table_text [qss_lists_to_text $table_lists]

            qf_input type hidden value $table_tid name table_tid label ""
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
            qf_textarea value $table_text cols 40 rows 6 name table_text label "Table data:"
            qf_append html "</div>"
        }

        qf_input type submit value "Save"
        qf_close id $form_id
        set form_html [qf_read id $form_id]

    }
    w {
        #  save.....  (write) table_tid and dist_curve_tid
        # should already have been handled above
        ns_log Notice "pert.tcl:  mode = save THIS SHOULD NOT BE CALLED."
        # it's called in validation section.
    }
    n {
        #  new....... creates new, blank context (form)    
        ns_log Notice "pert.tcl:  mode = new"
        #requires no table_tid, dist_curve_tid
        set table_text ""

        # make a form with no existing table_tid and dist_curve_tid

        set form_id [qf_form action pert method get id 20140415]

        qf_input type hidden value w name mode label ""
        qf_append html "<h3>Table</h3>"
        qf_append html "<div style=\"width: 70%; text-align: right;\">"
        qf_input type text value "" name act_name label "Table name:" size 40 maxlength 40
        qf_append html "<br>"
        qf_input type text value "" name act_title label "Title:" size 40 maxlength 80
        qf_append html "<br>"
        qf_textarea value "" cols 40 rows 3 name act_comments label "Comments:"
        qf_append html "<br>"
        qf_textarea value $table_text cols 40 rows 6 name table_text label "Table data:"
        qf_append html "</div>"

        qf_input type submit value "Save" name test class btn

        qf_close form_id $form_id
        set form_html [qf_read form_id $form_id]
    }
    c {
        #  compute... compute/process and write output as a new table, present post_calc results
        ns_log Notice "pert.tcl:  mode = compute"
        #requires table_tid
        # given table_tid 
##### compute pretti_..
        
    }
    r {
        #  review.... show computed output 
        ns_log Notice "pert.tcl:  mode = review"
        #requires table_tid

        # option not used for this app. Calcs are saved as a table. use mode v
    }
    v {
        #  view table(s) (standard, html page document/report)
        ns_log Notice "pert.tcl:  mode = $mode ie. view table"
        if { [qf_is_natural_number $table_tid] && $write_p } {
            lappend menu_list [list edit "table_tid=${table_tid}&mode=e"]
            set menu_e_p 1
        } else {
            set menu_e_p 0
        }
        if { [qf_is_natural_number $table_tid] } {
            set act_stats_list [qss_table_stats $table_tid]
            set act_name [lindex $act_stats_list 0]
            set act_title [lindex $act_stats_list 1]
            set act_comments [lindex $act_stats_list 2]
            set table_html "<h3>${act_title} (${act_name})</h3>\n"
            set act_lists [qss_table_read $table_tid]
            set act_text [qss_lists_to_text $act_lists]
            set table_tag_atts_list [list border 1 cellpadding 3 cellspacing 0]
            append table_html [qss_list_of_lists_to_html_table $act_lists $table_tag_atts_list]
            append table_html "<p>${act_comments}</p>"
            if { !$menu_e_p && $write_p } {

                lappend menu_list [list edit "table_tid=${table_tid}&mode=e"]
            }
        }
        # if scenario meets minimum compute requirements, add a compute button to menu:
        if { [qf_is_natural_number $table_tid] && [qf_is_natural_number $dist_curve_tid] } {
            lappend menu_list [list compute "table_tid=${table_tid}&mode=c"]
        }
    }
    default {
        # default includes v,p

        #  present...... presents a list of contexts/scenarios to choose from
        ns_log Notice "pert.tcl:  mode = $mode ie. default"


        # show tables
        # sort by template_id, columns, and table_type (flags)

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
            set table_ref_name table_tid
            
##### each active_link becomes a separate form..
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
        # sort for now. Later, just get table_tables with same template_id
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

#       convert menus to use buttons like this: qf_input type submit value "Save" name test class btn
#### but first have to figure out how to pass i8ln values.. ???? converts to test=Save...
####         qf_input type submit value "#jhkjhk.Save2#" name test2 class btn
# the way to do it is pass the name.. the name is fieldname and is consistent regardless of il8n value
# and only gets passed if input type button is submitted.. 
# so, to establish both mode and next_mode, combined both and identify uniquely with a prefix z
# for example, zn for mode=n next_mode="" etc
set menu_html ""
array unset form_input_arr
set form_id [qf_form action pert method post id 20140417]
foreach item_list $menu_list {
    set label [lindex $item_list 0]
    set url [lindex $item_list 1]
    set url_list [split $url "&="]
    set name1 ""
    set name2 ""
    foreach {val1 val2} $url_list {
        # buttons reverse the use of name and value for mode and next_mode
        if { $val1 eq "mode" } {
            set value "#accounts-finance.${label}#"
            set name1 $val2
        } elseif { $val1 eq "next_mode" } {
            set value "#accounts-finance.${label}#"
            set name2 $val2
        } else {
            set form_input_arr($val1) $val2
        }
    }
    if { $name1 ne "" } {
        set name "z${name1}${name2}"
        qf_input form_id $form_id type submit value $value name $name class btn
    }
#    append menu_html "<a href=\"pert?${url}\">${label}</a>&nbsp;"
}
foreach {name value} [array get form_input_arr] {
    qf_input form_id $form_id type hidden value $value name $name label ""
}
qf_close form_id $form_id
set menu_html [qf_read form_id $form_id]

set user_message_html ""
foreach user_message $user_message_list {
    append user_message_html "<li>${user_message}</li>"
}
