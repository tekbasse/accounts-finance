ad_library {
    Automated tests for accounts-finance

    @creation-date 2014-04-30
}

aa_register_case pert_OMP_curve_conversions {
    Test acc_fin::pretti_geom_avg_of_curve proc
} {    
    
    aa_run_with_teardown \
        -rollback \
        -test_code {
ns_log Notice "aa_register_case.14: Begin test"

            # Use examples from 
            # http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique
            # Te = time_expected
            set table_text [lindex [acc_fin::example_table p20a] 2]
            set line_break "\n
"
            set delimiter ","
            set table_rows_list [split $table_text $line_break]
            set x [expr { 1. / 6. } ]
            # cut down the empty table_rows from table_rows_list (length of 17 s/b 7)
            foreach table_row [lrange $table_rows_list 1 end] {
                if { $table_row ne "" } {
                    set row_cells_list [split $table_row $delimiter]
                    set curve_lol [list [list y x label]]
                    set activity [lindex $row_cells_list 0]
                    set expected_time [lindex $row_cells_list 4]
                    regsub -all -- {[^0-9\.]} $expected_time {} expected_time
                    set expected_time_len [string length $expected_time]
                    set expected_decimals [string first "." $expected_time]
                    if { $expected_decimals eq -1 } {
                        set expected_decimals 0
                    } else {
                        set expected_decimals [expr { $expected_time_len - ( $expected_decimals + 1 ) } ]
                    }
                    foreach y [lrange $row_cells_list 1 3] {
                        set row [list $y $x [ad_generate_random_string]]
                        lappend curve_lol $row
                    }
                    
                    # test making a curve based on min/med/max values
                    set optimistic [lindex $row_cells_list 1]
                    set opti_dec [string first "." $optimistic]
                    if { $opti_dec > -1 } {
                        set opt_dec_count [expr { [string length $optimistic] - $opti_dec - 1 } ]
                    } else {
                        set opt_dec_count 0
                    }
                    set optimistic [expr { $optimistic + 0. } ]

                    set median [lindex $row_cells_list 2]
                    set med_dec [string first "." $median]
                    if { $med_dec > -1 } {
                        set med_dec_count [expr { [string length $median] - $med_dec - 1 } ]
                    } else {
                        set med_dec_count 0
                    }
                    set median [expr { [lindex $row_cells_list 2] + 0. } ]

                    set pessimistic [lindex $row_cells_list 3]
                    set pes_dec [string first "." $pessimistic]
                    if { $pes_dec > -1 } {
                        set pes_dec_count [expr { [string length $pessimistic] - $pes_dec - 1 } ]
                    } else {
                        set pes_dec_count 0
                    }
                    set pessimistic [expr { [lindex $row_cells_list 3] + 0. } ]

                    # test Time expected geometric average
                    
                    set geo_avg [expr { ( $optimistic + 4. * $median + $pessimistic ) / 6. } ] 
                    set geo_avg_fmt [qaf_round_to_decimals $geo_avg $expected_decimals]
                    aa_equals "Test1 for ${activity}: calced Te vs. pre-calced Te" $geo_avg_fmt $expected_time
#                    set n_points_list [list 3 5 9 16 18 24 51 127]
                    set n_points_list [list 18 24 51 127]
#                    set n_points_list [list 24 51 60]
                    set tolerance_list [list .01 .02 .05 .1 .2]
 #                   set tolerance_list [list .01]
                    foreach n_points $n_points_list {
                        aa_log "testing OMP values to curve using acc_fin::pert_omp_to_normal_dc"
                        # confirm curve's representation at critical original parameters o,m,p:
                        set curve2_lol [acc_fin::pert_omp_to_normal_dc $optimistic $median $pessimistic $n_points]
                        ns_log Notice "accounts-finance/tcl/test/pretti-test-procs.tcl: curve2_lol $curve2_lol"
                        set optimistic2 [qaf_y_of_x_dist_curve 0 $curve2_lol 0]
                        set median2 [qaf_y_of_x_dist_curve .5 $curve2_lol 0]
                        set pessimistic2 [qaf_y_of_x_dist_curve 1 $curve2_lol 0]
                        set optimistic2 [qaf_round_to_decimals $optimistic2 $opt_dec_count]
                        set median2 [qaf_round_to_decimals $median2 $med_dec_count]
                        set pessimistic2 [qaf_round_to_decimals $pessimistic2 $pes_dec_count]
                        aa_equals "Test2N for '${activity}' w/ ${n_points}-point Normal curve matches @ optimistic" $optimistic2 $optimistic
                        aa_equals "Test3N for '${activity}' w/ ${n_points}-point Normal curve matches @ median" $median2 $median
                        aa_equals "Test4N for '${activity}' w/ ${n_points}-point Normal curve matches @ pessimistic" $pessimistic2 $pessimistic
                        # create a strict curve to test against.
                        set curve3_lol [acc_fin::pert_omp_to_strict_dc $optimistic $median $pessimistic]
                        set optimistic3 [qaf_y_of_x_dist_curve 0 $curve3_lol 0]
                        set median3 [qaf_y_of_x_dist_curve .5 $curve3_lol 0]
                        set pessimistic3 [qaf_y_of_x_dist_curve 1 $curve3_lol 0]
                        aa_equals "Test2S for '${activity}' w/ 3-point Strict curve matches @ optimistic" $optimistic3 $optimistic
                        aa_equals "Test3S for '${activity}' w/ 3-point Strict curve matches @ median" $median3 $median
                        aa_equals "Test4S for '${activity}' w/ 3-point Strict curve matches @ pessimistic" $pessimistic3 $pessimistic


                        aa_log "testing acc_fin::pretti_geom_avg_of_curve"
                        #set curv_geo_avg [acc_fin::pretti_geom_avg_of_curve $curve2_lol -1]
                        set curve_t_expected [expr { ( $optimistic2 + 4. * $median2 + $pessimistic2 ) / 6. } ]
                        set curv_avg_fmt [qaf_round_to_decimals $curve_t_expected $expected_decimals]
                        set test5_p [expr { $curv_avg_fmt >= $expected_time } ]
                        aa_true "Test5N for Te of ${activity} w/ ${n_points}-point normal curve ${curv_avg_fmt} not less than pre-calced Te ${expected_time}" $test5_p

                        set curv_geo_avg2 [acc_fin::pretti_geom_avg_of_curve $curve3_lol]
                        set curv_avg_fmt2 [qaf_round_to_decimals $curv_geo_avg2 $expected_decimals]
                        aa_equals "Test5S for median of ${activity}'s Strict Curve matches pre-calced median" $curv_avg_fmt2 $expected_time

                        foreach tolerance $tolerance_list {
                            set t_pct [expr { int( $tolerance * 100. ) } ]
                            set optimistic_p [expr { ( abs( $optimistic2 - $optimistic ) / $optimistic ) < $tolerance } ]
                            set median_p [expr { ( abs( $median2 - $median ) / $median ) < $tolerance } ]
                            set pessimistic_p [expr { ( abs( $pessimistic2 - $pessimistic ) / $pessimistic ) < $tolerance } ]
                            aa_true "Test6N for '${activity}' w/ ${n_points}-point normal curve within $t_pct % margin  @optimistic" $optimistic_p
                            aa_true "Test7N for '${activity}' w/ ${n_points}-point normal curve within $t_pct % margin @median" $median_p
                            aa_true "Test8N for '${activity}' w/ ${n_points}-point normal curve within $t_pct % margin @pessimistic" $pessimistic_p
                        }
                    }
                }                
            }
        }
}


