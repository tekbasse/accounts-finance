ad_library {

    PRETTI routines used for Project Reporting Evaluation and Track Task Interpretation
    With Hints Of GANTT Activity Network Task Tracking (PRETTI WHO GANTT)
    Project Activity Network Evaluation By Reporting Low Float Paths In Fast Tracks
    @creation-date 11 Feb 2014
    @cvs-id $Id:
    Temporary comment about git commit comments: http://xkcd.com/1296/
}

namespace eval acc_fin {}

ad_proc -public acc_fin::pert_omp_to_strict_dc {
    optimistic
    most_likely
    pessimistic
} {
    Creates a curve in PRETTI table format representing strict characteristics of 
    a PERT expected time function (Te), where 
    Te = ( o + 4 * m + p ) / 6 and o = optimistic time, m = most likely time, and p = pessimistic time.
    This 3 point curve has lower limit (o), upper limit (p) and median (m). 
} {
#    ns_log Notice "acc_fin::pert_omp_to_strict_dc.24: optimistic $optimistic most_likely $most_likely pessimistic $pessimistic"
    # nomenclature of inputs  statistics:
    # set median $most_likely
    # set minimum $optimistic
    # set maximum $pessimistic
    set curve_lists [list ]
    lappend curve_lists [list y x]
    set one_sixth [expr { 1. / 6. } ]
    set point_list [list $optimistic $one_sixth]
    lappend curve_lists $point_list
    set point_list [list $most_likely [expr { 4. / 6. } ] ]
    lappend curve_lists $point_list
    set point_list [list $pessimistic $one_sixth]
    lappend curve_lists $point_list
    return $curve_lists
}

ad_proc -public acc_fin::pert_omp_to_normal_dc {
    optimistic
    most_likely
    pessimistic
    {n_points "24"}
} {
    Creates a normal distribution curve in PRETTI table format representing characteristics of 
    a PERT expected time function (Te), where 
    Te = ( o + 4 * m + p ) / 6 and o = optimistic time, m = most likely time, and p = pessimistic time.
    The normal distribution curve has lower limit (o), upper limit (p) and median (m). 
} {
    #ns_log Notice "acc_fin::pert_omp_to_normal_dc.23: starting"
#    ns_log Notice "acc_fin::pert_omp_to_normal_dc.24: optimistic $optimistic most_likely $most_likely pessimistic $pessimistic n_points $n_points"
    # nomenclature of inputs  statistics:
    # set median $most_likely
    # set minimum $optimistic
    # set maximum $pessimistic
    set n_points [f::max [expr { int( $n_points - 2 ) } ] 6]
    set n_areas  [expr { int( $n_points - 2 ) } ]

    #set pi 3.14159265358979
    set pi [expr { atan2( 0. , -1. ) } ]
    #set e 2.718281828459  see exp()
    set sqrt_2pi [expr { sqrt( 2. * $pi ) } ]
    set sqrt_2 [expr { sqrt( 2. ) } ]
    set optimistic [expr { $optimistic * 1. } ]
    set most_likely [expr { $most_likely * 1. } ]
    set pessimistic [expr { $pessimistic * 1. } ]
    # Symetric calculations use indexed arrays to swap between tails.
    # Index of:
    # 0 = left tail
    # 1 = right tail

    # Build a curve using Normal Distribution calculations as a base
    # Split the curve into two tails, in case med - min value does not equal max - med.
    # Left tail represents minimum to median.
    # So, create a standard_deviation for left side by assuming curve is symmetric:
    # set std_dev_left [expr { sqrt( 2 * pow( $minimum - $median , 2) + 4 * pow( $median - $median , 2) ) } ]
    # resolves to:
    # set std_dev_left [expr { sqrt( 2 * pow( $minimum - $median , 2)  ) } ]
    # which further reduces to:
    set std_dev(0) [expr { $sqrt_2 * abs( $most_likely - $optimistic ) } ]
    # Right tail represents median to maximum.
    set std_dev(1) [expr { $sqrt_2 * abs( $pessimistic - $most_likely ) } ]
    #ns_log Notice "acc_fin::pert_omp_to_normal_dc.42: std_dev_left $std_dev(0) std_dev_right $std_dev(1)"
    # f(x) is the normal distribution function. x = 0 at $median
    
    # for each section of the curve divided into $n_areas sections:
    # k = 1. / sqrt( 2. * $pi )
    # f(x) = k * pow( $e , -0.5 * pow( $x - $median , 2. ) )
    # where x  is -2. * std_dev_left to 2. * std_dev_right
    # and value at x is :
    # if x < 0
    # $minimum + sigma f( $x from -2. * $std_dev_left to x = 0 ) * n_areas / 2.
    # if x => 0
    # $median + sigma f( $x from x = 0 to 2. * $std_dev_right ) * n_areas / 2.
    
    # Determine x points. Start with 0 to get critical area near distribution peak.
    set order_larr(0) [list 0 1]
    set order_larr(1) [list 1 0]
    if { $std_dev(0) > $std_dev(1) } {
        set order_list $order_larr(0)
    } else {
        set order_list $order_larr(1)
    }
    # $a is the tail with the largest standard deviation
    set e [lindex $order_list 0]
    set f [lindex $order_list 1]
    # if there is an odd number of points, use the extra point on the longer side
    set p_count($f) [expr { int( $n_areas / 2. ) } ]
    set p_count($e) [expr { $n_areas - $p_count($f) } ]

    # create tails and their analogs
    # ns_log Notice "acc_fin::pert_omp_to_normal_dc.83: ** Create tails"
    # from median to double standard deviation to approximate OMP calculations
    foreach ii $order_list {
        set x_larr($ii) [list ]
        set nd_larr($ii) [list ]
        set a_larr($ii) [list ]
        set da_larr($ii) [list ]
        set a 0.
        set a_prev $a
        set x_prev 0.
        # standard deviation = sigma
        set 4sigma [expr { 4. * $std_dev($ii) } ]
        set k0 [expr { $4sigma / ( $p_count($ii) * 1. ) } ]
        set y1 [expr { exp( -0.5 * pow( $x_prev , 2. ) ) / $sqrt_2pi } ] 
 #       ns_log Notice "acc_fin::pert_omp_to_normal_dc.93: ii $ii e $e f $f 4sigma $4sigma k0 $k0 p_count($ii) $p_count($ii)"
        # for i = 1 to p_count 
        lappend nd_larr($ii) $y1
        lappend x_larr($ii) $x_prev
        lappend a_larr($ii) $a
        lappend da_larr($ii) $a
 #       ns_log Notice "acc_fin::pert_omp_to_normal_dc.99: i '' x_prev $x_prev delta_x '' y2 '' y1 '$y1' a '$a'"
        for {set i 0 } { $i < $p_count($ii) } { incr i } {
            # range of x over f(x) is -2. * std_dev_left to 2. * std_dev_right
            set x [expr { $k0 * ( $i + 1. ) } ]
            lappend x_larr($ii) $x
            # Calculate nd = f(x) = for the normal distribution of this tail
            # Probability density function:
            set y2 [expr { exp( -0.5 * pow( $x , 2. ) ) / $sqrt_2pi } ] 
            lappend nd_larr($ii) $y2
            # Calculate area under normal distribution curve.
            # delta_x is arguably $k0
            set delta_x [expr { $x - $x_prev } ]
 #           ns_log Notice "acc_fin::pert_omp_to_normal_dc.100: i $i x '$x' delta_x '$delta_x' y2 '$y2' y1 '$y1' a '$a'"
            set a [expr { $a + $delta_x * ( $y2 + $y1 ) / 2. } ]
            set delta_a [expr { $a - $a_prev } ]
            lappend a_larr($ii) $a
            lappend da_larr($ii) $delta_a
            set y1 $y2
            set x_prev $x
            set a_prev $a
        }
        set a_arr($ii) [f::sum $da_larr($ii)]
#        ns_log Notice "acc_fin::pert_omp_to_normal_dc.107: a_arr($ii) $a_arr($ii)"
    }
    # tail areas must be equal.
    if { $a_arr(1) != $a_arr(0) } {
        ns_log Notice "acc_fin::pert_omp_to_normal_dc.118: a_arr(0) of $a_arr(0) != a_arr(1) $a_arr(1) Attempting fix."
        if { $a_arr(1) > $a_arr(0) } {
            set order2_list $order_larr(1)
        } elseif { $a_arr(0) > $a_arr(1) } {
            # The smaller standard deviation has the largest area.
            set order2_list $order_larr(0)
        }
        # $c is the area to match
        set c [lindex $order2_list 0]
        # $d is the area that needs to match $c
        set d [lindex $order2_list 1]
        ns_log Notice "Attempting to match area of tail $c by modifying area of tail $d."

       set a_diff [expr { $a_arr($c) - $a_arr($d) } ]
        # Add $a_diff to the first area of $d
        # but, delta_x is not calculated at this point.
        # so, add x_diff to each value of x in $d tail (but the first one).
        # a_old s/b 0 at this point

        # Note that x was previously normalized.
        set nd0 [lindex $nd_larr($d) 0]
        set x0 [lindex $x_larr($d) 0]
        set nd1 [lindex $nd_larr($d) 1]
        set x1 [lindex $x_larr($d) 1]
        set y [expr { ( $nd0 + $nd1 ) / 2. } ]
        set a01_old [expr {  $y * ( $x1 - $x0 ) } ]
        set a01_new [expr { $a01_old + $a_diff } ]
        set x_new [expr { $a01_new / $y } ]
        # determine new delta_x
        set x_diff [expr { $x_new - $x1 } ]
        # modify tail.
        set x_list_new [list ]
        lappend x_list_new [lindex $x_larr($d) 0]
        foreach x [lrange $x_larr($d) 1 end] {
            set x_new [expr { $x + $x_diff } ]
            lappend x_list_new $x_new
        }
        set a_new [expr { $a_diff + $a_arr($d) } ]
        # choose the area that best matches a_larr($e)
        set test [expr { $a_new - $a_arr($d) } ]
        if { $test < $a_diff } {
            # Adjustment fits better than original, replace original tail
            set x_larr($d) $x_list_new
            set y1 [expr { exp( -0.5 * pow( $x_prev , 2. ) ) / $sqrt_2pi } ] 
            # Recalc everything based on x
            set nd_larr($d) [list $y1]
            set a 0.
            set da_larr($d) [list $a]
            set x_prev [lindex $x_larr($d) 0]
            set a_prev $a
            ns_log Notice "acc_fin::pert_omp_to_normal_dc.159: delta_x '' y2 '' y1 '$y1' a '$a' "
            foreach x [lrange $x_larr($d) 1 end] {
                # use x_larr($d), do not re-calc x_larr()
                # Calculate nd = f(x) = for the normal distribution of this tail
                set y2 [expr { exp( -0.5 * pow( $x , 2. ) ) / $sqrt_2pi } ] 
                lappend nd_larr($ii) $y2
                # Calculate area under normal distribution curve.
                # x has already been normalized.
                set delta_x [expr { $x - $x_prev } ]
                
                ns_log Notice "acc_fin::pert_omp_to_normal_dc.160: x '$x' delta_x '$delta_x' y2 '$y2' y1 '$y1' a '$a'"
                set a [expr { $a + $delta_x * ( $y2 + $y1 ) / 2. } ]
                set delta_a [expr { $a - $a_prev } ]
                lappend a_larr($ii) $a
                lappend da_larr($ii) $delta_a
                set y1 $y2
                set x_prev $x
                set a_prev $a
            }
            set a_arr($d) [f::sum $da_larr($d)]
        }
        # Report if adjustment is less than optimally effective
        set a2_diff [expr { $a_arr(1) - $a_arr(0) } ]
        if { [expr { abs( $a2_diff ) } ] > 0.0001 } {
            ns_log Notice "acc_fin::pert_omp_to_normal_dc.163: tail areas are significantly different (a2_diff > 0.0001)."
            ns_log Notice "acc_fin::pert_omp_to_normal_dc.164: a_arr($d) $a_arr($d) a_arr($c) $a_arr($c)"
            ns_log Notice "acc_fin::pert_omp_to_normal_dc.165: a_diff $a_diff a2_diff $a2_diff"
            ns_log Notice "acc_fin::pert_omp_to_normal_dc.166: optimistic $optimistic most_likely $most_likely pessimistic $pessimistic n_areas $n_areas"
        }
    }

    # Translate tail f(x) = nd to f(i) = y values
#    ns_log Notice "acc_fin::pert_omp_to_normal_dc.196: ** Translate standard deviation tails to curve."
    # left tail, assume symmetric, but calculate to reduce error
    set y_range_arr(0) [expr { ( $most_likely - $optimistic ) } ]
    # right tail, assume symmetric
    set y_range_arr(1) [expr { ( $pessimistic - $most_likely ) } ]


    # build final left tail
#    ns_log Notice "acc_fin::pert_omp_to_normal_dc.204: ** Final left tail."
    set curve_lists [list ]
    lappend curve_lists [list y x]

    set x_prev [lindex $x_larr(0) end]
#    ns_log Notice "acc_fin::pert_omp_to_normal_dc.209: x_larr(0) $x_larr(0)"
    # standard conversion is:
    set y1 [lindex $nd_larr(0) end]
    # f_x is $optimistic
    set f_x $optimistic

    # tail must end with at least  0.5 for median
    if { $a < 0.5 } {
        set a [expr { 0.5 - $a_arr(0) } ]
    } else {
        set a 0.
    }
    set a_prev $a
    # add the minimum case
    set point_list [list $f_x $a_prev]
    lappend curve_lists $point_list

    # x_count is one after start of left tail: last index - 1 ie: length - 2
    set x_count [expr { [llength $x_larr(0)] - 2 } ]
#    ns_log Notice "acc_fin::pert_omp_to_normal_dc.222: x_prev $x_prev x_count $x_count y2 '' y1 $y1 a $a delta_a '' f_x $f_x"
    for {set i $x_count} { $i > -1 } {incr i -1} {
        # note: x already normalized
        set x [lindex $x_larr(0) $i]
        set y2 [lindex $nd_larr(0) $i]
        # going backwards, so delta_x sign is reversed.
        set delta_x [expr { $x_prev - $x } ]
        # a is area under curve

        set a [expr { $a + $delta_x * ( $y1 + $y2 ) / 2. } ]
        set delta_a [expr { $a - $a_prev } ]
        # Use two equations, one for left side, one for right side:
        set f_x [expr { $optimistic + $y_range_arr(0) * 2. * $a } ]
#        ns_log Notice "acc_fin::pert_omp_to_normal_dc.235: i $i x $x delta_x '$delta_x' y2 '$y2' y1 '$y1' a $a delta_a $delta_a f_x $f_x "
#        set point_list [list $f_x $a]
        set point_list [list $f_x $delta_a]
        # reverse order of left tail
        lappend curve_lists $point_list
        set y1 $y2
        set x_prev $x
        set a_prev $a
    }
    set a3_diff [expr { 0.5 - $a } ]
    if { $a3_diff > 0.00001 } {
        ns_log Warning "acc_fin::pert_omp_to_normal_dc.244: a should be ( within 0.00001 of) 0.5 at this point. Instead, a $a delta_a $delta_a a3_diff ${a3_diff}."
    }
    # Similar pattern (of left tail) for final right tail
 #   ns_log Notice "acc_fin::pert_omp_to_normal_dc.251: ** Final right tail."
    # is f::sum $a_arr(1) is near 0.5
    # a = right tail's  0.5 + 0.5 - $a_arr(1) ie 0.5 to 1
    set a 0.
    # Attempt to balance the tail areas 
    if { $a_arr(0) < $a_arr(1) } {
        set a [expr { $a_arr(0) - $a_arr(1) } ]
    } 
    set a_prev $a
    set y1 [lindex $nd_larr(1) 0]
    set x_prev [lindex $x_larr(1) 0]
    set f_x $most_likely
    # add the median case
    set point_list [list $f_x $a]
    lappend curve_lists $point_list
    set i 1
  #  ns_log Notice "acc_fin::pert_omp_to_normal_dc.261: i $i x_prev $x_prev y2 '' y1 $y1 a $a delta_a '' f_x $f_x"
    foreach x [lrange $x_larr(1) 1 end] {
        set y2 [lindex $nd_larr(1) $i]
        set delta_x [expr { $x - $x_prev } ]
        # a is area under curve
        set a [expr { $a + $delta_x * ( $y1 + $y2 ) / 2. } ]
        set delta_a [expr { $a - $a_prev } ]
        # Use two equations, one for left side, one for right side:
        # this y range is from median to high
        set f_x [expr { $most_likely + $y_range_arr(1) * 2. * $a } ]
 #       ns_log Notice "acc_fin::pert_omp_to_normal_dc.272: i $i x $x delta_x '$delta_x' y2 '$y2' y1 '$y1' a '$a' f_x $f_x "
#        set point_list [list $f_x $a]
        set point_list [list $f_x $delta_a]
        # reverse order of left tail
        lappend curve_lists $point_list
        set y1 $y2
        set x_prev $x
        set a_prev $a
        incr i
    }
    # modify last point
    set curve_lists [lrange $curve_lists 0 end-1]
#    set point_list [list $pessimistic $a]
    set point_list [list $pessimistic $delta_a]
    lappend curve_lists $point_list

    # remove header for point count
    set points_count [expr { [llength $curve_lists] - 1 } ]
    if { $points_count != $n_points } {
        ns_log Warning "acc_fin::pert_omp_to_normal_dc.288: curve has $points_count points instead of requested $n_points points."
    }
    return $curve_lists
}


