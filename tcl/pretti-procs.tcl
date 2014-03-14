ad_library {

    PRETTI routines used for Project Reporting Evaluation and Track Task Interpretation
    With Hints Of GANTT Activity Network Task Tracking (PRETTI WHO GANTT)
    Project Activity Network Evaluation By Reporting Low Float Paths In Fast Tracks
    @creation-date 11 Feb 2014
    @cvs-id $Id:
    Temporary comment about git commit comments: http://xkcd.com/1296/
}

namespace eval acc_fin {}

# page flags as pretti_types:
#  p in positon 1 = PRETTI app specific
#  p1  scenario
#  p2  task network (unique tasks and their dependencies)
#  p2e task network with all factors expanded (internal -depricated )
#  p3  task types (can also have dependencies)
#  cd2 distribution curve
#  p4  PRETTI report (output)
#  cd2 Estimated project duration distribution curve (can be used to create other projects)

# p1 PRETTI Scenario
#      activity_table_tid
#      activigy_table_name      name of table containing task network
#      period_unit          measure of time used in task duration etc.
#      time_dist_curve_name      a default distribution curve name when a task type doesn't reference one.
#      time_dist_curve_tid      a default distribution curve table_id, dist_curve_name overrides dist_curve_dtid
#      cost_dist_curve_name      a default distribution curve name when a task type doesn't reference one.
#      cost_dist_curve_tid      a default distribution curve table_id, dist_curve_name overrides dist_curve_dtid
#      with_factors_p  defaults to 1 (true). Set to 0 (false) if any factors in p3 are to be ignored.
#                           This option is useful to intercede in auto factor expansion to add additional
#                           variation in repeating task detail. (deprecated by auto expansion of nonexisting coefficients).

# p2 Task Network
#      activity_ref           reference for an activity, a unique task id, using "activity" to differentiate between table_id's tid 
#                             An activity reference is essential a function as in f() with no attributes,
#                             However, there is room to grow this by extending a function to include explicitly set paramemters
#                             within the function, similar to how app-model handles functions aka vectors
#                             The multiple of an activity is respresented by a whole number followed by an "*" 
#                             with no spaces between (when spaces are used as an activity delimiter), or
#                             with spaces allowed (when commas or another character is used as an activity delimiter.
#                
#      aid_type               activity type from p3
#      dependent_tasks        direct predecessors , activity_ref of activiites this activity depends on.
#      name                   defaults to type's name (if exists else blank)
#      description            defaults to type's description (if exists else blank)
#      max_concurrent         defaults to type's max_concurrent 
#      max_overlap_pct021     defaults to type's max_overlap_pct021

#      time_est_short         estimated shortest duration. (Lowest statistical deviation value)
#      time_est_median        estimated median duration. (Statistically, half of deviations are more or less than this.) 
#      time_est_long          esimated longest duration. (Highest statistical deviation value.)
#      time_est_dist_curve_id Use this distribution curve instead of the time_est short, median and long values
#                             Consider using a variation of task_type as a reference
#      time_est_dist_curv_eq  Use this distribution curve equation instead.
#      time_probability_moment A percentage (0..1) along the (cumulative) distribution curve. defaults to 0.5

#      cost_est_low           estimated lowest cost. (Lowest statistical deviation value.)
#      cost_est_median        estimated median cost. (Statistically, half of deviations are more or less than this.)
#      cost_est_high          esimage highest cost. (Highest statistical deviation value.)
#      cost_est_dist_curve_id Use this distribution curve instead of equation and value defaults
#      cost_est_dist_curv_eq  Use this distribution curve equation. 
#      cost_probability_moment A percentage (0..1) along the (cumulative) distribution curve

# p3 Task Types:   
#      type
#      dependent_types      Other dependent types required by this type. (possible reference collisions. type_refs != activity_refs.
#
#####                       dependent_types should be checked against activity_dependents' types 
#                           to confirm that all dependencies are satisified.
#      name
#      description
#      max_concurrent       (as an integer, blank = no limit)
#      max_overlapp_pct021  (as a percentage from 0 to 1, blank = 1)
#   deprecated:
#      dependent_tasks      These are other tasks referenced in p2
#                           How to handle nomenclature collisons? 
#                           They only collide if p3.dependent_tasks are referenced; and there's no need for this complexity. REMOVED.

# p2e  same as p2, except that factors in p2.dependent_tasks are inactivate
#      p2.dependent_tasks. It is assumed that any factors in p2.dependent_tasks
#      have already been expanded and collectively represented as an aggregate task
#      THIS IS DEPRICATED.
#      Any task reference with factor is first checked against existing task references.
#      If task reference with factor is not found, a new one is created and added to p2. 

