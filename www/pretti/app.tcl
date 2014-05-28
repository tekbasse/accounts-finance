# generic header for static .adp pages


set instance_id [ad_conn package_id]
set user_id [ad_conn user_id]
set read_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege read]
if { $read_p } {
    set create_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege create]
    set write_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege write]
    if { $write_p } {
        set delete_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege delete]
        if { $delete_p } {
            set admin_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege admin]
        } else {
            set admin_p 0
        }
    } else {
        set admin_p 0
        set delete_p 0
    }
} else {
    set create_p 0
    set write_p 0
    set admin_p 0
    set delete_p 0
}
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
    trash_folder_p "0"\
    column_name "" \
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
set trash_folder_p $input_array(trash_folder_p)
set column_name $input_array(column_name)

if { $form_posted } {
    if { [info exists input_array(x) ] } {
        unset input_array(x)
    }
    if { [info exists input_array(y) ] } {
        unset input_array(y)
    }


    # following is part of dynamic menu processing using form tags instead of url/GET.. and lib/pretti-menu1
    set input_array_idx_list [array names input_array]
    set modes_idx [lsearch -regexp $input_array_idx_list {z[vprnwctdes][vc]?}]
    if { $modes_idx > -1 && $mode eq "p" } {
        set modes [lindex $input_array_idx_list $modes_idx]
        # modes 0 0 is z
        set mode [string range $modes 1 1]
        set mode2 [string range $modes 2 2]
        if { [string length $mode2] == 1 } {
            set next_mode $mode2
        }
    }
    # trash_folder_p = 0 to view untrashed content, or = 1 to view trashed content
    set trash_folder_p $input_array(trash_folder_p)
    set table_tid $input_array(table_tid)
    set column_name $input_array(column_name)

    # validate input
    # cleanse, validate mode
    # determine input completeness
    # form has modal inputs, so validation is a matter of cleansing data and verifying references
    set validated 0

    switch -exact -- $mode {
        e {
            ns_log Notice "accounts-finance/www/pretti/app.tcl.68:  validated for e"
            if { [qf_is_natural_number $table_tid] } {
                set validated 1
            } else {
                set mode "n"
                set next_mode ""
                set validated 0
            }
        }
        d {
            set validated 0
            # Form has to handle multiple table_tid's from checkboxes.
            set tid_name_list [array names input_array -regexp {tid_[0-9]+} ]
            set tid_list [list ]
            foreach tid $tid_name_list {
                if { [qf_is_natural_number $input_array($tid)] } {
                    ns_log Notice "accounts-finance/www/pretti/app.tcl.70: tid '$tid' input_array($tid) '$input_array($tid)'"
                    lappend tid_list $input_array($tid)
                }
            }
            if { ( [qf_is_natural_number $table_tid] || [llength $tid_list] > 0 ) && $delete_p } {
                set validated 1
            } else {
                ns_log Notice "accounts-finance/www/pretti/app.tcl.76 table_tid '${table_tid}' or delete_p $delete_p is not valid for mode d"
                set mode "p"
                set next_mode ""
            }
        }
        t {
            set validated 0
            # Form has to handle multiple table_tid's from checkboxes.
            set tid_name_list [array names input_array -regexp {tid_[0-9]+} ]
            set tid_list [list ]
            foreach tid $tid_name_list {
                #ns_log Notice "accounts-finance/www/pretti/app.tcl.80: tid '$tid' input_array($tid) '$input_array($tid)'"
                if { [qf_is_natural_number $input_array($tid)] } {
                    lappend tid_list $input_array($tid)
                }
            }
            # can only check for minimum permission at this point. ie $create_p for trashable self-created content
            if { ( [qf_is_natural_number $table_tid] || [llength $tid_list] > 0 ) && $create_p } {
                set validated 1
            } else {
                ns_log Notice "accounts-finance/www/pretti/app.tcl.86: table_tid '${table_tid}' or llength tid_list [llength $tid_list] is not valid for mode t"
                set mode "p"
                set next_mode ""
            }
        }
        c {
            set validated 1
            if { ![qf_is_natural_number $table_tid] } {
                ns_log Notice "accounts-finance/www/pretti/app.tcl.94: table_tid '${table_tid}' is not valid for mode c"
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
            ns_log Notice "accounts-finance/www/pretti/app.tcl.105:  validated for w"
        }
        n {
            if { [info exists table_tid] } {
                unset table_tid
            }
            set validated 1
            ns_log Notice "accounts-finance/www/pretti/app.tcl.109:  validated for n"
        }
        r {
            set validated 1
            ns_log Notice "accounts-finance/www/pretti/app.tcl.113:  validated for r"
        }
        s {
            set validated 1
            ns_log Notice "accounts-finance/www/pretti/app.tcl.123:  validated for s"
            if { ![qf_is_natural_number $table_tid] } {
                ns_log Notice "accounts-finance/www/pretti/app.tcl.129: table_tid '${table_tid}' is not valid for mode s"
                lappend user_message_list "Table has not been specified."
                set validated 0
                set mode "p"
                set next_mode ""
            } 
        }
        default {
            ns_log Notice "accounts-finance/www/pretti/app.tcl.116:  validated for v"
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
                ns_log Notice "accounts-finance/www/pretti/app.tcl.157:  table_name '${table_name}' [string length $table_name]"
                # table_comments Comments
                set table_comments $input_array(table_comments)
                # table_text
           
                # convert tables from _text to _list
                set line_break "\n"
                set delimiter ","
                # linebreak_char delimiter rows_count columns_count 
                set table_text_stats [qss_txt_table_stats $table_text]
                ns_log Notice "accounts-finance/www/pretti/app.tcl.167: table_text_stats $table_text_stats"
                set line_break [lindex $table_text_stats 0]
                set delimiter [lindex $table_text_stats 1]

                ns_log Notice "accounts-finance/www/pretti/app.tcl.171: table_text ${table_text}"
                set table_lists [qss_txt_to_tcl_list_of_lists $table_text $line_break $delimiter]
                ns_log Notice "accounts-finance/www/pretti/app.tcl.173: set table_lists ${table_lists}"
                # cleanup input
                set table_lists_new [list ]
                foreach condition_list $table_lists {
                    set row_new [list ]
                    foreach cell $condition_list {
                        set cell_new [string trim $cell]
                        regsub -all -- {[ ][ ]*} $cell_new { } cell_new
                        lappend row_new $cell_new
                        #ns_log Notice "accounts-finance/www/pretti/app.tcl.182:  new cell '$cell_new'"
                    }
                    if { [llength $row_new] > 0 } {
                        lappend table_lists_new $row_new
                    }
                }
                set table_lists $table_lists_new
                ns_log Notice "accounts-finance/www/pretti/app.tcl.189: : create/write table" 
                ns_log Notice "accounts-finance/www/pretti/app.tcl.190: : llength table_lists [llength $table_lists]"
                # detect table type for flags
                set table_flags [acc_fin::pretti_type_flag $table_lists]
                ns_log Notice "accounts-finance/www/pretti/app.tcl.193: table_flags $table_flags"
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
                        qss_table_create $table_lists $table_name $table_title $table_comments $table_template_id $table_flags $instance_id $user_id
                    }

                } else {
                    ns_log Notice "accounts-finance/www/pretti/app.tcl.210: qss_table_create new table"
                    qss_table_create $table_lists $table_name $table_title $table_comments "" $table_flags $instance_id $user_id
                }

            }
            # since table_tid is deleted, remove it from any remaining mode activity
            unset table_tid
            set mode $next_mode
            set next_mode ""
        }
        if { $mode eq "d" } {
            #  delete.... removes context     
            ns_log Notice "accounts-finance/www/pretti/app.tcl.222:  mode = delete"
            #requires table_tid
            # delete table_tid 
            if { [qf_is_natural_number $table_tid] } {
                lappend tid_list $table_tid
            }
            foreach table_tid $tid_list {
                # permissions checked for each table_tid in qss_table_delete
                qss_table_delete $table_tid $instance_id $user_id
            }
            # unset to not trigger wrong state in adp include logic
            unset table_tid
            set mode $next_mode
            set next_mode ""
        }
        if { $mode eq "t" } {
            #  trash
            ns_log Notice "accounts-finance/www/pretti/app.tcl.233:  mode = trash"
            #requires table_tid
            # trash table_tid 
            if { [qf_is_natural_number $table_tid] } {
                lappend tid_list $table_tid
            }
            foreach table_tid $tid_list {
                # permissions checked for each table_tid in qss_table_trash
                set trashed_p [lindex [qss_table_stats $table_tid] 7]
                if { $trashed_p == 1 } {
                    set trash 0
                } else {
                    set trash 1
                }
#                ns_log Notice "accounts-finance/www/pretti/app.tcl.238: qss_table_trash $trash $table_tid $instance_id $user_id"
                qss_table_trash $trash $table_tid $instance_id $user_id
            }
            # unset to not trigger wrong state in adp include logic
            unset table_tid
            set mode "p"
            set next_mode ""
        }
    }
    # end validated input if
    if { $mode eq "s" } {
        if { [qf_is_natural_number $table_tid] && $column_name ne "" } {
            lappend tid_list $table_tid
        }
        foreach table_tid $tid_list {
            set table_stats_list [qss_table_stats $table_tid]
            # name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id.
            set trashed_p [lindex $table_stats_list 7]
            set table_flags [lindex $table_stats_list 6]
            set tid_user_id [lindex $table_stats_list 11]
            if { ( $table_flags eq "p2" || $table_flags eq "p3" ) && ( ( $create_p && $tid_user_id == $user_id ) || $write_p ) } {
                qss_table_split $table_tid $column_name
            }
        }
        set mode "p"
        set next_mode ""
    }
}

