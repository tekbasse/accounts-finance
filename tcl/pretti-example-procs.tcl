ad_library {

    PRETTI example data used for Project Reporting Evaluation and Track Task Interpretation
    @creation-date 8 May 2014
    @cvs-id $Id:
    @Copyright (c) 2014 Benjamin Brink
    @license GNU General Public License 3, see project home or http://www.gnu.org/licenses/gpl-3.0.en.html
    @project home: http://github.com/tekbasse/accounts-finance
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: kappa@dekka.com
    
    PRETTI examples and test data generator procs.

}

namespace eval acc_fin {}

ad_proc -private acc_fin::example_table {
    {table_ref ""}
} {
    Returns a list of 3 items. index 0 is table title; index 1 is table description, index 2 is table in data entry format, commas between columns, spaces between multiple items in same row and column;  
} {
    set ret_list ""
    switch -exact $table_ref {
        p10a {
            # goes with p20a
            set ret_list [list [list name value] [activity_table_name "WikipediaPERT"] [list time_est_short 5 ] [list time_est_median 8] [list time_est_long 12] [time_probability_moment 0.5]]
        }
        p11b {
            # goes with p20b
            set ret_list [list [list name value] [activity_table_name "WikipediaPERTchart"]]
        }
        p20a {
            set ret_list [list "Wikipedia PERT" "This is an example from PERT entry of Wikipedia. See entry for details: http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique" "activity_ref,time_est_short,time_est_med,time_est_long,time_ext,dependent_tasks\n
A,2,4,6,4.0\n
B,3,5,9,5.33\n
C,4,5,7,5.17\n
D,4,6,10,6.33\n
E,4,5,7,5.17\n
F,3,4,8,4.5\n
G,3,5,8,5.17\n" ]
        }
        p20b {
            set ret_list [list "Wikipedia PERT chart" "This is an example rendered from a chart image in the PERT entry of Wikipedia. See image for details: http://en.wikipedia.org/wiki/File:Pert_chart_colored.svg" "activity_ref,time_est_med,dependent_tasks,color\n
10,0,,grey\n
A,3,10,green\n
B,4,10,green\n
20,0,B,grey\n
30,0,A,grey\n
D,1,30,blue\n
40,0,D,grey\n
F,3,40,brown\n
C,3,20,brown\n
50,0,F E C,grey\n"

        }
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
            #      max_overlap_pct     defaults to type's max_overlap_pct021
            
            #      time_est_short         estimated shortest duration. (Lowest statistical deviation value)
            #      time_est_median        estimated median duration. (Statistically, half of deviations are more or less than this.) 
            #      time_est_long          esimated longest duration. (Highest statistical deviation value.)
            #      time_dist_curve_tid Use this distribution curve instead of the time_est short, median and long values
            #                             Consider using a variation of task_type as a reference
            #      time_dist_curv_eq  Use this distribution curve equation instead.
            
            #      cost_est_low           estimated lowest cost. (Lowest statistical deviation value.)
            #      cost_est_median        estimated median cost. (Statistically, half of deviations are more or less than this.)
            #      cost_est_high          esimage highest cost. (Highest statistical deviation value.)
            #      cost_dist_curve_tid Use this distribution curve instead of equation and value defaults
            #      cost_dist_curv_eq  Use this distribution curve equation. 
            #
            #      RESERVED columns:
            #      _tCurveRef             integer reference to time curve in time_clarr and   time duration estimate at time_probability_moment in t_est_arr
            #      _cCurveRef             integer reference to cost curve in cost_clarr and   cost duration estimate at cost_probability_moment in c_est_arr
            set ret_list [list activity_ref aid_type dependent_tasks name description max_concurrent max_overlap_pct time_est_short time_est_median time_est_long time_dist_curve_tid time_dist_curve_name time_probability_moment cost_est_low cost_est_median cost_est_high cost_dist_curve_tid cost_dist_curve_name cost_probability_moment]

        }
        p21 {
            set ret_list [list activity_ref dependent_tasks]
        }
        p30 {
            # p3 Task Types:   
            #      type
            #      dependent_types      Other dependent types required by this type. (possible reference collisions. type_refs != activity_refs.
            #
            #####                       dependent_types should be checked against activity_dependents' types 
            #                           to confirm that all dependencies are satisified.
            #      name
            #      description
            #      max_concurrent       (as an integer, blank = no limit)
            #      max_overlap_pct021  (as a percentage from 0 to 1, blank = 1)
            #
            #      RESERVED columns:
            #      _tCurveRef             integer reference to time curve in time_clarr and   time duration estimate at time_probability_moment in t_est_arr
            #      _cCurveRef             integer reference to cost curve in cost_clarr and   cost duration estimate at cost_probability_moment in c_est_arr
            set ret_list [list type dependent_tasks dependent_types name description max_concurrent max_overlap_pct activity_table_tid activity_table_name task_types_tid task_types_name time_dist_curve_name time_dist_curve_tid cost_dist_curve_name cost_dist_curve_tid time_est_short time_est_median time_est_long time_probability_moment cost_est_low cost_est_median cost_est_high cost_probability_moment db_format]            
        }
        p31 {
            set ret_list [list type]
            # if changing p3 or p2 lists, see also constants_woc_list in this file.
        }
        p40 {
            # each column is track_{number} and generated by code so not used in this context

            # p4 Display modes
            #  
            #  tracks within n% of CP duration, n represented as %12100 or a duration of time as total lead slack
            #  tracks w/ n fixed count closest to CP duration. A n=1 shows CP track only.
            #  tracks that contain at least 1 CP track 
            set ret_list [list track_1]
        }
        p41 {
            # each column is track_{number} and generated by code so not used in this context
            set ret_list [list track_1]
        }
        p50 {
            # each row is a cell, in format of detailed PRETTI internal output. See code. All columns are required to reproduce output to p4 (including p4 comments).

            set ret_list [list activity_ref activity_seq_num dependencies_q cp_q significant_q popularity waypoint_duration activity_time direct_dependencies activity_cost waypoint_cost]
        }
        p51 {
            # each row is a cell, in format of detailed PRETTI internal output. See code. 
            set ret_list [list activity_ref activity_seq_num dependencies_q cp_q significant_q popularity waypoint_duration activity_time direct_dependencies activity_cost waypoint_cost]
        }
        dc0 {
            # dc2 distribution curve table
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
            set ret_list [list y x label]
        }
        dc1 {
            set ret_list [list y x]
        }
        default {
            ns_log Notice "acc_fin::pretti_columns_list (242): bad reference sref '$sref'. Returning blank list."
            set ret_list [list ]
        }
    }
    return $ret_list
}

ad_proc -private acc_fin::pretti_example_maker {
    {name_value_list ""}
} {
    Creates a randomized scenario with accompanying required tables, mainly used for testing. Pass a list of optional arguments as a list of name-value pairs; See code for options.
} {
    # scenario_prettify requires:
    # p1 scenario table
    # p2 activity table
    # optional:
    # p3 activity_type table
    # dc distribution curves
    
    # p1 data refers to p2 table. Create p2 table before p1.
    # p2 data refers to dc or p3 tables. Create dc or p3 tables before p2.

    # acts = accounts count
    # cols = columns count
    # types = types count
    # dots = points count
    set dc1_list [acc_fin::pretti_columns_list dc 1]
    set dc1_len [llength $dc1_list]
    set dc0_list [acc_fin::pretti_columns_list dc 0]
    set dc0_len [llength $dc0_list]
    set p11_list [acc_fin::pretti_columns_list p1 1]
    set p11_len [llength $p11_list]
    set p10_list [acc_fin::pretti_columns_list p1 0]
    set p10_len [llength $p10_list]
    set p21_list [acc_fin::pretti_columns_list p2 1]
    set p21_len [llength $p21_list]
    set p20_list [acc_fin::pretti_columns_list p2 0]
    set p20_len [llength $p20_list]
    set p31_list [acc_fin::pretti_columns_list p3 1]
    set p31_len [llength $p31_list]
    set p30_list [acc_fin::pretti_columns_list p3 0]
    set p30_len [llength $p30_list]

    set param_arr(dc_count_min) 0
    set param_arr(dc_count_max) 5
    set param_arr(dc_count) [expr { int( rand() * ( $param_arr(dc_count_max) - $param_arr(dc_count_min) + .99 ) ) + $param_arr(dc_count_min) } ]
    set param_arr(dc_dots_min) 0
    set param_arr(dc_dots_max) 10
    set param_arr(dc_cols_min) $dc1_len
    set param_arr(dc_cols_max) $dc0_len

    
    set param_arr(p3_types_min) 0
    set param_arr(p3_types_max) 120
    set param_arr(p3_cols_min) $p31_len
    set param_arr(p3_cols_max) $p30_len
    set param_arr(p3_cols) [expr { int( rand() * ( $param_arr(p3_cols_max) - $param_arr(p3_cols_min) + .99 ) ) + $param_arr(p3_cols_min) } ]

    set param_arr(p2_acts_max) 100
    set param_arr(p2_acts_min) 20
    set param_arr(p2_cols_min) $p21_len
    set param_arr(p2_cols_max) $p20_len
    set param_arr(p2_cols) [expr { int( rand() * ( $param_arr(p2_cols_max) - $param_arr(p2_cols_min) + .99 ) ) + $param_arr(p2_cols_min) } ]

    set param_arr(p1_vals_min) $p11_len
    set param_arr(p1_vals_max) $p10_len
    set param_arr(p1_cols) [expr { int( rand() * ( $param_arr(p1_cols_max) - $param_arr(p1_cols_min) + .99 ) ) + $param_arr(p1_cols_min) } ]

    # blank means column inclusion is randomized. Otherwise list specific columns to try/use
    # acc_fin::pretti_columns_list is a handy column name reference
    set param_arr(p1_req_cols) ""
    set param_arr(p2_req_cols) ""
    set param_arr(p3_req_cols) ""
    # Use an existing case to test..??? not implemented.

    # Add optional arguments
    # ie generative parameters
    foreach {name value} $name_value_list {
        if { [info exists param_arr($name) ] } {
            set param_arr($name) $value
        }
    }
    
    # dc
    for {set i 0} { $i < $param_arr(dc_count) } { incr i } {
        set dc_larr($i) [list ]
        set param_arr(dc_cols) [expr { int( rand() * ( $param_arr(dc_cols_max) - $param_arr(dc_cols_min) + .99 ) ) + $param_arr(dc_cols_min) } ]
        set title_list $dc1_list
        set cols_diff [expr { $param_arr(dc_cols) -  [llength $title_list] } ]
        if { $cols_diff > 0 } {
            lappend title_list [lindex $dc0_list [expr { $dc0_len - $dc1_len - 1 } ] ]
        }
        lappend dc_larr($i) $title_list
        set param_arr(dc_dots) [expr { int( rand() * ( $param_arr(dc_dots_max) - $param_arr(dc_dots_min) + .99 ) ) + $param_arr(dc_dots_min) } ]
        for { set i 0} {$i < $param_arr(dc_dots)} {incr i} {
            # dist curve point
            foreach title $title_list {
                set row_list [list ]
                switch -exact $title {
                    x { 
                        # a random amount, assume hours for a task for example
                        set dot(x) [expr { int( rand() * 256. + 5. ) / 6. } ]
                    }
                    y {
                        # these could be usd or btc for example
                        set dot(y) [expr { int( rand() * 30000. + 90. ) / 100. } ]
                    }
                    label {
                        set dot(label) [ad_generate_random_string]
                    }
                }
                lappend row_list $dot($title)
            }
            # add row
            lappend dc_larr($i) $row_list
        }
        # save dc curve
        set dc_comments_arr($i) "This is a test table representing a distribution curve (dc)"
        set dc_name_arr($i) "dc-[ad_generate_random_string] [ad_generate_random_string]"
        set dc_title_arr($i) [string title $dc_name_arr($i)]
        set dc_table_id_arr($i) [qss_table_create $dc_larr($i) $dc_name_arr($i) $dc_title_arr($i) $dc_comments_arr($i) "" dc $package_id $user_id]
        #####
    }
    

    # p3
    set p3_larr($i) [list ]
    set param_arr(p3_cols) [expr { int( rand() * ( $param_arr(p3_cols_max) - $param_arr(p3_cols_min) + .99 ) ) + $param_arr(p3_cols_min) } ]
    # required: type
    set title_list $p31_list
    set cols_diff [expr { $param_arr(p3_cols) -  [llength $title_list] } ]
    if { $cols_diff > 0 } {
        # Try to make some sane choices by choosing groups of titles with consistency
        # sane groupings of titles:
        if { $cols_diff > 3 } {
            # time_est_short time_est_median time_est_long
            lappend title_list time_est_short time_est_median time_est_long
            incr cols_diff -3
        }
        if { $cols_diff > 3 } {
            # cost_est_low cost_est_median cost_est_high 
            lappend cost_est_low cost_est_median cost_est_high 
            incr cols_diff -3
        }
        # ungrouped ones can include partial groupings:
        # max_concurrent max_overlap_pct
        # time_dist_curve_name time_dist_curve_tid 
        # name description
        # cost_dist_curve_name cost_dist_curve_tid 
        # time_est_short time_est_median time_est_long
        # cost_est_low cost_est_median cost_est_high 

        # dependent_tasks
        # dependent_types --not implemented

        set ungrouped_list $p30_list
        foreach title $title_list {
            # remove existing title from ungrouped_list
            set title_idx [lsearch -exact $ungrouped_list $title]
            if { $title_idx > 0 } {
                set ungrouped_list [lreplace $ungrouped_list $title_idx $title_idx]
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.327: title '$title' not found in p30 title list '${ungrouped_list}'"
            }
        }
        set ungrouped_len [llength $ungrouped_list]
        # set cols_diff expr $param_arr(p3_cols) - llength $title_list
        while { $cols_diff > 0 && $ungrouped_len > 0}
        # Select a random column to add to title_list
        set rand_idx [expr { int( rand() * $ungrouped_len ) } ]
        lappend title_list [lindex $ungrouped_list $rand_idx]
        set ungrouped_list [lreplace $ungrouped_list $rand_idx $rand_idx]
        set ungrouped_len [llength $ungrouped_list]
        incr cols_diff -1
    }
    lappend p3_larr($i) $title_list
    set p2_types_list [list ]
    set param_arr(p3_types) [expr { int( rand() * ( $param_arr(p3_types_max) - $param_arr(p3_types_min) + .99 ) ) + $param_arr(p3_types_min) } ]
    for { set i 0} {$i < $param_arr(p3_types)} {incr i} {
        # dist curve point
        foreach title $title_list {
            set row_list [list ]
            switch -exact $title {
                time_est_short  -
                time_est_median -
                time_est_long   { 
                    # a random amount, assume hours for a task for example
                    set row_arr($title) [expr { int( rand() * 256. + 5. ) / 6. } ]
                }
                cost_est_low    -
                cost_est_median - 
                cost_est_high   {
                    # these could be usd or btc for example
                    set row_arr($title) [expr { int( rand() * 30000. + 90. ) / 100. } ]
                }
                max_concurrent {
                    set row_arr($title) [expr { int( rand() * 12 ) + 1 } ]
                }
                max_overlap_pct {
                    set row_arr($title) [expr { int( rand() * 1000. ) / 1000. } ]
                }
                cost_dist_curve_name -
                time_dist_curve_name {
                    set x [expr { int( rand() * $param_arr(dc_count) ) } ]
                    set row_arr($title) $dc_name_arr($x)
                }
                cost_dist_curve_tid -
                time_dist_curve_tid {
                    set x [expr { int( rand() * $param_arr(dc_count) ) } ]
                    set row_arr($title) $dc_table_id_arr($x)
                }
                name        -
                description {
                    set row_arr($title) [ad_generate_random_string]
                }
                type {
                    set row_arr($title) [ad_generate_random_string]
                    # add to a list for referencing in p2 form for later
                    lappend p2_types_list $row_arr($title)

                }

            }
            lappend row_list $dot($title)
        }
        # add row
        lappend p3_larr($i) $row_list
    }
    # save p3 curve
    set p3_comments "This is a test table of PRETTI activity types (p3)"
    set p3_name "p3-[ad_generate_random_string] [ad_generate_random_string]"
    set p3_title [string title ${p3_name}]
    set p3_table_id [qss_table_create $p3_larr($i) ${p3_name} ${p3_title} $p3_comments "" p3 $package_id $user_id ]

    # p2
    ###### copied p3 to p2, need to fit specifically to p2..
    set p2_larr($i) [list ]
    set param_arr(p2_cols) [expr { int( rand() * ( $param_arr(p2_cols_max) - $param_arr(p2_cols_min) + .99 ) ) + $param_arr(p2_cols_min) } ]
    # required: type
    set title_list $p21_list
    set cols_diff [expr { $param_arr(p2_cols) -  [llength $title_list] } ]
    if { $cols_diff > 0 } {
        # Try to make some sane choices by choosing groups of titles with consistency
        # sane groupings of titles:
        if { $cols_diff > 3 } {
            # time_est_short time_est_median time_est_long
            lappend title_list time_est_short time_est_median time_est_long
            incr cols_diff -3
        }
        if { $cols_diff > 3 } {
            # cost_est_low cost_est_median cost_est_high 
            lappend cost_est_low cost_est_median cost_est_high 
            incr cols_diff -3
        }
        # ungrouped ones can include partial groupings:
        # max_concurrent max_overlap_pct
        # time_dist_curve_name time_dist_curve_tid 
        # name description
        # cost_dist_curve_name cost_dist_curve_tid 
        # time_est_short time_est_median time_est_long
        # cost_est_low cost_est_median cost_est_high 

        # dependent_tasks
        # dependent_types --not implemented

        set ungrouped_list $p20_list
        foreach title $title_list {
            # remove existing title from ungrouped_list
            set title_idx [lsearch -exact $ungrouped_list $title]
            if { $title_idx > 0 } {
                set ungrouped_list [lreplace $ungrouped_list $title_idx $title_idx]
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.327: title '$title' not found in p20 title list '${ungrouped_list}'"
            }
        }
        set ungrouped_len [llength $ungrouped_list]
        # set cols_diff expr $param_arr(p2_cols) - llength $title_list
        while { $cols_diff > 0 && $ungrouped_len > 0}
        # Select a random column to add to title_list
        set rand_idx [expr { int( rand() * $ungrouped_len ) } ]
        lappend title_list [lindex $ungrouped_list $rand_idx]
        set ungrouped_list [lreplace $ungrouped_list $rand_idx $rand_idx]
        set ungrouped_len [llength $ungrouped_list]
        incr cols_diff -1
    }
    lappend p2_larr($i) $title_list
    set p2_types_len [llength $p2_types_list]
    set param_arr(p2_types) [expr { int( rand() * ( $param_arr(p2_types_max) - $param_arr(p2_types_min) + .99 ) ) + $param_arr(p2_types_min) } ]
    set p3_to_p2_count_ratio [expr { $param_arr(p2_types) / $p2_types_len } ]
    set p2_act_list [list ]
    for { set i 0} {$i < $param_arr(p2_types)} {incr i} {
        # dist curve point
        foreach title $title_list {
            set row_list [list ]
            switch -exact $title {
                time_est_short  -
                time_est_median -
                time_est_long   { 
                    # a random amount, assume hours for a task for example
                    set row_arr($title) [expr { int( rand() * 256. + 5. ) / 6. } ]
                }
                cost_est_low    -
                cost_est_median - 
                cost_est_high   {
                    # these could be usd or btc for example
                    set row_arr($title) [expr { int( rand() * 30000. + 90. ) / 100. } ]
                }
                max_concurrent {
                    set row_arr($title) [expr { int( rand() * 12 ) + 1 } ]
                }
                max_overlap_pct {
                    set row_arr($title) [expr { int( rand() * 1000. ) / 1000. } ]
                }
                cost_dist_curve_name -
                time_dist_curve_name {
                    set x [expr { int( rand() * $param_arr(dc_count) ) } ]
                    set row_arr($title) $dc_name_arr($x)
                }
                cost_dist_curve_tid -
                time_dist_curve_tid {
                    set x [expr { int( rand() * $param_arr(dc_count) ) } ]
                    set row_arr($title) $dc_table_id_arr($x)
                }
                activity_ref {
                    set row_arr($title) [ad_generate_random_string]
                    lappend p2_act_list $row_arr($title)
                }
                name        -
                description {
                    set row_arr($title) [ad_generate_random_string]
                }
                aid_type {
                    # choose some blank types
                    set x [expr { int( rand() * $p2_types_len * 2. ) } ]
                    set row_arr($title) [lindex $p2_types_list $x]
                }
                dependent_tasks {
                    # directly dependent
                    set row_arr($title) ""
                    set count [expr { int( pow( rand() * 2. , rand() * 3. ) ) } ]
                    set ii 1
                    while { $ii < $count } {
                        set x [expr { int( rand() * $i ) } ]
                        append row_arr($title) " "
                        append row_arr($title) [lindex $p2_act_list $x]
                    }
                }
            }
            lappend row_list $dot($title)
        }
        # add row
        lappend p2_larr($i) $row_list
    }
    # save p2 curve
    set p2_comments "This is a test table of PRETTI activity table (p2)"
    set p2_name "p2-[ad_generate_random_string] [ad_generate_random_string]"
    set p2_title [string title ${p2_name}]
    set p2_table_id [qss_table_create $p2_larr($i) ${p2_name} ${p2_title} $p2_comments "" p2 $package_id $user_id ]

    # p1
    # activity_table_tid 
    # activity_table_name task_types_tid 
    # task_types_name 
    # time_dist_curve_name time_dist_curve_tid 
    # cost_dist_curve_name cost_dist_curve_tid 
    # time_est_short time_est_median time_est_long 
    # time_probability_moment 
    # cost_est_low cost_est_median cost_est_high 
    # cost_probability_moment 
    # db_format (1 or 0) saves p5 report table if db_format ne ""




    return 1
}