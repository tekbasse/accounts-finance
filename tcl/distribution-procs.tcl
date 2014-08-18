ad_library {

    distribution based routines used for statistics, modeling etc
    @creation-date 23 May 2012
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public qaf_distribution_normalize {
    distribution_lol
    {x_p "1"}
    {y_p "0"}
} {
    Normalizes x to 1, or y to 1, or if both x_p and y_p are 1, the area under curve to 1. distribution_lol is a list of lists of x y.
} {
    if { $x_p ne "0" } {
        set x_p 1
    }
    if { $y_p ne "1" } {
        set y_p 0
    }
    if { $x_p ||$y_p } {
        set d_new_lol [list ]
        if { $x_p } {
            # normalize x to 1
            set x_list [list ]
            foreach row $distribution_lol {
                lappend x_list [lindex $row 0]
                
            }
            set denom [f::sum $x_list ]
            foreach row $distribution_lol {
                set row2_list [list [expr { [lindex $row 0] / ( 1. * $denom ) } ] [lindex $row 1]]
                lappend d_new_lol $row2_list
            }
        } elseif { $y_p } {
            # normalize y to 1
            set y_list [list ]
            foreach row $distribution_lol {
                lappend y_list [lindex $row 1]
            }
            set denom [f::sum $y_list ]
            foreach row $distribution_lol {
                row2_list [list [lindex $row 0] [expr { [lindex $row 1] / ( 1. * $denom ) } ]]
                lappend d_new_lol $row2_list
            }
        }
        if { $x_p && $y_p } {
            # x has been normalized to 1, now adjust y so that area under curve is 1
            # assumes area with each point is x * y
            set xy_list [list ]
            foreach row $d_new_lol {
                lappend xy_list [expr { 1. * [lindex $row 0] * [lindex $row 1] } ]
            }
            set denom [expr { 1. * [f::sum $xy_list ] } ]
            set d2_new_lol [list ]
            foreach row $d_new_lol {
                set row3_list [list [lindex $row 0] [expr { [lindex $row 1] / $denom } ] ]
                lappend d2_new_lol $row3_list 
            }
        } else {
            set d2_new_lol $d_new_lol
        }
    
    } else {
        set d2_new_lol $distribution_lol
    }
    return $d2_new_lol
}


ad_proc -public qaf_y_of_x_dist_curve {
    p
    y_x_lol
    {interpolate_p 0}
} {
    returns y where p is in the range of x ie y(p,x).  Where p is some probability between 0 and 1. 
    Assumes y_x_lol is an ordered list of lists representing a curve. Set interpolate_p to 1
    to interpolate when p is between two discrete points that represent a continuous curve. if first row contains labels x and y as labels, 
    these positions will be used to extract data from remaining rows. a pair y,x is assumed
}  {
    #ns_log Notice "qaf_y_of_x_dist_curve.82: *****************************************************************" 
    ns_log Notice "qaf_y_of_x_dist_curve.83: p $p interpolate_p $interpolate_p "
    set p [expr { $p + 0. } ]
    set first_row_list [lindex $y_x_lol 0]
    set x_idx [lsearch -exact $first_row_list "x"]
    set y_idx [lsearch -exact $first_row_list "y"]
    if { $y_idx == -1 || $x_idx == -1 } {
        set x_idx 1
        set y_idx 0
        set data_row_1 0
    } else {
        set data_row_1 1
    }

    # normalize x to 1.. first extract x list
    set x_list [list ]
    foreach y_x [lrange $y_x_lol $data_row_1 end] {
        lappend x_list [lindex $y_x $x_idx]
    }
    #ns_log Notice "qaf_y_of_x_dist_curve.102: y_x_lol length [llength $y_x_lol] y_x_lol $y_x_lol " 
    ns_log Notice "qaf_y_of_x_dist_curve.103: x_list length [llength $x_list] x_list $x_list"
    set x_sum [f::sum $x_list]
    set x_len [llength $x_list]
    set loop_limit [expr { $x_len + 1 } ]
    # normalize p to range of x
    set p_normalized [expr { $p * $x_sum * 1. } ]

    #ns_log Notice "qaf_y_of_x_dist_curve.104: x_sum '$x_sum' p '$p' p_normalized '$p_normalized' y_idx '$y_idx' x_idx '$x_idx' data_row_1 '$data_row_1'"
    # determine y @ x

    set i 0
    set p_idx $i
    set p_test 0.
    while { $p_test < $p_normalized && $i < $loop_limit } {
        set x [lindex $x_list $i]
    #    ns_log Notice "qaf_y_of_x_dist_curve.117: i '$i' x '$x' p_test '$p_test'"
        if { $x ne "" } {
            set p_test [expr { $p_test + $x } ]
            set p_idx $i
        }
        incr i
    }
    # $p_idx is the index point in x_list where p is in the range of p_idx
    set y_x_i [expr { $data_row_1 + $p_idx } ]
    set row_list [lindex $y_x_lol $y_x_i]
    #ns_log Notice "qaf_y_of_x_dist_curve.120: i $i p_test $p_test x '$x' row_list '$row_list' y_x_i '$y_x_i'"
    if { $interpolate_p && $p_test != $p_normalized } {
        # point(i) is p(x2,y2)
        set x2 [lindex $row_list $x_idx]
        set y2 [lindex $row_list $y_idx]
        # point(i-1) is p(x1,y1)
        set y_x_i_1 [expr { $y_x_i - 1 } ]
        set row_list [lindex $y_x_lol $y_x_i_1]
        set x1 [lindex $row_list $x_idx]
        set y1 [lindex $row_list $y_idx]
        set y [qal_interpolatep1p2_at_x $x1 $y1 $x2 $y2 $p_normalized 1]

    } else {
        set y [lindex $row_list $y_idx]
        if { $y ne "" } {
            set y [expr { $y + 0. } ]
        }
    }

    #ns_log Notice "qaf_y_of_x_dist_curve.141: y $y"
    return $y
}

ad_proc -public qaf_distribution_points_create {
    distribution_p_list
    {number_of_points ""}
    {min_sum_of_outputs ""}
    {interpolate_rightmost_p "0"}
    {y_col "0"}
    {x_col "1"}
} {
    Given a distribution curve represented as a discrete, ordered set of value- probability pairs (y,x) in a list, for example: { {1 .5} { 3 .3} { 6 .1} { 12 .06} { 250 .04} }. Any extra columns are ignored. Rightmost (last) entry is highest y value; Intervals are not assumed to be equal. The sum of the probabilities should equal 1.  Returns a list of a random set of the discrete numbers that approximate the distribution.  (FUTURE IMPLEMENTATIONs: To accomodate a varying rightmost discrete number which represents a wide range of perhaps infrequent numbers, set interpolate_rightmost_p to 1 use interpolation on the rightmost discrete number.  If the discrete numbers represent a curve, set interpolate_p to 1.)
} {
    set amount_p [expr { [string length $min_sum_of_outputs] > 0 } ]
    set count_p [expr { [string length $number_of_points] > 0 } ]
        
    # count_max is the number of discrete numbers
    set count_max [llength $distribution_p_list]
    set curve_error 0
    # build support arrays
    set area(-1) 0
    set count 0
    set total_pct 0
#ns_log Notice "qaf_distribution_points_create: y_col '$y_col' x_col '$x_col'"
#ns_log Notice "qaf_distribution_points_create: distribution_p_list $distribution_p_list"
    foreach row $distribution_p_list {
        set yvalue [lindex $row $y_col]
        set frequency [lindex $row $x_col]
        # p_val(index) discrete values
        set p_val($count) $yvalue
        # area(index) is the area under the distribution curve to the left of the sale amt
#ns_log Notice "qaf_distribution_points_create: yvalue '$yvalue' frequency '$frequency'"
        # total_pct adds all the rcp amounts to confirm it is 100%
        # frequency must be a number
        if { [ad_var_type_check_number_p $frequency] } {
#            ns_log Notice "qaf_distribution_points_create: frequency $frequency"
            set area($count) [expr { $area([expr { $count - 1 } ]) + $frequency } ] 
            set total_pct [expr { $total_pct + $frequency } ]
        } else {
            set curve_error 1
        }
        incr count
    }
    if { $total_pct != 1. } {
        # distribution is not 100% represented
        # recalculate distribution to 100% representation
        # ie. divide each frequency by the total
#ns_log Notice "qaf_distribution_points_create: distribution_p_list $distribution_p_list"
        set area(-1) 0
        set count 0
        set total_check 0.
        foreach row $distribution_p_list {
            set yvalue [lindex $row $y_col]
            set frequency [lindex $row $x_col]
            if { [ad_var_type_check_number_p $frequency] } {
                set area($count) [expr { $area([expr { $count - 1 } ]) + ( $frequency / $total_pct ) } ]
                set total_check [expr { $total_check + $frequency } ]
            }
            incr count
        }
        if { $total_check != 1. } {
            ns_log Warning "qaf_distribution_points_create: unable to represent distribution equal to 1. total_check = ${total_check}"
        }
        set total_pct $total_check
    }
        
    # initial set conditions
    set data_sum 0.
    set point_count 0
    set data_list [list ]

    if { $total_pct != 0 } {
        # every case assumes to reach target
        while { ( $amount_p && ( $data_sum < $min_sum_of_outputs ) ) || ( $count_p && ($point_count < $number_of_points ) ) } {
            
            set point_seed [random ]
            set count 0
            # We have area under a normalized curve, let's find interval 
            while { $point_seed > $area($count) } {
            incr count
            }
            
            if { $count > $count_max } {
                ns_log Warning "qaf_distribution_points_create: Count is right of rightmost discrete point. count $count count_max ${count_max} point_seed $point_seed"
                set p_y $p_val($count_max)
            } else {
                set p_y $p_val($count)
            }
            
            incr point_count
            lappend data_list $p_y
            set data_sum [expr { $data_sum + $p_y } ]
        }
    }
    return $data_list
}

ad_proc -public qaf_discrete_dist_report {
    population_list
} {
    Given a list of numbers, returns a paired list of discrete numbers and their frequency (as a decimal)
} {
    # make a probability distribution table
    set pcount [llength $population_list]
    
    foreach pnumber $population_list {
        if { [string length $pnumber] == 0 } {
            #ignore
            incr pcount -1
        } else {
            if { [info exists pop_array($pnumber) ] } {
                incr pop_array($pnumber)
            } else {
                set pop_array($pnumber) 1
            }
        }
    }
    set frequencies_tot 0.
    foreach {discrete_nbr count} [array get pop_array] {
        set frequency [expr { $count / ( $pcount * 1.) } ]
        set disc_array(${discrete_nbr}) $frequency
        set frequencies_tot [expr { $frequencies_tot + $frequency } ]
    }
    if { $frequencies_tot != 1. } {
        ns_log Warning "qaf_discrete_dist_report: Total of frequencies does not equal 1, but: ${frequencies_tot}"
    }
    set discrete_list [array names disc_array]
    ns_log Notice "qaf_discrete_dist_report: discrete_list: $discrete_list"
    set discrete_ord_list [lsort -real $discrete_list]
    if { [catch { lsort -real $discrete_list } result] }  {
        # there was an error
        ns_log Notice "qaf_discrete_dist_report: discrete numbers contains non-real numbers."
        set discrete_ord_list [lsort $discrete_list]
    } else {
        set discrete_ord_list $result
    }
    set distribution_list [list ]
    foreach arr_name $discrete_ord_list {
        lappend distribution_list $arr_name $disc_array($arr_name)
    }

    return $distribution_list
}

ad_proc -public qaf_left_area_at_x_probability_density_curve {
    {n_points "24"}
} {
    Returns a the approximate area at x, where total area = 1; 
    Anything beyond 2 standard deviations is at limit p= 0 or p= 1.
} {
    # remember the curve for future calls, to save having to build the curve each time, if this is buried in a loop etc.
    # the base curve is "standard normal distribution" per http://en.wikipedia.org/wiki/Normal_distribution#Standard_normal_distribution
    upvar 1 __probability_dc_larr pdc_larr
    
    # eps = 2.22044604925e-016 = Smallest number such that 1+eps != 1  from: http://wiki.tcl.tk/15256
    set eps 2.22044604925e-016
    #set pi 3.14159265358979
    set pi [expr { atan2( 0. , -1. ) } ]
    #set e 2.718281828459  see exp()
    set sqrt_2pi [expr { sqrt( 2. * $pi ) } ]
    set sqrt_2 [expr { sqrt( 2. ) } ]

    set pdc_larr_exists_p [array exists pdc_larr]
    set pdc_lists_len 0
    set half_n_points [expr { int( $n_points / 2. ) } ]
    if { [expr { $n_points / 2. } ] == $half_n_points } {
        # npoints are even. Median is an important central point.
        # Since there is an even number of points, add one
        incr $n_points
    }

    if { $pdc_larr_exists_p } {
        set pdc_lists_exists_p [info exists pdc_larr(${n_points}) ]
        if { $pdc_lists_exists_p } {
            set pdc_lists_len [llength $pdc_larr(${n_points}) ]
        }
    }
    if { $pdc_lists_len < $n_points } {
        # build or re-build list
        # x = deviation from normal. mean = 0, standard deviation = 1, where pow( std_dev, 2.) = variance, sigma = standard deviation
        #     http://en.wikipedia.org/wiki/Probability_density_function
        # p = 
        # y = f(x) = exp( -0.5 * pow( $x , 2.) ) ) / $sqrt_2pi
        # a = area left of x intersect
        # Since standard deviation = 1 and this curve starts at -2 sigma to 2 sigma:
        # A tail has half_n_points over a range of 2.
        set x_step [f::max $eps [expr { 2. / $half_n_points } ]]

        # Since left and right tail are symmetric, build one tail, alter to get other side
        set tail_point_count [expr { round( $n_points / 2. ) } ]
        set x_prev 0.
        set y_at_median [expr { exp( -0.5 * pow( ( 0. , 2. ) ) ) / $sqrt_2pi } ]
        set y_prev $y_at_median
        # First step is a half step to calc y in middle of each segment.
        set tail_a_from_median [expr { $y_prev * $x_step / 2. } ]
        set tail_x_list [list $x_prev]
        set tail_y_list [list $y_prev]
        set tail_delta_a_list [list 0.]
        set tail_a_from_median_list [list $tail_a_from_median]

        # make a base tail starting at median and extending outward
        for {set x [expr { 0. + $x_step } ] } {$x <= 2. } { set x [expr { $x + $x_step } ] } {
            set y [expr { exp( -0.5 * pow( ( $x , 2. ) ) ) / $sqrt_2pi } ]
            set a_delta [f::max $eps [expr { $x_step * $y } ] ]
            set tail_a_from_median [expr { $tail_a_from_median + $a_delta } ]
            append tail_x_list $x            
            append tail_y_list $y
            append tail_delta_a_list $a_delta
            append tail_a_from_median_list $a_from_median
        }

        # build curve from two tails.

        # left tail, a = 0 to 0.5 (or whatever $a_from_median is), standard deviation= -2 to 0
        # add any missing tail to the left tail end (minimum point)
        set a_prev [expr { 0.5 - $a_from_median } ]
        # math check
        if { $a_prev < 0. } {
            ns_log Warning "qaf_left_area_at_x_probability_density_curve.357: tail area exceeds 0.5. This shouldn't happen."
        }

        # for purposes of qaf DCs, x_dev is y, standard f(x) = 7 is used to calculate area
        # Therefore titles do not match variables used with standard equation.

        set title_row [list y f_of_x x a]
        # was
        #set title_row [list x_dev y x a]

        set pdc_lists [list ]
        lappend pdc_lists $title_row

        set tail_end [llength $tail_x_list]
        incr tail_end -1
        set area2_left $a_prev
        for { set i $tail_end } { $i > 0 } { incr i -1 } {
            # x_dev = deviation from median on x.
            set x_dev [expr { -1. * [lindex $tail_x_list $i] } ]
            set y [lindex $tail_y_list $i]
            set x [lindex $tail_delta_a_list $i]
            set area2left [expr { $area2left + $x } ]
            set curve_row [list $x_dev $y $x $a]
            lappend pdc_lists $curve_row
        }

        # build the middle point
        set median_x_dev 0.
        set y $y_at_median
        set x [f::max $eps [expr { $x_step * $y } ]]
        set area2left [expr { $area2left + $x } ]
        set curve_row [list $x_dev $y $x $a ]
        lappend pdc_lists $curve_row

        # build right tail

        for { set i 0 } { $i < $tail_end } { incr i } {
            # x_dev = deviation from median on x.
            set x_dev [lindex $tail_x_list $i]
            set y [lindex $tail_y_list $i]
            set x [lindex $tail_delta_a_list $i]
            set area2left [expr { $area2left + $x } ]
            set curve_row [list $x_dev $y $x $a]
            lappend pdc_lists $curve_row
        }
        
        # build the last, rightmost point
        set x_dev [lindex $tail_x_list $tail_end]
        set y [lindex $tail_y_list $tail_end]
        #set x [lindex $tail_delta_a_list $tail_end]
        set x [f::max $eps [expr { 1.0 - $area2left } ]]
        #set area2left [expr { $area2left + $x } ]
        # increase tail area to normalize area under curve at 1
        set area2left 1.0 
        set curve_row [list $x_dev $y $x $a]
        lappend pdc_lists $curve_row

        set pdc_larr(${n_points}) $pdc_lists
    }
    return tbd
}