switch -exact -- $mode {
    e {
        #  edit...... edit/form mode of current context
        ns_log Notice "accounts-finance/www/pretti/app.tcl.264:  mode = edit"
        set mode_name "#accounts-finance.edit#"
        #requires table_tid
        # make a form to edit 
        # get table from ID


#        set form_id [qf_form action app method post id 20120531 hash_check 1]
        
#        qf_input type hidden value w name mode label ""
        
        if { [qf_is_natural_number $table_tid] } {
            set table_stats_list [qss_table_stats $table_tid]
            set table_name [lindex $table_stats_list 0]
            set table_title [lindex $table_stats_list 1]
            set table_comments [lindex $table_stats_list 2]
            set table_flags [lindex $table_stats_list 6]
            set table_template_id [lindex $table_stats_list 5]
            set trashed_p [lindex $table_stats_list 7]
            set trash_folder_p $trashed_p
            set table_lists [qss_table_read $table_tid]
            set table_text [qss_lists_to_text $table_lists]

            qf_input type hidden value $table_tid name table_tid label ""
            qf_input type hidden value $table_flags name table_flags label ""
            qf_input type hidden value $table_template_id name table_template_id label ""
            qf_append html "<h3>Table</h3>"
            qf_append html "<div style=\"width: 70%; text-align: right;\">"
            qf_input type text value $table_name name table_name label "Name:" size 40 maxlength 40
            qf_append html "<br>"
            qf_input type text value $table_title name table_title label "Title:" size 40 maxlength 80
            qf_append html "<br>"
            qf_textarea value $table_comments cols 40 rows 3 name table_comments label "Comments:"
            qf_append html "<br>"
            qf_textarea value $table_text cols 40 rows 6 name table_text label "Contents:"
            qf_append html "</div>"
        }

        qf_input type submit value "Save" name "zw" class btn
#        qf_close form_id $form_id
        qf_append html "</form>"
#        set form_html [qf_read form_id $form_id]
        set form_html [qf_read ]

    }
    w {
        #  save.....  (write) table_tid 
        # should already have been handled above
        ns_log Notice "accounts-finance/www/pretti/app.tcl.309:  mode = save THIS SHOULD NOT BE CALLED."
        # it's called in validation section.
    }
    n {
        #  new....... creates new, blank context (form)    
        ns_log Notice "accounts-finance/www/pretti/app.tcl.314:  mode = new"
        set mode_name "#accounts-finance.new#"
        #requires no table_tid
        set table_text ""

        # make a form with no existing table_tid 

 #       set form_id [qf_form action app method post id 20140415 hash_check 1]

#        qf_input type hidden value w name mode label ""
        qf_append html "<h3>Table</h3>"
        qf_append html "<div style=\"width: 70%; text-align: right;\">"
        qf_input type text value "" name table_name label "Name:" size 40 maxlength 40
        qf_append html "<br>"
        qf_input type text value "" name table_title label "Title:" size 40 maxlength 80
        qf_append html "<br>"
        qf_textarea value "" cols 40 rows 3 name table_comments label "Comments:"
        qf_append html "<br>"
        qf_textarea value $table_text cols 40 rows 6 name table_text label "Contents:"
        qf_append html "</div>"

        qf_input type submit value "Save" name "zw" class btn

#        qf_close form_id $form_id
        qf_append html "</form>"
#        set form_html [qf_read form_id $form_id]
        set form_html [qf_read ]
    }
    c {
        #  process... compute/process and write output as a new table, present post_calc results
        ns_log Notice "accounts-finance/www/pretti/app.tcl.342:  mode = process"
        set mode_name "#accounts-finance.process#"
        #requires table_tid
        # given table_tid 
##### process pretti_..
        
    }
    r {
        #  review.... show processd output 
        ns_log Notice "accounts-finance/www/pretti/app.tcl.351:  mode = review"
        #requires table_tid

        # option not used for this app. Calcs are saved as a table. use mode v
    }
    v {
        #  view table(s) (standard, html page document/report)
        ns_log Notice "accounts-finance/www/pretti/app.tcl.358:  mode = $mode ie. view table"
        set mode_name "#accounts-finance.view#"
        set table_stats_list [qss_table_stats $table_tid]
        # name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id
        # set table_name [lindex $table_stats_list 0]
        # set table_title [lindex $table_stats_list 1]
        # set table_comments [lindex $table_stats_list 2]
        set table_flags [lindex $table_stats_list 6]
        set trash_folder_p [lindex $table_stats_list 7]
        # see lib/pretti-view-one and lib/pretti-menu1
    }
    default {
        # default includes v,p
        #  present...... presents a list of contexts/tables to choose from
        ns_log Notice "accounts-finance/www/pretti/app.tcl.392:  mode = $mode ie. default"
        # see lib/pretti-view and lib/pretti-menu1
    }
}
# end of switches

set user_message_html ""
foreach user_message $user_message_list {
    append user_message_html "<li>${user_message}</li>"
}
set app_name "PRETTI"
set title ${app_name}
set context [list [list app $title] $mode_name]
