ad_library {

    filter routines used for statistical smoothing of data etc
    @creation-date 1 Jan 2014
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public acc_fin::smoothing_filter {
    filter_list
    data_list
} {
    Returns the data_list as a list of numbers smoothed by geometric averaging of n-terms in sequence.. For example, if filter_list contains 1 2 4, then for each data list item, the nth term will be recalculated using the geometric average of 4*nth term + 2 * (n-1) term + 1 * (n - 2). The first n-1 terms will have partial averaging, since the filter cannot extend before the first term.  
} {
    
    # make some procs that generate N term filters ie number series lists.
    # binary expansion:       (1-x)(1-2*x) ?                                                                                                         
    # Fibonacci                                                                                                                                      
    # power of 2 expans.               10^a(n)+1                                                                                                     
    # 100*e/(x+1))  round(271.8/(x+1))                                                                                                               
    # or term_count / ( x + 1/term_count )                                                                                                           
    set invese_p2_list [list 1 1 1 1 2 2 2 3 4 6 11 144]
    # Graph vs. actual data. and check best fit...                                                                                                   
    set inverse_prop_list [list 272 136 91 68 54 45 39 34 30 27 25 23 21 19 18 17 16 ]
    set inverse_p_rev_list [list 16 17 18 19 21 23 25 27 30 34 39 45 54 68 91 136 272 ]
    set binary_expan_list [list 1 1 2 4 8 16 32 64 128 256 512 1024 2048]
    set fibonnacci_list [list 1 1 2 3 5 8 13 21 34 55 89 144 ]
    set sums_of_all_previous_list [list 1 2 3 6 12 24 48 96 192 384 768 1536 ]

    return filtered_data_list
}
 
ad_proc -public acc_fin::shuffle_list {
    a_list
} {
    Shuffles ( or randomizes the order of ) a list into a random order.
} {
    # Algorithm/Code extracted from wiki.tcl.tk/941 version shuffle10a on 20 May 2014.
    # Added more keywords in description to help find this proc.

    randomInit [clock clicks]
    set len [llength $a_list]
    while { $len > 0 } {
        set n_idx [expr { int( $len * [random] ) } ]
        set tmp [lindex $a_list $n_idx]
        lset a_list $n_idx [lindex $a_list [incr len -1]]
        lset a_list $len $tmp
    }
    return $a_list
}