ad_proc -public acc_fin::pretti_geom_avg_of_curve {
    curve_lol
} {
    Given a curve with x and y columns, finds the geometric average determined by: (y1*x1 + y2*x2 .. yN*xN ) / sum(x1..xN)
} {
    # This is a generalization of the PERT Time-expected function
    set constants_list [list y x]
    # get first row of titles
    set title_list [lindex $curve_lol 0]
    set y_idx [lsearch -exact $title_list "y"]
    set x_idx [lsearch -exact $title_list "x"]
    set geometric_avg ""
    if { $y_idx > -1 && $x_idx > -1 } {
        set x_list [list ]
        set numerator_list [list ]
        foreach point_list [lrange $curve_lol 1 end] {
            set x [lindex $point_list $x_idx]
            set y [lindex $point_list $y_idx]
            lappend x_list $x
            lappend  numerator_list [expr { $x * $y * 1. } ]
        }
        set x_sum [f::sum $x_list ]
        if { $x_sum != 0. } {
            set numerator [f::sum $numerator_list ]
            set geometric_avg [expr { $numerator / $x_sum } ]
        } else {
            ns_log Notice "acc_fin::pretti_geom_avg_of_curve.170: divide by zero caught for x_sum. numerator $numerator"
        }
    } else {
        ns_log Notice "acc_fin::pretti_geom_avg_of_curve.178: y_idx $y_idx x_idx $x_idx"
    }
    return $geometric_avg
}


