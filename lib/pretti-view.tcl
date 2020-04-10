# accounts-finance/lib/pretti-view.tcl
# requires: instance_id form_action_attr

if { [info exists app_url] } {
    set form_action_attr "app"
}

set user_id [ad_conn user_id]
set read_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege read]

#  presents a list of contexts/tables to choose from

if { $read_p } {
    set write_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege write]
    if { $write_p } {
        set admin_p [permission::permission_p -party_id $user_id -object_id [ad_conn package_id] -privilege admin]
        set delete_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege delete]
    } else {
        set admin_p 0
        set delete_p 0
    }
    # show tables
    # sort by template_id, columns, and table_type (flags)
    
    set table_ids_list [qss_tables $instance_id]
    set table_stats_lists [list ]
    set table_trashed_lists [list ]
    set cell_formating_list [list ]
    set tables_stats_lists [list ]
    
    # get the entire list, to sort it before processing
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
        set title [lindex $stats_list 2]
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
        if { [qss_tid_from_name $name $instance_id $user_id] eq $table_id } {
            # create a link out of name
            set name_link "<a href=\"${name}\">${name}</a>"
            set stats_list [lreplace $stats_list 1 1 $name_link]
        } else {
            set tid_link "<a href=\"${table_id}\">${table_id}</a>"
            set stats_list [lreplace $stats_list 0 0 $tid_link]
            # make a link out of table_id
        }
        lappend stats_list $col_length
        
        # convert table row for use with html
        # change name to an active link
        # set table_ref_name table_tid
        
        # each $active_link becomes a separate form..
        if { $write_p } {

            set form_id [qf_form action $form_action_attr method post id 20140420-[util::random] hash_check 1]
            
            ## if using name_link, comment out this next line:
            qf_input type submit value $select_label name "zv" class btn
            
            qf_input type hidden value $table_id name table_tid
            if { ( $admin_p || $table_user_id == $user_id ) && $trashed_p == 1 } {
                #append active_link " \[<a href=\"app?${table_ref_name}=${table_id}&mode=t\">${untrash_label}</a>\]"
                qf_input type submit value $untrash_label name "zt" class btn
            } elseif { $table_user_id == $user_id || $admin_p } {
                #append active_link " \[<a href=\"app?${table_ref_name}=${table_id}&mode=t\">${trash_label}</a>\]"
                qf_input type submit value $trash_label name "zt" class btn
            } 
            if { $delete_p && $trashed_p == 1 } {
                #append active_link " \[<a href=\"app?${table_ref_name}=${table_id}&mode=d\">${delete_label}</a>\]"
                qf_input type submit value $delete_label name "zd" class btn
            } 
            qf_close form_id $form_id
            set active_link [qf_read form_id $form_id]
            #set stats_list [lreplace $stats_list 1 1 $name_link]
            set stats_list [linsert $stats_list 3 $active_link]
        } 

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
        
        #set table_trashed_html "<h3>#accounts-finance.trashed# #accounts-finance.tables#</h3>\n"
        set table_trashed_html [qss_list_of_lists_to_html_table $table_trashed_sorted_lists $table_tag_atts_list $cell_formating_list]
        #    append table_stats_html $table_trashed_html
    }

    
}
