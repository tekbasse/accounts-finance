# generic header for static .adp pages


set instance_id [ad_conn package_id]
set user_id [ad_conn user_id]
set read_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege write]

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

    # following is part of dynamic menu processing using form tags instead of url/GET.. and lib/pretti-menu1
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
        default {
            ns_log Notice "app.tcl.116:  validated for v"
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
        # This is a read-only page. no actions expected here.
        
        # execute validated input
        # end validated input if
    }
}

switch -exact -- $mode {
    v {
        #  view table(s) (standard, html page document/report)
        ns_log Notice "app.tcl.358:  mode = $mode ie. view table"
        set mode_name "#accounts-finance.view#"
        set table_stats_list [qss_table_stats $table_tid]
        # name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id
        # set table_name [lindex $table_stats_list 0]
        # set table_title [lindex $table_stats_list 1]
        # set table_comments [lindex $table_stats_list 2]
        set table_flags [lindex $table_stats_list 6]
        
        # see lib/pretti-view-one and lib/pretti-menu1
    }
    default {
        # default includes v,p
        #  present...... presents a list of contexts/tables to choose from
        ns_log Notice "app.tcl.392:  mode = $mode ie. default"
        # see lib/pretti-view and lib/pretti-menu1
    }
}
# end of switches

set user_message_html ""
foreach user_message $user_message_list {
    append user_message_html "<li>${user_message}</li>"
}
set app_name "PRETTI"
set title "${app_name} ${mode_name}"
set context [list [list app $title] $mode_name]
