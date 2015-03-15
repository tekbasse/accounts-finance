ad_library {

    routines used for affiliate modeling
    @creation-date 11 Feb 2014
    @Copyright (c) 2014 Benjamin Brink
    @license GNU General Public License 3, see project home or http://www.gnu.org/licenses/gpl-3.0.en.html
    @project home: http://github.com/tekbasse/accounts-finance
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com

    Temporary comment about git commit comments: http://xkcd.com/1296/
}

namespace eval acc_fin {}

## acs-tcl/tcl/set-operation-procs.tcl 


# sample proc
ad_proc -public acc_fin::pretti_equation_vars {
} {
    Returns a list of value triplets, where each value pair consists of 1. a variable name used in pretti custom equation feature,  2. a human legible variable equivalent, and 3. a brief definition of the variable
} {
    set vars_lol [list [list 0 path_len "Number of different activities in path"] \
                      [list 1 path_len_w_coefs "Number of activities in path"] \
                      [list 2 act_cp_ratio "Ratio of activities in path that are also in Critical Path"] \
                      [list 3 cost_ratio "Cost ratio: cost of path / cost of project"] \
                      [list 4 on_critical_path_p "1 if path is Critical Path, otherwise 0"] \
                      [list 5 duration_ratio "Duration ratio: duration of path / duration of Critical Path"] \
                      [list 6 path_counter "A path's sequence number from Critical Path based on PRETTI index"] \
                      [list 7 act_count_median "Median count of unique activities on a path."] \
                      [list 8 act_count_max "Max count of unqiue activities on a path."] \
                      [list 9 paths_count "Count of all complete paths."] \
                      [list 10 a_sig_path_p "1 if path contains at least one activity that is above the median count (act_path_count_median), otherwise 0"] ]
    return $vars_lol
}

