ad_library {

    number-progression based routines 
    @creation-date 26 May 2012
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public qaf_triangular_numbers {
    number_of_points
} {
    Creates a progression of triangular numbers (see http://en.wikipedia.org/wiki/Triangular_number ) as a list.
} {
# code
    set triangle_list [list ]
    if { $number_of_points > 0 } {
        set triangle_number 0
        for {set i 0} { $i < $number_of_points } { incr i } {
            set count [expr { $i + 1 } ]
            set triangle_number [expr { $triangle_number + $count } ]
            lappend triangle_list $triangle_number
        }
    }
    return $triangle_list
}


ad_proc -public qaf_harmonic_terms {
    number_of_points
} {
   Creates a progression of Harmonic series terms as decimal values defined as 1 + 1/2 + 1/3 + 1/4 + .. + 1/n. ( See http://en.wikipedia.org/wiki/Harmonic_series_%28mathematics%29 )
} {
  # code
    set harmonic_list [list ]
    if { $number_of_points > 0 } {
        for {set i 0} { $i < $number_of_points } { incr i } {
            set denominator [expr { $i + 1 } ]
            set harmonic_number [expr { 1. / $denominator } ]
            lappend harmonic_list $harmonic_number
        }
    } 
    ns_log Notice "qaf_harmonic_terms: len of list [llength $harmonic_list] harmonic_list $harmonic_list"
    return $harmonic_list
}