aa_register_case list_filter {
    Test acc_fin::list_filter proc
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {
            set unfiltered_name_list [list ]
            for { set i 1} { $i < 20} { incr i } {
                set name [ad_generate_random_string]
                lappend unfiltered_name_list $name
            }
            set filtered_name_list [acc_fin::list_filter alphanum $unfiltered_name_list]
            set success_p 1
            set violations ""
            set violations_list [list ]
            foreach name $filtered_name_list {
                
                if { [regexp -nocase -- {[^0-9a-z,]} name violations] } {
                    set success_p 0
                    lappend violations_list $violations
                }
            }
            if { $success_p } {
                aa_true "Test9 filtering gremlin characters in names." $success_p
            } else {
                aa_true "Test9 filtering gremlin characters in names. Fail for '${violations_list}'" $success_p
            }
        }
}

aa_register_case larr_set {
    Test acc_fin::larr_set proc
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {
            set unsorted_name_list [list ]
            set unique_counter 0
            set larr_max 0
            set jcount [string range [clock clicks -microseconds] end end]
            incr jcount
            for { set j 0} { $j < $jcount } { incr j } {
                set val [string range [clock clicks -microseconds] end end]
                set larr_counter [acc_fin::larr_set test_arr $val]
                set larr_max [f::max $larr_counter $larr_max]
                if { [info exists count_arr($val)] } {
                    # do nothing, larr_counter already counted
                    incr count_arr($val)
                } else {
                    set count_arr($val) 1
                    incr unique_counter
                }
                lappend unsorted_name_list $val
            }
            set sorted_name_list [lsort -unique $unsorted_name_list]
            # compare count_arr index count with test_arr index count (s/b same) and identical to llength $sorted_name_list
            set sorted_uniques_count [llength $sorted_name_list]
            # larr_counter includes 0 in count
            incr larr_max
            set success_p [expr { $sorted_uniques_count eq $larr_max && $larr_max eq $unique_counter } ]
            
            aa_true "Test acc_fin::larr_set sorted_uniques ${sorted_uniques_count} larr ${larr_max} uniques ${unique_counter}" $success_p
        }
}

