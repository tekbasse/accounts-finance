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
ns_log Notice "aa_register_case.14: Begin test 



"

            # Use examples from 
            # http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique
            # Te = time_expected
            set table_text [lindex [acc_fin::example_tables p20a] 2]
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
                    set optimistic [expr { [lindex $row_cells_list 1] + 0. } ]
                    set median [expr { [lindex $row_cells_list 2] + 0. } ]
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
                        set optimistic2 [qaf_y_of_x_dist_curve 0 $curve2_lol 0]
                        set median2 [qaf_y_of_x_dist_curve .5 $curve2_lol 0]
                        set pessimistic2 [qaf_y_of_x_dist_curve 1 $curve2_lol 0]
                        set optimistic2 [qaf_round_to_decimals $optimistic2 5]
                        set median2 [qaf_round_to_decimals $median2 5]
                        set pessimistic2 [qaf_round_to_decimals $pessimistic2 5 ]
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
                        set curv_geo_avg [acc_fin::pretti_geom_avg_of_curve $curve2_lol -1]
                        set curv_avg_fmt [qaf_round_to_decimals $curv_geo_avg $expected_decimals]
                        set test5_p [expr { $curv_geo_avg >= $expected_time } ]                        
                        aa_true "Test5N for Te of ${activity} w/ ${n_points}-point normal curve ${curv_avg_fmt} not less than pre-calced Te ${expected_time}" $test5_p

                        set curv_geo_avg2 [acc_fin::pretti_geom_avg_of_curve $curve3_lol]
                        set curv_avg_fmt2 [qaf_round_to_decimals $curv_geo_avg2 $expected_decimals]
                        aa_equals "Test5S for Te of ${activity}'s Strict Curve matches pre-calced Te" $curv_avg_fmt2 $expected_time

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


aa_register_case list_index_filter {
    Test acc_fin::list_index_filter proc
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {
            set unfiltered_name_list [list ]
            for { set i 1} { $i < 20} { incr i } {
                set name [ad_generate_random_string]
                lappend unfiltered_name_list $name
            }
            set filtered_name_list [acc_fin::list_index_filter $unfiltered_name_list]
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

            dot_count [expr { int( [random] * ( 10 - 1 + .99 ) ) + 1 } ]
            set 1or2 [expr { int( [random] * ( 2 - 1 + .99 ) ) + 1 } ] 
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
            set default_lists [list $c_x_list $c_y_list $c_label_list]

            set minimum [expr { int( [random] * 256. + 5. ) / 6. } ]
            set median [expr { int( [random] * 512. + 5. ) / 6. + 256. } ]
            set maximum [expr { int( [random] * 1024. + 5. ) / 6. + 1024 } ]


            set test1 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]

            # 2. If a curve exists in curve_lists where each element is a list of x,y(,label), use it.
            set c_x_list [list ]
            set c_y_list [list ]
            set c_label_list [list ]

            set test2 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]

            # 3. If a minimum, median, and maximum is available, make a curve of it. 
            set curve_lists [list ]
            set test3 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]

            # 4. if an median value is available, make a curve of it, 
            set minimum ""
            set maximum ""
            set test4 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]

            # 5. if an ordered list of lists x,y,label exists, use it as a fallback default, otherwise 
            set median ""
            set test5 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]

            # 6. return a representation of a normalized curve as a list of lists similar to curve_lists 
            set default_lists [list ]
            set test6 [acc_fin::curve_import $c_x_list $c_y_list $c_label_list $curve_lists $minimum $median $maximum $default_lists]

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