# cd2 distribution curve table
#                   Y         where Y = f(x) and f(x) is a 
#                             probability mass function ie probability density function as a distribution
#                             http://en.wikipedia.org/wiki/Probability_mass_function
#                             http://en.wikipedia.org/wiki/Probability_density_function
#                         aka http://en.wikipedia.org/wiki/Discrete_probability_distribution#Discrete_probability_distribution
#                             The discrete values are the values of Y included in the table

#                    X        Where X = the probability of Y.
#                             These can be counts of a sample or a frequency.  When the table is saved,
#                             the total area under the distribution is normalized to 1.

#                   label     Where label represents the value of Y at x. This is a short phrase or reference
#                             that identifies a boundary point in the distribution.
# A three point (short/median/long or low/median/high) estimation curve can be respresented as
# a discrete set of six points:  minimum median median median median maximum 
# of standard bell curve probabilities (outliers + standard deviation).
# Thereby allowing *_probability_moment variable to be used in estimates with lower statistical resolution.

# p4 Display modes
#  
#  tracks within n% of CP duration, n represented as %12100 or a duration of time as total lead slack
#  tracks w/ n fixed count closest to CP duration. A n=1 shows CP track only.
#  tracks that contain at least 1 CP track 

# p5 Project fast-track duration curve
#  same as cd2

ad_proc -public acc_fin::task_factors_expand {
    a_pretti_lol
} {
    Expands dependent tasks with factors in a pretti_list_of_lists by appending new definitions of tasks that match tasks with factors as indexes.
} {



    return $pretti_expanded_lol
}

ad_proc -public acc_fin::list_filter {
    user_input_list
} {
    filters alphanumeric input as a list to meet basic word or reference requirements
} {
    set filtered_list [list ]
    foreach input_unfiltered $user_input_list {
        regsub -all -nocase -- {[^a-z0-9,]+} $input_unfiltered {} input_filtered
        lappend filtered_list $input_filtered
    }
    return $filtered_list
}

ad_proc -public acc_fin::table_type_scenario_p {
    a_list_of_lists
} {
    returns 1 if lol table is a pretti scenario
} {
    return $test_p
}

ad_proc -public acc_fin::table_type_distr_p {
    a_list_of_lists
} {
    returns 1 if lol table is a statistical distribution
} {
    return $test_p
}

ad_proc -public acc_fin::table_type_network_p {
    a_list_of_lists
} {
    returns 1 if lol table is a pretti network of dependencies
} {
    return $test_p
}

ad_proc -public acc_fin::table_type_pretti_p {
    a_list_of_lists
} {
    returns 1 if lol table is a pretti output format (special) table
} {
    return $test_p
}



ad_proc -public acc_fin::pretti_ck_lol {
    scenario_list_of_lists
} {
    returns 1 if scenario is valid for processing
} {
        #requires scenario_tid
        # given scenario_tid 
        # activity_table contains:
        # activity_ref predecessors time_est_short time_est_median time_est_long cost_est_low cost_est_median cost_est_high time_dist_curv_eq cost_dist_curv_eq
    return $valid_p
}

