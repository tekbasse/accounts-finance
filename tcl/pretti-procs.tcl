ad_library {

    PRETTI routines used for Project Reporting Evaluation and Track Task Interpretation
    @creation-date 11 Feb 2014
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public acc_fin::pretti_ck_lol {
    scenario_list_of_lists
} {
    returns 1 if scenario is valid for processing
} {
    return $valid_p
}

ad_proc -public acc_fin::prettify_lol {
    scenario_list_of_lists
} {
    processes scenario. Returns resulting PRETTI table as a list of lists
} {
    return $pretti_lol
}
