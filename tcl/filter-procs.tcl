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
    return filtered_data_list
}
 