ad_proc -private acc_fin::curve_import {
    c_x_list
    c_y_list
    c_label_list
    curve_lists
    minimum
    median
    maximum
    default_lists
} {
    Returns curve data to standard representation for PRETTI processing. 
    1. If a curve exists in c_x_list, c_y_list (, c_label_list), use it.
    2. If a curve exists in curve_lists where each element is a list of x,y(,label), use it.
    3. If a minimum, median, and maximum is available, make a curve of it. 
    4. if an median value is available, make a curve of it, 
    5. if an ordered list of lists x,y,label exists, use it as a fallback default, otherwise 
    6. return a representation of a normalized curve as a list of lists similar to curve_lists 
} {
    # In persuit of making curve_data
    #     local curves are represented as a list of lists, with each list a triplet set x, y, label
    #     or as separate lists.. so this proc must check for both forms.

    #     local 3-point (min,median,max) represented as a list of 3 elements
    #     local median represented as a single element
    #     default curve represented as a list of lists
    #     if no default available, create one based on a normalized standard.

    set standard_deviation 0.682689492137 
    set std_dev_parts [expr { $standard_deviation / 4. } ]
    set outliers [expr { 0.317310507863 / 2. } ]
    set c_lists [list ]

    # 1. If a curve exists in c_x_list, c_y_list (, c_label_list), use it.
    set c_x_list_len [llength $c_x_list]
    set c_y_list_len [llength $c_y_list]
    set c_label_list_len [llength $c_label_list]
    set list_len 0
    if { $c_x_list_len > 0 && $c_x_list_len < $c_y_list_len } {
        set list_len $c_x_list_len
    } elseif { $c_y_list_len > 0 } {
        set list_len $c_y_list_len
    }
    if { $list_len > 0 } {
        if { $c_label_list_len > 0 } {
            # x, y and label
            for {set i 0} {$i < $list_len} {incr i} {
                set row [list [lindex $c_x_list $i] [lindex $c_y_list $i] [lindex $c_label_list $i] ]
                lappend c_lists $row
            }
        } else {
            # x and y only
            for {set i 0} {$i < $list_len} {incr i} {
                set row [list [lindex $c_x_list $i] [lindex $c_y_list $i] ]
                lappend c_lists $row
            }
        }

    } 

    # 2. If a curve exists in curve_lists where each element is a list of x,y(,label), use it.
    set curve_lists_len [llength $curve_lists]
    if { [llength $c_lists] == 0 && $curve_lists_len > 0 } {

        # curve exists. 
        set point_len [llength [lindex $curve_lists 0] ]
        if { $point_len > 1 } {
            set c_lists $curve_lists
        }
        
    }
 
    # 3. If a minimum, median, and maximum is available, make a curve of it. 
    # or
    # 4. if an median value is available, make a curve of it, 
    if { [llength $c_lists] == 0 && $median ne "" } {
        set med_label "med"
        if { $minimum eq "" } {
            set minimum $median
            set min_label $med_label
        } else {
            set min_label "min"
        }
        if { $maximum eq "" } {
            set maximum $median
            set max_label $med_label
        } else {
            set max_label "max"
        }

        # min,avg,max values available
        # Geometric median requires all three values
        
        # time_expected = ( time_optimistic + 4 * time_most_likely + time_pessimistic ) / 6.
        # per http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique
        
        # Just include the part of x under the area of each y
        set c_x_list [list $outliers $st_dev_parts $st_dev_parts $st_dev_parts $st_dev_parts $outliers]
        set c_y_list [list $minimum $median $median $median $median $maximum]
        set c_label_list [list $min_label $med_label $med_label $med_label $med_label $max_label]
        
        for {set i 0} {$i < $c_larr_y_len } {incr i} {
            set row [list [lindex $c_x_list $i] [lindex $c_y_list $i] [lindex $c_label_list $i]]
            lappend c_lists $row
        }


    }
    
    # 5. if an ordered list of lists x,y,label exists, use it as a fallback default
    if { [llength $default_lists] > 0 && [llength [lindex $default_lists 0] ] > 1 } {
        set c_lists $default_lists
    }

    # 6. return a representation of a normalized curve as a list of lists similar to curve_lists 
    if { [llength $c_lists] == 0 } {
        # No time defaults.
        # set duration to 1 for limited block feedback.

        set tc_larr(x) [list $outliers $st_dev_parts $st_dev_parts $st_dev_parts $st_dev_parts $outliers]
        # using approximate cumulative distribution y values for standard deviation of 1.
        set tc_larr(y) [list 0.15 0.3 0.45 0.7 0.82 1.]
    }

    # Return an ordered list of lists representing a curve
    return $c_lists
}


