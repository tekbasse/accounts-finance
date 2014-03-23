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
    Assumes y_x_lol is an ordered list of y-x list representing a curve. Set interpolate_p to 1
    to interpolate when p is between two discrete points that represent a continuous curve.
}  {
    set p [expr { $p + 0. } ]

    set count_max [llength $y_x_pair_list]
    set i 0
    set p_test 0.
    # normalize x to 1.
    set x_list [list ]
    foreach y_x $y_x_list {
        lappend x_list [lindex $y_x 1]
    }
    set x_sum [f::sum $x_list]
    # normalize p to range of x
    set p_normalized [expr { $p * $x_sum } ]
    # determine y @ x
    while { $i < $count_max && $p_test < $p_normalized} {
        set row_list [lindex $y_x_list $i]
        set x [lindex $row_list 1]
        set p_test [expr { $x + $p_test + 0. } ]
        incr i
    }
    if { $interpolate_p } {
        set x2 $x
        set y2 [expr { [lindex $row_list 0] + 0. } ]
        incr i -1
        set row_prev_list [lindex $y_x_list $i]
        set x1 [expr { [lindex $row_prev_list 1] + 0. } ]
        set y1 [expr { [lindex $row_prev_list 0] + 0. } ]
        set y [expr { ( $y2 - $y1 ) * ( $p_normalized - $x1 ) / ( $x2 - $x1) + $y1 } ]
    } else {
        set y [expr { [lindex $row_list 0] + 0. } ]
    }

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