ad_proc -public acc_fin::pretti_type_flag {
    table_lists_name
} {
    Guesses which type of pretti table
} {
    upvar $table_lists_name table_lists
    # page flags as pretti_types:
    #  p in positon 1 = PRETTI app specific
    #  p1  scenario
    #  p2  task network (unique tasks and their dependencies)
    #  p3  task types (can also have dependencies)
    #  dc distribution curve
    #  p4  PRETTI report (output)
    #  p5  PRETTI db report (output) (similar format to  p3, where each row represents a path, but in p5 all paths are represented
    #  dc Estimated project duration distribution curve (can be used to create other projects)

    # get first row
    set title_list [lindex $table_lists 0]
    set type_return ""
    # check for type p1 separate from the other cases, because the table is specified differently from other cases.
    set p(p1) 0
    set name_idx [lsearch -exact $title_list name]
    set value_idx [lsearch -exact $title_list value]
    if { $name_idx > -1 && $value_idx > -1 } {
        # get name column
        set name_list [list ]
        foreach row $table_lists {
            lappend name_list [lindex $row $name_idx]
        }
        # check name_list against p1 required names:
        set p(p1) 1
        set check_list [acc_fin::pretti_columns_list "p1" 1 ]
        foreach check $check_list {
            set p(p1) [expr { $p(p1) && ( [lsearch -exact $name_list $check] > -1 ) } ]
        }
    }
    if { $p(p1) } {
        set type_return "p1"
    } else {
        # filter other p table types by required minimums first
        set type_list [list "p2" "p3" "p4" "p5" "dc"]
        foreach type $type_list {
            set p($type) 1
            set check_list [acc_fin::pretti_columns_list $type 1]
            ns_log Notice "acc_fin::pretti_type_flag (58): type $type check_list $check_list"
            foreach check $check_list {
                set p($type) [expr { $p($type) && ( [lsearch -exact $title_list $check] > -1 ) } ]
                ns_log Notice "acc_fin::pretti_type_flag (60): check $check p($type) $p($type)"
            }
        }
        
        # how many types might this table be?
        set type1_p_list [list ]
        foreach type $type_list {
            if { $p($type) } {
                lappend type1_p_list $type
            }
        }
        ns_log Notice "acc_fin::pretti_type_flag (69): type1_p_list '${type1_p_list}'"
        set type_count [llength $type1_p_list]
        if { $type_count > 1 } {
            # choose one
            if { $p(p2) && $p(p3) && $type_count == 2 } {
                if { [lsearch -exact $title_list "aid_type" ] > -1 } {
                    set type_return "p2"
                } elseif { [lsearch -exact $title_list "type" ] > -1 } {
                    set type_return "p3"
                } 
            } else {
                set type3_list [list ]
                # Which type best meets full list of implemented column names?
                foreach type $type1_p_list {
                    set name_list [acc_fin::pretti_columns_list $type 0]
                    set name_list_count [llength $name_list]
                    set exists_count 0
                    foreach name $name_list {
                        if { [lsearch -exact $title_list $name] > -1 } {
                            incr exists_count
                        }
                    }
                    if { $name_list_count > 0 } {
                        set type_pct_list [list $type [expr { ( $exists_count * 1. ) / ( $name_list_count * 1. ) } ] ]
                        lappend type3_list $type_pct_list
                    } 
                }
                set type3_list [lsort -real -index 1 -decreasing $type3_list]
                set type_return [lindex [lindex $type3_list 0] 0]
            }
        } else {
            # append is used here in case no type meets the criteria, an empty string is returned
            append type_return [lindex $type1_p_list 0]
        }
    }
            
    return $type_return
}

ad_proc -private acc_fin::pretti_columns_list {
    type
    {required_only_p "0"}
} {
    Returns a list of column names used by pretti table type. If required_only_p is 1, only returns the required columns for specified type. Reserved words are not included in the list.
} {
    set sref $type
    append sref $required_only_p
    switch -exact $sref {
        p10 {
            # p1 PRETTI Scenario
            # consists of a "name" and "value" column, with names of:
            #      activity_table_tid
            #      activity_table_name      name of table containing task network
            #      period_unit          measure of time used in task duration etc.
            #      time_dist_curve_name      a default distribution curve name when a task type doesn't reference one.
            #      time_dist_curve_tid      a default distribution curve table_id, dist_curve_name overrides dist_curve_dtid
            #      cost_dist_curve_name      a default distribution curve name when a task type doesn't reference one.
            #      cost_dist_curve_tid      a default distribution curve table_id, dist_curve_name overrides dist_curve_dtid
            #      with_factors_p  defaults to 1 (true). Set to 0 (false) if any factors in p3 are to be ignored.
            #                           This option is useful to intercede in auto factor expansion to add additional
            #                           variation in repeating task detail. (deprecated by auto expansion of nonexisting coefficients).
            #      time_probability_moment A percentage (0..1) along the (cumulative) distribution curve. defaults to 0.5
            #      cost_probability_moment A percentage (0..1) along the (cumulative) distribution curve
            #set ret_list \[list name value\]
            set ret_list [list activity_table_tid activity_table_name task_types_tid task_types_name time_dist_curve_name time_dist_curve_tid cost_dist_curve_name cost_dist_curve_tid time_est_short time_est_median time_est_long time_probability_moment cost_est_low cost_est_median cost_est_high cost_probability_moment]
        }
        p11 {
            #set ret_list \[list name value\]
            set ret_list [list activity_table_tid ]
        }
        p20 {
            # p2 Task Network
            #      activity_ref           reference for an activity, a unique task id, using "activity" to differentiate between table_id's tid 
            #                             An activity reference is essential a function as in f() with no attributes,
            #                             However, there is room to grow this by extending a function to include explicitly set paramemters
            #                             within the function, similar to how app-model handles functions aka vectors
            #                             The multiple of an activity is respresented by a whole number followed by an "*" 
            #                             with no spaces between (when spaces are used as an activity delimiter), or
            #                             with spaces allowed (when commas or another character is used as an activity delimiter.
            #                
            #      aid_type               activity type from p3
            #      dependent_tasks        direct predecessors , activity_ref of activiites this activity depends on.
            #      name                   defaults to type's name (if exists else blank)
            #      description            defaults to type's description (if exists else blank)
            #      max_concurrent         defaults to type's max_concurrent 
            #      max_overlap_pct     defaults to type's max_overlap_pct021
            
            #      time_est_short         estimated shortest duration. (Lowest statistical deviation value)
            #      time_est_median        estimated median duration. (Statistically, half of deviations are more or less than this.) 
            #      time_est_long          esimated longest duration. (Highest statistical deviation value.)
            #      time_dist_curve_tid Use this distribution curve instead of the time_est short, median and long values
            #                             Consider using a variation of task_type as a reference
            #      time_dist_curv_eq  Use this distribution curve equation instead.
            
            #      cost_est_low           estimated lowest cost. (Lowest statistical deviation value.)
            #      cost_est_median        estimated median cost. (Statistically, half of deviations are more or less than this.)
            #      cost_est_high          esimage highest cost. (Highest statistical deviation value.)
            #      cost_dist_curve_tid Use this distribution curve instead of equation and value defaults
            #      cost_dist_curv_eq  Use this distribution curve equation. 
            #
            #      RESERVED columns:
            #      _tCurveRef             integer reference to time curve in time_clarr and   time duration estimate at time_probability_moment in t_est_arr
            #      _cCurveRef             integer reference to cost curve in cost_clarr and   cost duration estimate at cost_probability_moment in c_est_arr
            set ret_list [list activity_ref aid_type dependent_tasks name description max_concurrent max_overlap_pct time_est_short time_est_median time_est_long time_dist_curve_tid time_dist_curve_name time_probability_moment cost_est_low cost_est_median cost_est_high cost_dist_curve_tid cost_dist_curve_name cost_probability_moment]

        }
        p21 {
            set ret_list [list activity_ref dependent_tasks]
        }
        p30 {
            # p3 Task Types:   
            #      type
            #      dependent_types      Other dependent types required by this type. (possible reference collisions. type_refs != activity_refs.
            #
            #####                       dependent_types should be checked against activity_dependents' types 
            #                           to confirm that all dependencies are satisified.
            #      name
            #      description
            #      max_concurrent       (as an integer, blank = no limit)
            #      max_overlap_pct021  (as a percentage from 0 to 1, blank = 1)
            #
            #      RESERVED columns:
            #      _tCurveRef             integer reference to time curve in time_clarr and   time duration estimate at time_probability_moment in t_est_arr
            #      _cCurveRef             integer reference to cost curve in cost_clarr and   cost duration estimate at cost_probability_moment in c_est_arr
            set ret_list [list type dependent_tasks dependent_types name description max_concurrent max_overlap_pct activity_table_tid activity_table_name task_types_tid task_types_name time_dist_curve_name time_dist_curve_tid cost_dist_curve_name cost_dist_curve_tid time_est_short time_est_median time_est_long time_probability_moment cost_est_low cost_est_median cost_est_high cost_probability_moment db_format]            
        }
        p31 {
            set ret_list [list type]
            # if changing p3 or p2 lists, see also constants_woc_list in this file.
        }
        p40 {
            # each column is track_{number} and generated by code so not used in this context

            # p4 Display modes
            #  
            #  tracks within n% of CP duration, n represented as %12100 or a duration of time as total lead slack
            #  tracks w/ n fixed count closest to CP duration. A n=1 shows CP track only.
            #  tracks that contain at least 1 CP track 
            set ret_list [list track_1]
        }
        p41 {
            # each column is track_{number} and generated by code so not used in this context
            set ret_list [list track_1]
        }
        p50 {
            # each row is a cell, in format of detailed PRETTI internal output. See code. All columns are required to reproduce output to p4 (including p4 comments).

            set ret_list [list activity_ref activity_seq_num dependencies_q cp_q significant_q popularity waypoint_duration activity_time direct_dependencies activity_cost waypoint_cost]
        }
        p51 {
            # each row is a cell, in format of detailed PRETTI internal output. See code. 
            set ret_list [list activity_ref activity_seq_num dependencies_q cp_q significant_q popularity waypoint_duration activity_time direct_dependencies activity_cost waypoint_cost]
        }
        dc0 {
            # dc2 distribution curve table
            #                   Y         where Y = f(x) and f(x) is a 
            #                             probability mass function ie probability density function as a distribution
            #                             http://en.wikipedia.org/wiki/Probability_mass_function
            #                             http://en.wikipedia.org/wiki/Probability_density_function
            #                         aka http://en.wikipedia.org/wiki/Discrete_probability_distribution#Discrete_probability_distribution
            #                             The discrete values are the values of Y included in the table
            
            #                    X        Where X = the probability of Y.
            #                             These can be counts of a sample or a frequency.  When the table is saved,
            #                             the total area under the distribution is normalized to 1.
            
            #                   label     Where label represents the value of Y at x. This is a short phrase or reference
            #                             that identifies a boundary point in the distribution.
            # A three point (short/median/long or low/median/high) estimation curve can be respresented as
            # a discrete set of six points:  minimum median median median median maximum 
            # of standard bell curve probabilities (outliers + standard deviation).
            # Thereby allowing *_probability_moment variable to be used in estimates with lower statistical resolution.
            set ret_list [list y x label]
        }
        dc1 {
            set ret_list [list y x]
        }
        default {
            ns_log Notice "acc_fin::pretti_columns_list (242): bad reference sref '$sref'. Returning blank list."
            set ret_list [list ]
        }
    }
    return $ret_list
}