aa_register_case curve_import {
    Test acc_fin::curve_import proc
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {
            # case
            # 1. If a curve exists in c_x_list, c_y_list (, c_label_list), use it.
            set c_x_list [list ]
            set c_y_list [list ]
            set c_label_list [list ]
            set curve_lists [list ]

            set dot_count [expr { int( [random] * ( 10 - 1 + .99 ) ) + 1 } ]
            set 1or2 [expr { int( [random] * ( 2 - 1 + .5 ) ) + 1 } ] 
            for {set i 0} { $i < $dot_count} {incr i} {
                foreach col_list [lrange [list x y label] 0 $1or2] {
                    switch -exact $col_list {
                        x { 
                            # a random amount, assume hours for a task for example
                            lappend c_x_list [expr { int( [random] * 256. + 5. ) / 6. } ]
                        }
                        y {
                            # these could be usd or btc for example
                            lappend c_y_list [expr { int( [random] * 30000. + 90. ) / 100. } ]
                        }
                        label {
                            lappend c_label_list [ad_generate_random_string]
                        }
                    }
                }
            }

            set minimum [expr { int( [random] * 256. + 5. ) / 6. } ]
            set median [expr { int( [random] * 512. + 5. ) / 6. + 256. } ]
            set maximum [expr { int( [random] * 1024. + 5. ) / 6. + 1024 } ]
            set x_len [llength $c_x_list]
            if { $c_label_list eq "" } {
                set titles [list x y]
                set expected [list $titles]
                for {set i 0} {$i < $x_len} {incr i} {
                    set row [list [lindex $c_x_list $i] [lindex $c_y_list $i]]
                    lappend expected $row
                }
            } else {
                set titles [list x y label]
                set expected [list $titles]
                for {set i 0} {$i < $x_len} {incr i} {
                    set row [list [lindex $c_x_list $i] [lindex $c_y_list $i] [lindex $c_label_list $i]]
                    lappend expected $row
                }
            }
            set default_lists $expected
            set curve_lists $expected

            set test1 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]
            set affirm_p [qss_tables_are_equiv_p $test1 $expected]
            if { $affirm_p } {
                aa_true "Case 1" $affirm_p
            } else {
                aa_true "Case 1" $affirm_p
                aa_log "Case 1 \n $test1 \n != $expected \n"
            }
            # 2. If a curve exists in curve_lists where each element is a list of x,y(,label), use it.
            set c_x_list [list ]
            set c_y_list [list ]
            set c_label_list [list ]

            set test2 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]
            set affirm_p [qss_tables_are_equiv_p $test2 $curve_lists]
            if { $affirm_p } {
                aa_true "Case 2" $affirm_p
            } else {
                aa_true "Case 2" $affirm_p
                aa_log "Case 2 \n $test2 \n != $curve_lists \n"
            }
            # 3. If a minimum, median, and maximum is available, make a curve of it. 
            set curve_lists [list ]
            set test3 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]
            set c_lists [acc_fin::pert_omp_to_normal_dc $minimum $median $maximum ]
            set affirm_p [qss_tables_are_equiv_p $test3 $c_lists]
            if { $affirm_p } {
                aa_true "Case 3" $affirm_p
            } else {
                aa_true "Case 3" $affirm_p
                aa_log "Case 3 \n $test3 \n != $c_lists \n"
            }

            # 4. if a median value is available, make a curve of it
            set minimum ""
            set maximum ""
            set test4 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]
            set med_label "med"
            if { $minimum eq "" } {
                set minimum $median
                set min_label $med_label
            } else {
                set min_label "min"
            }
            if { $maximum eq "" } {
                set maximum $median
                set max_label $med_label
            } else {
                set max_label "max"
            }
            set c_lists [acc_fin::pert_omp_to_normal_dc $minimum $median $maximum ]
            set affirm_p [qss_tables_are_equiv_p $test4 $c_lists]
            if { $affirm_p } {
                aa_true "Case 4" $affirm_p
            } else {
                aa_true "Case 4" $affirm_p
                aa_log "Case 4 \n $test4 \n != $c_lists \n"
            }

            # 5. if an ordered list of lists x,y,label exists, use it as a fallback default, otherwise 
            set median ""
            set test5 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]
            set affirm_p [qss_tables_are_equiv_p $test5 $default_lists]
            if { $affirm_p } {
                aa_true "Case 5" $affirm_p
            } else {
                aa_true "Case 5" $affirm_p
                aa_log "Case 5 \n $test5 \n != $default_lists \n"
            }

            # 6. return a representation of a normalized curve as a list of lists similar to curve_lists 
            set default_lists [list ]
            set test6 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]
            set minimum 0.5
            set median 1.
            set maximum 2.
            set tc_larr(y) [list y $minimum $median $median $median $median $maximum]
            # using approximate cumulative distribution y values for standard deviation of 1.
            set portion [expr { 1. / 6. } ]
            set tc_larr(x) [list x $portion $portion $portion $portion $portion $portion ]
            set tc_larr(label) [list label "outlier" "standard deviation 2" "standard deviation 1" "standard deviation 1" "standard deviation 2" "outlier" ]
            set c_lists [list ]
            for {set i 0} {$i < 7} {incr i} {
                lappend c_lists [list [lindex $tc_larr(x) $i] [lindex $tc_larr(y) $i] [lindex $tc_larr(label) $i]]
            }

            set affirm_p [qss_tables_are_equiv_p $test6 $c_lists]
            if { $affirm_p } {
                aa_true "Case 6" $affirm_p
            } else {
                aa_true "Case 6" $affirm_p
                aa_log "Case 6 \n $test6 \n != $c_lists \n"
            }

        }
}


