ad_library {

    general procs with utility elsewhere and first used and thus defined in this package.
    @creation-date 8 August 2014
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public acc_fin::gray_from_color {
    hexcolor
} {
    Converts an html color into it's grey with similar contrast.
} {
    # add brightnesses
    set error_p 0
    if { [string range $hexcolor 0 0] eq "#" } {
        set hexcolor [string range $hexcolor 1 end]
    }
    set hex_list [split $hexcolor ""]
    set dec_list [list ]
    set hexnum_list [list 0 1 2 3 4 5 6 7 8 9 a b c d e f]
    foreach hex_dig $hex_list {
        lappend dec_list [lsearch -exact $hexnum_list $hex_dig]
    }
    set dec_sum 0
    set dec_list_len [llength $dec_list ]
    if { $dec_list_len == 6 } {
        foreach {exp1 exp0} $dec_list {
            set dec_sum [expr { $dec_sum + $exp1 * 16 + $exp0 } ]
        }
    } elseif { $dec_list_len == 3 } {
        foreach exp1 $dec_list {
            set dec_sum [expr { $dec_sum + $exp1 * 16 } ]
        }
    } else {
        # don't understand. Return average grey
        set dec_sum 381
    }

    set dec_avg [expr { round( $dec_sum / 3. ) }]
    set dec1 [expr { int( $dec_avg / 16. ) } ]
    set hex1 [lindex $hexnum_list $dec1 ]
    set dec0 [expr { $dec_avg - $dec1 * 16 } ]
    set hex0 [lindex $hexnum_list $dec0 ]
    set hexgrey "${hex1}${hex0}${hex1}${hex0}${hex1}${hex0}"

    return $hexgrey
}