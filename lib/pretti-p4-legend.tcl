set legend_html ""

     set on_cp_list [list 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1]
    set on_sig_list [list 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0]
set popularity_list [list 8 7 6 5 4 3 2 1 8 7 6 5 4 3 2 1 0]
set max_act_count_per_track [f::lmax $popularity_list ]
#set color_cp_mask_idx 3
#set color_sig_mask_idx 5

# ..
set legend_color0_list [list ]
set legend_color1_list [list ]
set legend_grey0_list [list ]
set legend_grey1_list [list ]

for {set odd_row_p 1} {$odd_row_p > -1} {incr odd_row_p -1} {
    set param_list [list ]
    for {set i 0} {$i < 17} {incr i} {
        set on_cp_p [lindex $on_cp_list $i]
        set on_a_sig_path_p [lindex $on_sig_list $i]
        set popularity [lindex $popularity_list $i]
        set colorhex [acc_fin::pretti_color_chooser $on_cp_p $on_a_sig_path_p $odd_row_p $popularity $max_act_count_per_track ]
        set cell $colorhex
        set popularity_pct [expr { int( 1000. * $popularity / $max_act_count_per_track ) / 10. } ]
        switch -exact -- $on_cp_p {
            -1 { 
                lappend param_list " inactive "
            }
            0 {
                lappend param_list "sig:${on_a_sig_path_p}&nbsp;p%${popularity_pct}"
            }
            1 {
                lappend param_list " cp "
            }
        }
        lappend legend_color${odd_row_p}_list $colorhex
        if { [info exists grey($colorhex) ] } {
             lappend legend_grey${odd_row_p}_list $grey($colorhex)
        } else {
            set grey($colorhex) [acc_fin::gray_from_color $colorhex]
            lappend legend_grey${odd_row_p}_list $grey($colorhex)
        }
    }
    lappend legend_content_list $param_list
}

set legend_table_list [list $legend_color1_list $legend_color0_list $legend_grey1_list $legend_grey0_list ]

set css_list [list]
foreach legend_row_list $legend_table_list {
    set css_row_list [list ]
    foreach color $legend_row_list {
        set css "background-color: #$color;"
        set attr_list [list style $css]
        lappend css_row_list $attr_list
    }
    lappend css_list $css_row_list
}
lappend legend_content_list [lindex $legend_content_list 0] [lindex $legend_content_list 1] 
set legend_html [qss_list_of_lists_to_html_table $legend_table_list [list style "border-style: solid; border-width: 1px; border-color: #999999;"] $css_list]