ad_proc -public acc_fin::pretti_table_to_html {
    pretti_lol
    comments
} {
    Interprets a saved p4 pretti output table into html table.
} {
    # process table by building columns in row per html TABLE TR TD tags
    # pretti_lol consists of first row:
    # track_1 track_2 track_3 ... track_N
    # subsequent rows:
    # cell_r1c1 cell_r1c2 cell_r1c3 ... cellr1cN
    # ...
    # cell_rMc1 cell_rMc2 cell_rMc3 ... cellrMcN
    # for N tracks of a maximum of M rows.
    # Each cell is an activity.
    # Each column is a track
    # Track_1 is CP

    # empty cells have empty string value.
    # other cells will contain comment format from acc_fin::scenario_prettify
    # "$activity "
    # "t:[lindex $track_list 7] "
    # "ts:[lindex $track_list 6] "
    # "c:[lindex $track_list 9] "
    # "cs:[lindex $track_list 10] "
    # "d:(${depnc_larr(${activity})) "
    # "<!-- [lindex $track_list 4] [lindex $track_list 5] --> "

    set column_count [llength [lindex $pretti_lol 0]]
    set row_count [llength $pretti_lol]
    incr row_count -1

    # values to be extracted from comments:
    # max_act_count_per_track and cp_duration_at_pm 
    # Other parameters could be added to comments for changing color scheme/bias
    set contrast_mask_idx ""
    regexp -- {[^a-z\_]?max_act_count_per_track[\ \=\:]([0-7])[^0-7]} $comments scratch contrast_mask_idx
    if { [ad_var_type_check_number_p $contrast_mask_idx] && $contrast_mask_idx > -1 && $contrast_mask_idx < 8 } {
        # do nothing
    } else {
        # set default
        set contrast_mask_idx 1
    }
    set colorswap_p ""
    regexp -- {[^a-z\_]?colorswap_p[\ \=\:]([0-1])[^0-1]} $comments scratch colorswap_p
    if { [ad_var_type_check_number_p $colorswap_p] && $colorswap_p > -1 && $colorswap_p < 2 } {
        # do nothing
    } else {
        # set default
        set colorswap_p 0
    }

    set max_act_count_per_track $row_count
    regexp -- {[^a-z\_]?max_act_count_per_track[\ \=\:]([0-9]+)[^0-9]} $comments scratch max_act_count_per_track
    if { $max_act_count_per_track == 0 } {
        set max_act_count_per_track $row_count
    }
    regexp -- {[^a-z\_]?cp_duration_at_pm[\ \=\:]([0-9]+)[^0-9]} $comments scratch cp_duration_at_pm
    if { $cp_duration_at_pm == 0 } {
        # Calculate cp_duration_at_pm manually, using track_1 (cp track)
        foreach row [lrange $pretti_lol 1 end] {
            set cell [lindex $row 0]
            if { $cell ne "" } {
                regexp -- {ts:([0-9\.]+)[^0-9]} $cell scratch test_num
            }
        }
        if { [ad_var_type_check_number_p $test_num] && $test_num > 0 } {
            set cp_duration_at_pm $test_num
        }
    }

    # determine list of CP activities
    set cp_list [list ]
    foreach row [lrange $pretti_lol 1 end] {
        set cell [lindex $row 0]
        if { $cell ne "" } {
            # activity is not Title of activity, but activity_ref
            if {  [regexp -- {^([^\ ]+) t:} $cell scratch activity_ref ] } {
                lappend cp_list $activity
            }
        }
    }

    # Coloring and formating will be interpreted 
    # based on values provided in comments, 
    # data from track_1 and table type (p4) for maximum flexibility.   

    # table cells need to indicate a relative time length in addition to dependency. check

    set title_formatting_list [list ]
    foreach title [lindex $pretti_lol 0] {
        lappend title_formatting_list [list style "font-style: bold;"]
    }
    set table_attribute_list [list ]
    set table_formating_list [list ]
    lappend table_formatting_list $title_formatting_list

    # build formatting colors
    # contrast decreases on up to 50%
    set hex_list [list 0 1 2 3 4 5 6 7 8 9 a b c d e f]
    set bin_list [list 000 100 010 110 001 101 011 111]
    set contrast_mask [lindex $contrast_mask_idx $bin_list]
    set contrast_mask_list [split $contrast_mask ""]
    set row_nbr 1
    set k1 [expr { $max_act_count_per_track / $cp_duration_at_pm } ]
    set k2 [expr {  16. / $column_count }

    foreach row [lrange $pretti_lol 1 end] {

        set row_formatting_list [list ]
        set odd_row_p [expr { ( $row_nbr / 2. ) == int( $row_nbr / 2 ) } ]
        set cell_nbr 0
        foreach cell $row {
            set activity_time_expected ""
            regexp {t:([0-9\.]+)[^0-9]} $cell scratch activity_time_expected
            set row_size [f::max [list [expr { int( $activity_time_expected * $k1 ) } ] 1]]
            # CP in highest contrast (yellow ff9), others in lowering contrast to f70, and dimmer contrasts on even rows
            # f becomes e for even rows etc.
            # CP alt in alternating lt blue to lt green: 99f .. 9f9 
            # others in alternating medium blue/green:   66f .. 6f6

            # set contrast 
            if { $odd_row_p } {
                set c(0) "ee"
            } else {
                set c(0) "ff"
            }

            # then set color1 and color2 based on activity count, blue lots of count, green is less count
            if { $cell_nbr eq 0 } {
                # on CP
                set c(1) "ff"
                set c(2) "99"
            } elseif { $on_a_sig_path_p } {
                regexp { ([0-9\.]+) --> } $cell scratch popularity 
                set dec_nbr_val [f::min [list [expr { int( $popularity * $k2 ) } ] 16]]
                set hex_nbr1 [expr { $dec_nbr_val } ]
                set hex_nbr2 [expr { 16 - $hex_nbr1 } ]
                set c(1) [lindex $hex_list $hex_nbr1]
                set c(2) [lindex $hex_list $hex_nbr2]
                append c(1) $c(1)
                append c(2) $c(2)
            } else {
                regexp { ([0-9\.]+) --> } $cell scratch popularity 
                # constrast_step is number from 1 to 7, with 1  being most popular, 7 least popular
                set contrast_step [f::max [list [f::min [list 7 [expr { int( $popularity * $k2 / 2. ) } ]]] 1]]
                set dec_nbr_val [f::min [list [expr { int( $popularity * $k2 ) } ] 16]]
                set hex_nbr1 [expr { $dec_nbr_val - $contrast_step } ]
                set hex_nbr2 [expr { 16 - $hex_nbr1 - $contrast_step } ]
                set c(1) [lindex $hex_list $hex_nbr1]
                set c(2) [lindex $hex_list $hex_nbr2]
                append c(1) $c(1)
                append c(2) $c(2)
            }
            # contrast_mask_list
            set colorhex ""
            if { $colorswap_p } {
                set color_ref 2
                set color_inc -1
            } else {
                set color_ref 1
                set color_inc 1
            }
            foreach digit $contrast_mask_list {
                set i $digit
                if { $digit eq 1 } {
                    set i $color_ref
                    incr $color_ref $color_inc
                    # in case all 3 digits are 1, set the last case to reference 0
                    set color_inc [expr { -1 * $color_ref } ]
                }
                append colorhex $c($i)
            }
            set cell_formatting [list style "background-color: #${colorhex};"]
            lappend row_formatting_list $cell_formatting
        }
        lappend table_formatting_lists $row_formatting_list
    }
    
    # html
    set pretti_html "<h3>Computation report</h3>"
    
    append pretti_html [qss_list_of_lists_to_html_table $pretty_lol $table_attribute_list $table_formatting_lists]
}
    return pretti_html
}

ad_proc -public acc_fin::larr_set {
    larr_name
    data_list
} {
    Assigns a data_list to an index in array larr_name 
    in a manner that minimizes memory footprint. 
    If the list already exists (exactly), 
    it returns the existing index, 
    otherwise it assignes a new index in array and 
    a new index of array is returned. 
    This procedure helps reduce memory overhead 
    for indexes with lots of list data.
} {
    upvar $larr_name larr_name
    # If memory issues exist even after using this proc, one can further compress the array by applying a dictionary storage technique.
    # It may be possible to use the list as an index and gain from tcl internal handling for example.
    # hmm. Initial tests suggest this array(list) works, but might not be practical to store references..
    set indexes_list [array names $larr_name]
    set icount [llength $indexes_list]
    set i 0
    set index [lindex $indexes_list $i]
    while { $i < $icount && $larr_name($index) ne $data_list } {
        incr i
        set index [lindex $indexes_list $i]
    }
    if { $larr_name($index) ne $data_list } {
        set i $icount
        set larr_name($icount) $data_list
    } 
    return $i
}