ad_proc -public acc_fin::scenario_prettify {
    scenario_list_of_lists
    {with_factors_p 0}
} {
    processes PRETTI scenario. Returns resulting PRETTI table as a list of lists. If with_factors_p is 1, an intermediary step processes factor multiplicands in dependent_tasks list, appending table with a complete list of expanded, nonrepeating tasks.
} {
    # load scenario values
    
    # load pretti2_lol table
    

    if { $with_factors_p } {
        # append p2 file, call this proc referencing p2 with_factors_p 0 before continuing.
        set pretti2e_lol [acc_fin::p2_factors_expand $pretti2_lol]
    }
    # vertical represents time. All tasks are rounded up to quantized time_unit.
    # Smallest task duration is the number of quantized time_units that result in 1 line of text.

    # Represent multiple dependencies of same task for example 99 cartwheels using * as in 99*cartwheels

    # Representing task bottlenecks --limits in parallel activity of same type
    # Parallel limits represented by:
    # concurrency_limit: count of tasks of same type that can operate in parallel
    # overlap_limit: a percentage representing amount of overlap allowed.
    #                overlap_limit, in effect, creates progressions of activity

    # To find, repeat PRETTI scenario on tracks with CP tasks by task type, then increment by quantized time_unit (row), tracking overages
    # amount to extend CP duration: collision_count / task_type * ( row_counts / ( time_quanta per task_type_duration ) + 1 )
    
    # Since PRETTI does not schedule, don't manipulate task positioning,
    # just increase duration of CP to account for limit overages.
    
    # Multiple task requirements are represented with a number followed by asterisk.
    
    # Create a projected completion curve by stepping through the range of all the performance curves N times instead of Monte Carlo simm.
    
    
    ns_log Notice "acc_fin::scenario_prettify: start"
    #requires scenario_tid
    
    # given scenario_tid 
    # activity_table contains:
    # activity_ref predecessors time_est_short time_est_median time_est_long cost_est_low cost_est_median cost_est_high time_dist_curv_eq cost_dist_curv_eq
    set error_fail 0
    
    # get scenario into array p1_arr
    set constants_list [list activity_table_tid activity_table_name task_types_tid task_types_name time_dist_curve_name time_dist_curve_tid cost_dist_curve_name cost_dist_curve_tid time_est_short time_est_median time_est_long time_probability_moment cost_est_low cost_est_median cost_est_high cost_probability_moment]
    foreach constant $constants_list {
        set p1_arr($constant) ""
    }
    set constants_required_list [list activity_table_tid ]
    qss_tid_scalars_to_array $scenario_tid p1_arr $constants_list $constants_required_list $package_id $user_id
    if { $p1_arr(activity_table_name) ne "" } {
        # set activity_table_tid
        set p1_arr(activity_table_tid) [qss_tid_from_name $p1_arr(activity_table_name) ]
    } 
    if { $p1_arr(task_types_name) ne "" } {
        # set task_types_tid
        set p1_arr(task_types_tid) [qss_tid_from_name $p1_arr(task_types_name) ]
    } 
    if { $p1_arr(time_dist_curve_name) ne "" } {
        # set dist_curve_tid
        set p1_arr(time_dist_curve_tid) [qss_tid_from_name $p1_arr(time_dist_curve_name) ]
    }
    if { $p1_arr(cost_dist_curve_name) ne "" } {
        # set dist_curve_tid
        set p1_arr(cost_dist_curve_tid) [qss_tid_from_name $p1_arr(cost_dist_curve_name) ]
    }


    set constants_exist_p 1
    set compute_message_list [list ]
    foreach constant $constants_required_list {
        if { $p1_arr($constant) eq "" } {
            set constants_exist_p 0
            lappend compute_message_list "Initial condition constant '${constant}' is required but does not exist."
            set error_fail 1
        }
    }
    
    # Make time_curve_data This is the default unless more specific data is specified in a task list.
    # The most specific information is used by default. 
    # Median (most likely) point is assumed along the (cumulative) distribution curve, unless
    # a time_probability_moment is specified.  time_probability_moment is only available as a general term.
    #     local curve
    #     local 3-point (min,median,max)
    #     general curve (normalized to local 1 point median ); local 1 point median is minimum time data requirement
    #     general 3-point (normalized to local median)
    
    

    if { $p1_arr(time_dist_curve_tid) ne "" } {
        # get time curve into array tc_larr
        set constants_list [list y x label]
        foreach constant $constant_list {
            set tc_larr($constant) ""
        }
        set constants_required_list [list y x]
        qss_tid_columns_to_array_of_lists $time_dist_curve_tid tc_larr $constants_list $constants_required_list $package_id $user_id
        #tc_larr(x), tc_larr(y) and optionally tc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n
    } 
    set tc_lists [acc_fin::curve_import $tc_larr(x) $tc_larr(y) $tc_larr(label) [list ] $p1_arr(time_est_short) $p1_arr(time_est_median) $p1_arr(time_est_long) [list ] ]

    #### check flags if any curves are not normalized in x, normalize to 1
    ### Add option in App to normalize any column to 1, sort any column up/down.
    ###   which is handy for most cases. 
    ### It cannot be done by default for all cases, because order may already be predetermined.
    
    # Make cost_curve_data 
    # Don't support cost_dist_curv_eq for now. Interpreting an equation adds a layer of complexity.
    if { $p1_arr(cost_dist_curve_tid) ne "" } {
        set constants_list [list y x label]
        foreach constant $constants_list {
            set cc_larr($constant) ""
        }
        set constants_required_list [list y x]
        set cost_curve_data_lists $cost_dist_curve_tid cc_larr $constants_list $constants_required_list $package_id $user_id
        #cc_larr(x), cc_larr(y) and optionally cc_larr(label) where _larr refers to an array where each value is a list of column data by row 1..n
        
    } 
    set cc_lists [acc_fin::curve_import $cc_larr(x) $cc_larr(y) $cc_larr(label) [list ] $p1_arr(cost_est_low) $p1_arr(cost_est_median) $p1_arr(cost_est_high) [list ] ]

  ######  
    # import task_types_list
    if { $p1_arr(task_types_tid) ne "" } {
        # load task types table
        set constants_list [list type dependent_tasks dependent_types name description max_concurrent max_overlapp activity_table_tid activity_table_name task_types_tid task_types_name time_dist_curve_name time_dist_curve_tid cost_dist_curve_name cost_dist_curve_tid time_est_short time_est_median time_est_long time_probability_moment cost_est_low cost_est_median cost_est_high cost_probability_moment]
        set constants_required_list [list type]
        foreach column $constants_list {
            set p3_larr($column) [list ]
        }
        qss_tid_columns_to_array_of_lists $p1_arr(task_types_tid) p3_larr $constants_list $constants_required_list $package_id $user_id
        # filter user input that is going to be used as references in arrays:
        set p3_larr(type) [acc_fin::list_filter $p3_larr(type)]
        set p3_larr(dependent_tasks) [acc_fin::list_filter $p3_larr(dependent_tasks)]
    }


    # import activity_list
    if { $p1_arr(activity_table_id) ne "" } {
        # load activity table
        set constants_list [list activity_ref aid_type dependent_tasks name description max_concurrent max_overlap_pct021 time_est_short time_est_median time_est_long time_est_dist_curve_id time_probability_moment cost_est_low cost_est_median cost_est_high cost_est_dist_curve_id cost_probability_moment]
        set constants_required_list [list activity_ref dependent_tasks]
        foreach column $constants_list {
            set p2_larr($column) [list ]
        }
        qss_tid_columns_to_array_of_lists $p1_arr(activity_table_id) p2_larr $constants_list $constants_required_list $package_id $user_id
        # activity_ref and dependent_tasks are the only required lists. 
        # Others can be filled by defaults from scalars or activity types (if exists)

        # filter user input
        set activities_filtered_list [list ]
        set depnc_filtered_list [list ]
        foreach act_unfiltered $p2_larr(activity_ref) {
            regsub -all -nocase -- {[^a-z0-9,]+} $act_unfiltered {} act
            lappend activities_filtered_list $act
        }
        set p2_larr(activity_ref) $activities_filtered_list
        foreach depnc_unfiltered $p2_larr(dependent_tasks) {
            regsub -all -nocase -- {[^a-z0-9,]+} $depnc_unfiltered {} depnc
            lappend depnc_filtered_list $depnc
        }
        set p2_larr(dependent_tasks) $depnc_filtered_list

    }


    #### load other reference tables

    # handy api ref
    # util_commify_number
    # format "% 8.2f" $num
    # f::sum $list
    
    ## # PERT calculations

    
    # Build activity map table:
    # activity_ref dependent_tasks
    # add: activity time curve
    # add: activity cost curve
    # add: time_expected cost_expected (based on *_probability_moment)
    
    # build array of activity_ref sequence_num
    # default for each acitivity_ref 1
    # assign an activity_ref one more than the max sequence_num of its dependencies
    # acitivity_refs are indexes to arrays since no predetermination can be made about p2_larr content
    set i 0
    set sequence_1 0
    foreach act $p2_larr(activity_ref) {
        set depnc [lindex $p2_larr(dependent_tasks) $i]
        # depnc: comma list of dependencies
        # depnc_arr() list of dependencies
        set depnc_arr($act) [split $depnc ,]
        # calcd_p_arr($act) Answers question: Has relative sequence number for $act been calculated?
        set calcd_p_arr($act) 0
        # act_seq_num_arr is relative sequence number of an activity. 
        set act_seq_num_arr($act) $sequence_1
        incr i
    }
    

    # each element in act_time_est_list is a curve. If curve is blank, the default curve is used.
    # tc_larr(x) is a list_of_lists , denoting normalized percent of area under curve (p021)
    # tc_larr(y) is duration value of curve
    set i 0
    foreach act $p2_larr(activity_ref) {
        
        # If act has a info for calculating a curve, get it

        # More cases have act_tc_larr, so default to 1
        set has_act_tc_larr_p 1
        set act_time_est_list [lindex $p2_larr(time_dist_curve_tid) $i]
        if { $act_time_est_list ne "" } {
            # get time curve into array tc_larr
            # use tempoary arr act_tc_larr to pass info from qss_*
            set act_tc_larr(x) [list ]
            set act_tc_larr(y) [list ]
            set act_tc_larr(label) [list ]
            set constants_list [list y x label]
            set constants_required_list [list y x]
            qss_tid_columns_to_array_of_lists $time_dist_curve_tid act_tc_larr $constants_list $constants_required_list $package_id $user_id
            
        } elseif { [llength $tc_larr(y) > 0] } {
            # If there is a default, use it
            set act_tc_larr(x) $tc_larr(x)
            set act_tc_larr(y) $tc_larr(y)
            set act_tc_larr(label) $tc_larr(label)
            
        } else {
            # No time defaults.
            set has_act_tc_larr_p 0
        }
        if { $has_act_tc_larr_p } {
            set act_tc_larr_len [llength $act_tc_larr(y)]
            set act_tc_larr(xy) [list ]
            for {set i 0} {$i < $act_tc_larr_len } {incr i} {
                set row [list [lindex $act_tc_larr(x) $i] [lindex $act_tc_larr(y) $i]]
                lappend act_tc_larr(xy) $row
            }
            # Set the curve for this act
            
            set tcn_larr($act) $act_tc_larr(xy)
        } else {
            # use a default curve for this act
            
            #### this should check to see if activity type has a dist_curve before using the default...
            
            set tcn_larr($act) $tc_larr(xy)
        }
        # Calculate the default time_expected
        set time_expected_arr($act) [qaf_y_of_x_dist_curve $p1_arr(time_probability_moment) $tc_larr(xy) 0]
        
        
        
        # Set default of path_durations
        set path_dur_arr($act) $time_expected_arr($act)
        incr i
    }
    
    # Calculate paths in the main loop to save resouces.
    #  Each path is a list of numbers referenced by array, where array is path.
    #  set path_segment_ends_in_lists($act) 
    #         so future segments can quickly reference it to build theirs.
    # This keeps path making nearly linear. There are as many path references as there are activities..
    # Some of the references are incomplete paths, but these can be filtered as needed.
    # All paths must be assessed in order to handle all possibilities
    # Paths are used to determine critical path and fast crawl a single path.
    
    # An activity cannot start until the longest dependent segment has completed.
    
    # for strict critical path, create a list of lists, where 
    # each list is a list of dependencies from start to finish (aka path)  + the longest duraction path of activity including dependencies.
    # sum the duration for each list. The longest duration is the strict defintion of critical path.
    
    # create dependency check equations
    # depnc_eq_arr() is equation that answers question: Are dependencies met for $act?
    foreach act $p2_larr(activity_ref) {
        set eq "1 &&"
        foreach dep $depnc_arr($act) {
            # CODING NOTE:
            # strings generally are okay to 100,000,000+ chars..
            # considering reducing size of calcd_p_arr to increase capacity
            # or switch to manually calculate each incompletely calced network
            append eq " calcd_p_arr($dep) &&"
        }
        set eq [string range $eq 0 end-3]
        regsub -all -- {calcd} $eq {$calcd} depnc_eq_arr($act)
    }
    # main process looping
    set all_calced_p 0
    set activity_count [llength $p2_larr(activity_ref)]
    set i 0
    set act_seq_list_arr($sequence_1) [list ]
    set act_count_of_seq_arr($sequence_1) 0
    set path_seg_dur_list [list ]
    # act_seq_max is the current maximum path length
    # act_count_of_seq_arr($seq_num) is the count of activities in sequence_num
    while { !$all_calced_p && $activity_count > $i } {
        set all_calcd_p 1
        foreach act $p2_larr(activity_ref) {
            set dependencies_met_p [expr $depnc_eq_arr($act) ]
            set act_seq_max $sequence_1
            if { $dependencies_met_p && !$calcd_p_arr($act) } {
                
                # max_num: maximum relative sequence number for activity dependencies
                set max_num 0
                foreach test_act $depnc_arr($act) {
                    set test $act_seq_num_arr($test_act)
                    if { $max_num < $test } {
                        set max_num $test
                    }
                }
                # Add activity's relative sequence number: act_seq_num_arr
                set act_seq_nbr [expr { $max_num + 1 } ]
                set act_seq_num_arr($act) $act_seq_nbr
                set calcd_p_arr($act) 1
                # increment act_seq_max and set defaults for a new max seq number?
                if { $act_seq_nbr > $act_seq_max } {
                    set act_seq_max $act_seq_nbr
                    set act_seq_list_arr($act_seq_max) [list ]
                    set act_count_of_seq_arr($act_seq_max) 0
                }
                # add activity to the network for this sequence number
                lappend act_seq_list_arr($act_seq_nbr) $act
                incr act_count_of_seq_arr($act_seq_nbr)
                
                # Analize prior path segments here.
                # path_duration(path) is the min. path duration to complete dependent paths
                set path_duration 0
                # set duration_new to the longest dependent segment.
                foreach dep_act $depnc_arr($act) {
                    if { $path_dur_arr($dep_act) > $path_duration } {
                        set path_duration $path_dur_arr($dep_act)
                    }
                }
                set duration_arr($act) [expr { $path_duration + $time_expected_arr($act) } ]
                set path_seg_list_arr($act) [list ]
                #bad referencing here: separate duration from rest.
                foreach dep_act $depnc_arr($act) {
                    foreach path_list $path_seg_list_arr($dep_act) {
                        set path_new $path_list
                        lappend path_new $act
                        lappend path_seg_list_arr($act) $path_new
                        lappend path_seg_dur_list [list $path_new $duration_arr($act)]
                    }
                }
                if { [llength $path_seg_list_arr($act)] eq 0 } {
                    lappend path_seg_list_arr($act) $act
                    lappend path_seg_dur_list [list $act $duration_arr($act)]
                }
            }
            set all_calcd_p [expr { $all_calcd_p && $calcd_p_arr($act) } ]
        }
        incr i
    }
    set dep_met_p 1
    ns_log Notice "acc_fin::scenario_prettify: path_seg_dur_list $path_seg_dur_list"
    foreach act $p2_larr(activity_ref) {
        set $dep_met_p [expr $depnc_eq_arr($act) && $dep_met_p ]
        # ns_log Notice "acc_fin::scenario_prettify: act $act act_seq_num_arr '$act_seq_num_arr($act)'"
        # ns_log Notice "acc_fin::scenario_prettify: act_seq_list_arr '$act_seq_list_arr($act_seq_num_arr($act))' $act_count_of_seq_arr($act_seq_num_arr($act))"
    }
    ns_log Notice "acc_fin::scenario_prettify: dep_met_p $dep_met_p"
    
    # sort by path duration
    # critical path is the longest path. Float is the difference between CP and next longest CP.
    # create an array of paths from longest to shortest to help build base table
    set path_seg_dur_sort1_list [lsort -decreasing -real -index 1 $path_seg_dur_list]
    # Critical Path (CP) is 
    set cp_list [lindex [lindex $path_seg_dur_sort1_list 0] 0]
    #ns_log Notice "acc_fin::scenario_prettify: path_seg_dur_sort1_list $path_seg_dur_sort1_list"
    
    # Extract most significant CP alternates for a focused table
    # by counting the number of times an act is used in the largest proportion (first half) of paths in path_set_dur_sort1_list
    set path_count [llength $path_seg_dur_sort1_list]
    set extract_limit [expr { $path_count / 2 + 1 } ]
    set extractv1_list [lrange $path_seg_dur_sort1_list 0 ${extract_limit}] 
    # act_freq_in_load_cp_alts_arr counts the number of times an activity is in a path  for the most significant CP alternates
    set max_act_count_per_seq 0
    foreach act $p2_larr(activity_ref) {
        set act_freq_in_load_cp_alts_arr($act) 0
        if { $act_count_of_seq_arr($act) > $max_act_count_per_seq } {
            set max_act_count_per_seq $act_count_of_seq_arr($act)
        }
    }
    foreach path_seg_list $extractv1_list {
        set path2_list [lindex $path_seg_list 0]
        foreach act $path2_list {
            incr act_freq_in_load_cp_alts_arr($act)
        }
    }
    set act_sig_list [list ]
    foreach act $p2_larr(activity_ref) {
        lappend act_sig_list [list $act $act_freq_in_load_cp_alts_arr($act)]
    }
    set act_sig_sorted_list [lsort -decreasing -integer -index 1 $act_sig_list]
    set act_max_count [lindex [lindex $act_sig_sorted_list 0] 1]
    set act_sig_median_pos [expr { $extract_limit / 2 } + 1 ]
    set act_median_count [lindex [lindex $act_sig_sorted_list $act_sig_median_pos] 1]
    
    # build base table
    # Table width should be limited to max count of acivities per sequence.
    
    # activity_ref act_seq_num_arr has_direct_dependency_p time_expected direct_dependencies_list
    set base_lists [list ]
    
    foreach act $p2_larr(activity_ref) {
        set has_direct_dependency_p [expr { [llength $depnc_arr($act)] > 0 } ]
        set on_critical_path_p [expr { [lsearch -exact $cp_list $act] > -1 } ]
        set on_a_sig_path_p [expr { $act_freq_in_load_cp_alts_arr($act) > $act_median_count } ]
        set activity_list [list $act $act_seq_num_arr($act) $has_direct_dependency_p $on_critical_path_p $on_a_sig_path_p $act_freq_in_load_cp_alts_arr($act) $duration_arr($act) $time_expected_arr($act) $depnc_arr($act) ]
        lappend base_lists $activity_list
    }
    
    # act_count_of_seq_arr( sequence_number) is the count of activities at this sequence number
    # max_act_count_per_seq is the maximum number of activities in a sequence number.
    
    ns_log Notice "acc_fin::scenario_prettify: base_lists $base_lists"
    # critical path is the longest expexted duration of dependent activities..
    # so:
    # primary sort is act_seq_num_arr ascending
    # secondary sort is part_of_critical_path_p descending
    # third sort is has_direct_dependency_p descending (1 = true, 0 false)
    # fourth sort is path duraction descending
    
    set fourth_sort [lsort -decreasing -real -index 6 $base_lists]
    set third_sort [lsort -decreasing -integer -index 2 $fourth_sort]
    set second_sort [lsort -decreasing -integer -index 3 $third_sort]
    set primary_sort [lsort -increasing -integer -index 1 $second_sort]
    
    ns_log Notice "acc_fin::scenario_prettify: primary_sort $primary_sort"
    
    # prep for conversion to html by adding missing TDs, setting formatting (colors, size etc).
    # primary_sort list_of_lists consists of this order of elements:
    #  act act_seq_num_arr has_direct_dependency_p on_critical_path_p on_a_sig_path_p act_freq_in_load_cp_alts path_duration time_expected dependencies_list
    # sorted by: act_seq_num on_critical_path_p has_direct_dependency_p duration
    
    
    # build formatting colors
    set act_count [llength $p2_larr(activity_ref)]
    # contrast decreases on up to 50%
    set contrast_step [expr { int( 16 / ( $max_act_count_per_seq / 2 + 1 ) ) } ]
    set hex_list [list 0 1 2 3 4 5 6 7 8 9 a b c d e f]
    set row_nbr 0
    set cell_nbr 0
    set act_seq_num $sequence_1
    # each row is a relative sequence
    set cells_per_row $max_act_count_per_seq
    set cell_formatting_list [list ]
    set cell_value_list [list ]
    set table_formatting_lists [list ]
    set table_value_lists [list ]
    # act_count_of_seq_arr( sequence_number) is the count of activities at this sequence number
    foreach cell $primary_sort {
        set cell_nbr_prev $cell_nbr
        set act_seq_num_prev $act_seq_num
        incr cell_nbr
        set cell_formatting [list ]
        set cell_value ""
        # set initial values
        set act [lindex $cell 0]
        set act_seq_num [lindex $cell 1]
        set has_direct_dependency_p [lindex $cell 2]
        set on_critical_path_p [lindex $cell 3]
        set on_a_sig_path_p [lindex $cell 4]
        set act_freq_in_load_cp_alts [lindex $cell 5]
        set path_duration [lindex $cell 6]
        set time_expected [lindex $cell 7]
        set dependencies_list [lindex $cell 8]
        set dependencies ""
        set separator ""
        foreach dependency $dependencies_list {
            append dependencies $separator $dependency
            set separator ", "
        }
        if { $act_seq_num_prev ne $act_seq_num } {
            # new row
            set cell_nbr 0
            set row_nbr_prev $row_nbr
            incr row_nbr
            set hex_nbr_val 16
            lappend table_formatting_lists $cell_formatting_list
            lappend table_value_lists $cell_formatting_list
            set cell_formatting_list [list ]
            set cell_value_list [list ]
        }
        # build cell
        set cell_value "$act t:${time_expected} T:${path_duration} D:${dependencies} "
        set odd_row_p [expr { ( $row_nbr / 2. ) == int( $row_nbr / 2 ) } ]
        # CP in highest contrast (yellow ff9), others in lowering contrast to f70
        # CP alt in alternating lt blue 99f, lt green 9f9 
        # others in alternating medium blue/green 66ff, 6f6
        if { $on_critical_path_p } {
            set bgcolor "#ffff00"
        } elseif { $on_a_sig_path_p } {
            set hex_nbr_val [expr { $hex_nbr - $contrast_step } ]
            set hex_nbr [lindex $hex_list $hex_nbr_val]
            if { $odd_row_p } {
                set bgcolor "#ff${hex_nbr}${hex_nbr}99"
            } else {
                set bgcolor "#${hex_nbr}ff${hex_nbr}"
            }
            
        } elseif { $odd_row_p } {
            set bgcolor "#6666ff"
        } else {
            set bgcolor "#66ff66"
        }
        set cell_formatting bgcolor $bgcolor
        lappend cell_formatting_list $cell_formatting
        lappend cell_value_list $cell_value
    }
    
    # build unique list of dependencies
    
    # Build Network Breakdown Table: activity vs. path
    # 
    # activity_ref predecessors
    # add: sequence_num time_expected cost_expected
    # add:
    
    
    # the_time Time calculation completed
    set p1_arr(the_time) [clock format [clock seconds] -format "%Y %b %d %H:%M:%S"]
    
    # html
    set html_arr(apt) "<h3>Computation report</h3>"
    
    append html_arr(apt) [qss_list_of_lists_to_html_table $table_value_lists $table_attribute_list $table_formatting_lists]
    append html_arr(apt) "Completed $p1_arr(the_time)"
    append computation_report_html $html_arr(apt)
    
    
    
    return $pretti_lol
}

