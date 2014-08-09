set legend_html ""

# create a list of cells from highest priority to lowest.
     set on_cp_list [list  1  0  0  0  0  0  0 0 0 0 0 0 0 0 0 0 -1]
    set on_sig_list [list  1  1  1  1  1  1  1 1 1 0 0 0 0 0 0 0  0]
set popularity_list [list 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1  0]
set max_act_count_per_track 16
set color_cp_mask_idx 3
set color_sig_mask_idx 5
# from acc_fin::pretti_table_to_html

# build formatting colors

set hex_list [list 0 1 2 3 4 5 6 7 8 9 a b c d e f]
set bin_list [list 000 100 010 110 001 101 011 111]

set color_cp_mask [lindex $bin_list $color_cp_mask_idx]
set color_cp_mask_list [split $color_cp_mask ""]
set color_sig_mask [lindex $bin_list $color_sig_mask_idx]
set color_sig_mask_list [split $color_sig_mask ""]

#set k1 [expr { $row_count / $cp_duration_at_pm } ]
set k2 [expr {  7. / $max_act_count_per_track } ]

# ..
set legend_color0_list [list ]
set legend_color1_list [list ]
set legend_grey0_list [list ]
set legend_grey1_list [list ]

for {set odd_row_p 1} {$odd_row_p > -1} {incr odd_row_p -1} {

    for {set i 0} {$i < 17} {incr i} {
        set on_cp_p [lindex $on_cp_list $i]
        set act_on_cp_p $on_cp_p
        set on_a_sig_path_p [lindex $on_sig_list $i]
        set popularity [lindex $popularity_list $i]

        if { $on_cp_p > -1 } {


            # ..from acc_fin::pretti_table_to_html

            if { $on_cp_p || $act_on_cp_p } {
                set color_mask_list $color_cp_mask_list
                set c(1) 15
            } else {
                set color_mask_list $color_sig_mask_list
                set c(1) [f::max 1 [f::min 15 [expr { int( ( 9 * $on_a_sig_path_p ) + $popularity * $k2 ) } ]]]
            }
            set c(0) [expr { 15 - $c(1) } ]
            set colorhex ""

            if { $odd_row_p } {
                incr c(1) -1
            }

            foreach digit $color_mask_list {
                append colorhex [lindex $hex_list $c($digit) ]
                append colorhex "f"
            }
            if { [string length $colorhex] != 6 } {
                ns_log Notice "accounts-finance/lib/pretti-p4-legend.914: row_nbr '${row_nbr}' cell_nbr '${cell_nbr}' odd_row_p '${odd_row_p}' row_size '${row_size}' activity_time_expected '${activity_time_expected}'"
                ns_log Notice "accounts-finance/lib/pretti-p4-legend.915: issue colorhex '$colorhex' on_a_sig_path_p ${on_a_sig_path_p} popularity $popularity on_cp_p $on_cp_p c(0) '$c(0)' c(1) '$c(1)' color_mask_list '${color_mask_list}'"
            }
        } else {
            set cell "&nbsp;"
            set colorhex "999999"
        }
        lappend legend_color${odd_row_p}_list $colorhex
        if { [info exists grey($colorhex) ] } {
             lappend legend_grey${odd_row_p}_list $grey($colorhex)
        } else {
            set grey($colorhex) [acc_fin::gray_from_color $colorhex]
            lappend legend_grey${odd_row_p}_list $grey($colorhex)
        }
    }
}
set legend_html [qss_list_of_lists_to_html_table [list $legend_color1_list $legend_color0_list $legend_grey1_list $legend_grey0_list] "" ""]
