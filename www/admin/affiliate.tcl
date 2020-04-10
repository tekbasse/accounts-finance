# generic header for static .adp pages

set title "Affiliate program"
set context [list $title]

set package_id [qc_set_instance_id]
set user_id [ad_conn user_id]
set write_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege write]
set admin_p [permission::permission_p -party_id $user_id -object_id [ad_conn package_id] -privilege admin]
set delete_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege delete]
# randmize rand with seed from clock
expr { srand([clock clicks]) }

# affiliate program based on Triangular numbers 
# see http://en.wikipedia.org/wiki/Triangular_number
# context: One one context for this app
# table_id product_sales_curve or
# table_id  initial_conditions:
#   growth_curve_eq_ref
#   interval_start
#   units_per_period s/b period_unitunit
#   iterations_count

# input default values
#  data (title,price, pct of total sales)
# price must be listed in lowest to highest
# last sale is a threashold of a range to 100% that gets interpolated up to $sale_max
# sale (as a percentage of total sale) for each sale amount measured
# These values must be in 1:1 coorespondence with sales list

# to make it real easy, we are creating a text table to fill a list_of_lists
# and thus to replaces the list equivalents:
#    price_list 
#    sales_pct_list
#    product_label_list

# now becomes:

# revenue_curve_list_of_lists
# row1 {price sales_pct  label}
# row2 ..
#    price_list [list 1 5 10 20]\
#    sales_pct_list [list 12.5 50. 25. 12.5]\


# case_id "" = initial_conditions_tid + sales_curve_tid
# period_size "" ; in units
# interval_start ""
# iterations_count ""
# action --> mode
# context

# tid = table_id

#### kill this app if user is not admin. It is not demo ready
if { !$admin_p } {
    ad_script_abort
}

