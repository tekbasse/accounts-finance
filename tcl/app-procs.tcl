ad_library {

    routines for systems modeling app
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


ad_proc -public acc_fin::app_table_type_flag {
    table_lists
} {
    Guesses which type of table. First revision was acc_fin::pretti_type_flag
} {
    #upvar $table_lists_name table_lists
    # page flags as pretti_types:
    #  p in positon 1 = PRETTI app specific
    #  p1  scenario
    #  p2  task network (unique tasks and their dependencies)
    #  p3  task types (can also have dependencies)
    #  dc distribution curve
    #  p4  PRETTI report (output)
    #  p5  PRETTI db report (output) (similar format to  p3, where each row represents a path, but in p5 all paths are represented)
    #  dc Estimated project duration distribution curve (can be used to create other projects)

    # get first row
    set title_list [lindex $table_lists 0]
    set type_return ""
    # check for type p1 separate from the other cases, because the table is specified differently from other cases.
    set p(p1) 0
    set name_idx [lsearch -exact $title_list "name" ]
    set value_idx [lsearch -exact $title_list "value" ]
    #    ns_log Notice "acc_fin::pretti_columns_list.390 name_idx $name_idx value_idx $value_idx title_list '$title_list'"
    if { $name_idx > -1 && $value_idx > -1 } {
        # get name column
        set name_list [list ]
        #        ns_log Notice "acc_fin::pretti_columns_list.400 table_lists '$table_lists'"
        foreach row [lrange $table_lists 1 end] {
            lappend name_list [lindex $row $name_idx]
        }
        #        ns_log Notice "acc_fin::pretti_columns_list.401 name_list '$name_list'"
        # check name_list against p1 required names. 
        # All required names need to be in list, but not all list names are required.
        set p(p1) 1
        # required names in check_list
        # p1 is special because it requires either activity_table_tid *or* activity_table_name
        #set check_list [acc_fin::pretti_columns_list "p1" 1 ]
        #        ns_log Notice "acc_fin::pretti_columns_list.402 check_list $check_list"
        # foreach check $check_list {
        #    if { [lsearch -exact $name_list $check] < 0 } {
        #        set p(p1) 0
        #    }
        #            ns_log Notice "acc_fin::pretti_columns_list.404 check $check p(p1) $p(p1)"
        #}
        set name_idx [lsearch -exact $name_list activity_table_name]
        set tid_idx [lsearch -exact $name_list activity_table_tid]
        if { $name_idx < 0 && $tid_idx < 0 } {
            set p(p1) 0
        }
    }
    if { $p(p1) } {
        set type_return "p1"
        #        ns_log Notice "acc_fin::pretti_columns_list.410 type = p1"
    } else {
        # filter other p table types by required minimums first
        set type_list [list "p2" "p3" "p4" "p5" "dc"]
        #        ns_log Notice "acc_fin::pretti_columns_list.414 type not p1. check for $type_list"
        foreach type $type_list {
            set p($type) 1
            set check_list [acc_fin::pretti_columns_list $type 1]
            #            ns_log Notice "acc_fin::pretti_type_flag.58: type $type check_list $check_list"
            foreach check $check_list {
                if { [lsearch -exact $title_list $check] < 0 } {
                    set p($type) 0
                }
                #                ns_log Notice "acc_fin::pretti_type_flag.60: check $check p($type) $p($type)"
            }
        }
        
        # how many types might this table be?
        set type1_p_list [list ]
        foreach type $type_list {
            if { $p($type) } {
                lappend type1_p_list $type
            }
        }
        #        ns_log Notice "acc_fin::pretti_type_flag.69: type1_p_list '${type1_p_list}'"
        set type_count [llength $type1_p_list]
        if { $type_count > 1 } {
            # choose one
            if { $p(p2) && $p(p3) && $type_count == 2 } {
                if { [lsearch -exact $title_list "aid_type" ] > -1 } {
                    set type_return "p2"
                } elseif { [lsearch -exact $title_list "type" ] > -1 } {
                    set type_return "p3"
                } 
            } else {
                set type3_list [list ]
                # Which type best meets full list of implemented column names?
                foreach type $type1_p_list {
                    set name_list [acc_fin::pretti_columns_list $type 0]
                    set name_list_count [llength $name_list]
                    set exists_count 0
                    foreach name $name_list {
                        if { [lsearch -exact $title_list $name] > -1 } {
                            incr exists_count
                        }
                    }
                    if { $name_list_count > 0 } {
                        set type_pct_list [list $type [expr { ( $exists_count * 1. ) / ( $name_list_count * 1. ) } ] ]
                        lappend type3_list $type_pct_list
                    } 
                }
                set type3_list [lsort -real -index 1 -decreasing $type3_list]
                #                ns_log Notice "acc_fin::pretti_type_flag.450: type1_p_list '${type1_p_list}'"
                #                ns_log Notice "acc_fin::pretti_type_flag.453: type3_list '$type3_list'"
                set type_return [lindex [lindex $type3_list 0] 0]
            }
        } else {
            # append is used here in case no type meets the criteria, an empty string is returned
            append type_return [lindex $type1_p_list 0]
        }
    }
    
    return $type_return
}