ad_proc -private acc_fin::p_load_tid {
    constants_list
    constants_required_list
    p_larr_name
    tid
    {p3_larr_name ""}
} {
    loads array_name with p2 or p3 style table for use with internal code
} {
    upvar $p_larr_name p_larr
    upvar time_clarr time_clarr
    upvar cost_clarr cost_clarr
    upvar type_t_curve_arr type_t_curve_arr
    upvar type_c_curve_arr type_c_curve_arr
    set task_type_column_exists_p 0
    set task_types_exist_p 0    
    set type_tcurve_list [list ]
    set type_ccurve_list [list ]
    if { [info exists p_larr(type)] } {
        set task_type_column_exists_p 1
    }
    if { $p3_larr_name ne ""} {
        upvar $p3_larr_name p3_larr
        if { $task_type_column_exists_p && [llength $p_larr(type)] > 0 } {
            set task_types_exist_p 1
        } 
    }
# following are not upvar'd because the cache is mainly useless after proc ends
#    upvar tc_cache_larr tc_cache_larr
#    upvar cc_cache_larr cc_cache_larr
# following are not upvar'd because these are temporary arrays for loading list representations of curves
#    upvar tc_larr tc_larr
#    upvar cc_larr cc_larr

    # load task types table
    foreach column $constants_list {
        set p_larr($column) [list ]
    }
    qss_tid_columns_to_array_of_lists $tid p_larr $constants_list $constants_required_list $package_id $user_id
    # filter user input that is going to be used as references in arrays:
    set p_larr(type) [acc_fin::list_index_filter $p_larr(type)]
    set p_larr(dependent_tasks) [acc_fin::list_index_filter $p_larr(dependent_tasks)]
    set p_larr(_tCurveRef) [list ]
    set p_larr(_cCurveRef) [list ]
    set i_max [llength $p_larr(type)]
    for {set i 0} {$i < $i_max} {incr i} {

        if { $task_type_column_exists_p } {
            set type [lindex $p_larr(type) $i]
        }
        if { $task_types_exist_p } {
            if { $type ne "" } {
                set type_tcurve_list $time_clarr($type_t_curve_arr($type))
                # also grab cost curve from task_type
                set type_ccurve_list $cost_clarr($type_c_curve_arr($type))
            } else {
                set type_tcurve_list [list ]
                set type_ccurve_list [list ]
            }
        }

        # time curve
        if { $p_larr(time_dist_curve_name) ne "" } {
            set p_larr(time_dist_curve_tid) [qss_tid_from_name $p_larr(time_est_curve_name) ]
        }
        if { $p_larr(time_dist_curve_tid) ne "" } {
            set ctid $p_larr(time_dist_curve_tid)
            set constants_list [acc_fin::pretti_columns_list dc]
            if { [info exists tc_cache_larr(x,$ctid) ] } {
                # already loaded tid curve from earlier. 
                foreach constant $constant_list {
                    set tc_larr($constant) $tc_cache_larr($constant,$ctid)
                }
            } else {
                foreach constant $constant_list {
                    set tc_larr($constant) ""
                }
                set constants_required_list [acc_fin::pretti_columns_list dc 1]
                qss_tid_columns_to_array_of_lists $time_dist_curve_tid tc_larr $constants_list $constants_required_list $package_id $user_id
                # add to input tid cache
                foreach constant $constant_list {
                    set tc_cache_larr($constant,$ctid) $tc_larr($constant)
                }
                #tc_larr(x), tc_larr(y) and optionally tc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n
            }
            # import curve given all the available curve choices
            set curve_list [acc_fin::curve_import $tc_larr(x) $tc_larr(y) $tc_larr(label) $type_tcurve_list [lindex $p_arr(time_est_short) $i] [lindex $p_arr(time_est_median) $i] [lindex $p_arr(time_est_long) $i] $time_clarr(0) ]
            set tcurvenum [acc_fin::larr_set time_clarr $curve_list]
        } else {
            # use the default curve
            set tcurvenum 0
        }

        # cost curve
        if { $p_larr(cost_dist_curve_name) ne "" } {
            set p_larr(cost_dist_curve_tid) [qss_tid_from_name $p_larr(cost_est_curve_name) ]
        }
        if { $p_larr(cost_dist_curve_tid) ne "" } {
            set ctid $p_larr(cost_dist_curve_tid)
            set constants_list [acc_fin::pretti_columns_list dc]
            if { [info exists cc_cache_larr(x,$ctid) ] } {
                # already loaded tid curve from earlier. 
                foreach constant $constant_list {
                    set cc_larr($constant) $cc_cache_larr($constant,$ctid)
                }
            } else {
                foreach constant $constant_list {
                    set cc_larr($constant) ""
                }
                set constants_required_list [acc_fin::pretti_columns_list dc 1]
                qss_tid_columns_to_array_of_lists $cost_dist_curve_tid cc_larr $constants_list $constants_required_list $package_id $user_id
                # add to input tid cache
                foreach constant $constant_list {
                    set cc_cache_larr($constant,$ctid) $cc_larr($constant)
                }
                #cc_larr(x), cc_larr(y) and optionally cc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n
            }
            # import curve given all the available curve choices
            set curve_list [acc_fin::curve_import $cc_larr(x) $cc_larr(y) $cc_larr(label) $type_ccurve_list [lindex $p_arr(cost_est_low) $i] [lindex $p_arr(cost_est_median) $i] [lindex $p_arr(cost_est_high) $i] $cost_clarr(0) ]
            set ccurvenum [acc_fin::larr_set cost_clarr $curve_list]
        } else {
            # use the default curve
            set ccurvenum 0
        }

        # add curve references for both time and cost. 
        lappend p_larr(_tCurveRef) $tcurvenum
        lappend p_larr(_cCurveRef) $ccurvenum
        # If this is a p3_larr, create pointer arrays for use with p2_larr
        if { $task_type_column_exists_p && !$task_types_exist_p } {
            if { $type ne "" } {
                set type_t_curve_arr($type) $tcurvenum
                set type_c_curve_arr($type) $ccurvenum
            }
        }
    }
    return 1
}

ad_proc -public acc_fin::list_index_filter {
    user_input_list
} {
    filters alphanumeric input as a list to meet basic word or reference requirements
} {
    set filtered_list [list ]
    foreach input_unfiltered $user_input_list {
        regsub -all -nocase -- {[^a-z0-9,]+} $input_unfiltered {} input_filtered
        lappend filtered_list $input_filtered
    }
    return $filtered_list
}

ad_proc -public acc_fin::table_type {
    table_id
} {
    returns table flags.
} {
    set stats_list [qss_table_stats $table_id]
    # stats: name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id.
    set flags [string trim [lindex $stats_list 6]]
    return $flags
}


ad_proc -private acc_fin::curve_import {
    c_x_list
    c_y_list
    c_label_list
    curve_lists
    minimum
    median
    maximum
    default_lists
} {
    Returns curve data to standard representation for PRETTI processing. 
    1. If a curve exists in c_x_list, c_y_list (, c_label_list), use it.
    2. If a curve exists in curve_lists where each element is a list of x,y(,label), use it.
    3. If a minimum, median, and maximum is available, make a curve of it. 
    4. if an median value is available, make a curve of it, 
    5. if an ordered list of lists x,y,label exists, use it as a fallback default, otherwise 
    6. return a representation of a normalized curve as a list of lists similar to curve_lists 
} {
    # In persuit of making curve_data
    #     local curves are represented as a list of lists, with each list a triplet set x, y, label
    #     or as separate lists.. so this proc must check for both forms.

    #     local 3-point (min,median,max) represented as a list of 3 elements
    #     local median represented as a single element
    #     default curve represented as a list of lists
    #     if no default available, create one based on a normalized standard.

    set c_lists [list ]

    # 1. If a curve exists in c_x_list, c_y_list (, c_label_list), use it.
    set c_x_list_len [llength $c_x_list]
    set c_y_list_len [llength $c_y_list]
    set c_label_list_len [llength $c_label_list]
    set list_len 0
    if { $c_x_list_len > 0 && $c_x_list_len < $c_y_list_len } {
        set list_len $c_x_list_len
    } elseif { $c_y_list_len > 0 } {
        set list_len $c_y_list_len
    }
    if { $list_len > 0 } {
        if { $c_label_list_len > 0 } {
            # x, y and label
            for {set i 0} {$i < $list_len} {incr i} {
                set row [list [lindex $c_x_list $i] [lindex $c_y_list $i] [lindex $c_label_list $i] ]
                lappend c_lists $row
            }
        } else {
            # x and y only
            for {set i 0} {$i < $list_len} {incr i} {
                set row [list [lindex $c_x_list $i] [lindex $c_y_list $i] ]
                lappend c_lists $row
            }
        }

    } 

    # 2. If a curve exists in curve_lists where each element is a list of x,y(,label), use it.
    set curve_lists_len [llength $curve_lists]
    if { [llength $c_lists] == 0 && $curve_lists_len > 0 } {

        # curve exists. 
        set point_len [llength [lindex $curve_lists 0] ]
        if { $point_len > 1 } {
            set c_lists $curve_lists
        }
        
    }
 
    # 3. If a minimum, median, and maximum is available, make a curve of it. 
    # or
    # 4. if an median value is available, make a curve of it, 
    #set standard_deviation 0.682689492137 
    #set std_dev_parts [expr { $standard_deviation / 4. } ]
    #set outliers [expr { 0.317310507863 / 2. } ]

    if { [llength $c_lists] == 0 && $median ne "" } {
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

        # min,med,max values available
        # Geometric median requires all three values
        
        # time_expected = ( time_optimistic + 4 * time_most_likely + time_pessimistic ) / 6.
        # per http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique

        set c_lists [acc_fin::pert_omp_to_normal_dc $minimum $median $maximum ]
    }
    
    # 5. if an ordered list of lists x,y,label exists, use it as a fallback default
    if { [llength $default_lists] > 0 && [llength [lindex $default_lists 0] ] > 1 } {
        set c_lists $default_lists
    }

    # 6. return a representation of a normalized curve as a list of lists similar to curve_lists 
    if { [llength $c_lists] == 0 } {
        # No time defaults.
        # set duration to 1 for limited block feedback.

        set tc_larr(x) [list $outliers $std_dev_parts $std_dev_parts $std_dev_parts $std_dev_parts $outliers]
        # using approximate cumulative distribution y values for standard deviation of 1.
        set tc_larr(y) [list 0.15 0.3 0.45 0.7 0.82 1.]
    }

    # Return an ordered list of lists representing a curve
    return $c_lists
}