array set input_array [list \
    sales_curve_tid ""\
    initial_conditions_tid ""\
    revenue_target 22222.\
    sale_max 10000.\
    initial_conditions_lists [list [list name value ] [list sale_max 10000] [list revenue_target 100000] [list pct_pooled .10] [list interpolate_last_band_p 0] [list growth_curve_eq 1] [list commissions_eq 1] [list interval_start 1] [list interval_size 3] [list interval_count 4] [list sales_curve_name ""] [list sales_curve_tid ""]]\
    initial_conditions_text ""\
    sales_curve_lists [list [list price sales_share label] [list 1 .125 bar1] [list 5 .5 bar2] [list 10 .25 bar3] [list 20 .125 bar4]]\
    sales_curve_text ""\
    sample_rate 1\
    period_unit period\
    pct_pooled 1.\
    commissions_eq 1\
    interpolate_last_band_p 0\
    ic_name ""\
    ic_title ""\
    ic_comments ""\
    ic_template_id ""\
    ic_flags ""\
    sc_name ""\
    sc_title ""\
    sc_comments ""\
    sc_template_id ""\
    sc_flags ""\
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
set sales_curve_default [qss_lists_to_text $input_array(sales_curve_lists)]
set initial_conditions_default [qss_lists_to_text $input_array(initial_conditions_lists)]

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

    set sales_curve_tid $input_array(sales_curve_tid)
    set initial_conditions_tid $input_array(initial_conditions_tid)
    set initial_conditions_lists $input_array(initial_conditions_lists)
    set sales_curve_lists $input_array(sales_curve_lists)
    set ic_template_id $input_array(ic_template_id)
    set ic_flags $input_array(ic_flags)
    set sc_template_id $input_array(sc_template_id)
    set sc_flags $input_array(sc_flags)
    # validate input
    # cleanse, validate mode
    # determine input completeness
    # form has modal inputs, so validation is a matter of cleansing data and verifying references
    set validated 0

    switch -exact -- $mode {
        e {
            ns_log Notice "affiliate.tcl validated for e"
            set validated 1
            if { ![qf_is_natural_number $initial_conditions_tid] && ![qf_is_natural_number $sales_curve_tid] } {
                set mode "n"
                set next_mode ""
            } 
        }
        d {
            ns_log Notice "affiliate.tcl validated for d"
            set validated 1
            if { ( ![qf_is_natural_number $initial_conditions_tid] && ![qf_is_natural_number $sales_curve_tid] ) || !$delete_p } {
                set mode "p"
                set next_mode ""
            } 
        }
        t {
            ns_log Notice "affiliate.tcl validated for t"
            set validated 1
            if { ![qf_is_natural_number $initial_conditions_tid] && ![qf_is_natural_number $sales_curve_tid] } {
                set mode "p"
                set next_mode ""
            } 
        }
        c {
            ns_log Notice "affiliate.tcl validated for c"
            set validated 1
            if { ![qf_is_natural_number $initial_conditions_tid] } {
                lappend user_message_list "Table for Initial Conditions has not been specified."
                set validated 0
                set mode "p"
                set next_mode ""
            } 
            if { ![qf_is_natural_number $sales_curve_tid] } {
                lappend user_message_list "Table for Sales Curve has not been specified."
                set validated 0
                set mode "p"
                set next_mode ""
            } 
            set interpolate_last_band_p $input_array(interpolate_last_band_p)
            set sample_rate $input_array(sample_rate)
            set period_unit $input_array(period_unit)
            set commissions_eq $input_array(commissions_eq)
        }
        w {
            set initial_conditions_text $input_array(initial_conditions_text)
            set sales_curve_text $input_array(sales_curve_text)
            set validated 1
            ns_log Notice "affiliate.tcl validated for w"
        }
        n {
            set validated 1
            ns_log Notice "affiliate.tcl validated for n"
        }
        r {
            set validated 1
            ns_log Notice "affiliate.tcl validated for r"
        }
        default {
            ns_log Notice "affiliate.tcl validated for v"
            if { [qf_is_natural_number $initial_conditions_tid] || [qf_is_natural_number $sales_curve_tid] } {
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
            # ic_* is initial_conditions_
            # sc_* is sales_curve_
            if { [string length $initial_conditions_text] > 0 && $initial_conditions_text ne $initial_conditions_default } {
                # ic_name  Table Name

                if { $input_array(ic_name) eq "" && $initial_conditions_tid eq "" } {
                    set ic_name "ic[clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(ic_name) eq "" } {
                    set ic_name "initCon${initial_conditions_tid}"
                } else {
                    set ic_name $input_array(ic_name)
                }
                # ic_title Table title
                if { $input_array(ic_title) eq "" && $initial_conditions_tid eq "" } {
                    set ic_title "Initial conditions [clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(ic_title) eq "" } {
                    set ic_title "Initial conditions ${initial_conditions_tid}"
                } else {
                    set ic_title $input_array(ic_title)
                }
                ns_log Notice "affiliate.tcl ic_name '${ic_name}' [string length $ic_name]"
                # ic_comments Comments
                set ic_comments $input_array(ic_comments)
                # initial_conditions_text
           
                # convert tables from _text to _list
                set line_break "\n"
                set delimiter ","
                # linebreak_char delimiter rows_count columns_count 
                set ic_text_stats [qss_txt_table_stats $initial_conditions_text]
                ns_log Notice "affiliate.tcl: ic_text_stats $ic_text_stats"
                set line_break [lindex $ic_text_stats 0]
                set delimiter [lindex $ic_text_stats 1]
                ns_log Notice "affiliate.tcl: initial_conditions_text ${initial_conditions_text}"
                set ic_lists [qss_txt_to_tcl_list_of_lists $initial_conditions_text $line_break $delimiter]
                ns_log Notice "affiliate.tcl: set ic_lists ${ic_lists}"
                # cleanup input
                set ic_lists_new [list ]
                foreach condition_list $ic_lists {
                    set row_new [list ]
                    foreach cell $condition_list {
                        set cell_new [string trim $cell]
                        regsub -all -- {[ ][ ]*} $cell_new { } cell_new
                        lappend row_new $cell_new
                        #ns_log Notice "affiliate.tcl new cell '$cell_new'"
                    }
                    if { [llength $row_new] > 0 } {
                        lappend ic_lists_new $row_new
                    }
                }
                set ic_lists $ic_lists_new
                ns_log Notice "affiliate.tcl: create/write table" 
                ns_log Notice "affiliate.tcl: llength ic_lists [llength $ic_lists]"
                if { [qf_is_natural_number $initial_conditions_tid] } {
                    set table_stats [qss_table_stats $initial_conditions_tid]
                    set name_old [lindex $table_stats 0]
                    set title_old [lindex $table_stats 1]
                    if { $name_old eq $ic_name && $title_old eq $ic_title } {
                        ns_log Notice "affiliate.tcl: qss_table_write table_id ${initial_conditions_tid}" 
                        qss_table_write $ic_lists $ic_name $ic_title $ic_comments $initial_conditions_tid $ic_template_id $ic_flags $package_id $user_id
                    } else {
                        # changed name. assume this is a new table
                        ns_log Notice "affiliate.tcl: qss_table_create new table initial_conditions because name/title changed"
                        qss_table_create $ic_lists $ic_name $ic_title $ic_comments $ic_template_id $ic_flags $package_id $user_id

                    }
                } else {
                    ns_log Notice "affiliate.tcl: qss_table_create new table initial_conditions"
                    qss_table_create $ic_lists $ic_name $ic_title $ic_comments $ic_template_id $ic_flags $package_id $user_id
                }

            }
            if { [string length $sales_curve_text] > 0 && $sales_curve_text ne $sales_curve_default } {
                # sc_name  Table Name
                if { $input_array(sc_name) eq "" && $sales_curve_tid eq "" } {
                    set sc_name "sc[clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(sc_name) eq "" } {
                    set sc_name "Sales Curve ${sales_curve_tid}"
                } else {
                    set sc_name $input_array(sc_name)
                }
                ns_log Notice "affiliate.tcl sc_name '${sc_name}' [string length $sc_name]"
                # sc_title Table title
                if { $input_array(sc_title) eq "" && $initial_conditions_tid eq "" } {
                    set sc_title "Sales Curve [clock format [clock seconds] -format %Y%m%d-%X]"
                } elseif { $input_array(sc_title) eq "" } {
                    set sc_title "Sales Curve ${sales_curve_tid}"
                } else {
                    set sc_title $input_array(sc_title)
                }
                # sc_comments Comments
                set sc_comments $input_array(sc_comments)
                # sales_curve_text

                # convert tables from _text to _list
                set line_break "\n"
                set delimiter ","
                # linebreak_char delimiter rows_count columns_count 
                set sc_text_stats [qss_txt_table_stats $sales_curve_text]
                set line_break [lindex $sc_text_stats 0]
                ns_log Notice "affiliate.tcl: sales_curve_text ${sales_curve_text}"
                set sc_lists [qss_txt_to_tcl_list_of_lists $sales_curve_text $line_break $delimiter]
                ns_log Notice "affiliate.tcl: set sc_lists ${sc_lists}"
                # cleanup input
                set sc_lists_new [list ]
                foreach curve_list $sc_lists {
                    set row_new [list ]
                    foreach cell $curve_list {
                        set cell_new [string trim $cell]
                        regsub -all -- {[ ][ ]*} $cell_new { } cell_new
                        lappend row_new $cell_new
                    }
                    if { [llength $row_new] > 0 } {
                        lappend sc_lists_new $row_new
                    }
                }
                set sc_lists $sc_lists_new
            
                set curve_error 0
                set sales_pct_list [list ]
                set sc_header_list [lindex $sc_lists 0]
                set sales_share_idx [lsearch -exact $sc_header_list "sales_share"]

                if { $sales_share_idx > -1 } {
                    foreach curve_list [lrange $sc_lists 1 end] {
                        # area under curve aka probability is second item in list --now sales_share_idx
                        lappend sales_pct_list [lindex $curve_list $sales_share_idx]
                    }

                # normalize sales_pct_list curve. Total should equal 1. (100%)
                set rcp_total 0.

                foreach sales_pct $sales_pct_list {
                    # sales_pct must be a number
                    if { [qfad_is_number_p $sales_pct] } {
                        set rcp_total [expr { $rcp_total + $sales_pct } ]
                    } else {
                        set curve_error 1
                    }
                }
                if { $rcp_total > 0 } {
                    set adj_factor [expr { 1. / $rcp_total } ]
                
                    if { $adj_factor != 1. } {
                        # edit the probability values
                        set new_rcp_list [list ]
                        foreach sales_pct $sales_pct_list {
                            if { [qfad_is_number_p $sales_pct] } {
                                set sales_pct_adj [expr { $adj_factor * $sales_pct } ]
                                lappend new_rcp_list $sales_pct_adj
                            } else {
                                lappend "${sales_pct} (ignored)"
                                set curve_error 1
                            }
                        }
                        set sales_pct_list $new_rcp_list
                        # now we need to add them back into sc_lists
                        set sc_lists_new [list ]
                        set row_nbr 0
                        foreach curve_list $sc_lists {
                            set row_new [lreplace $curve_list 1 1 [lindex $sales_pct_list $row_nbr]]
                            lappend sc_lists_new $row_new
                            incr row_nbr
                        }
                        set sc_lists $sc_lists_new
                        ns_log Notice "affiliate.tcl: adjust probability value sum to 1: results"
                        ns_log Notice "affiliate.tcl: set sc_lists ${sc_lists}"
                    }
                    # sort $price_list (and the cooresponding lists).
                    if { !$curve_error } {
                        set sc_lists [lsort -index 0 -real $sc_lists]
                    }
                } else {
                    ns_log Notice "affiliate.tcl: sales_curve $sales_curve_tid cannot be normalized."
                    lappend user_message_list "Unable to normalize Sales Curve. Saved as is."
                }
                } else {
                    set curve_error 1
                    ns_log Notice "affiliate.tcl: sales_share does not exist for sales_curve $sales_curve_tid ."
                    lappend user_message_list "Column sales_share does not exist. Saved as is."

                }

                ns_log Notice "affiliate.tcl: sorted sc_lists. Results:"
                ns_log Notice "affiliate.tcl: set sc_lists ${sc_lists}"

                ns_log Notice "affiliate.tcl: create/write table" 
                ns_log Notice "affiliate.tcl: length sc_lists [llength $sc_lists]"


                if { [qf_is_natural_number $sales_curve_tid] } {
                    set table_stats [qss_table_stats $sales_curve_tid]
                    set name_old [lindex $table_stats 0]
                    set title_old [lindex $table_stats 1]
                    if { $name_old eq $sc_name && $title_old eq $sc_title } {
                        ns_log Notice "affiliate.tcl: qss_table_write table_id ${sales_curve_tid}" 
                        qss_table_write $sc_lists $sc_name $sc_title $sc_comments $sales_curve_tid $sc_template_id $sc_flags $package_id $user_id
                    } else {
                        # changed name. assume this is a new table
                        ns_log Notice "affiliate.tcl: qss_table_create new table sales_curve"
                        qss_table_create $sc_lists $sc_name $sc_title $sc_comments $sc_template_id $sc_flags $package_id $user_id
                    }
                } else {
                    ns_log Notice "affiliate.tcl: qss_table_create new table sales_curve"
                    qss_table_create $sc_lists $sc_name $sc_title $sc_comments $sc_template_id $sc_flags $package_id $user_id
                }
            }

            set mode $next_mode
            set next_mode ""
        }
        if { $mode eq "d" } {
            #  delete.... removes context     
            ns_log Notice "affiliate.tcl mode = delete"
            #requires initial_conditions_tid or sales_curve_tid
            # delete initial_conditions_tid or sales_curve_tid or both, if both supplied
            if { [qf_is_natural_number $sales_curve_tid] } {
                qss_table_delete $sales_curve_tid
            }
            if { [qf_is_natural_number $initial_conditions_tid] } {
                qss_table_delete $initial_conditions_tid
            }
            set mode $next_mode
            set next_mode ""
        }
        if { $mode eq "t" } {
            #  trash
            ns_log Notice "affiliate.tcl mode = trash"
            #requires initial_conditions_tid or sales_curve_tid
            # delete initial_conditions_tid or sales_curve_tid or both, if both supplied
            if { [qf_is_natural_number $sales_curve_tid] && $write_p } {
                set trashed_p [lindex [qss_table_stats $sales_curve_tid] 7]
                if { $trashed_p == 1 } {
                    set trash 0
                } else {
                    set trash 1
                }
                qss_table_trash $trash $sales_curve_tid
            }
            if { [qf_is_natural_number $initial_conditions_tid] && $write_p } {
                set trashed_p [lindex [qss_table_stats $initial_conditions_tid] 7]
                if { $trashed_p == 1 } {
                    set trash 0
                } else {
                    set trash 1
                }
                qss_table_trash $trash $initial_conditions_tid
            }
            set mode "p"
            set next_mode ""
        }
        
    }
    # end validated input if

}


set menu_list [list [list Affiliate ""]]

if { $write_p } {
    lappend menu_list [list new mode=n]
}

switch -exact -- $mode {
    e {
        #  edit...... edit/form mode of current context
        ns_log Notice "affiliate.tcl mode = edit"
        #requires initial_conditions_tid, sales_curve_tid
        # make a form to edit 
        # get table from ID


        qf_form action affiliate method get id 20120531
        
        qf_input type hidden value w name mode label ""
        
        if { [qf_is_natural_number $initial_conditions_tid] } {
            set ic_stats_list [qss_table_stats $initial_conditions_tid]
            set ic_name [lindex $ic_stats_list 0]
            set ic_title [lindex $ic_stats_list 1]
            set ic_comments [lindex $ic_stats_list 2]
            set ic_flags [lindex $ic_stats_list 6]
            set ic_template_id [lindex $ic_stats_list 5]

            set initial_conditions_lists [qss_table_read $initial_conditions_tid]
            set initial_conditions_text [qss_lists_to_text $initial_conditions_lists]

            qf_input type hidden value $initial_conditions_tid name initial_conditions_tid label ""
            qf_input type hidden value $ic_flags name ic_flags label ""
            qf_input type hidden value $ic_template_id name ic_template_id label ""
            qf_append html "<h3>Initial conditions</h3>"
            qf_append html "<div style=\"width: 70%; text-align: right;\">"
            qf_input type text value $ic_name name ic_name label "Table name:" size 40 maxlength 40
            qf_append html "<br>"
            qf_input type text value $ic_title name ic_title label "Title:" size 40 maxlength 80
            qf_append html "<br>"
            qf_textarea value $ic_comments cols 40 rows 3 name ic_comments label "Comments:"
            qf_append html "<br>"
            qf_textarea value $initial_conditions_text cols 40 rows 6 name initial_conditions_text label "Table data:"
            qf_append html "</div>"
        }
        if { [qf_is_natural_number $sales_curve_tid] } {
            # get table from ID
            set sc_stats_list [qss_table_stats $sales_curve_tid]
            set sc_name [lindex $sc_stats_list 0]
            set sc_title [lindex $sc_stats_list 1]
            set sc_comments [lindex $sc_stats_list 2]
            set sc_flags [lindex $sc_stats_list 6]
            set sc_template_id [lindex $sc_stats_list 5]

            set sales_curve_lists [qss_table_read $sales_curve_tid]
            set sales_curve_text [qss_lists_to_text $sales_curve_lists]
            
            qf_input type hidden value $sales_curve_tid name sales_curve_tid label ""
            qf_input type hidden value $sc_flags name sc_flags label ""
            qf_input type hidden value $sc_template_id name sc_template_id label ""
            qf_append html "<h3>Sales curve</h3>"
            qf_append html "<div style=\"width: 70%; text-align: right;\">"
            qf_input type text value $sc_name name sc_name label "Table name:" size 40 maxlength 40
            qf_append html "<br>"
            qf_input type text value $sc_title name sc_title label "Title:" size 40 maxlength 80
            #        qf_append html "<br><div style=\"vertical-align: top; display: inline-block; border: 1px solid black;\">"
            qf_append html "<br>"
            qf_textarea value $sc_comments cols 40 rows 3 name sc_comments label "Comments:"
            #       qf_append html "</div><br>"
            qf_append html "<br><div style=\"clear: both;\">"
            qf_textarea value $sales_curve_text cols 40 rows 20 name sales_curve_text label "Table data:"
            qf_append html "</div>"
        }

        qf_input type submit value "Save"
        qf_close
        set form_html [qf_read]

    }
    w {
        #  save.....  (write) initial_conditions_tid and sales_curve_tid
        # should already have been handled above
        ns_log Notice "affiliate.tcl mode = save THIS SHOULD NOT BE CALLED."
        # it's called in validation section.
    }
    n {
        #  new....... creates new, blank context (form)    
        ns_log Notice "affiliate.tcl mode = new"
        #requires no initial_conditions_tid, sales_curve_tid
        set initial_conditions_text [qss_lists_to_text $initial_conditions_lists]
        set sales_curve_text [qss_lists_to_text $sales_curve_lists]

        # make a form with no existing initial_conditions_tid and sales_curve_tid

        qf_form action affiliate method get id 20120530

        qf_input type hidden value w name mode label ""
        if { $initial_conditions_tid > 0 && $sales_curve_tid > 0 } {
            ns_log Warning "mode n while initial_conditions_tid and sales_curve_tid exist"
        }
        qf_append html "<h3>Initial conditions</h3>"
        qf_append html "<div style=\"width: 70%; text-align: right;\">"
        qf_input type text value "" name ic_name label "Table name:" size 40 maxlength 40
        qf_append html "<br>"
        qf_input type text value "" name ic_title label "Title:" size 40 maxlength 80
        qf_append html "<br>"
        qf_textarea value "" cols 40 rows 3 name ic_comments label "Comments:"
        qf_append html "<br>"
        qf_textarea value $initial_conditions_text cols 40 rows 6 name initial_conditions_text label "Table data:"
        qf_append html "</div>"

        qf_append html "<h3>Sales curve</h3>"
        qf_append html "<div style=\"width: 70%; text-align: right;\">"
        qf_input type text value "" name sc_name label "Table name:" size 40 maxlength 40
        qf_append html "<br>"
        qf_input type text value "" name sc_title label "Title:" size 40 maxlength 80
        #        qf_append html "<br><div style=\"vertical-align: top; display: inline-block; border: 1px solid black;\">"
        qf_append html "<br>"
        qf_textarea value "" cols 40 rows 3 name sc_comments label "Comments:"
 #       qf_append html "</div><br>"
        qf_append html "<br><div style=\"clear: both;\">"
        qf_textarea value $sales_curve_text cols 40 rows 20 name sales_curve_text label "Table data:"
        qf_append html "</div>"

        qf_input type submit value "Save"
        qf_close
        set form_html [qf_read]
    }
    c {
        #  compute... compute/process (and cache) output, present post_calc results
        ns_log Notice "affiliate.tcl mode = compute"
        #requires initial_conditions_tid, sales_curve_tid
        # given initial_conditions_tid and sales_curve_tid
        set error_fail 0
        set initial_conditions_lists [qss_table_read $initial_conditions_tid]
        set constants_list [list sale_max revenue_target pct_pooled interpolate_last_band_p growth_curve_eq commissions_eq interval_start interval_size interval_count sample_rate sales_curve_name sales_curve_tid period_unit]
        set constants_required_list [list revenue_target pct_pooled sales_curve_name sales_curve_tid]
        set condition_headers_list [lindex $initial_conditions_lists 0]
        set ic_name_idx [lsearch -exact $condition_headers_list "name" ]
        set ic_value_idx [lsearch -exact $condition_headers_list "value"]
        if { $ic_name_idx > -1 && $ic_value_idx > -1 } {
            foreach condition_list [lrange $initial_conditions_lists 1 end] {
                set constant [lindex $condition_list $ic_name_idx]
                if { [lsearch -exact $constants_list $constant] > -1 } {
                    set input_array($constant) [lindex $condition_list $ic_value_idx]
                    set $constant $input_array($constant)
                }
            }
        } else {
            set error_fail 1
            lappend compute_message_list "Initial condition column 'name' or 'value' is required but does not exist."
        }
        if { [info exists sales_curve_name] } {
            # set sales_curve_tid
            set table_ids_list [qss_tables $package_id]
            foreach table_id $table_ids_list {
                if { [lindex [qss_table_stats $table_id] 0] eq $sales_curve_name } {
                    set sales_curve_tid $table_id
                }
            }

        } 
        if { [info exists sales_curve_tid] } {
            set sales_curve_name [lindex [qss_table_stats $sales_curve_tid] 0]
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
        
        # interpolate_last_band_p : interpolate last sale item? choose this if you have a large sale item that you want to vary over the value range

        # Get revenue_curve_data 
        set revenue_curve_data_lists [qss_table_read $sales_curve_tid]
        set rc_header_list [lindex $revenue_curve_data_lists 0]
        set rc_price_idx [lsearch -exact $rc_header_list "price"]
        set rc_probability_idx [lsearch -exact $rc_header_list "sales_share"]
        set rc_label_idx [lsearch -exact $rc_header_list "label"]
        set revenue_curve_data_lists [lrange $revenue_curve_data_lists 1 end]
        # make the distribution curve accessible as lists
        set price_list [list ]
        set probability_list [list ]
        set price_label_list [list ]
        set value_probability_lists [list ]
        foreach curve_band_list $revenue_curve_data_lists {
            lappend price_list [lindex $curve_band_list $rc_price_idx]
            lappend probability_list [lindex $curve_band_list $rc_probability_idx]            
            lappend price_label_list [lindex $curve_band_list $rc_label_idx]
            lappend value_probability_lists [list $price_list $probability_list]
        }
        #        ns_log Notice "affiliate.tcl price_list $price_list"
        ##### looped, varying initial conditions include:
        # put lists and html in a separate arrays from the scalars
        # scalar_arr abbreviated as s_arr
        # list_arr  
        # html_arr pdt_html, stat_html, sum_html
        
        # data_set_list
        # commission_list 
        # pdt_list ; distribution curve for data_set
        # shares_list (function of triangle_numbers etc)
        # apt_lists
        
        # revenue_target
        # sale_count
        # revenue
        # commissions_pot
        # shares_tot
        # share_value
        # commissions_tot
        # the_time Time calculation completed
        
        # html
        set computation_report_html ""
        if { [info exists interval_count] && $interval_count > 1 } {
            set interval_end [expr { $interval_start + ( $interval_size * $interval_count ) } ]
            set intervals_list [list ]
            for { set i $interval_start } { $i <= $interval_end } { set i [expr { $i + $interval_size } ] } {
                lappend intervals_list $i
                # generate target_revenue for each interval
                switch -exact $growth_curve_eq {
                    1 {
                        # logistic curve input 0 = circa 0% to 12 =circa 100% revenue_target
                        set x [expr { $i * 5. / 3. - 10. } ]
                        set y [acc_fin::logistic_curve $x]
                        set gr_i [expr { $y * $revenue_target} ]
                    }
                    2 {
                        # logistic curve input 0 = circa 0% to 6 =circa 100% revenue_target, 12 = circa 0%
                        set x [expr { $i * 30. } ]
                        set y [acc_fin::pos_sine_cycle $x]
                        set gr_i [expr { $y * $revenue_target / 2. } ]
                    }
                    default {
                        # no modification of revenue_target
                        set gr_i $revenue_target
                    }
                }
                set scalar_arr(revenue_target-$i) $gr_i
            }
        } elseif { [info exists interval_start] } {
            set intervals_list [list $interval_start ]
            set scalar_arr(revenue_target-${interval_start}) $revenue_target
        } else {
            set interval_start 1
            set intervals_list [list $interval_start ]
            set scalar_arr(revenue_target-${interval_start}) $revenue_target
        }
                   
        foreach i $intervals_list {
            
            # generate the data points
            set list_arr(data_set_list-$i) [qaf_distribution_points_create $revenue_curve_data_lists "" $scalar_arr(revenue_target-$i)]
            set scalar_arr(sale_count-$i) [llength $list_arr(data_set_list-$i)]
            set scalar_arr(revenue-$i) [f::sum $list_arr(data_set_list-$i)]
            set list_arr(ddr_list-$i) [qaf_discrete_dist_report $list_arr(data_set_list-$i)]
            set scalar_arr(pct_pooled-$i) $pct_pooled

            foreach {sale_value frequency} $list_arr(ddr_list-$i) {
                
                # find same sale under original curve
                set sale_idx [lsearch -exact $price_list $sale_value]
                if { $sale_idx > -1 } {
                    set sale_freq [lindex $probability_list $sale_idx]
                    set sale_label [lindex $price_label_list $sale_idx]
                } else {
                    set sale_freq 0
                    set sale_label ""
                }
                
                # add column and format
                if { [qfad_is_number_p $frequency] } {
                    set frequency_fmtd "[format "% 1.4f" $frequency]%"
                } else {
                    set frequency_fmtd $frequency
                }
                set row_new [list $sale_label $sale_value $frequency_fmtd]
                lappend row_new "[format "% 1.4f" ${sale_freq}]%"
                # add row to report
                lappend list_arr(pdt_list-$i) $row_new
            }
            

            switch -exact $commissions_eq {
                2 {
                    set list_arr(shares_list-$i) [qaf_harmonic_terms $scalar_arr(sale_count-$i)]
                }
                3 {
                    set triangle_list [lreverse [qaf_triangular_numbers $scalar_arr(sale_count-$i)]]
                    if { [llength $triangle_list] > 0 } {
                        set triangle_tot [f::sum $triangle_list]
                    } else {
                        set triangle_tot 0.
                    }
                    set geometric_list [list ]
                    set revenue_tot $scalar_arr(revenue-$i)
                    set sales_list $list_arr(data_set_list-$i)
                    set sale_idx 0
                    foreach triangle_nbr $triangle_list {
                        set sales_amt [lindex $sales_list $sale_idx]
                        if { [qfad_is_number_p $sales_amt] } {
#ns_log Notice "affiliate.tcl(l739):  ( triangle_nbr $triangle_nbr revenue_tot $revenue_tot sales_amt $sales_amt triangle_tot $triangle_tot  "
                            lappend geometric_list [expr { ( $triangle_nbr * $revenue_tot ) + ( $sales_amt * $triangle_tot ) } ]
                        } else {
                            lappend geometric_list 0.
                        }
                        incr sale_idx
                    }
                    set list_arr(shares_list-$i) $geometric_list
                }
                default {
                    # 1. this is the triangular equation
                    set list_arr(shares_list-$i) [lreverse [qaf_triangular_numbers $scalar_arr(sale_count-$i)]]
                }
            }
            
            # replace above using qaf_harmonic_terms or qaf_trianguar_numbers
            
            if { [llength $list_arr(shares_list-$i)] > 0 } {
                set scalar_arr(shares_tot-$i) [f::sum $list_arr(shares_list-$i)]
            } else {
                set scalar_arr(shares_tot-$i) 0
            }

            set scalar_arr(commissions_pot-$i) [expr { $scalar_arr(revenue-$i) * $scalar_arr(pct_pooled-$i) } ]

            if { [qfad_is_number_p $scalar_arr(shares_tot-$i) ] && $scalar_arr(shares_tot-$i) != 0 } {
                set scalar_arr(share_value-$i) [expr { $scalar_arr(commissions_pot-$i) / $scalar_arr(shares_tot-$i) } ]
            } else {
                set scalar_arr(share_value-$i) 0
            }
            
            # build list of commissions for period
            set list_arr(commission_list-$i) [list ]
            set share_value $scalar_arr(share_value-$i)
            foreach shares_count $list_arr(shares_list-$i) {
#                set commission [expr { int( $shares_count * $scalar_arr(commissions_pot-$i) * 100. ) / ( 100. * $scalar_arr(shares_tot-$i) ) } ]
                set commission [expr { int( $share_value * $shares_count * 100. ) / 100. } ]
                lappend list_arr(commission_list-$i) $commission
            }
            set scalar_arr(commissions_tot-$i) [f::sum $list_arr(commission_list-$i)]
            
            set commissions_diff [expr { abs( $scalar_arr(commissions_pot-$i) - $scalar_arr(commissions_tot-$i) ) } ]
            if { $commissions_diff < 0 } {
                lappend user_messages_lists "Audit note: Commission pot for period $i is less than the sum of the comissions by ${commissions_diff}"
            }
            if { $scalar_arr(revenue-$i) != 0 } {
                set scalar_arr(pct_of_sales-$i) "% [format "% 8.2f" [expr { $scalar_arr(commissions_tot-$i) / $scalar_arr(revenue-$i) * 100. } ] ]"
            } else {
                set scalar_arr(pct_of_sales-$i) "% div by 0!"
            }
       
            # summary report numbers, make pretty
            set scalar_arr(commissions_tot-$i) [util_commify_number [format "%0.2f" $scalar_arr(commissions_tot-$i)]]
            set scalar_arr(commissions_pot-$i) [util_commify_number [format "%0.2f" $scalar_arr(commissions_pot-$i)]]
            set scalar_arr(revenue-$i) [util_commify_number [format "%0.2f" $scalar_arr(revenue-$i)]]
            set scalar_arr(revenue_target-$i) [util_commify_number [format "%0.2f" $scalar_arr(revenue_target-$i)]]
            set scalar_arr(shares_tot-$i)  [util_commify_number [format "%0.0f" $scalar_arr(shares_tot-$i)]]
            set scalar_arr(the_time-$i) [clock format [clock seconds] -format "%Y %b %d %H:%M:%S"]
            
            set compute_message_html ""
            foreach compute_message $compute_message_list {
                append compute_message_html "<li>${compute_message}</li>"
            }
        }
        # end interval calculations

        # affiliate calculations table
        set apt_html "<h3>Computation report</h3>"
        # for each data_set, loop through that sample_rate (%) of times to get a pool of rows,
        set rows_list [list 0]
        foreach i $intervals_list {
            set last_row [expr { $scalar_arr(sale_count-$i) - 1 } ]
            # add boundary rows (first and last)
            lappend rows_list $last_row
            set row_step [expr { 1. / $sample_rate } ]
            for { set ii 0 } { $ii < $last_row } { set ii [expr { $ii + $row_step } ] } {
#                ns_log Notice "affiliate.tcl i $i last_row $last_row row_step $row_step ii $ii"
                set row_idx [expr { int( $ii ) } ]
                lappend rows_list $row_idx
            }
        }
        set rows_list [lsort -integer -unique $rows_list]

        # build main columns and prepare formatting lists
        set header_list [list "Affiliate number"]
        set rows_max 0
        # first row of formatting is blank
        set apt_format_list [list [list ]]
        # setup formating for these columns
        set column_formats_list [list [list align right]]
        # add columns for each period
        foreach i $intervals_list {
            lappend header_list "${period_unit} $i Revenue"
            lappend column_formats_list [list align right bgcolor #ffcccc]
            lappend header_list "${period_unit} $i Micropayments"
            lappend column_formats_list [list align right bgcolor #ccffcc]
            lappend header_list "${period_unit} $i Commissions"
            lappend column_formats_list [list align right bgcolor #ccccff]
            # while we loop through $i, lets determine the max rows for this table
            if { $scalar_arr(sale_count-$i) > $rows_max } {
                set rows_max $scalar_arr(sale_count-$i)
            }
        }
        set apt_lists [list $header_list]
        set table_attribute_list [list border 1 bgcolor #ffffff cellpadding 3 cellspacing 0]
        lappend apt_format_list $column_formats_list

        # combine the lists(columns) into one apt_lists table of them all
        foreach row_idx $rows_list {

            set affiliate_ii [expr { $row_idx + 1 } ]
            set calc_list [list $affiliate_ii]
            foreach i $intervals_list {
                set sale_count $scalar_arr(sale_count-$i)
                if { $row_idx < $sale_count } {
                    # in original loop, ii is set here, and now known as row_idx
                    set commission_ii [lindex $list_arr(commission_list-$i) $row_idx]
                    if { [qfad_is_number_p $commission_ii] } {
                        set commission_ii [util_commify_number [format "%0.2f" $commission_ii]]
                    }
                    set revenue_ii [lindex $list_arr(data_set_list-$i) $row_idx]
                    if { [qfad_is_number_p $revenue_ii] } {
                        set revenue_ii [util_commify_number [format "%0.2f" $revenue_ii]]
                    }
                    set micropayment_ii [lindex $list_arr(shares_list-$i) $row_idx] 
                    if { [qfad_is_number_p $micropayment_ii] } {
                        if { $micropayment_ii > 2 } {
                            set micropayment_ii [util_commify_number [format "%1.0f" $micropayment_ii]]
                        } else {
                            set micropayment_ii [util_commify_number [format "%1.6f" $micropayment_ii]]
                        }
                    }

                    lappend calc_list $revenue_ii 
                    lappend calc_list $micropayment_ii
                    lappend calc_list $commission_ii
                } else {
                    lappend calc_list "" "" ""
                }
            }
            lappend apt_lists $calc_list
        }
        append apt_html [qss_list_of_lists_to_html_table $apt_lists $table_attribute_list $apt_format_list]
        append computation_report_html $apt_html

        set sum_html "<h3>Summary</h3>\n"
        # build summary table
        set sum_list [list [list ${period_unit} Revenue_target "Total revenue" "Commissions pool" "Total commissions" "% of revenue dedicated to referrals" "Number of affiliates" "Number of 'parts' (micropaymens)" "Micropayment value ($)"] ]
        set sum_format_list [list [list ] [list [list align right] [list align right] [list align right] [list align right] [list align right] [list align right] [list align right] [list align right] [list align right]]]
        foreach i $intervals_list { 
            regsub -all -- {,} $scalar_arr(shares_tot-$i) {} shares_tot_i
            regsub -all -- {,} $scalar_arr(commissions_tot-$i) {} commissions_tot_i
            if { [qfad_is_number_p $commissions_tot_i ] && [qfad_is_number_p $shares_tot_i ] } {
                set micropayment_val [format "%1.14f" [expr { $commissions_tot_i / $shares_tot_i } ]]
            } else {
                set micropayment_val "&nbsp;"
            }
            lappend sum_list [list $i $scalar_arr(revenue_target-$i) $scalar_arr(revenue-$i) $scalar_arr(commissions_pot-$i) $scalar_arr(commissions_tot-$i) $scalar_arr(pct_of_sales-$i) $scalar_arr(sale_count-$i) $scalar_arr(shares_tot-$i) $micropayment_val]
        }
        append sum_html [qss_list_of_lists_to_html_table $sum_list $table_attribute_list $sum_format_list]
        append computation_report_html $sum_html
        # determine distribution curve for this set of data
        set stat_html "<h3>Statistics</h3>"
        set stat_header_list [list "Product/sale&nbsp;label" "Value" "Original frequency"]
        set stat_row2_list [list "" [list align right] [list align right] ]
        set column_nbr 3
        foreach i $intervals_list {
            lappend stat_header_list "${period_unit} $i frequency"
            if { [f::odd_p $column_nbr ] } {
                lappend stat_row2_list [list align right]
            } else {
                lappend stat_row2_list [list align right bgcolor #cccccc]
            }
            incr column_nbr
        }
        set stat_list [list $stat_header_list]
        set table_attribute_list [list border 1 bgcolor ffffff cellpadding 3 cellspacing 0]
        set stat_format_list [list [list ] $stat_row2_list]

        ##### build rows by: foreach original sales_curve value
        # first create hash of each period, for quick, accurate referencing
        foreach i $intervals_list {
            foreach { sale_value frequency} $list_arr(ddr_list-$i) {
                set scalar_arr(ddr-idx-$i-${sale_value}) "[format "% 1.4f" ${frequency}]%"
            }
        }
        set price_idx 0
        foreach price $price_list {
            set frequency_orig [lindex $probability_list $price_idx]
            set frequency_orig "[format "% 1.4f" ${frequency_orig}]%"
            set row_list [list [lindex $price_label_list $price_idx] [qaf_round_to_decimals $price] $frequency_orig ]
            foreach i $intervals_list {
                if { [info exists scalar_arr(ddr-idx-$i-$price)] } {
                    lappend row_list $scalar_arr(ddr-idx-$i-$price)
                } else {
                    lappend row_list 0
                }
            }
            lappend stat_list $row_list
            incr price_idx
        }

        
        append stat_html [qss_list_of_lists_to_html_table $stat_list $table_attribute_list $stat_format_list]
        append computation_report_html $stat_html
        
        
    }
    r {
        #  review.... show computed output 
        ns_log Notice "affiliate.tcl mode = review"
        #requires initial_conditions_tid, sales_curve_tid

        # option not used for this app. No Calcs saved.
    }
    v {
        #  view table(s) (standard, html page document/report)
        ns_log Notice "affiliate.tcl mode = $mode ie. view table"
        if { [qf_is_natural_number $initial_conditions_tid] && [qf_is_natural_number $sales_curve_tid] && $write_p } {
            lappend menu_list [list edit "initial_conditions_tid=${initial_conditions_tid}&sales_curve_tid=${sales_curve_tid}&mode=e"]
            set menu_e_p 1
        } else {
            set menu_e_p 0
        }
        if { [qf_is_natural_number $initial_conditions_tid] } {
            set ic_stats_list [qss_table_stats $initial_conditions_tid]
            set ic_name [lindex $ic_stats_list 0]
            set ic_title [lindex $ic_stats_list 1]
            set ic_comments [lindex $ic_stats_list 2]
            set initial_conditions_html "<h3>${ic_title} (${ic_name})</h3>\n"
            set ic_lists [qss_table_read $initial_conditions_tid]
            set ic_text [qss_lists_to_text $ic_lists]
            set table_tag_atts_list [list border 1 cellpadding 3 cellspacing 0]
            append initial_conditions_html [qss_list_of_lists_to_html_table $ic_lists $table_tag_atts_list]
            append initial_conditions_html "<p>${ic_comments}</p>"
            if { ![qf_is_natural_number $sales_curve_tid] } {
                # can sales_curve_tid be extracted from initial_conditions?
                set constants_list [list sales_curve_tid]
                foreach condition_list $ic_lists {
                    set constant [lindex $condition_list 0]
                    if { [lsearch -exact $constants_list $constant] > -1 } {
                        set input_array($constant) [lindex $condition_list 1]
                        set $constant $input_array($constant)
                        ns_log Notice "affiliate.tcl: constant $constant set to $input_array($constant)"
                    }
                }
            }
            if { !$menu_e_p && $write_p } {

                lappend menu_list [list edit "initial_conditions_tid=${initial_conditions_tid}&mode=e"]
            }
        }
        if { [qf_is_natural_number $sales_curve_tid] } {
            set sc_stats_list [qss_table_stats $sales_curve_tid]
            set sc_name [lindex $sc_stats_list 0]
            set sc_title [lindex $sc_stats_list 1]
            set sc_comments [lindex $sc_stats_list 2]
            set sales_curve_html "<h3>${sc_title} (${sc_name})</h3>\n"

            # get table from ID
            set sc_lists [qss_table_read $sales_curve_tid]
            set sc_text [qss_lists_to_text $sales_curve_lists]
            set table_tag_atts_list [list border 1 cellpadding 3 cellspacing 0]
            append sales_curve_html [qss_list_of_lists_to_html_table $sc_lists $table_tag_atts_list]
            append sales_curve_html "<p>${sc_comments}</p>"
            if { !$menu_e_p && ![qf_is_natural_number $initial_conditions_tid] && $write_p } {
                lappend menu_list [list edit "sales_curve_tid=${sales_curve_tid}&mode=e"]
            }
        }
        if { [qf_is_natural_number $initial_conditions_tid] && [qf_is_natural_number $sales_curve_tid] } {
            lappend menu_list [list compute "initial_conditions_tid=${initial_conditions_tid}&sales_curve_tid=${sales_curve_tid}&mode=c"]
        }
    }
    default {
        # default includes v,p

        #  present...... presents a list of contexts/scenarios to choose from
        ns_log Notice "affiliate.tcl mode = $mode ie. default"


        # show initial_conditions, sales_curve  tables
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
                set table_ref_name initial_conditions_tid

            } else { 
                set table_ref_name sales_curve_tid
            }

            set active_link "<a\ href=\"affiliate?${table_ref_name}=${table_id}\">$name</a>"

            if { ( $admin_p || $table_user_id == $user_id ) && $trashed_p == 1 } {
                set trash_label "untrash"
                append active_link " \[<a href=\"affiliate?${table_ref_name}=${table_id}&mode=t\">${trash_label}</a>\]"
            } elseif { $table_user_id == $user_id || $admin_p } {
                set trash_label "trash"
                append active_link " \[<a href=\"affiliate?${table_ref_name}=${table_id}&mode=t\">${trash_label}</a>\]"
            } 
            if { $delete_p && $trashed_p == 1 } {
                append active_link " \[<a href=\"affiliate?${table_ref_name}=${table_id}&mode=d\">delete</a>\]"
            } 
            set stats_list [lreplace $stats_list 0 1 $active_link]
            if { $trashed_p == 1 } {
                lappend table_trashed_lists $stats_list
            } else {
                lappend table_stats_lists $stats_list
            }

        }
        # sort for now. Later, just get initial_conditions_tables with same template_id
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
    append menu_html "<a href=\"affiliate?${url}\">${label}</a>&nbsp;"
}

set user_message_html ""
foreach user_message $user_message_list {
    append user_message_html "<li>${user_message}</li>"
}