aa_register_case scenario_prettify_test1 {
    Test acc_fin::scenario_prettify proc
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {
            # scenario_prettify requires:
            # p1 scenario table
            # p2 activity table
            # optional:
            # p3 activity_type table
            # dc distribution curves

            # p1 data refers to p2 table. Create p2 table before p1.
            # p2 data refers to dc or p3 tables. Create dc or p3 tables before p2.
            # all above is handled in acc_fin::pretti_example_maker
            set scenario_tid [acc_fin::pretti_example_maker ]
            acc_fin::scenario_prettify $scenario_tid

            

            #set date [dt_ansi_to_julian_single_arg "2003-01-01 01:01:01"]
            #aa_equals "Returns correct julian date" $date "2452641"

        }
}

aa_register_case pretti_curve_tc_multiply {
    Test acc_fin::pretti_curve_time_multiply and acc_fin::pretti_curve_cost_multiply proc
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            # To test these procs, a single point curve is passed to test all cases.

            # The tested procedures determine the longest run within constraints based on equations.

            # To test, this procedure checks all cases from coefficient to 1 to see
            # which parameters are the best fit, then checks values against values 
            # returned from the tested procs.

            # set defaults
            set activity "pretti_curve_tc_multiply"
            set user_id 0
            set instance_id [qc_set_instance_id]
            set scenario_id 0
            set base_curve_lol [list ]
            lappend base_curve_lol [list x y]
            set tcurvenum ""
            set ccurvenum ""
            set use_t_run_p 1

            # Instead of random, to consider all cases, a combination of distributed numbers are used.
            # For simplicity, the combinations are run through a base_n number count.
            set base_n 5
            set combo_set_count 4
            set permutations_count [expr { pow( $base_n , $combo_set_count ) } ]
            set permutations_length [acc_fin::base $base_n $permutations_count]
            set i 0
            set random_list [list ]
            for {set ii 0} { $ii < $base_n } { incr ii } {
                set random_arr($ii) [qaf_round_to_decimals [random] 3]
            }
            set zeros [string range "000000000000000" 1 $combo_set_count]
            while { $i < $permutations_count } {
                
                set i_n $zeros
                set i_n2 [acc_fin::base $base_n $i]
                append i_n $i_n2
                ns_log Notice "accounts-finance/tcl/test/pretti-test-procs.tcl.425: ********* loop i $i i_n2 $i_n2"
                set offset [expr { $combo_set_count - 1 } ]
                set i0 [string range $i_n end-$offset end]
                set i_list [split $i0 ""]
                #ns_log Notice "accounts-finance/tcl/test/pretti-test-procs.tcl.429: i0 $i0 i_list '$i_list'"
                lassign $i_list ri(1) ri(2) ri(3) ri(4) ri(5)
                #ns_log Notice "accounts-finance/tcl/test/pretti-test-procs.tcl.430: ri(1) $ri(1) ri(2) $ri(2) ri(3) $ri(3) ri(4) $ri(4) ri(5) $ri(5) ri(6) $ri(6) ri(7) $ri(7) ri(8) $ri(8)"
                #ns_log Notice "accounts-finance/tcl/test/pretti-test-procs.tcl.431: i_list '$i_list'"
                for {set ii 1} {$ii <= $combo_set_count} {incr ii} {
                    set r($ii) $random_arr($ri($ii))
                    #ns_log Notice "accounts-finance/tcl/test/pretti-test-procs.tcl.436: r($ii) $r($ii) ri($ii) $ri($ii) random_arr(ri($ii)) $random_arr($ri($ii))"
                }
                set coefficient [expr { ceil( $r(1) * 1024 ) } ]
                set y_time [qaf_round_to_decimals [expr { $r(2) * 100. + .0125 } ] 5]
                # Set the constraints:
                set max_overlap_pct $r(1)
                set max_concurrent [expr { ceil( $coefficient * $r(2) * 1.1 + .001 ) } ]
                set max_run_time [expr { $y_time * $coefficient * $r(3) * 1.1 } ]
                set max_tasks_per_run [expr { ceil( $coefficient * $r(4) * 1.1 ) } ]
                set max_discount_pct $r(2)
                # using r(3) in y_cost to save in combinations.
                set y_cost [qaf_round_to_decimals [expr { $r(3) * 10000. } ] 3]

                # initializations. assume no constraints
                set t_test_curve_lol $base_curve_lol
                set row [list 1 $y_time]
                lappend t_test_curve_lol $row
                set c_test_curve_lol $base_curve_lol
                set row [list 1 $y_cost]
                lappend c_test_curve_lol $row
                #ns_log Notice "acc_fin::pretti_curve_time_multiply.455: y_cost $y_cost c_test_curve_lol $c_test_curve_lol t_test_curve_lol $t_test_curve_lol"

                # if max_concurrent is unlimited, then 1 tasks_per_run
                set tasks_per_run 1
                set run_count 1

                # if max_concurrent were 1, then tasks_per_run would be $coefficient

                # block_count is coefficient constrained by max_concurrent
                set block_count [expr { round( ceil( $coefficient / $max_concurrent ) + 0. ) } ]

                set max_dedicated_pct [expr { 1. - $max_overlap_pct } ]
                set max_batch_rate_pct [expr { 1. - $max_discount_pct } ]
                
                # multiple activity length 
                set test_run_count 1
                set test_tasks_per_run $block_count
                set test_coef [expr { 1. * $test_tasks_per_run * $max_dedicated_pct + $max_overlap_pct } ]
                set test_time [expr { $test_coef * $y_time } ]
                set limited_p 0
                # What are run_count and tasks_per_run, and subsequently y_new using brute force testing?
                while { ( $test_coef > $max_tasks_per_run || $test_time > $max_run_time) && $test_tasks_per_run > 1 } {
                    incr test_tasks_per_run -1
                    set limited_p 1
                    set test_coef [expr { 1. * $test_tasks_per_run * $max_dedicated_pct + $max_overlap_pct } ]
                    set test_run_count [expr { ceil( $block_count / ( $test_tasks_per_run + 0. ) ) } ]
                    set test_time [expr { $test_coef * $y_time } ]
                }
                set test_time_runs [expr { $test_time * $test_run_count } ]

                # set t and test_time_runs_fmtd to same decimals as y_time
                set tdecimals 0
                set tdecimal_idx [string first "." $y_time]
                if { $tdecimal_idx > -1 } {
                    set tdecimals [expr { [string length $y_time] - $tdecimal_idx - 1 } ]
                }


                set test_cost [expr { $test_run_count * $y_cost * ( 1. * ( $test_tasks_per_run + 0. ) * $max_batch_rate_pct + $max_discount_pct ) } ]

                # set c and test_cost to same decimals as y_cost
                set cdecimals 0
                set cdecimal_idx [string first "." $y_cost]
                if { $cdecimal_idx > -1 } {
                    set cdecimals [expr { [string length $y_cost] - $cdecimal_idx - 1 } ]
                }
                # test brute force against procs
                # setup procs with preliminary environmental variables
                set use_t_run_p 0
                set t_constrained_by_time_p 0
                set tcurve_lol [acc_fin::pretti_curve_time_multiply $t_test_curve_lol "" $coefficient $scenario_id $user_id $instance_id ]
                set y_idx [lsearch -exact [lindex $tcurve_lol 0] "y"]
                set t [qaf_round_to_decimals [lindex [lindex $tcurve_lol 1] $y_idx] $tdecimals]
                set test_time_runs_fmtd [qaf_round_to_decimals $test_time_runs $tdecimals]

                set ccurve_lol [acc_fin::pretti_curve_cost_multiply $c_test_curve_lol "" $coefficient $scenario_id $user_id $instance_id ]
                set y_idx [lsearch -exact [lindex $ccurve_lol 0] "y"]
                set c [qaf_round_to_decimals [lindex [lindex $ccurve_lol 1] $y_idx] $cdecimals]
                set test_cost_fmtd [qaf_round_to_decimals $test_cost $cdecimals]
                # check against proc
                if { ![aa_equals "Test $i for T with coef ${coefficient} limited_p $limited_p test_tasks_per_run ${test_tasks_per_run} test_time_runs_fmtd ${test_time_runs_fmtd} t $t" $t $test_time_runs_fmtd] } {
                    # log all the parameters..
                    aa_log "y_time $y_time max_overlap_pct ${max_overlap_pct} max_concurrent ${max_concurrent} max_run_time ${max_run_time} max_tasks_per_run ${max_tasks_per_run}"
                    aa_log "caclulated: block_count ${block_count} max_dedicated_pct ${max_dedicated_pct} test_coef ${test_coef} test_run_count ${test_run_count}"

                }
                if { ![aa_equals "Test $i for C with coef ${coefficient} limited_p $limited_p test_tasks_per_run ${test_tasks_per_run} test_cost_fmtd ${test_cost_fmtd} c $c" $c $test_cost_fmtd] } {
                    # log all the parameters..
                    aa_log "max_overlap_pct ${max_overlap_pct} max_concurrent ${max_concurrent} max_run_time ${max_run_time} max_tasks_per_run ${max_tasks_per_run}"
                    aa_log "y_cost $y_cost max_discount_pct ${max_discount_pct}"
                    aa_log "caclulated: block_count ${block_count} max_dedicated_pct ${max_dedicated_pct} test_coef ${test_coef} test_run_count ${test_run_count}"
                    aa_log "use_t_run_p ${use_t_run_p} t_constrained_by_time_p ${t_constrained_by_time_p}"
                    

                }
                incr i
            }
        }
}