ad_proc -public acc_fin::scenario_prettify {
    scenario_list_of_lists
    {with_factors_p 0}
} {
    Processes PRETTI scenario. Returns resulting PRETTI table as a list of lists. 
    If with_factors_p is 1, an intermediary step processes factor multiplicands 
    in dependent_tasks list, appending table with a complete list of expanded, 
    nonrepeating tasks.
} {
    set setup_start [clock seconds]
    # load scenario values
    
    # load pretti2_lol table
    
    #if { $with_factors_p } {
    #    # append p2 file, call this proc referencing p2 with_factors_p 0 before continuing.
    #    set pretti2e_lol [acc_fin::p2_factors_expand $pretti2_lol]
    #}
    # vertical represents time. All tasks are rounded up to quantized time_unit.
    # Smallest task duration is the number of quantized time_units that result in 1 line of text.
    
    # Represent multiple dependencies of same task for example 99 cartwheels using * as in 99*cartwheels
    
    # Representing task bottlenecks --limits in parallel activity of same type
    # Parallel limits represented by:
    # concurrency_limit: count of tasks of same type that can operate in parallel
    # overlap_limit: a percentage representing amount of overlap allowed.
    #                overlap_limit, in effect, creates progressions of activity
    
    # To find, repeat PRETTI scenario on tracks with CP tasks by task type, then increment by quantized time_unit (row), tracking overages
    # amount to extend CP duration: collision_count / task_type * ( row_counts / ( time_quanta per task_type_duration ) + 1 )
    
    # Since PRETTI does not schedule, don't manipulate task positioning,
    # just increase duration of CP to account for limit overages.
    
    # Multiple task requirements are represented with a number followed by asterisk.
    
    # Create a projected completion curve by stepping through the range of all the performance curves N times instead of Monte Carlo simm.
    
    
    ns_log Notice "acc_fin::scenario_prettify: start"
    #requires scenario_tid
    
    # given scenario_tid 
    # activity_table contains:
    # activity_ref predecessors time_est_short time_est_median time_est_long cost_est_low cost_est_median cost_est_high time_dist_curv_eq cost_dist_curv_eq
    set error_fail 0
    
    # get scenario into array p1_arr
    set constants_list [acc_fin::pretti_columns_list p1]
    foreach constant $constants_list {
        set p1_arr($constant) ""
    }
    set constants_required_list [acc_fin::pretti_columns_list p1 1]
    qss_tid_scalars_to_array $scenario_tid p1_arr $constants_list $constants_required_list $package_id $user_id
    if { $p1_arr(activity_table_name) ne "" } {
        # set activity_table_tid
        set p1_arr(activity_table_tid) [qss_tid_from_name $p1_arr(activity_table_name) ]
    } 
    if { $p1_arr(task_types_name) ne "" } {
        # set task_types_tid
        set p1_arr(task_types_tid) [qss_tid_from_name $p1_arr(task_types_name) ]
    } 
    if { $p1_arr(time_dist_curve_name) ne "" } {
        # set dist_curve_tid
        set p1_arr(time_dist_curve_tid) [qss_tid_from_name $p1_arr(time_dist_curve_name) ]
    }
    if { $p1_arr(cost_dist_curve_name) ne "" } {
        # set dist_curve_tid
        set p1_arr(cost_dist_curve_tid) [qss_tid_from_name $p1_arr(cost_dist_curve_name) ]
    }
    
    
    set constants_exist_p 1
    set compute_message_list [list ]
    foreach constant $constants_required_list {
        if { $p1_arr($constant) eq "" } {
            set constants_exist_p 0
            lappend compute_message_list "Initial condition constant '${constant}' is required but does not exist."
            set error_fail 1
        }
    }
    
    # Make time_curve_data This is the default unless more specific data is specified in a task list.
    # The most specific information is used for each activity.
    # Median (most likely) point is assumed along the (cumulative) distribution curve, unless
    # a time_probability_moment is specified.  time_probability_moment is only available as a general term.
    #     local curve
    #     local 3-point (min,median,max)
    #     general curve (normalized to local 1 point median ); local 1 point median is minimum time data requirement
    #     general 3-point (normalized to local median)    
    
    if { $p1_arr(time_dist_curve_tid) ne "" } {
        # get time curve into array tc_larr
        set constants_list [acc_fin::pretti_columns_list dc]
        foreach constant $constant_list {
            set tc_larr($constant) ""
        }
        set constants_required_list [acc_fin::pretti_columns_list dc 1]
        qss_tid_columns_to_array_of_lists $time_dist_curve_tid tc_larr $constants_list $constants_required_list $package_id $user_id
        #tc_larr(x), tc_larr(y) and optionally tc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n
    } 
    set tc_lists [acc_fin::curve_import $tc_larr(x) $tc_larr(y) $tc_larr(label) [list ] $p1_arr(time_est_short) $p1_arr(time_est_median) $p1_arr(time_est_long) [list ] ]
    
    # Make cost_curve_data 
    if { $p1_arr(cost_dist_curve_tid) ne "" } {
        set constants_list [acc_fin::pretti_columns_list dc]
        foreach constant $constants_list {
            set cc_larr($constant) ""
        }
        set constants_required_list [acc_fin::pretti_columns_list dc 1]
        qss_tid_columns_to_array_of_lists $cost_dist_curve_tid cc_larr $constants_list $constants_required_list $package_id $user_id
        #cc_larr(x), cc_larr(y) and optionally cc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n
        
    } 
    set cc_lists [acc_fin::curve_import $cc_larr(x) $cc_larr(y) $cc_larr(label) [list ] $p1_arr(cost_est_low) $p1_arr(cost_est_median) $p1_arr(cost_est_high) [list ] ]
    
    # curves_larr has 2 versions: time as t_c_larr and cost as c_c_larr
    set time_clarr(0) $tc_lists
    set cost_clarr(0) $cc_lists
    
    # index 0 is default
    
    # import task_types_list
    #### Use [lsearch -regexp {[a-z][0-9]} -all -inline $x_list] to screen alt debit/credit/"cost/revenue" columns and create list for custom summary feature.
    #### Use [lsearch -regexp {[a-z][0-9]s} -all -inline $x_list] to screen alt time columns and create list for a scheduling feature
    #### with parameters defined in scenario or as a separate compilation of pretti output
    
    if { $p1_arr(task_types_tid) ne "" } {
        set constants_list [acc_fin::pretti_columns_list p3]
        set constants_required_list [acc_fin::pretti_columns_list p3 1]
        acc_fin::p_load_tid $constants_list $constants_required_list p3_larr $p1_arr(task_types_tid)
    }
    # The multi-level aspect of curve data storage needs a double-pointer to be efficient for projects with large memory footprints
    # act_curve_arr($act) => curve_ref
    # type_t_curve_arr($type) => curve_ref
    # type_c_curve_arr($type) => curve_ref
    # tid_curve_arr($tid) => curve_ref
    # where curve_ref is index of curves_lol
    # where curve_ref = 0 is default
    # so, add a p2_larr(curve_ref) column which references curves_lol
    #  add a p3_larr(curve_ref) column
    
    # import activity_list
    #### Use lsearch -glob or -regexp to screen alt columns and create list for custom summary feature. [a-z][0-9]
    #### ..connected to cost_probability_moment.. so columns represent curve IDs..
    #### Use [lsearch -regexp {[a-z][0-9]s} -all -inline $x_list] to screen alt time columns and create list for a scheduling feature.
    if { $p1_arr(activity_table_tid) ne "" } {
        # load activity table
        set constants_list [acc_fin::pretti_columns_list p2]
        set constants_required_list [acc_fin::pretti_columns_list p2 1]
        acc_fin::p_load_tid $constants_list $constants_required_list p2_larr $p1_arr(activity_table_tid)
        # filter user input
        set p2_larr(activity_ref) [acc_fin::list_index_filter $p2_larr(activity_ref)]
        set p2_larr(dependent_tasks) [acc_fin::list_index_filter $p2_larr(dependent_tasks)]
    }
    
    # Substitute task_type data (p3_larr) into activity data (p2_larr) when p2_larr data is less detailed or missing.
    # Curve data has already been substituted in p_load_tid
    # Other substitutions when a p2_larr field is blank.
    #  Effectively, this is acc_fin::pretti_columns_list p2  -  acc_fin::pretti_columns_list p3, but some of p3 fields are not same such as aid_type vs type.. 
    # and p3 includes default modifiers from p1 as well.
    set constants_woc_list [list name description]
    # Removed dependent_tasks from task_type substitution, 
    # because dependent_tasks creates a level of complexity significant enough to be avoided
    # through program set-up.
    set p3_type_list $p3_larr(type)
    set p2_task_type_list $p2_larr(aid_type)
    # _woc_ = without curve data
    foreach constant $constants_woc_list {
        if { [llength $p2_larr(aid_type) ] > 0 && [llength $p3_larr($constant)] > 0 } {
            set i 0
            set p2_col_list $p2_larr($constant)
            foreach act $p2_larr(activity_ref) {
                set p2_value [lindex $p2_col_list $i]
                if { $p2_value eq "" } {
                    set ii [lsearch -exact $p3_type_list [lindex $p2_task_type_list $i]]
                    set p2_col_list [lreplace $p2_col_list $i $i [lindex $p3_larr($constant) $ii] ]
                }
                incr i
            }
            set p2_larr($constant) $p2_col_list
        }
    }
    
    # Confirm that dependencies exist as activities.
    #  Expand p2_larr to include dependent activities with coefficients.
    #  by appending new definitions of tasks that don't yet have defined coefficients.
    set activities_list $p2_larr(activity_ref)
    
    foreach dependencies_list $p2_larr(dependent_tasks) {
        foreach activity $dependencies_list {
            if { [lsearch -exact $activities_list $activity] == -1 } {
                # A dependent activity doesn't exist..
                
                set term ""
                set coefficient ""
                # Is $activity an existing activity, but referenced with a coeffient?
                if { [regexp {^([0-9]+)[\*]([^\*]+)} $activity scratch coefficient term] } {
                    
                    # If $term is a defined activity, get index
                    set term_idx [lsearch -exact $activities_list $term]
                    if { $term_idx > -1 } {
                        # Requirements met: There is a coefficient and an existing activity.
                        # Generate a new activity with coeffient for this run.                        
                        foreach constant $constants_list {
                            lappend p2_larr($constant) [lindex $p2_larr($constant) $term_idx]
                        }
                        # create new tCurves and cCurves and references to them.
                        set tcurvenum [lindex $p2_larr(_tCurveRef) $term_idx]
                        if { $tcurvenum ne "" } {
                            # create new curve based on the one referenced 
                            # parameters: max_concurrent max_overlap_pct021
                            #      max_overlap_pct  (as a percentage from 0 to 1, blank = 1)
                            #      max_concurrent       (as an integer, blank = no limit)
                            # activity curve @tcurvenum
                            # for each point t(pm) in curve time_clarr($_tCurveRef), max_overlap_pct, max_concurrent, coeffient c
                            if { [ad_var_type_check_number_p $max_overlap_pct ] && $max_overlap_pct < 2 && $max_overlap_pct > -1 } {
                                # validated
                            } else {
                                set max_overlap_pct 1.
                            }
                            # coef_p1 * max_concurrent + coef_p2 = $coefficient
                            set coef_p1 [expr { int( $coeffcient / $max_concurrent ) } ]
                            set coef_p2 [expr { $coefficient - $coef_p1 * $max_concurrent } ]
                            # coef_p2 should be at most 1 less than max_concurrent
                            # max_trailing_pct = 1. - max_overlap_pct
                            # k3 calculates length of a full block max_concurrent wide
                            set k3 [expr { 1. + ( $coef_p1 - 1 ) * ( 1. - $max_overlap_pct ) } ]
                            # k4 calculates length of partial blocks (one more activity than full block activity count, but maybe not overlapped as far)
                            set k4 [expr { 1. + ( $coef_p2 - 1 ) * ( 1. - $max_overlap_pct ) } ]
                            # Choose the longer of the two blocks:
                            set k5 [f::max [list $k3 $k4] ]
                            set curve_lol [list ]
                            foreach point $time_clarr($tcurvenum) {
                                # point: y x label
                                set y [lindex $point 0]
                                set x [lindex $point 1]
                                set label [lindex $point 2]
                                set y_new [expr { $y * $k5 } ]
                                set point_new [list $y_new $x $label]
                                lappend curve_lol $point_new
                            }
                            # save new curve
                            set tcurvenum [acc_fin::larr_set time_clarr $curve_lol]
                            # save new reference
                            lappend $p2_larr(_tCurveRef) $tcurvenum
                        } else {
                            lappend $p2_larr(_tCurveRef) ""
                        }
                        if { [lindex $p2_larr(_cCurveRef) $term_idx] ne "" } {
                            # New curve is isn't affected by overlap or max_concurrent. 
                            # New curve is simple multiplication of old and coefficient
                            # create new curve
                            set curve_lol [list ]
                            foreach point $cost_clarr($ccurvenum) {
                                # point: y x label
                                set y [lindex $point 0]
                                set x [lindex $point 1]
                                set label [lindex $point 2]
                                set y_new [expr { $y * $coefficient } ]
                                set point_new [list $y_new $x $label]
                                lappend curve_lol $point_new
                            }
                            
                            # save new curve
                            set ccurvenum [acc_fin::larr_set cost_clarr $curve_lol]
                            # save new reference
                            lappend $p2_larr(_cCurveRef) $ccurvenum
                        } else {
                            lappend $p2_larr(_cCurveRef) ""
                        }
                    } else {
                        # No activity defined for this factor (term with coefficient), flag an error --missing dependency.
                        lappend compute_message_list "Dependency '${term}' is undefined, referenced in: '${activity}'."
                        set error_fail 1
                    }
                } else {
                    # No activity defined for this factor (term with coefficient), flag an error --missing dependency.
                    lappend compute_message_list "Dependency '${activity}' is undefined as an activity."
                    set error_fail 1
                    
                }
            }
            # else, an activity for the dependency exists. Do nothing.
        }
    }

    # Multiple probability_moments allowed
    set t_moment_list [split $p1_arr(time_probability_moment)]
    set c_moment_list [split $p1_arr(cost_probability_moment)]
    # Be sure any new values are nullified between each loop
    set setup_end [clock seconds]
    set time_start [clock seconds]
    foreach t_moment $t_moment_list {
        
        # Calculate base durations for time_probability_moment. These work for activities and task types.
        array unset t_est_arr
        foreach tCurve [array names time_clarr] {
            set t_est_arr($tCurve) [qaf_y_of_x_dist_curve $t_moment $time_clarr($tCurve) ]
        }
        
        foreach c_moment $c_moment_list {
            # Calculate base costs for cost_probability_moment. These work for activities and task types.
            array unset c_est_arr
            foreach cCurve [array names cost_clarr] {
                set c_est_arr($cCurve) [qaf_y_of_x_dist_curve $c_moment $cost_clarr($cCurve) ]
            }
            # Create activity time estimate and cost estimate arrays for repeated use in main loop
            set i 0
            array unset time_expected_arr
            array unset path_dur_arr
            array unset cost_expected_arr
            array unset path_cost_arr
            array unset depnc_eq_arr
            foreach act $p2_larr(activity_ref) {
                set $act_list [list $act]
                # the first paths are single activities, subsequently time expected and duration are same values
                set tref [lindex $p2_larr(_tCurveRef) $i]
                set time_expected $t_est_arr($tref)
                set time_expected_arr($act) $time_expected
                set path_dur_arr($act_list) $time_expected
                # the first paths are single activities, subsequently cost expected and path segment costs are same values
                set cref [lindex $p2_larr(_cCurveRef) $i]
                set cost_expected $c_est_arr($cref)
                set cost_expected_arr($act) $cost_expected
                set path_cost_arr($act_list) $cost_expected
                
                incr i
            }
            
            # handy api ref
            # util_commify_number
            # format "% 8.2f" $num
            
            # PERTTI calculations
            
            # Build:
            #  activity map table:  depnc_larr($activity_ref) dependent_tasks_list
            #  array of activity_ref sequence_num: act_seq_num_arr($activity_ref) sequence_number
            # An activity_ref's sequence is one more than the max sequence_num of its dependencies
            set i 0
            set sequence_1 0
            array unset act_seq_num_arr
            array unset depnc_larr
            array unset _c
            foreach act $p2_larr(activity_ref) {
                set depnc [lindex $p2_larr(dependent_tasks) $i]
                # depnc: comma list of dependencies
                # depnc_larr() list of dependencies
                # Filter out any blanks
                set scratch_list [split $depnc ";, "]
                set scratch2_list [list ]
                foreach dep $scratch_list {
                    if { $dep ne "" } {
                        lappend scratch2_list $dep
                    }
                }
                set depnc_larr($act) $scratch2_list
                # _c($act) Answers question: Has relative sequence number for $act been calculated?
                set _c($act) 0
                # act_seq_num_arr is relative sequence number of an activity. 
                set act_seq_num_arr($act) $sequence_1
                incr i
            }
            
            # Calculate paths in the main loop to save resources.
            #  Each path is a list of numbers referenced by array, where 
            #  array indexes last path activity (of a dependency track).
            #  set path_segment_ends_in_lists($act) 
            #  so future segments can quickly reference it to build theirs.
            
            # This keeps path making nearly linear. There are as many path references as there are activities..
            
            # Since some activities depend on others, some of the references are 
            # incomplete activity tracks, but these can be filtered as needed.
            
            # All paths must be assessed in order to handle all possibilities
            # Paths are used to determine critical path and fast crawl a single path.
            
            # An activity cannot start until the longest dependent segment has completed.
            
            # For strict critical path, create a list of lists, where 
            # each list is a list of dependencies from start to finish (aka path)  + the longest duraction path of activity including dependencies.
            # sum the duration for each list. The longest duration is the strict defintion of critical path.
            
            # create dependency check equations
            # depnc_eq_arr() is equation that answers question: Are dependencies met for $act?
            foreach act $p2_larr(activity_ref) {
                set eq "1 &&"
                foreach dep $depnc_larr($act) {
                    # CODING NOTE: strings generally are okay to 100,000,000+ chars..
                    # If there are memory issues, convert eq to an eq_reference_list to calculate elements sequentially. Sort of what it does internally anyway.
                    
                    # array _c() answers question: are all dependencies calculated for activity?
                    append eq " _c($dep) &&"
                }
                # remove the last " &&":
                set eq [string range $eq 0 end-3]
                # convert _c_arr reference to a variable by adding a dollar sign prefix:
                regsub -all -- { _c} $eq { $_c} depnc_eq_arr($act)
            }
            # main process looping
            array unset act_seq_list_arr
            array unset act_count_of_seq_arr
            set all_calced_p 0
            set activity_count [llength $p2_larr(activity_ref)]
            set i 0
            set act_seq_list_arr($sequence_1) [list ]
            # act_count_of_seq_arr( sequence_number) is the count of activities at this sequence number
            set act_count_of_seq_arr($sequence_1) 0
            set path_seg_dur_list [list ]
            # act_seq_max is the current maximum path length
            array unset duration_arr
            array unset cost_arr
            array unset path_seg_list_arr
            array unset full_track_p_arr
            
            while { !$all_calced_p && $activity_count > $i } {
                set all_calcd_p 1
                foreach act $p2_larr(activity_ref) {
                    set dependencies_met_p [expr { $depnc_eq_arr($act) } ]
                    set act_seq_max $sequence_1
                    if { $dependencies_met_p && !$calcd_p_arr($act) } {
                        
                        # Calc max_num: maximum relative sequence number for activity dependencies
                        set max_num 0
                        foreach test_act $depnc_larr($act) {
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
                        set path_duration 0.
                        set paths_cost 0.
                        # set duration_new to the longest duration dependent segment.
                        # depnc_larr() is a list of direct dependencies for each activity
                        foreach dep_act $depnc_larr($act) {
                            if { $path_dur_arr($dep_act) > $path_duration } {
                                set path_duration $path_dur_arr($dep_act)
                            }
                            # Add all the costs for each dependency path
                            set paths_cost [expr { $paths_cost + $cost_expected_arr($dep_act) } ]
                        }
                        # duration_arr() is duration of track segment up to (and including) activity.
                        set duration_arr($act) [expr { $path_duration + $time_expected_arr($act) } ]
                        
                        # cost is cost of all dependent paths plus cost of this activity
                        set cost_arr($act) [expr { $paths_cost + $cost_expected_arr($act) } ]
                        
                        # path_seg_larr() is an array of partial (and perhaps complete) 
                        #   activity paths (or tracks) represented as a list of lists in chronological order (last acitivty last).
                        #   For example, if A depends on B and C, and C depends on D then:
                        #   path_seg_larr(A) == list list B A list D C A
                        # full_track_p_arr answers question: is this track complete (ie not a subset of another track)?
                        # path_seg_dur_list is a list_of_list pairs: path_list and duration. This allows the paths to be sorted to quickly determine CP.
                        set path_seg_larr($act) [list ]
                        foreach dep_act $depnc_larr($act) {
                            foreach path_list $path_seg_larr($dep_act) {
                                set path_new_list $path_list
                                # Mark which tracks are complete (not partial track segments), 
                                # so that total program cost calculations don't include duplicate, incomplete tracks that remain in path_seg_dur_list
                                set full_track_p_arr($path_list) 0
                                lappend path_new_list $act
                                set full_track_p_arr($path_new_list) 1
                                lappend path_seg_larr($act) $path_new_list
                                set pair_list [list $path_new_list $duration_arr($act)]
                                lappend path_seg_dur_list $pair_list
                            }
                        }
                        if { [llength $path_seg_larr($act)] eq 0 } {
                            lappend path_seg_larr($act) $act
                            set full_track_p_arr($act) 1
                            set pair_list [list $act $duration_arr($act)]
                            lappend path_seg_dur_list $pair_list
                        }
                    }
                    set all_calcd_p [expr { $all_calcd_p && $calcd_p_arr($act) } ]
                }
                incr i
            }
        
            set dep_met_p 1
            ns_log Notice "acc_fin::scenario_prettify: path_seg_dur_list $path_seg_dur_list"
            foreach act $p2_larr(activity_ref) {
                set $dep_met_p [expr { $depnc_eq_arr($act) && $dep_met_p } ] 
                # ns_log Notice "acc_fin::scenario_prettify: act $act act_seq_num_arr '$act_seq_num_arr($act)'"
                # ns_log Notice "acc_fin::scenario_prettify: act_seq_list_arr '$act_seq_list_arr($act_seq_num_arr($act))' $act_count_of_seq_arr($act_seq_num_arr($act))"
            }
            ns_log Notice "acc_fin::scenario_prettify: dep_met_p $dep_met_p"
            
            # remove incomplete tracks from path_seg_dur_list by placing only complete tracks in track_dur_list
            set track_dur_list [list ]
            foreach {path_list duration} $path_seg_dur_list {
                if { $full_track_p_arr($path_list) } {
                    set td_list [list $path_list $duration]
                    lappend track_dur_list $td_list
                }
            }
            
            # sort by path duration
            # critical path is the longest path. Float is the difference between CP and next longest CP.
            # create an array of paths from longest to shortest to help build base table
            set path_seg_dur_sort1_list [lsort -decreasing -real -index 1 $track_dur_list]
            # Critical Path (CP) is 
            set cp_list [lindex [lindex $path_seg_dur_sort1_list 0] 0]
            #ns_log Notice "acc_fin::scenario_prettify: path_seg_dur_sort1_list $path_seg_dur_sort1_list"
            
            # Extract most significant CP alternates for a focused table
            # by counting the number of times an act is used in the largest proportion (first half) of paths in path_set_dur_sort1_list
            
            
            
            # act_freq_in_load_cp_alts_arr   a count the number of times an activity is in a path 
            # max_act_count_per_seq          maximum number of activities in a sequence number.
            unset act_freq_in_load_cp_alts_arr
            
            set max_act_count_per_seq 0
            foreach act $p2_larr(activity_ref) {
                set act_freq_in_load_cp_alts_arr($act) 0
                if { $act_count_of_seq_arr($act) > $max_act_count_per_seq } {
                    set max_act_count_per_seq $act_count_of_seq_arr($act)
                }
            }
            foreach path_seg_list $path_seg_dur_sort1_list {
                set path2_list [lindex $path_seg_list 0]
                foreach act $path2_list {
                    incr act_freq_in_load_cp_alts_arr($act)
                }
            }
            # Make a list of the activities in the most tracks by count
            set act_sig_list [list ]
            foreach act $p2_larr(activity_ref) {
                lappend act_sig_list [list $act $act_freq_in_load_cp_alts_arr($act)]
            }
            set act_sig_sorted_list [lsort -decreasing -integer -index 1 $act_sig_list]
            set act_sig_median_pos [expr { [llength $path_seg_dur_sort1_list] / 2 } + 1 ]
            set act_max_count [lindex [lindex $act_sig_sorted_list 0] 1]
            set act_median_count [lindex [lindex $act_sig_sorted_list $act_sig_median_pos] 1]
            
            # build base table
            # Cells need this info for presentation: 
            #   activity_time_expected, time_start (path_duration - time_expected),time_finish (path_duration)
            #   activity_cost_expected, path_costs to complete activity
            #   direct dependencies
            # and some others for sorting.
            set base_lists [list ]
            set base_titles_list [acc_fin::pretti_columns_list p5 1]
            foreach {path_list duration} $path_seg_dur_sort1_list {
                set act [lindex $path_list end]
                set tree_act_cost_arr($act) $cost_arr($act)
                set has_direct_dependency_p [expr { [llength $depnc_larr($act)] > 0 } ]
                set on_critical_path_p [expr { [lsearch -exact $cp_list $act] > -1 } ]
                set on_a_sig_path_p [expr { $act_freq_in_load_cp_alts_arr($act) > $act_median_count } ]
                
                #  0 activity_ref
                #  1 activity_seq_num_arr() ie count of activities in track
                #  2 Q: Does this activity have any dependencies? ie predecessors
                #  3 Q: Is this the CP?
                #  4 Q: Is this activity referenced in more than a median number of times?
                #  5 act_freq_in_load_cp_alts  count of activity is in a path or track
                #  6 duration_arr              track duration
                #  7 activity_time_expected    time expected of this activity
                #  8 depnc_larr                direct activity dependencies
                #  9 cost_expected_arr         cost to complete activity
                # 10 cost_arr                  cost to complete path (including all path dependents)
                
                set activity_list [list $act $act_seq_num_arr($act) $has_direct_dependency_p $on_critical_path_p $on_a_sig_path_p $act_freq_in_load_cp_alts_arr($act) $duration_arr($act) $time_expected_arr($act) $depnc_larr($act) $cost_expected_arr($act) $cost_arr($act) ]
                lappend base_lists $activity_list
            }
            
            ns_log Notice "acc_fin::scenario_prettify: base_lists $base_lists"
            
            # sort by: act_seq_num_arr descending
            set fourth_sort_lists [lsort -decreasing -real -index 1 $base_lists]
            # sort by: Q. has_direct_dependency_p? descending (1 = true, 0 false)
            set third_sort_lists [lsort -decreasing -integer -index 2 $fourth_sort_lists]
            # sort by: Q. on part_of_critical_path_p? descending
            set second_sort_lists [lsort -decreasing -integer -index 3 $third_sort_lists]
            
            # critical path is the longest expected duration of dependent activities, so final sort:
            # sort by path duration descending
            set primary_sort_lists [lsort -increasing -integer -index 6 $second_sort_lists]
            ns_log Notice "acc_fin::scenario_prettify: primary_sort_lists $primary_sort_lists"
            
            # *_at_pm means at probability moment
            set cp_duration_at_pm [lindex [lindex $primary_sort_lists 0] 1]
            # calculate cp_cost_at_pm
            set cp_cost_at_pm 0.
            foreach {act tree_cost} [array get tree_act_cost_arr] {
                set cp_cost_at_pm [expr { $cp_cost_at_pm + $tree_cost } ]
            }
            set scenario_stats_list [qss_table_stats $scenario_tid]
            set scenario_name [lindex $scenario_stats_list 0]
            if { [llength $t_moment_list ] > 1 } {
                set t_moment_len_list [list ]
                foreach moment $t_moment_list {
                    lappend t_moment_len_list [string length $moment]
                }
                set t_moment_format "%1.f"
                append t_moment_format [expr { [f::max $t_moment_len_list] - 2 } ]
                lappend " t=[format ${t_moment_format} ${t_moment}]"
            }
            if { [llength $c_moment_list ] > 1 } {
                set c_moment_len_list [list ]
                foreach moment $c_moment_list {
                    lappend c_moment_len_list [string length $moment]
                }
                set c_moment_format "%1.f"
                append c_moment_format [expr { [f::max $t_moment_len_list] - 2 } ]
                lappend " c=[format ${c_moment_format} ${c_moment}]"
            }
            set scenario_title [lindex $scenario_stats_list 1]
            
            set time_end [clock seconds]
            set time_diff_secs [expr { $time_end - $time_start } ]
            set setup_diff_secs [expr { $setup_end - $setup_start } ]
            # the_time Time calculation completed
            set p1_arr(the_time) [clock format [clock seconds] -format "%Y %b %d %H:%M:%S"]
            # comments should include cp_duration_at_pm, cp_cost_at_pm, max_act_count_per_track 
            # time_probability_moment, cost_probability_moment, 
            # scenario_name, processing_time, time/date finished processing
            set comments "Scenario report for ${scenario_title}: "
            append comments "scenario_name ${scenario_name} , cp_duration_at_pm ${cp_duration_at_pm} , cp_cost_at_pm ${cp_cost_at_pm} ,"
            append comments "max_act_count_per_track ${act_max_count} , time_probability_moment ${t_moment} , cost_probability_moment ${c_moment} ,"
            append comments "setup_time ${setup_diff_secs} , main_processing_time ${time_diff_secs} seconds , time/date finished processing $p1_larr(the_time) "
            
            
            if { $p1_larr(db_format) ne "" } {
                # Add titles before saving as p5 table
                set primary_sort_lists [lreplace $primary_sort_lists 0 0 $base_titles_list]
                qss_table_create $primary_sort_lists "${scenario_name}.p5" "${scenario_title}.p5" $comments "" p5 $package_id $user_id
            }
            
            # save as a new table of type PRETTI 
            append comments "contrast_mask_idx 1 , colorswap_p 0"
            
            # max activity account per track = $act_max_count
            # whereas
            # each PRETTI table uses standard delimited text file format.
            # Need to convert into rows ie.. transpose rows of each column to a track with column names: track_(1..N). track_1 is CP
            # trac_1 track_2 track_3 ... track_N
            
            set pretti_lists [list ]
            set title_row_list [list ]
            set track_num 1
            foreach track_list $primary_sort_lists {
                # each primary_sort_lists is a track:
                # activity_ref  is the last activity_ref in the track
                set activity_ref [lindex $track_list 0]
                # activity_seq_num 
                # dependencies_q cp_q significant_q popularity waypoint_duration activity_time 
                # direct_dependencies activity_cost waypoint_cost
                
                # path_seg_larr($act) is a list of activities in track, from left to right, right being last, referenced by last activity.
                set track_activity_list $path_seg_larr($activity_ref)
                set track_name "track_${track_num}"
                lappend title_row_list $track_name
                # in PRETTI table, each track is a column, so each row is built from each column, each column lappends each row..
                # store each row in: row_larr()
                for {set i 0} {$i < $act_max_count} {incr i} {
                    set row_larr($i) [list ]
                }
                for {set i 0} {$i < $act_max_count} {incr i} {
                    set activity [lindex $track_activity_list $i]
                    if { $activity ne "" } {
                        # cell should contain this info: "$act t:${time_expected} T:${path_duration} D:${dependencies} "
                        set cell "$activity "
                        append cell "t:[lindex $track_list 7] "
                        append cell "ts:[lindex $track_list 6] "
                        append cell "c:[lindex $track_list 9] "
                        append cell "cs:[lindex $track_list 10] "
                        append cell "d:($depnc_larr(${activity})) "
                        append cell "<!-- [lindex $track_list 4] [lindex $track_list 5] --> "
                        lappend row_larr($i) $cell
                    } else {
                        lappend row_larr($i) ""
                    }
                }
                incr track_num
            }
            # combine the rows
            lappend pretti_lists $title_row_list
            for {set i 0} {$i < $act_max_count} {incr i} {
                lappend pretti_lists $row_larr($i)
            }
            qss_table_create $primary_sort_lists ${scenario_name} ${scenario_title} $comments "" p4 $package_id $user_id
            # Comments data will be interpreted for determining standard deviation for determining cell highlighting
        }
        # next c_moment
    }
    # next t_moment
    
    return 1
}


