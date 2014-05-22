# generic header for static .adp pages


set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set write_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege write]
set admin_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege admin]
set delete_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege delete]
# randmize rand with seed from clock
expr { srand([clock clicks]) }

set table_default ""
set mode_name "#accounts-finance.tables#"
# tid = table_id
array set input_array [list \
    table_tid ""\
    table_template_id ""\
    table_name ""\
    table_title ""\
    table_comments ""\
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
set form_posted [qf_get_inputs_as_array input_array hash_check 1]
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
            ns_log Notice "pert.tcl.68:  validated for e"
            set validated 1
            if { ![qf_is_natural_number $table_tid] } {
                set mode "n"
                set next_mode ""
            } 
        }
        d {
            set validated 1
            if { ( ![qf_is_natural_number $table_tid] ) || !$delete_p } {
                ns_log Notice "pert.tcl table_tid '${table_tid}' or delete_p $delete_p is not valid for mode d"
                set mode "p"
                set next_mode ""
            } 
        }
        t {
            set validated 1
            if { ![qf_is_natural_number $table_tid] } {
                ns_log Notice "pert.tcl.86: table_tid '${table_tid}' is not valid for mode t"
                set mode "p"
                set next_mode ""
            } 
        }
        c {
            set validated 1
            if { ![qf_is_natural_number $table_tid] } {
                ns_log Notice "pert.tcl.94: table_tid '${table_tid}' is not valid for mode c"
                lappend user_message_list "Table has not been specified."
                set validated 0
                set mode "p"
                set next_mode ""
            } 
            # check for any form inputs?
        }
        w {
            set table_text $input_array(table_text)
            set validated 1
            ns_log Notice "pert.tcl.105:  validated for w"
        }
        n {
            set validated 1
            ns_log Notice "pert.tcl.109:  validated for n"
        }
        r {
            set validated 1
            ns_log Notice "pert.tcl.113:  validated for r"
        }
        default {
            ns_log Notice "pert.tcl.116:  validated for v"
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
            # write the data
            # a different user_id makes new context based on current context, otherwise modifies same context
            # or create a new context if no context provided.

            if { [string length $table_text] > 0 && $table_text ne $table_default } {
                # table_name  Table Name

                if { $input_array(table_name) eq "" && $table_tid eq "" } {
                    set table_name "table[clock format [clock seconds] -format %Y%m%d-%X]"
                    regsub -all -- {[\.\:\-]} $table_name {} table_name 
                } elseif { $input_array(table_name) eq "" } {
                    set table_name "initCon${table_tid}"
                } else {
                    set table_name $input_array(table_name)
                }
                # table_title Table title
                if { $input_array(table_title) eq "" && $table_tid eq "" } {
                    set table_title "Table [clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(table_title) eq "" } {
                    set table_title "Table ${table_tid}"
                } else {
                    set table_title $input_array(table_title)
                }
                ns_log Notice "pert.tcl.157:  table_name '${table_name}' [string length $table_name]"
                # table_comments Comments
                set table_comments $input_array(table_comments)
                # table_text
           
                # convert tables from _text to _list
                set line_break "\n"
                set delimiter ","
                # linebreak_char delimiter rows_count columns_count 
                set table_text_stats [qss_txt_table_stats $table_text]
                ns_log Notice "pert.tcl.167: table_text_stats $table_text_stats"
                set line_break [lindex $table_text_stats 0]
                set delimiter [lindex $table_text_stats 1]

                ns_log Notice "pert.tcl.171: table_text ${table_text}"
                set table_lists [qss_txt_to_tcl_list_of_lists $table_text $line_break $delimiter]
                ns_log Notice "pert.tcl.173: set table_lists ${table_lists}"
                # cleanup input
                set table_lists_new [list ]
                foreach condition_list $table_lists {
                    set row_new [list ]
                    foreach cell $condition_list {
                        set cell_new [string trim $cell]
                        regsub -all -- {[ ][ ]*} $cell_new { } cell_new
                        lappend row_new $cell_new
                        #ns_log Notice "pert.tcl.182:  new cell '$cell_new'"
                    }
                    if { [llength $row_new] > 0 } {
                        lappend table_lists_new $row_new
                    }
                }
                set table_lists $table_lists_new
                ns_log Notice "pert.tcl.189: : create/write table" 
                ns_log Notice "pert.tcl.190: : llength table_lists [llength $table_lists]"
                # detect table type for flags
                set table_flags [acc_fin::pretti_type_flag $table_lists]
                ns_log Notice "pert.tcl.193: table_flags $table_flags"
                if { [qf_is_natural_number $table_tid] } {
                    set table_stats [qss_table_stats $table_tid]
                    # name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id.
                    set name_old [lindex $table_stats 0]
                    set title_old [lindex $table_stats 1]
                    set comments_old [lindex $table_stats 2]
                    set table_template_id [lindex $table_stats 5]

                    # For revisioning purposes, create a new table each time, except:
                    # Don't create a new table if it is exactly the same as the old one... ie same table, name, title

                    # Old method wrote to the same table using qss_table_write when name and title were the same regardless of comments or content.

                    # Get table_lists_old table_comments_old and compare..
                    set table_old_lists [qss_table_read $table_tid]
                    if { $table_name eq $name_old && $table_title eq $title_old && $table_comments eq $comments_old && $table_lists eq $table_old_lists } {
                        # Don't create a new table. The new one is exactly like the old one..
                    } else {
                        qss_table_create $table_lists $table_name $table_title $table_comments $table_template_id $table_flags $package_id $user_id
                    }

                } else {
                    ns_log Notice "pert.tcl.210: qss_table_create new table"
                    qss_table_create $table_lists $table_name $table_title $table_comments "" $table_flags $package_id $user_id
                }

            }


            set mode $next_mode
            set next_mode ""
        }
        if { $mode eq "d" } {
            #  delete.... removes context     
            ns_log Notice "pert.tcl.222:  mode = delete"
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
            ns_log Notice "pert.tcl.233:  mode = trash"
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
        ns_log Notice "pert.tcl.264:  mode = edit"
        set mode_name "#accounts-finance.edit#"
        #requires table_tid
        # make a form to edit 
        # get table from ID


        set form_id [qf_form action pert method post id 20120531 hash_check 1]
        
        qf_input type hidden value w name mode label ""
        
        if { [qf_is_natural_number $table_tid] } {
            set table_stats_list [qss_table_stats $table_tid]
            set table_name [lindex $table_stats_list 0]
            set table_title [lindex $table_stats_list 1]
            set table_comments [lindex $table_stats_list 2]
            set table_flags [lindex $table_stats_list 6]
            set table_template_id [lindex $table_stats_list 5]

            set table_lists [qss_table_read $table_tid]
            set table_text [qss_lists_to_text $table_lists]

            qf_input type hidden value $table_tid name table_tid label ""
            qf_input type hidden value $table_flags name table_flags label ""
            qf_input type hidden value $table_template_id name table_template_id label ""
            qf_append html "<h3>Table</h3>"
            qf_append html "<div style=\"width: 70%; text-align: right;\">"
            qf_input type text value $table_name name table_name label "Table name:" size 40 maxlength 40
            qf_append html "<br>"
            qf_input type text value $table_title name table_title label "Title:" size 40 maxlength 80
            qf_append html "<br>"
            qf_textarea value $table_comments cols 40 rows 3 name table_comments label "Comments:"
            qf_append html "<br>"
            qf_textarea value $table_text cols 40 rows 6 name table_text label "Table data:"
            qf_append html "</div>"
        }

        qf_input type submit value "Save"
        qf_close form_id $form_id
        set form_html [qf_read form_id $form_id]

    }
    w {
        #  save.....  (write) table_tid 
        # should already have been handled above
        ns_log Notice "pert.tcl.309:  mode = save THIS SHOULD NOT BE CALLED."
        # it's called in validation section.
    }
    n {
        #  new....... creates new, blank context (form)    
        ns_log Notice "pert.tcl.314:  mode = new"
        set mode_name "#accounts-finance.new#"
        #requires no table_tid
        set table_text ""

        # make a form with no existing table_tid 

        set form_id [qf_form action pert method post id 20140415 hash_check 1]

        qf_input type hidden value w name mode label ""
        qf_append html "<h3>Table</h3>"
        qf_append html "<div style=\"width: 70%; text-align: right;\">"
        qf_input type text value "" name table_name label "Table name:" size 40 maxlength 40
        qf_append html "<br>"
        qf_input type text value "" name table_title label "Title:" size 40 maxlength 80
        qf_append html "<br>"
        qf_textarea value "" cols 40 rows 3 name table_comments label "Comments:"
        qf_append html "<br>"
        qf_textarea value $table_text cols 40 rows 6 name table_text label "Table data:"
        qf_append html "</div>"

        qf_input type submit value "Save" name test class btn

        qf_close form_id $form_id
        set form_html [qf_read form_id $form_id]
    }
    c {
        #  process... compute/process and write output as a new table, present post_calc results
        ns_log Notice "pert.tcl.342:  mode = process"
        set mode_name "#accounts-finance.process#"
        #requires table_tid
        # given table_tid 
##### process pretti_..
        
    }
    r {
        #  review.... show processd output 
        ns_log Notice "pert.tcl.351:  mode = review"
        #requires table_tid

        # option not used for this app. Calcs are saved as a table. use mode v
    }
    v {
        #  view table(s) (standard, html page document/report)
        ns_log Notice "pert.tcl.358:  mode = $mode ie. view table"
        set mode_name "#accounts-finance.view#"
        if { [qf_is_natural_number $table_tid] && $write_p } {
            lappend menu_list [list edit "table_tid=${table_tid}&mode=e"]
            set menu_e_p 1
        } else {
            set menu_e_p 0
        }
        if { [qf_is_natural_number $table_tid] } {
            set table_stats_list [qss_table_stats $table_tid]
            # name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id
            set table_name [lindex $table_stats_list 0]
            set table_title [lindex $table_stats_list 1]
            set table_comments [lindex $table_stats_list 2]
            set table_flags [lindex $table_stats_list 6]
            set table_html "<h3>${table_title} (${table_name})</h3>\n"
            set table_lists [qss_table_read $table_tid]
            set table_text [qss_lists_to_text $table_lists]
            set table_tag_atts_list [list border 1 cellpadding 3 cellspacing 0]
            append table_html [qss_list_of_lists_to_html_table $table_lists $table_tag_atts_list]
            append table_html "<p>${table_comments}</p>"
            if { !$menu_e_p && $write_p } {

                lappend menu_list [list edit "table_tid=${table_tid}&mode=e"]
            }
        }
        # if table is a scenario (meets minimum process requirements), add a process button to menu:
        if { [qf_is_natural_number $table_tid] && $table_flags eq "p1" } {
            lappend menu_list [list process "table_tid=${table_tid}&mode=c"]
        }
    }
    default {
        # default includes v,p
        #  present...... presents a list of contexts/tables to choose from
        ns_log Notice "pert.tcl.392:  mode = $mode ie. default"


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
        set select_label "#accounts-finance.select#"
        set untrash_label "#accounts-finance.untrash#"
        set trash_label "#accounts-finance.trash#"
        set delete_label "#accounts-finance.delete#"
        set table_titles_list [list "#accounts-finance.ID#" "#accounts-finance.Name#" "#accounts-finance.title#" "#accounts-finance.actions#" "#accounts-finance.comments#" "#accounts-finance.cells#" "#accounts-finance.rows#" "#accounts-finance.columns#" "#accounts-finance.type#" "#accounts-finance.last_modified#"]
        array set table_types_list [list "p1" "#accounts-finance.scenario#" \
                                        "p2" "#accounts-finance.activity#" \
                                        "p3" "#accounts-finance.task#" \
                                        "p4" "#accounts-finance.PRETTI_rows#" \
                                        "p5" "#accounts-finance.PRETTI_cells#" ]
        # table_id, name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id
        foreach stats_orig_list $tables_stats_lists {
            set stats_list [lrange $stats_orig_list 0 5]
            set table_id [lindex $stats_list 0]
            set name [lindex $stats_list 1]
            set table_template_id [lindex $stats_orig_list 6]
            set table_flags [lindex $stats_orig_list 7]
            set trashed_p [lindex $stats_orig_list 8]
            set last_modified [lindex $stats_orig_list 10]
            if { $last_modified ne "" } {
                set last_modified [lc_time_fmt $last_modified "%x %X"]
                set last_modified [lc_time_system_to_conn $last_modified ]
            }
            set table_user_id [lindex $stats_orig_list 12]
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
            # set table_ref_name table_tid
            
            # each $active_link becomes a separate form..

            ## app can be setup to use name_link with a dedicated index.vuh
            # set name_link "<a\ href=\"${name}\">${name}</a>"
            set random [clock clicks]
            set random "[clock clicks][string range [expr { rand() } ] 2 end]"
            set form_id [qf_form action pert method post id 20140420-$random hash_check 1]

            ## if using name_link, comment out this next line:
            qf_input type submit value $select_label name "zv" class btn

            qf_input type hidden value $table_id name table_tid
            if { ( $admin_p || $table_user_id == $user_id ) && $trashed_p == 1 } {
                #append active_link " \[<a href=\"pert?${table_ref_name}=${table_id}&mode=t\">${untrash_label}</a>\]"
                qf_input type submit value $untrash_label name "zt" class btn
            } elseif { $table_user_id == $user_id || $admin_p } {
                #append active_link " \[<a href=\"pert?${table_ref_name}=${table_id}&mode=t\">${trash_label}</a>\]"
                qf_input type submit value $trash_label name "zt" class btn
            } 
            if { $delete_p && $trashed_p == 1 } {
                #append active_link " \[<a href=\"pert?${table_ref_name}=${table_id}&mode=d\">${delete_label}</a>\]"
                qf_input type submit value $delete_label name "zd" class btn
            } 
            qf_close form_id $form_id
            set active_link [qf_read form_id $form_id]
            #set stats_list [lreplace $stats_list 1 1 $name_link]
            set stats_list [linsert $stats_list 3 $active_link]
            lappend stats_list $table_flags $last_modified
            if { $trashed_p == 1 } {
                lappend table_trashed_lists $stats_list
            } else {
                lappend table_stats_lists $stats_list
            }

        }
        # sort for now. Later, just get table_tables with same template_id
        set table_stats_sorted_lists $table_stats_lists
        set table_stats_sorted_lists [linsert $table_stats_sorted_lists 0 $table_titles_list ]
        set table_tag_atts_list [list border 1 cellspacing 0 cellpadding 3]
        set table_stats_html [qss_list_of_lists_to_html_table $table_stats_sorted_lists $table_tag_atts_list $cell_formating_list]
        # trashed
        if { [llength $table_trashed_lists] > 0 && $write_p } {
            set table_trashed_sorted_lists $table_trashed_lists
            set table_trashed_sorted_lists [linsert $table_trashed_sorted_lists 0 $table_titles_list ]
            set table_tag_atts_list [list border 1 cellspacing 0 cellpadding 3]

            set table_trashed_html "<h3>#accounts-finance.trashed# #accounts-finance.tables#</h3>\n"
            append table_trashed_html [qss_list_of_lists_to_html_table $table_trashed_sorted_lists $table_tag_atts_list $cell_formating_list]
            append table_stats_html $table_trashed_html
        }
    }
}
# end of switches

set menu_html ""
array unset form_input_arr
set form_id [qf_form action pert method post id 20140417 hash_check 1]
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

set title "PRETTI ${mode_name}"
set context [list [list pert $title] $mode_name]
