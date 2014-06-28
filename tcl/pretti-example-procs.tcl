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
50,0,F E C,grey\n"]

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
            set ret_list acc_fin::pretti_columns_list p2 0
            
        }
        p21 {
            set ret_list acc_fin::pretti_columns_list p2 1
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
            set ret_list acc_fin::pretti_columns_list p3 0
        }
        p31 {
            set ret_list acc_fin::pretti_columns_list p3 1
            # if changing p3 or p2 lists, see also constants_woc_list in this file.
        }
        p40 {
            # each column is track_{number} and generated by code so not used in this context

            # p4 Display modes
            #  
            #  tracks within n% of CP duration, n represented as %12100 or a duration of time as total lead slack
            #  tracks w/ n fixed count closest to CP duration. A n=1 shows CP track only.
            #  tracks that contain at least 1 CP track 
            set ret_list acc_fin::pretti_columns_list p4 0
        }
        p41 {
            # each column is track_{number} and generated by code so not used in this context
            set ret_list acc_fin::pretti_columns_list p4 1
        }
        p50 {
            # each row is a cell, in format of detailed PRETTI internal output. See code. All columns are required to reproduce output to p4 (including p4 comments).
            set ret_list acc_fin::pretti_columns_list p5 0
        }
        p51 {
            # each row is a cell, in format of detailed PRETTI internal output. See code. 
            set ret_list acc_fin::pretti_columns_list p5 1
        }
        p60 {
            # each row is a cell, in format of detailed PRETTI internal output. See code. All columns are required to reproduce output to p4 (including p4 comments).
            set ret_list acc_fin::pretti_columns_list p6 0
        }
        p61 {
            # each row is a path, in format of detailed PRETTI internal output. See code. 
            set ret_list acc_fin::pretti_columns_list p6 1
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
            set ret_list acc_fin::pretti_columns_list dc 0
        }
        dc1 {
            set ret_list acc_fin::pretti_columns_list dc 1
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
    {package_id ""}
    {user_id ""}
} {
    Creates a randomized scenario with accompanying required tables, mainly used for testing. Pass a list of optional arguments as a list of name-value pairs; See code for options.
} {
    set randomseed [expr { wide( [clock seconds] / 360 ) }] 
    #set random [expr { wide( fmod( $random * 38629 , 279470273 ) * 71 ) } ]
     set random [expr { srand($randomseed) } ]


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
    set param_arr(dc_count) [expr { int( [random] * ( $param_arr(dc_count_max) - $param_arr(dc_count_min) ) + .99 ) + $param_arr(dc_count_min) } ]
    set param_arr(dc_dots_min) 0
    set param_arr(dc_dots_max) 10
    set param_arr(dc_cols_min) $dc1_len
    set param_arr(dc_cols_max) $dc0_len

    
    set param_arr(p3_types_min) 0
    set param_arr(p3_types_max) 120
    set param_arr(p3_cols_min) $p31_len
    set param_arr(p3_cols_max) $p30_len
#    set param_arr(p3_cols) [expr { int( [random] * ( $param_arr(p3_cols_max) - $param_arr(p3_cols_min) + .99 ) ) + $param_arr(p3_cols_min) } ]

    set param_arr(p2_acts_max) 100
    set param_arr(p2_acts_min) 20
    set param_arr(p2_cols_min) $p21_len
    set param_arr(p2_cols_max) $p20_len
#    set param_arr(p2_cols) [expr { int( [random] * ( $param_arr(p2_cols_max) - $param_arr(p2_cols_min) + .99 ) ) + $param_arr(p2_cols_min) } ]

    set param_arr(p1_vals_min) $p11_len
    set param_arr(p1_vals_max) $p10_len
#    set param_arr(p1_vals) [expr { int( [random] * ( $param_arr(p1_vals_max) - $param_arr(p1_vals_min) + .99 ) ) + $param_arr(p1_vals_min) } ]

    # blank means column inclusion is randomized. Otherwise list specific columns to try/use
    # acc_fin::pretti_columns_list is a handy column name reference
    set param_arr(p1_req_vals) ""
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
    ns_log Notice "acc_fin::pretti_example_maker.248 dc start"
    for {set i 0} { $i < $param_arr(dc_count) } { incr i } {
        set dc_larr($i) [list ]
        set param_arr(dc_cols) [expr { int( [random] * ( $param_arr(dc_cols_max) - $param_arr(dc_cols_min) + .99 ) ) + $param_arr(dc_cols_min) } ]
        set title_list $dc1_list
        set cols_diff [expr { $param_arr(dc_cols) -  [llength $title_list] } ]
        if { $cols_diff > 0 } {
            lappend title_list [lindex $dc0_list end]
        }
        set title_list [acc_fin::shuffle_list $title_list]
        lappend dc_larr($i) $title_list
        set param_arr(dc_dots) [expr { int( [random] * ( $param_arr(dc_dots_max) - $param_arr(dc_dots_min) + .99 ) ) + $param_arr(dc_dots_min) } ]
        for { set ii 0} {$ii < $param_arr(dc_dots)} {incr ii} {
            # dist curve point
            set row_list [list ]
            foreach title $title_list {
                switch -exact $title {
                    x { 
                        # a random amount, assume hours for a task for example
                        set dot(x) [expr { int( [random] * 256. + 5. ) / 6. } ]
                    }
                    y {
                        # these could be usd or btc for example
                        set dot(y) [expr { int( [random] * 30000. + 90. ) / 100. } ]
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
        set dc_title_arr($i) [string totitle $dc_name_arr($i)]
        set type_guess [acc_fin::pretti_type_flag $dc_larr($i) ]
        if { $type_guess ne "dc" } {
            ns_log Notice "acc_fin::pretti_example_maker type should be 'dc'. Instead type_guess '$type_guess'"
        }
#        ns_log Notice "acc_fin::pretti_example_maker.289 dc saving dc_larr($i): $dc_larr($i)"
        set dc_table_id_arr($i) [qss_table_create $dc_larr($i) $dc_name_arr($i) $dc_title_arr($i) $dc_comments_arr($i) "" $type_guess $package_id $user_id]
        
    }
    

    # p3
    ns_log Notice "acc_fin::pretti_example_maker.294 p3 start"
    set p3_larr [list ]
    set param_arr(p3_cols) [expr { int( [random] * ( $param_arr(p3_cols_max) - $param_arr(p3_cols_min) + .99 ) ) + $param_arr(p3_cols_min) } ]
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
            lappend title_list cost_est_low cost_est_median cost_est_high 
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
            if { $title_idx > -1 } {
                set ungrouped_list [lreplace $ungrouped_list $title_idx $title_idx]
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.327: title '$title' not found in p30 title list '${ungrouped_list}'"
            }
        }
        set ungrouped_len [llength $ungrouped_list]
        # set cols_diff expr $param_arr(p3_cols) - llength $title_list
        while { $cols_diff > 0 && $ungrouped_len > 0} {
            # Select a random column to add to title_list
            set rand_idx [expr { int( [random] * $ungrouped_len ) } ]
            lappend title_list [lindex $ungrouped_list $rand_idx]
            set ungrouped_list [lreplace $ungrouped_list $rand_idx $rand_idx]
            set ungrouped_len [llength $ungrouped_list]
            incr cols_diff -1
        }
    }
    set title_list [acc_fin::shuffle_list $title_list]
    lappend p3_larr $title_list
    set p2_cols_list [list ]
    set param_arr(p3_types) [expr { int( [random] * ( $param_arr(p3_types_max) - $param_arr(p3_types_min) + .99 ) ) + $param_arr(p3_types_min) } ]
    ns_log Notice "acc_fin::pretti_example_maker.357: title_list '$title_list'"
    for { set i 0} {$i < $param_arr(p3_types)} {incr i} {
        # new row
        set row_list [list ]
        foreach title $title_list {
            switch -exact $title {
                time_est_short  {
                    set row_arr($title) [expr { int( [random] * 256. + 5. ) / 24. } ]
                }
                time_est_median {
                    set row_arr($title) [expr { int( [random] * 256. + 10. ) / 12. } ]
                }
                time_est_long   { 
                    set row_arr($title) [expr { int( [random] * 256. + 20. ) / 6. } ]
                    # a random amount, assume hours for a task for example
                }
                cost_est_low    {
                    set row_arr($title) [expr { int( [random] * 100. + 90. ) / 100. } ]
                }
                cost_est_median {
                    set row_arr($title) [expr { int( [random] * 200. + 180. ) / 100. } ]
                }
                cost_est_high   {
                    set row_arr($title) [expr { int( [random] * 400. + 360. ) / 100. } ]
                    # these could be usd or btc for example
                }
                max_concurrent {
                    set row_arr($title) [expr { int( [random] * 12 ) + 1 } ]
                }
                max_overlap_pct {
                    set row_arr($title) [expr { int( [random] * 1000. ) / 1000. } ]
                }
                cost_dist_curve_name -
                time_dist_curve_name {
                    if { $param_arr(dc_count) > 0 } {
                        set x [expr { int( [random] * $param_arr(dc_count) * .9 ) } ]
                        set row_arr($title) $dc_name_arr($x)
                    } else {
                        set row_arr($title) ""
                    }
                }
                cost_dist_curve_tid -
                time_dist_curve_tid {
                    if { $param_arr(dc_count) > 0 } {
                        set x [expr { int( [random] * $param_arr(dc_count) * .9 ) } ]
                        set row_arr($title) $dc_table_id_arr($x)
                    } else {
                        set row_arr($title) ""
                    }
                }
                name        -
                description {
                    set row_arr($title) [ad_generate_random_string]
                }
                type {
                    set row_arr($title) [ad_generate_random_string]
                    # add to a list for referencing in p2 form for later
                    lappend p2_cols_list $row_arr($title)

                }
                dependent_tasks -
                dependent_types {
                    set row_arr($title) ""
                }
                default {
                    ns_log Notice "acc_fin::pretti_example_maker.394: no switch option for '$title'"
                }
            }
            if { [info exists row_arr($title) ] } {
                lappend row_list $row_arr($title)
                array unset row_arr
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.396: no switch option for '$title'"
                lappend row_list ""
            }
        }
        # add row
        lappend p3_larr $row_list
    }
    # save p3 curve
    set p3_comments "This is a test table of PRETTI activity types (p3)"
    set p3_name "p3-[ad_generate_random_string] [ad_generate_random_string]"
    set p3_title [string totitle ${p3_name}]
    set type_guess [acc_fin::pretti_type_flag $p3_larr ]
    if { $type_guess ne "p3" } {
        ns_log Notice "acc_fin::pretti_example_maker type should be 'p3'. Instead type_guess '$type_guess'"
    }

    set p3_table_id [qss_table_create $p3_larr ${p3_name} ${p3_title} $p3_comments "" $type_guess $package_id $user_id ]

    # p2
    ns_log Notice "acc_fin::pretti_example_maker.419 p2 start"
    set p2_larr [list ]
    set param_arr(p2_cols) [expr { int( [random] * ( $param_arr(p2_cols_max) - $param_arr(p2_cols_min) + .99 ) ) + $param_arr(p2_cols_min) } ]
    # required: type
    set title_list $p21_list
    set cols_diff [expr { $param_arr(p2_cols) -  [llength $title_list] } ]
#    ns_log Notice "acc_fin::pretti_example_maker.434 cols_diff $cols_diff param_arr(p2_cols) '$param_arr(p2_cols)' title_list $title_list"
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
            lappend title_list cost_est_low cost_est_median cost_est_high 
            incr cols_diff -3
        }
#        ns_log Notice "acc_fin::pretti_example_maker.448 cols_diff $cols_diff title_list $title_list"
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
#        ns_log Notice "acc_fin::pretti_example_maker.430: ungrouped_list $ungrouped_list"
        foreach title $title_list {
            # remove existing title from ungrouped_list
            set title_idx [lsearch -exact $ungrouped_list $title]
            if { $title_idx > -1 } {
                set ungrouped_list [lreplace $ungrouped_list $title_idx $title_idx]
#                ns_log Notice "acc_fin::pretti_example_maker.432: title_idx $title_idx"
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.435: title '$title' not found in p20 title list '${ungrouped_list}'"
            }
        }
        set ungrouped_len [llength $ungrouped_list]
        # set cols_diff expr $param_arr(p2_cols) - llength $title_list
#        ns_log Notice "acc_fin::pretti_example_maker.480: ungrouped_len $ungrouped_len cols_diff $cols_diff"
        while { $cols_diff > 0 && $ungrouped_len > 0 } {
            # Select a random column to add to title_list
            set rand_idx [expr { int( [random] * $ungrouped_len ) } ]
            lappend title_list [lindex $ungrouped_list $rand_idx]
            set ungrouped_list [lreplace $ungrouped_list $rand_idx $rand_idx]
            set ungrouped_len [llength $ungrouped_list]
            incr cols_diff -1
#            ns_log Notice "acc_fin::pretti_example_maker.481: ungrouped_len $ungrouped_len rand_idx $rand_idx cols_diff $cols_diff"
        }
#        ns_log Notice "acc_fin::pretti_example_maker.489"
    }
#    ns_log Notice "acc_fin::pretti_example_maker.490"
    set title_list [acc_fin::shuffle_list $title_list]
    lappend p2_larr $title_list
    set p2_cols_len [llength $p2_cols_list]
    set param_arr(p2_cols) [expr { int( [random] * ( $param_arr(p2_cols_max) - $param_arr(p2_cols_min) + .99 ) ) + $param_arr(p2_cols_min) } ]
    set p3_to_p2_count_ratio [expr { $param_arr(p2_cols) / $p2_cols_len } ]
    set p2_act_list [list ]
#    ns_log Notice "acc_fin::pretti_example_maker.495: p2_cols_len $p2_cols_len p3_to_p2_count_ratio $p3_to_p2_count_ratio param_arr(p2_cols) title_list '$title_list'"
    for { set i 0} {$i < $param_arr(p2_cols)} {incr i} {
        # new row
#        ns_log Notice "acc_fin::pretti_example_maker.497: i $i"
        set row_list [list ]
        foreach title $title_list {
            switch -exact $title {
                time_est_short  {
                    set row_arr($title) [expr { int( [random] * 256. + 5. ) / 24. } ]
                }
                time_est_median {
                    set row_arr($title) [expr { int( [random] * 256. + 10. ) / 12. } ]
                }
                time_est_long   { 
                    # a random amount, assume hours for a task for example
                    set row_arr($title) [expr { int( [random] * 256. + 20. ) / 6. } ]
                }
                cost_est_low    {
                    set row_arr($title) [expr { int( [random] * 100. + 90. ) / 100. } ]
                }
                cost_est_median {
                    set row_arr($title) [expr { int( [random] * 200. + 180. ) / 100. } ]
                }
                cost_est_high   {
                    # these could be usd or btc for example
                    set row_arr($title) [expr { int( [random] * 400. + 360. ) / 100. } ]
                }
                max_concurrent {
                    set row_arr($title) [expr { int( [random] * 12 ) + 1 } ]
                }
                max_overlap_pct {
                    set row_arr($title) [expr { int( [random] * 1000. ) / 1000. } ]
                }
                cost_dist_curve_name -
                time_dist_curve_name {
                    if { $param_arr(dc_count) > 0 } {
                        set x [expr { int( [random] * $param_arr(dc_count) * .9 ) } ]
                        set row_arr($title) $dc_name_arr($x)
                    } else {
                        set row_arr($title) ""
                    }
                }
                cost_dist_curve_tid -
                time_dist_curve_tid {
                    if { $param_arr(dc_count) > 0 } {
                        set x [expr { int( [random] * $param_arr(dc_count) * .9 ) } ]
                        set row_arr($title) $dc_table_id_arr($x)
                    } else {
                        set row_arr($title) ""
                    }
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
                    set x [expr { int( [random] * $p2_cols_len * 2. ) } ]
                    if { $x < $p2_cols_len } {
                        set row_arr($title) [lindex $p2_cols_list $x]
                    } else {
                        set row_arr($title) ""
                    }
                }
                dependent_tasks {
                    set row_arr($title) ""
                    set count [expr { int( pow( [random] * 2. , [random] * 3. ) ) } ]
                    set ii 1
                    set delim ""
                    while { $ii < $count } {
                        set x [expr { int( [random] * $i ) } ]
                        append row_arr($title) $delim
                        append row_arr($title) [lindex $p2_act_list $x]
                        incr ii
                        set delim " "
                    }
                }
                cost_probability_moment -
                time_probability_moment {
                    set row_arr($title) ""
                }
                default {
                    ns_log Notice "acc_fin::pretti_example_maker.520: shouldn't happen. no switch option for '$title'"
                }
            }
            if { [info exists row_arr($title) ] } {
                lappend row_list $row_arr($title)
                array unset row_arr
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.530: no switch option for '$title'"
                lappend row_list ""
            }

        }
        # add row
        lappend p2_larr $row_list
    }
    # save p2 curve
    set p2_comments "This is a test table of PRETTI activity table (p2)"
    set p2_name "p2-[ad_generate_random_string] [ad_generate_random_string]"
    set p2_title [string totitle ${p2_name}]
    set type_guess [acc_fin::pretti_type_flag $p2_larr ]
    if { $type_guess ne "p2" } {
        ns_log Notice "acc_fin::pretti_example_maker type should be 'p2'. Instead type_guess '$type_guess'"
    }

    set p2_table_id [qss_table_create $p2_larr ${p2_name} ${p2_title} $p2_comments "" $type_guess $package_id $user_id ]

    # p1
    ns_log Notice "acc_fin::pretti_example_maker.560 p1 start"
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
   
    set p1_larr [list ]
    set param_arr(p1_vals) [expr { int( [random] * ( $param_arr(p1_vals_max) - $param_arr(p1_vals_min) + .99 ) ) + $param_arr(p1_vals_min) } ]
    # required: name value
    set title_list [list name value]
    lappend p1_larr $title_list
        # p1: activity_table_tid 
        # activity_table_name task_types_tid task_types_name time_dist_curve_name time_dist_curve_tid cost_dist_curve_name cost_dist_curve_tid time_est_short time_est_median time_est_long time_probability_moment cost_est_low cost_est_median cost_est_high cost_probability_moment db_format
    set vals_list $p11_list
    set vals_diff [expr { $param_arr(p1_vals) -  [llength $p11_list] } ]
    if { $vals_diff > 0 } {
        # Try to make some sane choices by choosing groups of names with consistency
        # sane groupings of names:
        if { $vals_diff > 3 } {
            # time_est_short time_est_median time_est_long
            lappend vals_list time_est_short time_est_median time_est_long
            incr vals_diff -3
        }
        if { $vals_diff > 3 } {
            # cost_est_low cost_est_median cost_est_high 
            lappend vals_list cost_est_low cost_est_median cost_est_high 
            incr vals_diff -3
        }
        # ungrouped ones can include partial groupings:
        # task_types_tid task_types_name
        # time_dist_curve_name time_dist_curve_tid 
        # cost_dist_curve_name cost_dist_curve_tid 
        # db_format
        # cost_probability_moment
        # time_probability_moment

        # why not these: ?? max_concurrent max_overlap_pct
        # currently defaults are unlimited and 100% overlapp

        set ungrouped_list $p10_list
        foreach value $vals_list {
            # remove existing name from ungrouped_list
            set val_idx [lsearch -exact $ungrouped_list $value]
            if { $val_idx > -1 } {
                set ungrouped_list [lreplace $ungrouped_list $val_idx $val_idx]
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.573: value '$value' not found in p10 title list '${ungrouped_list}'"
            }
        }
        set ungrouped_len [llength $ungrouped_list]
        # set vals_diff expr $param_arr(p1_vals) - llength $title_list
        while { $vals_diff > 0 && $ungrouped_len > 0 } {
            # Select a random column to add to title_list
            set rand_idx [expr { int( [random] * $ungrouped_len ) } ]
            lappend vals_list [lindex $ungrouped_list $rand_idx]
            set ungrouped_list [lreplace $ungrouped_list $rand_idx $rand_idx]
            set ungrouped_len [llength $ungrouped_list]
#            ns_log Notice "acc_fin::pretti_example_maker.618: ungrouped_len $ungrouped_len rand_idx $rand_idx vals_diff $vals_diff"
            incr vals_diff -1
        }
    }
    set vals_list [acc_fin::shuffle_list $vals_list]
    set p1_types_len [llength $vals_list]
#    ns_log Notice "acc_fin::pretti_example_maker.662: vals_list '$vals_list'"
    
    foreach name $vals_list {
        set row_list [list ]
        switch -exact $name {
            time_est_short  {
                set row_arr($title) [expr { int( [random] * 256. + 5. ) / 24. } ]
            }
            time_est_median {
                set row_arr($title) [expr { int( [random] * 256. + 10. ) / 12. } ]
            }
            time_est_long   { 
                # a random amount, assume hours for a task for example
                set row_arr($title) [expr { int( [random] * 256. + 20. ) / 6. } ]
            }
            cost_est_low    {
                set row_arr($title) [expr { int( [random] * 100. + 90. ) / 100. } ]
            }
            cost_est_median {
                set row_arr($title) [expr { int( [random] * 200. + 180. ) / 100. } ]
            }
            cost_est_high   {
                # these could be usd or btc for example
                set row_arr($title) [expr { int( [random] * 400. + 360. ) / 100. } ]
            }
            cost_dist_curve_name -
            time_dist_curve_name {
                if { $param_arr(dc_count) > -1 } {
                    set x [expr { int( [random] * $param_arr(dc_count) ) } ]
                    set row_arr($title) $dc_name_arr($x)
                } else {
                    set row_arr($title) ""
                }
            }
            cost_dist_curve_tid -
            time_dist_curve_tid {
                if { $param_arr(dc_count) > 0 } {
                    set x [expr { int( [random] * $param_arr(dc_count) ) } ]
                    set row_arr($title) $dc_table_id_arr($x)
                } else {
                    set row_arr($title) ""
                }
            }
            task_types_tid {
                set row_arr($title) $p3_table_id
            }
            task_types_name {
                set row_arr($title) $p3_name
            }
            activity_table_tid {
                set row_arr($title) $p2_table_id
            }
            activity_table_name {
                set row_arr($title) $p2_name
            }
            db_format   -
            name        -
            description {
                set row_arr($title) [ad_generate_random_string]
            }
            max_concurrent {
                set row_arr($title) [expr { int( [random] * 12 ) } ]
            }
            max_overlap_pct         -
            cost_probability_moment -
            time_probability_moment {
                # round off to nearest percent ( 0.01 )
                set row_arr($title) [expr { int( [random] * 100. ) / 100. } ]
            }
        }
        if { [info exists row_arr($title) ] } {
            lappend row_list $name $row_arr($title)
            array unset row_arr
            # add row to p1 table
            lappend p1_larr $row_list
        } else {
            ns_log Notice "acc_fin::pretti_example_maker.673: no switch option for '$title'"
        }
    }
    # save p1 table
    set p1_comments "This is a test table of PRETTI scenario table (p1)"
    set p1_name "p1-[ad_generate_random_string] [ad_generate_random_string]"
    set p1_title [string totitle ${p1_name}]
    set type_guess [acc_fin::pretti_type_flag $p1_larr ]
    if { $type_guess ne "p1" } {
        ns_log Notice "acc_fin::pretti_example_maker.671 type should be 'p1'. Instead type_guess '$type_guess'"
    }

    set p1_table_id [qss_table_create $p1_larr ${p1_name} ${p1_title} $p1_comments "" $type_guess $package_id $user_id ]
    # create a most simple test case using same data
    set p1b_lists [list [list name value] [list activity_table_tid ${p2_table_id}] ]
    set p1b_comments "This is a minimum test of PRETTI scenario table (p1)"
    set p1b_name "p1-minimum [ad_generate_random_string]"
    set p1b_title [string totitle ${p1b_name}]

    set type_guess [acc_fin::pretti_type_flag $p1b_lists ]
    if { $type_guess ne "p1" } {
        ns_log Notice "acc_fin::pretti_example_maker.683 type should be 'p1'. Instead type_guess '$type_guess'"
    }
    set p1b_table_id [qss_table_create $p1b_lists ${p1b_name} ${p1b_title} $p1b_comments "" $type_guess $package_id $user_id ]
    # check that tables saved without error.
    set status 1
    foreach {name dc_table_id} [array get dc_table_id_arr] {
        if { $dc_table_id eq 0 } {
            set status 0
            ns_log Notice "acc_fin::pretti_example_maker.690 dc_table_id for $name is '${dc_table_id}' instead of > 0."
        }
    }
    if { $p1b_table_id eq 0 || $p1_table_id eq 0 || $p2_table_id eq 0 || $p3_table_id eq 0 } {
        set status 0
        ns_log Notice "acc_fin::pretti_example_maker.695 all s/b > 0: p1b_table_id '$p1b_table_id' p1_table_id '$p1_table_id' p2_table_id '$p2_table_id' p3_table_id '$p3_table_id'"
    }
    if { $status } {
        set status $p1_table_id
    }
    return $status
}
