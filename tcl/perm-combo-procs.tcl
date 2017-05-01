ad_library {

    routines used in permutations and combinations
    @creation-date 6 Sep 2014
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public acc_fin::frombase {
    base
    number
} {
    Returns number a base n whole number into decimal, where n < 36.
} {
    set error_p 0
    # original by Richard Suchenwirth 2002-07-07 retrieved from http://wiki.tcl.tk/3662 on 2014-09-09
    # In the Tcl chatroom, Michael Schlenker reported:
    # set negative [expr {$number != [set number [expr {abs($number)}]]}]
    # is about five times faster if negative, and a bit faster if positive
    # than
    # set negative [regexp ^-(.+) $number -> number]
    set negative [expr { $number != [set number [expr { abs( $number ) } ] ] } ]
    set digits "0123456789abcdefghijklmnopqrstuvwxyz"
    set res 0
    foreach digit [split $number ""] {
        set decimal_value [string first $digit $digits]
        if { $decimal_value > -1 && $decimal_value < $base } {
            set res [expr { $res * $base + $decimal_value } ]
        } else {
            set error_p 1
            ns_log Notice "acc_fin::frombase.29: bad digit ${decimal_value} for base ${base}"
        }
    }
    if { $negative } { 
        set res -$res 
    }
    if { !$error_p } {
        return $res
    } else {
        return ""
    }
}


ad_proc -public acc_fin::base {
    base
    number
} {
    Returns number in base of $base
} {
    # original by Richard Suchenwirth 2002-07-07 retrieved from http://wiki.tcl.tk/3662 on 2014-09-09
    # In the Tcl chatroom, Michael Schlenker reported:
    # set negative [expr {$number != [set number [expr {abs($number)}]]}]
    # is about five times faster if negative, and a bit faster if positive
    # than
    # set negative [regexp ^-(.+) $number -> number]
    set negative [expr { $number != [set number [expr { abs( $number ) } ] ] } ]
    set digits "0123456789abcdefghijklmnopqrstuvwxyz"
    set res ""
    set base [expr { int( round( $base ) ) } ]
    set number [expr { int( round( $number ) ) } ]
    set i 0
    while { $number && $i < 36 } {
        set digit [expr {$number % $base} ]
        set res "[string range $digits $digit $digit]$res"
        set number [expr {$number / $base} ]
        incr i
    }
    if { $negative } { 
        set res -$res
    }
    return $res
}

ad_proc -public acc_fin::convert_number {
    number
    base_from
    base_to
} {
    Converts a number of most any base upto 36 to any other base upto 36.
} {
    # inspired from Michael A. Cleverly's proc convert_number at http://wiki.tcl.tk/1067 retrieved 2014-09-19
    return [acc_fin::base $base_to [acc_fin::frombase $base_from $number]]
}
