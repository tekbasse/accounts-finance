# based on
# accounts-finance/lib/pretti-menu2.tcl
# requires: mode form_action_url
# optional: instance_id app_name 
#           table_tid table_flags 

# generic header for static .adp pages
if { ![info exists instance_id] } {
    set instance_id [ad_conn package_id]
}
if { ![info exists table_flags] } {
    set table_tid ""
    set table_flags ""
    set trashed_p 0
}

if { ![info exists user_created_p] } {
    set user_created_p 0
}

if { ![info exists app_name] } {
    set app_name "App"
}

if { ![info exists read_p] || ![info exists write_p] || ![info exists admin_p] || ![info exists delete_p] } {
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
}

set menu_html ""
set menu_list [list [list $app_name ""]]

if { $write_p || ( $user_created_p && $create_p ) } {
    #set select_label "#accounts-finance.select#"
    set untrash_label "#accounts-finance.untrash#"
    set trash_label "#accounts-finance.trash#"
    set delete_label "#accounts-finance.delete#"

    if { ![info exists form_action_url] } {
        set form_action_url app
    }
    if { $write_p || $create_p } {
        lappend menu_list [list new mode=n]
    }
    switch -exact -- $mode {
        e {
            set mode_name "#accounts-finance.edit#"
        }
        n {
            #  new....... creates new, blank context (form)    
            ns_log Notice "accounts-finance/lib/pretti-menu2.tcl.314:  mode = new"
            set mode_name "#accounts-finance.new#"
        }
        c {
            #  process... compute/process and write output as a new table, present post_calc results
            ns_log Notice "accounts-finance/lib/pretti-menu2.tcl.342:  mode = process"
            set mode_name "#accounts-finance.process#"
        }
        r {
            #  review.... show processd output 
            ns_log Notice "accounts-finance/lib/pretti-menu2.tcl.351:  mode = review"
        }
        v {
            #  view table(s) (standard, html page document/report)
            ns_log Notice "accounts-finance/lib/pretti-menu2.tcl.358:  mode = $mode ie. view table"
            set mode_name "#accounts-finance.view#"
            set tid_is_num_p [qf_is_natural_number $table_tid]
            # no actions against a trashed item
            if { !$trashed_p } {
 
                # edit button
                if { $tid_is_num_p && ( $write_p || $user_created_p ) } {
                    lappend menu_list [list "edit" "table_tid=${table_tid}&mode=e"]
                }
                # if table is a scenario (meets minimum process requirements), add a process button to menu:
                if { $tid_is_num_p && [info exists table_flags] && $table_flags eq "p1" && $write_p } {
                    lappend menu_list [list "process" "table_tid=${table_tid}&mode=c"]
                }
                # split button
                if { $tid_is_num_p && [info exists table_flags] && ( $table_flags eq "p2" || $table_flags eq "p3" ) && ( $write_p || $user_created_p ) } {
                    # add a multiselect button with choice of table column_names
                    # delay creating the multi-select until the button is made
                    lappend menu_list [list "split" "table_tid=${table_tid}&mode=s"]
                }
            }

            if { ( $write_p || $user_created_p )  } {
                if { $trashed_p } {
                    #append active_link " \[<a href=\"app?${table_ref_name}=${table_id}&mode=t\">${untrash_label}</a>\]"
                    #qf_input type submit value $untrash_label name "zt" class btn
                    lappend menu_list [list "untrash" "mode=t"]
                    if { $admin_p } {
                        lappend menu_list [list "delete" "mode=d"]
                    }
               } else {
                    #append active_link " \[<a href=\"app?${table_ref_name}=${table_id}&mode=t\">${trash_label}</a>\]"
                    #qf_input type submit value $trash_label name "zt" class btn
                    lappend menu_list [list "trash" "table_tid=${table_tid}&mode=t"]
                }
            } 
        }
        default {
            # default includes v,p
            #  present...... presents a list of contexts/tables to choose from
            ns_log Notice "accounts-finance/lib/pretti-menu2.tcl.392:  mode = $mode ie. default"
            if { $write_p } {
                if { $trashed_p } {
                    #append active_link " \[<a href=\"app?${table_ref_name}=${table_id}&mode=t\">${untrash_label}</a>\]"
                    #qf_input type submit value $untrash_label name "zt" class btn
                    lappend menu_list [list "untrash" "mode=t"]
                    if { $delete_p || $admin_p } {
                        lappend menu_list [list "delete" "mode=d"]
                    }
                } else {
                    lappend menu_list [list "trash" "mode=t"]
                }
            } 
        }
    }
    # end of switches
    
    
    set form_id [qf_form action $form_action_url method post id 20140417 hash_check 1]
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

            if { $name1 eq "s" } {
                # add a multiselect per "split" menu item
                set table_lol [qss_table_read $table_tid $instance_id]
                set column_list [lindex $table_lol 0]
                set req_name_list [acc_fin::pretti_columns_list $table_flags 0]
                # remove required column_names, because each of those lines should be unique..
                set special_names_list [list name description label]
                foreach req_name $req_name_list {
                    set req_idx [lsearch -exact $column_list $req_name]
                    set special_idx [lsearch -exact $special_names_list $req_name]
                    if { $req_idx > -1 && $special_idx == -1 } {
                        # remove name
                        set column_list [lreplace $column_list $req_idx $req_idx]
                    }
                }
                if { [llength $column_list] > 0 } {
                    # create list for qf_choice
                    set col_qf_list [list ]
                    foreach col_name $column_list {
                        lappend col_qf_list [list label $col_name value $col_name]
                    }
                    qf_append html " &nbsp; ("
                    qf_input form_id $form_id type submit value $value name $name class btn
                    qf_choice form_id $form_id type select name column_name value $col_qf_list
                    qf_append html ") &nbsp; "
                }
            } else {
                qf_input form_id $form_id type submit value $value name $name class btn 
            }
        }
        #    append menu_html "<a href=\"app?${url}\">${label}</a>&nbsp;"
    }
#    foreach {name value} [array get form_input_arr] {
#        qf_input form_id $form_id type hidden value $value name $name label ""
#    }
        qf_input form_id $form_id type hidden value $trash_folder_p name trash_folder_p label ""
#    qf_close form_id $form_id
    set menu_html [qf_read form_id $form_id]
}
