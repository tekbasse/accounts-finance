ad_library {

    PRETTI routines used for Project Reporting Evaluation and Track Task Interpretation
    @creation-date 11 Feb 2014
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public acc_fin::tid_scalars_to_array {
    table_id 
    array_name
} {
    Saves scalars in a 2 column table to an array array_name, where array indexes are the scalars in the first column, and the value for each scalar is same row in second column. table_id is a reference to a qss_simple table.
} {
    upvar $array_name tid_arr
    # load table_id
    # extract each name-value pair, saving into array
}
ad_proc -public acc_fin::pretti_ck_lol {
    scenario_list_of_lists
} {
    returns 1 if scenario is valid for processing
} {
        #requires scenario_tid
        # given scenario_tid 
        # activity_table contains:
        # activity_ref predecessors time_est_short time_est_median time_est_long cost_est_low cost_est_median cost_est_high time_dist_curv_eq cost_dist_curv_eq
    return $valid_p
}

ad_proc -public acc_fin::prettify_lol {
    scenario_list_of_lists
} {
    processes PRETTI scenario. Returns resulting PRETTI table as a list of lists
} {
        #  compute... compute/process and write output as a new table_lists
        ns_log Notice "acc_fin::prettify_lol: start"
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
        # util_commify_number
        # format "% 8.2f" $num
        # f::sum $list

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
        ns_log Notice "acc_fin::prettify_lol: path_seg_dur_list $path_seg_dur_list"
        foreach act $act_list {
            set $dep_met_p [expr $depnc_eq_arr($act) && $dep_met_p ]
            # ns_log Notice "acc_fin::prettify_lol: act $act act_seq_num_arr '$act_seq_num_arr($act)'"
            # ns_log Notice "acc_fin::prettify_lol: act_seq_list_arr '$act_seq_list_arr($act_seq_num_arr($act))' $act_count_of_seq_arr($act_seq_num_arr($act))"
        }
        ns_log Notice "acc_fin::prettify_lol: dep_met_p $dep_met_p"
        
        # sort by path duration
        # critical path is the longest path. Float is the difference between CP and next longest CP.
        # create an array of paths from longest to shortest to help build base table
        set path_seg_dur_sort1_list [lsort -decreasing -real -index 1 $path_seg_dur_list]
        # Critical Path (CP) is 
        set cp_list [lindex [lindex $path_seg_dur_sort1_list 0] 0]
        #ns_log Notice "acc_fin::prettify_lol: path_seg_dur_sort1_list $path_seg_dur_sort1_list"
        
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
            set activity_list [list $act $act_seq_num_arr($act) $has_direct_dependency_p $on_critical_path_p $on_a_sig_path_p $act_freq_in_load_cp_alts_arr($act) $duration_arr($act) $time_expected_arr($act) $depnc_arr($act) ]
            lappend base_lists $activity_list
        }
        
        # act_count_of_seq_arr( sequence_number) is the count of activities at this sequence number
        # max_act_count_per_seq is the maximum number of activities in a sequence number.
        
        ns_log Notice "acc_fin::prettify_lol: base_lists $base_lists"
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
        
        ns_log Notice "acc_fin::prettify_lol: primary_sort $primary_sort"
        
        # prep for conversion to html by adding missing TDs, setting formatting (colors, size etc).
        # primary_sort list_of_lists consists of this order of elements:
        #  act act_seq_num_arr has_direct_dependency_p on_critical_path_p on_a_sig_path_p act_freq_in_load_cp_alts path_duration time_expected dependencies_list
        # sorted by: act_seq_num on_critical_path_p has_direct_dependency_p duration
        
        
        # build formatting colors
        set act_count [llength $act_list]
        # contrast decreases on up to 50%
        set contrast_step [expr { int( 16 / ( $max_act_count_per_seq / 2 + 1 ) ) } ]
        set hex_list [list 0 1 2 3 4 5 6 7 8 9 a b c d e f]
        set row_nbr 0
        set cell_nbr 0
        set act_seq_num $sequence_1
        # each row is a relative sequence
        set cells_per_row $max_act_count_per_seq
        set cell_formatting_list [list ]
        set cell_value_list [list ]
        set table_formatting_lists [list ]
        set table_value_lists [list ]
        # act_count_of_seq_arr( sequence_number) is the count of activities at this sequence number
        foreach cell $primary_sort {
            set cell_nbr_prev $cell_nbr
            set act_seq_num_prev $act_seq_num
            incr cell_nbr
            set cell_formatting [list ]
            set cell_value ""
            # set initial values
            set act [lindex $cell 0]
            set act_seq_num [lindex $cell 1]
            set has_direct_dependency_p [lindex $cell 2]
            set on_critical_path_p [lindex $cell 3]
            set on_a_sig_path_p [lindex $cell 4]
            set act_freq_in_load_cp_alts [lindex $cell 5]
            set path_duration [lindex $cell 6]
            set time_expected [lindex $cell 7]
            set dependencies_list [lindex $cell 8]
            set dependencies ""
            set separator ""
            foreach dependency $dependencies_list {
                append dependencies $separator $dependency
                set separator ", "
            }
            if { $act_seq_num_prev ne $act_seq_num } {
                # new row
                set cell_nbr 0
                set row_nbr_prev $row_nbr
                incr row_nbr
                set hex_nbr_val 16
                lappend table_formatting_lists $cell_formatting_list
                lappend table_value_lists $cell_formatting_list
                set cell_formatting_list [list ]
                set cell_value_list [list ]
            }
            # build cell
            set cell_value "$act t:${time_expected} T:${path_duration} D:${dependencies} "
            set odd_row_p [expr { ( $row_nbr / 2. ) == int( $row_nbr / 2 ) } ]
            # CP in highest contrast (yellow ff9), others in lowering contrast to f70
            # CP alt in alternating lt blue 99f, lt green 9f9 
            # others in alternating medium blue/green 66ff, 6f6
            if { $on_critical_path_p } {
                set bgcolor "#ffff00"
            } elseif { $on_a_sig_path_p } {
                set hex_nbr_val [expr { $hex_nbr - $contrast_step } ]
                set hex_nbr [lindex $hex_list $hex_nbr_val]
                if { $odd_row_p } {
                    set bgcolor "#ff${hex_nbr}${hex_nbr}99"
                } else {
                    set bgcolor "#${hex_nbr}ff${hex_nbr}"
                }
                
            } elseif { $odd_row_p } {
                set bgcolor "#6666ff"
            } else {
                set bgcolor "#66ff66"
            }
            set cell_formatting bgcolor $bgcolor
            lappend cell_formatting_list $cell_formatting
            lappend cell_value_list $cell_value
        }
        
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

        append html_arr(apt) [qss_list_of_lists_to_html_table $table_value_lists $table_attribute_list $table_formatting_lists]
        append html_arr(apt) "Completed $s_arr(the_time)"
        append computation_report_html $html_arr(apt)



    return $pretti_lol
}