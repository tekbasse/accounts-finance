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
                    foreach y [lrange $row_cells_list 1 3] {
                        set row [list $y $x [ad_generate_random_string]]
                        lappend curve_lol $row
                    }
                    # test Time expected geometric average
                    set geo_avg [acc_fin::pretti_geom_avg_of_curve $curve_lol]
                    set geo_avg_fmt [string range $geo_avg 0 $expected_time_len]
                    aa_equals "Activity $activity: Te calced matches Te expected" $geo_avg_fmt $expected_time
                    
                    # test making a curve based on min/med/max values
                    set optimistic [expr { [lindex $row_cells_list 1] + 0. } ]
                    set median [expr { [lindex $row_cells_list 2] + 0. } ]
                    set pessimistic [expr { [lindex $row_cells_list 3] + 0. } ]
                    set n_points_list [list 12 18 24 48 96]
                    #set tolerance_list [list .01 .02 .05 .1 .2]
                    set tolerance_list [list .01]
                    foreach n_points $n_points_list {
                        aa_log "testing conversion of OMP values to curve using acc_fin::pert_omp_to_normal_dc"
                        # confirm curve's representation at critical original parameters o,m,p:
                        set curve2_lol [acc_fin::pert_omp_to_normal_dc $optimistic $median $pessimistic ]
                        set optimistic2 [qaf_y_of_x_dist_curve 0 $curve2_lol 1]
                        set median2 [qaf_y_of_x_dist_curve .5 $curve2_lol 1]
                        set pessimistic2 [qaf_y_of_x_dist_curve 1 $curve2_lol 1]

                        aa_equals "Activity $activity: Curve Te matches @ optimistic" $optimistic2 $optimistic
                        aa_equals "Activity $activity: Curve Te matches @ median" $median2 $median
                        aa_equals "Activity $activity: Curve Te matches @ pessimistic" $pessimistic2 $pessimistic

                        aa_log "testing acc_fin::pretti_geom_avg_of_curve"
                        set curv_geo_avg [acc_fin::pretti_geom_avg_of_curve $curve2_lol]
                        set curv_avg_fmt [string range $curv_geo_avg 0 $expected_time_len]
                        aa_equals "Activity $activity: Curve Te matches expected Te" $curv_avg_fmt $expected_time
                        foreach tolerance $tolerance_list {
                            set t_pct [expr { int( $tolerance * 100. ) } ]
                            set optimistic_p [expr { ( ( ( $optimistic2 - $optimistic ) / $optimistic ) - 1. ) < $tolerance } ]
                            set median_p [expr { ( ( ( $median2 - $median ) / $median ) - 1. ) < $tolerance } ]
                            set pessimistic_p [expr { ( ( ( $pessimistic2 - $pessimistic ) / $pessimistic ) - 1. ) < $tolerance } ]
                            aa_true "Activity $activity: $n_points point curve within $t_pct % @optimistic" $optimistic_p
                            aa_true "Activity $activity: $n_points point curve within $t_pct % @median" $median_p
                            aa_true "Activity $activity: $n_points point curve within $t_pct % @pessimistic" $pessimistic_p
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

