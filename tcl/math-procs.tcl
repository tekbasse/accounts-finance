ad_library {

    math routines used for modeling etc
    @creation-date 25 May 2012
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public qaf_interp_line_p1p2_at_x {
    p1_x
    p1_y
    p2_x
    p2_y
    p3_x
    {avg_p "0"}
} {
    Returns y value of third point (p3), given cartesion points p1(x,y), p2(x,y). if avg_p == 1, returns the average of p1_y and p2_y instead of returning an empty string. 
    The average is useful for some point interpretations.
} {
    # interpolate, y=mx+b, slope = Dy/Dx = m, b = y axis intercept
    if { $p2_x != $p1_x } {
        # Classic math way:
        set m [expr { ( $p2_y - $p1_y ) / ( $p2_x - $p1_x ) } ]
        if { $p2_x != 0. } {
            set b [expr { $p2_y / ( $m * $p2_x ) } ]
        } elseif { $p1_y != 0. } {
            set b [expr { $p1_y / ( $m * $p1_x ) } ]
        }
        set p3_y [expr { ( $m * $p3_x ) + $b } ]
        # This might work, but haven't completely tested.. would be faster if it does.
        #        set delta_x31_pct [expr { ( $p3_x - $p1_x ) / ( $p2_x - $p1_x ) } ]
        #        set p3_y [expr { $delta_x31_pct * ( $p2_y - $p1_y ) } ]
    } else {
        # vertical line. 
        if { $avg_p } {
            set p3_y [expr { ( $p1_y + $p2_y ) / 2. } ]
        } else {
            set p3_y ""
        }
    }

    return $p3_y
}

ad_proc -public qaf_interpolatep1p2_at_x {
    p1_x
    p1_y
    p2_x
    p2_y
    p3_x
} {
    Returns y value of third point (p3) assuming p2_x > p1_y and p3_x is between p1_x and p2_x.
} {
    set x_diff [expr { $p2_x - $p1_x } ]

    if { $x_diff == 0 } {
        set p3_y $p1_y
    } else {
        set y_diff [expr { $p2_y - $p1_y } ]
        set x3_diff [expr { $p3_x - $p1_x } ]
        set x_pct_diff [expr { $x3_diff / $x_diff } ]
        set p3_y [expr { $x_pct_diff * $y_diff + $p1_y } ]
    }
    return $p3_y
}

ad_proc -public qaf_round_to_decimals {
    number
    {exponent "0"}
} {
    Rounds a number to n decimal places.
} {
    set magnitude [expr { pow( 10. , $exponent ) } ] 
    set rounded [expr { round( $number * $magnitude ) / $magnitude } ]
    return $rounded
}

ad_proc -public qaf_round_to_precision {
    number
    {precision "1"}
} {
    Rounds a number to a precision value. This is handy especially for exact monetary change when the smallest unit is not decimal, 0.05 for example.
} {
    # copy of dt_round_to_precision from acs-datetime
    return [expr { $precision * round( double($number) / $precision ) } ]
}
