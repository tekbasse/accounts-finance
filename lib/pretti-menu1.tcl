# accounts-finance/lib/pretti-menu1.tcl
# requires: mode form_action_url
# optional: instance_id app_name 
#           table_tid table_flags 

# generic header for static .adp pages
if { ![info exists $instance_id] } {
    set instance_id [ad_conn package_id]
}
set user_id [ad_conn user_id]
set read_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege read]
if { $read_p } {
    set write_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege write]
    
    set menu_list [list [list $app_name ""]]
    
    if { $write_p } {
        set admin_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege admin]
        set delete_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege delete]
        if { ![info exists form_action_url] } {
            set form_action_url app
        }

        lappend menu_list [list new mode=n]
    } else {
        set admin_p 0
        set delete_p 0
        if { ![info exists app_name] } {
            set app_name "App"
        }
    }
    
    switch -exact -- $mode {
        e {
            set mode_name "#accounts-finance.edit#"
        }
        n {
            #  new....... creates new, blank context (form)    
            ns_log Notice "accounts-finance/lib/pretti-menu1.tcl.314:  mode = new"
            set mode_name "#accounts-finance.new#"
        }
        c {
            #  process... compute/process and write output as a new table, present post_calc results
            ns_log Notice "accounts-finance/lib/pretti-menu1.tcl.342:  mode = process"
            set mode_name "#accounts-finance.process#"
        }
        r {
            #  review.... show processd output 
            ns_log Notice "accounts-finance/lib/pretti-menu1.tcl.351:  mode = review"
        }
        v {
            #  view table(s) (standard, html page document/report)
            ns_log Notice "accounts-finance/lib/pretti-menu1.tcl.358:  mode = $mode ie. view table"
            set mode_name "#accounts-finance.view#"
            if { [qf_is_natural_number $table_tid] && $write_p } {
                lappend menu_list [list edit "table_tid=${table_tid}&mode=e"]
                set menu_e_p 1
            } else {
                set menu_e_p 0
            }
            if { !$menu_e_p && $write_p } {
                
                lappend menu_list [list edit "table_tid=${table_tid}&mode=e"]
            }
            # if table is a scenario (meets minimum process requirements), add a process button to menu:
            if { [qf_is_natural_number $table_tid] && [info exists table_flags] && $table_flags eq "p1" } {
                lappend menu_list [list process "table_tid=${table_tid}&mode=c"]
            }
        }
        default {
            # default includes v,p
            #  present...... presents a list of contexts/tables to choose from
            ns_log Notice "accounts-finance/lib/pretti-menu1.tcl.392:  mode = $mode ie. default"
        }
    }
    # end of switches
    
    set menu_html ""
    array unset form_input_arr
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
            qf_input form_id $form_id type submit value $value name $name class btn
        }
        #    append menu_html "<a href=\"app?${url}\">${label}</a>&nbsp;"
    }
    foreach {name value} [array get form_input_arr] {
        qf_input form_id $form_id type hidden value $value name $name label ""
    }
    qf_close form_id $form_id
    set menu_html [qf_read form_id $form_id]
}
