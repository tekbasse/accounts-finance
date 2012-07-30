ad_library {

    math routines used for modeling etc
    @creation-date 25 May 2012
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public interpolatep1p2_at_x {
    p1_x
    P1_y
    p2_x
    p2_y
    p3_x
} {
    returns y value of third point (p3), given cartesion points p1(x,y), p2(x,y)
} {
    # interpolate, y=mx+b, slope = Dy/Dx = m, b = y axis intercept
    if { $p2_x != $p1_x } {
        set m [expr { ($p2_y - $p1_y) / ($p2_x - $p1_x) }]
        if { $p2_x != 0 } {
            set b [expr { $p2_y / ( $m * $p2_x ) } ]
        } else { $p1_y != 0 } {
            set b [expr { $p1_y / ( $m * $p1_x ) } ]
        }
        set p3_y [expr { ( $m * $p3_x ) + $b } ]
    } else {
        # vertical line. 
        set p3_y ""
    }
    return $p3_y
}
 