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
            
            # Use examples from 
            # http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique
            # Te = time_expected
            set table_text "\
activity_ref,time_est_short,time_est_med,time_est_long,time_ext\n
A,2,4,6,4.0\n
B,3,5,9,5.33\n
C,4,5,7,5.17\n
D,4,6,10,6.33\n
E,4,5,7,5.17\n
F,3,4,8,4.5\n
G,3,5,8,5.17\n
"
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
                    set n_points_list [list 24]
                    #set tolerance_list [list .01 .02 .05 .1 .2]
                    set tolerance_list [list .01]
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
                        aa_true "Test5N for Te of ${activity}'s Normal Curve ${curv_avg_fmt} not less than pre-calced Te ${expected_time}" $test5_p

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

            #set date [dt_ansi_to_julian_single_arg "2003-01-01 01:01:01"]
            #aa_equals "Returns correct julian date" $date "2452641"

        }
}

aa_register_case p2_factors_expand {
    Test acc_fin::p2_factors_expand proc
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            #set date [dt_ansi_to_julian_single_arg "2003-01-01 01:01:01"]
            #aa_equals "Returns correct julian date" $date "2452641"

        }
}

