ad_library {

    general procs with utility elsewhere and first used and thus defined in this package.
    @creation-date 8 August 2014
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public acc_fin::chart_file_names {
    chart_filename
    {instance_id ""}
} {
    Returns a list of standard paths used with generated charts. 
    ref 0 is OS pathname, ref 1 is web url, ref 2 is a temporary location while building chart
} {
    #ns_log Notice "acc_fin::chart_file_names.17: chart_filename $chart_filename instance_id $instance_id"
    regsub -all -- {[^a-zA-Z0-9\.\_\-]} $chart_filename {_} chart_filename
    if { ![string match -nocase "*.png" $chart_filename] } {
        append chart_filename ".png"
    }
    set acsroot [acs_root_dir]
    set tempdir [file join $acsroot "tmp"]
    set chart_webpath [acc_fin::file_web_pathname $instance_id]
    set chart_path [acc_fin::file_sys_pathname "" $chart_webpath $instance_id]
    # if chart_filename ne "" is always false..
    set file_append "/"
    append file_append ${chart_filename}
    append chart_path $file_append
    append chart_webpath $file_append
    append tempdir $file_append
    set name_list [list $chart_path $chart_webpath $tempdir]
    #ns_log Notice "acc_fin::chart_file_names.30: ${name_list}"
    return $name_list
}

ad_proc -public acc_fin::table_data_stats {
    {curve_list_name "curve_lists"}
    {x_list_name "maybe_x_list"}
    {y_list_name "maybe_y_list"}
    {x_min_name "x_min"}
    {x_max_name "x_max"}
    {y_min_name "y_min"}
    {y_max_name "y_max"}
    {x_sum_name "x_sum"}
    {y_sum_name "y_sum"}
} {
    Validates data, splits off the x and y data (if curve_list_name supplied), and gathers some statistics about it.
    Returns 1 if data validates, and values of x_min_name x_max_name y_min_name y_max_name x_list_name y_list_name via upvar
} {
    upvar 1 $curve_list_name curve_lists
    upvar 1 $x_list_name maybe_x_list
    upvar 1 $y_list_name maybe_y_list
    upvar 1 $x_min_name x_min
    upvar 1 $x_max_name x_max
    upvar 1 $y_min_name y_min
    upvar 1 $y_max_name y_max
    upvar 1 $x_sum_name x_sum
    upvar 1 $y_sum_name y_sum

    set error_p 0
    set maybe_x_list_len [llength $maybe_x_list ]
    set maybe_y_list_len [llength $maybe_y_list ]

    if { $curve_lists ne "" && $maybe_x_list eq "" && $maybe_y_list eq "" } {
        set table_titles_list [lindex $curve_lists 0]
        set table_data_list [lrange $curve_lists 1 end]
        set x_idx [lsearch -exact $table_titles_list "x"]
        set y_idx [lsearch -exact $table_titles_list "y"]
        set row_count [llength $table_data_list]
        if { $x_idx > -1 && $y_idx > -1 && $row_count > 0 } {
            
            # find min max x and y values and other preparations
            set row [lindex $table_data_list 0]
            set x_min [lindex $row $x_idx]
            set y_min [lindex $row $y_idx]
            set x_max $x_min
            set y_max $y_min
            set x_sum $x_min
            set y_sum $y_min
            set maybe_x_list [list $x_min]
            set maybe_y_list [list $y_min]
            foreach row [lrange $table_data_list 1 end]  {
                set x [lindex $row $x_idx]
                set y [lindex $row $y_idx]
                if { [ad_var_type_check_number_p $x] && [ad_var_type_check_number_p $y] } {
                    lappend maybe_x_list $x
                    lappend maybe_y_list $y
                    set maybe_x_list_len [llength $maybe_x_list ]
                    set x_sum [expr { $x_sum + abs( $x ) } ]
                    if { $y > $y_max } {
                        set y_max $y
                    }
                    if { $y < $y_min } {
                        set y_min $y
                    }
                    if { $x > $x_max } {
                        set x_max $x
                    } 
                    if { $x < $x_min } {
                        set x_min $x
                    }
                } else {
                    set error_p 1
                }
            }
        } else {
            set error_p 1
        }
    } elseif { $maybe_x_list_len > 0 && $maybe_y_list_len > 0 && $maybe_x_list_len == $maybe_y_list_len } {
        set y_p 1
        set x_p 1
        foreach x $maybe_x_list {
            if { ![qf_is_decimal $x] } {
                set x_p 0
                set error_p 1
            }
        }
        foreach y $maybe_y_list {
            if { ![qf_is_decimal $y] } {
                set y_p 0
                set error_p 1
            }
        }
        if { $error_p == 0 } {
            set row_count $maybe_x_list_len
            set x_max [f::lmax $maybe_x_list]
            set y_max [f::lmax $maybe_y_list]
            set x_min [f::lmin $maybe_x_list]
            set y_min [f::lmin $maybe_y_list]
            set x_sum [f::sum $maybe_x_list]
            set y_sum [f::sum $maybe_y_list]
        }
    } else {
        set error_p 1
    }
    set success_p 1
    if { $error_p } {
        set success_p 0
    }
    return $success_p
}


ad_proc -public acc_fin::cobbler_file_create_from_table {
    table_id
    {user_id ""}
    {instance_id ""}
} {
    This is a wrapper for acc_fin::cobbler_file_create to conveniently pass data to scheduled proc add_fin::schedule_do. table_id is a qss_simple_table id.
} {
    if { $instance_id eq "" } {
        ns_log Warning "acc_fin::cobbler_file_create_from_table.45: No instance_id supplied."
        set instance_id [ad_conn package_id]
    }
    if { $user_id eq "" } {
        ns_log Warning "acc_fin::cobbler_file_create_from_table.49: No user_id supplied."
        set user_id [ad_conn user_id]
    }
    set cobbler_filename [acc_fin::pretti_cobbler_filename $table_id]
    set curve_lists [qss_table_read $table_id $instance_id $user_id]
    set return_val [acc_fin::cobbler_file_create $cobbler_filename $curve_lists $instance_id]
    return $return_val
}

ad_proc -public acc_fin::cobbler_file_create {
    cob_filename
    curve_lists
    {instance_id ""}
    {maybe_x_list ""}
    {maybe_y_list ""}
    {x_max_min_px "100"}
    {x_max_max_px "1000"}
    {y_max_min_px "100"}
    {y_max_max_px "1000"}
    {color1 ""}
    {color2 ""}
} {
    returns filepathname or empty string if error. depends on graphicsmagick. Creates image if it doesn't exist.
    resolution adjusts automatically to fit smallest slice for pixel range of x_max_* by y_max_* 
    defaults: 
    x_max_min_px 100, x_max_max_px 1000, y_max_min_px 100, y_max_max_px 1000, color1 #999999, color2 #cccccc, url web
    If url is anything other than web or list, then a filesystem pathname is returned. 
    If web, the web url is returned.
    If url is 'list', then a list of both filesystem-pathname and web-pathname are returned.
} {
    set error_p 0
    set instance_id [ad_conn package_id]
    set user_id [ad_conn user_id]
    
    # set alternating colors
    if { [regexp {[\#]?([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])} $color1 ] } {
        set color_arr(1) "#$color1"
    } else {
        set color_arr(1) "#cccccc"
    }
    if { [regexp {[\#]?([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])} $color2 ] } {
        set color_arr(1) "#$color2"
    } else {
        set color_arr(0) "#999999"
    }
    if { ![qf_is_natural_number $x_max_min_px] } {
        set x_max_min_px 100
    }
    if { ![qf_is_natural_number $x_max_max_px] } {
        set x_max_max_px 1000
    }
    if { ![qf_is_natural_number $y_max_min_px] } {
        set y_max_min_px 100
    }
    if { ![qf_is_natural_number $y_max_min_px] } {
        set y_max_min_px 1000
    }

    set name_list [acc_fin::chart_file_names $cob_filename $instance_id]
    set cob_pathname [lindex $name_list 0]
    set cob_path [file dirname $cob_pathname]

    if { [file exists $cob_path] } {
        if { ![file isdirectory $cob_path] } {
            ns_log Warning "acc_fin::cobbler_file_create.68: unable to create filename, because '${cob_path}' is not a directory"
            set error_p 1
        }
    } else {
        file mkdir -p $cob_path
    }

    set cob_tmppathname [lindex $name_list 2]
    set tempdir [file dirname $cob_tmppathname]
    if { [file exists $tempdir] } {
        if { ![file isdirectory $tempdir] } {
            ns_log Warning "acc_fin::cobbler_file_create.102: unable to create filename, because '${tempdir}' is not a directory"
            set error_p 1
        }
    } else {
        file mkdir -p $tempdir
    }

    if { $error_p == 0 } {
        set cob_webpathname [lindex $name_list 1]

        if { ![file exists $cob_pathname] } {
            set success_p [acc_fin::table_data_stats ]
            set error_p [expr { abs( $success_p - 1 ) } ]
            if { $error_p == 0 } {
                # style cobbler (square pie) chart
                # make chart as png image?
                if { ![file exists $cob_pathname] } {
                    # Create canvas image 
                    # to create a solid red canvas image: 
                    # gm convert -size 640x480 "xc:#f00" canvas.png 
                    # from: www.graphicsmagick.org/FAQ.html 
                    # Assume the same border for the farsides. It may be easier for a user to clip than to add margin.
                    # Image 0 point should be at twelve oclock. (subtract 90 from angle)
                    # split any angle over 180 degrees into two angles < 180.
                    # Try to provide image resolution at least one pixel per degree and/or 1% of range of y.

                    # r_case1 is resolution along min size of (x) 1 pixel for min width
                    set r_case1 [f::max $x_max_min_px [f::min $x_max_max_px [expr { $x_sum / $x_min } ]]]
                    # r_case2 is resolution along range of y.
                    set r_case2 [f::max $y_max_min_px [f::min $y_max_max_px [expr { $y_max - $y_min } ]]]
                    set r [f::max $r_case1 $r_case2 ]
                    set dim_px [expr { round( $r + .99 )  } ]
                    set dim_py [expr { round( $r / 3.6 ) } ]
                    exec gm convert -size ${dim_px}x${dim_py} "xc:#ffffff" $cob_tmppathname
                    set x0 0
                    set y0 [expr { $dim_py } ]
                    set x2 $x0
                    set y2 $y0
                    set k1 [expr { $r / ( $x_sum + 0. ) } ]
                    set k2 [expr { $dim_py / ( $y_max + 0. ) } ]
                    set maybe_x_list_len [llength $maybe_x_list ]
                    for {set j 0} { $j < $maybe_x_list_len } {incr j } {
                        set odd_p [expr { 1 + $j - int( ( $j + 1 ) / 2 ) * 2 } ]
                        set x [lindex $maybe_x_list $j]
                        set y [lindex $maybe_y_list $j]
                        set bar_width [expr { $x * $k1 } ]
                        set bar_height [expr { $y * $k2 } ]
                        set x1 $x2
                        set y1 $y0
                        set x2 [expr { round( $x1 + $bar_width ) } ]
                        set y2 [expr { round( $y0 - $bar_height ) } ]
                        #ns_log Notice "accounts-finance/lib/pretti-one-view.tcl x0 $x0 y0 $y0 x1 $x1 y1 $y1 x2 $x2 y2 $y2"
                        exec gm convert -size ${dim_px}x${dim_py} -fill $color_arr($odd_p) -stroke $color_arr($odd_p) -draw "rectangle $x1,$y1 $x2,$y2" $cob_tmppathname $cob_tmppathname
                    }
                    # some OSes are less buggy with copy/delete instead of move on busy VMs apparently due to server/OS file memory hooks.
                    file copy $cob_tmppathname $cob_pathname
                    file delete $cob_tmppathname
                }
            }
        }
    }
    if { $error_p } {
        set return_val 0
    } else {
        set return_val 1
    }
    return $return_val
}



ad_proc -public acc_fin::cobbler_html_view {
    cobbler_filename
} {
    Returns image url if available, otherwise empty string.
} {
    #ns_log Notice "acc_fin::cobbler_html_view.309: cobbler_filename $cobbler_filename"
    set cobbler_html ""
    # acc_fin::file_sys_pathname gets webpath, so let's get it here to save a double
    # trip on a positive case
    # get web pathname
    set web_path [acc_fin::file_web_pathname]

    set filepathname [acc_fin::file_sys_pathname $cobbler_filename $web_path]
    if { [file exists $filepathname ] } {
        append web_path "/"
        append web_path $cobbler_filename
        set cobbler_html $web_path
    }
    return $cobbler_html
}

ad_proc -public acc_fin::cobbler_html_build_n_view {
    cob_filename
    curve_lists
    maybe_x_list
    maybe_y_list
    {x_max_min_px "100"}
    {x_max_max_px "500"}
    {y_max_min_px "100"}
    {y_max_max_px "500"}
    {color1 ""}
    {color2 ""}
} {
    returns html string or empty string if error.
    resolution adjusts automatically to fit smallest slice for pixel range of x_max_* by y_max_* 
    defaults: 
    x_max_min_px 100, x_max_max_px 500, y_max_min_px 100, y_max_max_px 500, color1 #999999, color2 #cccccc
} {
    set error_p 0
    set instance_id [ad_conn package_id]
    set user_id [ad_conn user_id]
    set cob_html ""
    set name_list [acc_fin::chart_file_names $cob_filename $instance_id]
    set cob_pathname [lindex $name_list 0]
    if { [file exists $cob_pathname] && ![file isdirectory $cob_pathname] } {
        # display image
        set cob_webpathname [lindex $name_list 1]
        set dim_px ""
        set dim_py ""
        set suffix [string range [file extension $cob_pathname] 1 end]
        if { [string match -nocase $suffix {[pjg][npi][gf]} ] } {
            set dims_list [ns_imgsize $cob_pathname]
            set dim_px " width=\""
            set dim_py " height=\""
            append dim_px [lindex $dims_list 0]
            append dim_py [lindex $dims_list 1]
            append dim_px "\""
            append dim_py "\""
        }

        set cob_html "<img src=\"${cob_webpathname}\"${dim_px}${dim_py} alt=\"See table for numerical detail.\" title=\"See table for numerical detail.\">"

    } else {
        # display html in lieu of image. 
        # set alternating colors
        if { [regexp {[\#]?([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])} $color1 ] } {
            set color_arr(1) "#$color1"
        } else {
            set color_arr(1) "#cccccc"
        }
        if { [regexp {[\#]?([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])} $color2 ] } {
            set color_arr(1) "#$color2"
        } else {
            set color_arr(0) "#999999"
        }
        # verify that color pixel files exist. If not, generate using graphicsmagick
        
        if { ![qf_is_natural_number $x_max_min_px] } {
            set x_max_min_px 100
        }
        if { ![qf_is_natural_number $x_max_max_px] } {
            set x_max_max_px 500
        }
        if { ![qf_is_natural_number $y_max_min_px] } {
            set y_max_min_px 100
        }
        if { ![qf_is_natural_number $y_max_min_px] } {
            set y_max_min_px 500
        }

        if { $error_p == 0 } {
            set success_p [acc_fin::table_data_stats ]
            set error_p [expr { abs( $success_p - 1 ) } ]

            if { $error_p == 0 } {
                # style cobbler (square pie) chart

                # Try to provide image resolution at least one pixel per degree and/or 1% of range of y.

                # r_case1 is resolution along min size of (x) 1 pixel for min width
                set rx [f::max $x_max_min_px [f::min $x_max_max_px [expr { $x_sum / ( $x_min + 0. )} ]]]
                # r_case2 is resolution along range of y.
                set ry [f::max $y_max_min_px [f::min $y_max_max_px [expr { $y_max - $y_min + 0. } ]]]
                set dim_px [expr { round( $rx + .99 ) } ]
                set dim_py [expr { round( $ry / 3.6 ) } ]
                set cob_html "<div style=\"margin: 3px; padding-bottom: 0; width: ${dim_px} px ; height: ${dim_py} px ; display: inline-block; border-style: solid; border-width: 1 px ; border-color: #000000; \">\n"
                
                set x0 0
                set y0 $dim_py
                set x2 $x0
                set y2 $y0
                set k1 [expr { $dim_px / ( $x_sum + 0. ) } ]
                set k2 [expr { $dim_py / ( $y_max + 0. ) } ]
                set bar_width 0.
                set xy_list [list x y]
                set comb_bar_curv_lol [list $xy_list]
                set xy_delim ""
                set xy_html ""
                set batch_y_list [list]
                set bars_count 1
                set bar_width_accum 0.
                set maybe_x_list_len [llength $maybe_x_list]
                set odd_p 1
                for {set j 0} { $j < $maybe_x_list_len } {incr j } {
                    set x [lindex $maybe_x_list $j]
                    set y [lindex $maybe_y_list $j]
                    set bar_width [expr { round( $x * $k1 ) } ]
                    set bar_height [expr { round( $y * $k2 ) } ]

                    set bar_width_accum [expr { $bar_width_accum + $bar_width } ]
                    #set bar_height [expr { $y * $k2 } ]
                    #ns_log Notice "acc_fin::cobbler_html_view.433 j $j x $x y $y bar_width $bar_width bar_height $bar_height"
                    if { $bar_width_accum >= 1. } {
                        if { $bar_width > 3 } {
                            set bars_count [llength $comb_bar_curv_lol]
                            if { $bars_count > 1 } {
                                # split this into two bars for presentation purposes. First bar is the fractional ones
                                incr bars_count -1
                                #ns_log Notice "acc_fin::cobbler_html_view.443 bars_count $bars_count [llength $batch_y_list] $batch_y_list"
                                if { $bars_count > 1 } {
                                    set bar_height [expr { round( [f::lmax [lrange $batch_y_list 0 end-1]] / $bars_count ) } ]
                                } else {
                                    set bar_height [lindex $batch_y_list 0]
                                }
                                append cob_html "<div style=\"margin: 0; padding: 0; width: ${bar_width} px; height: ${bar_height} px; display: inline-block; vertical-align: bottom; border-style: none; background-color: $color_arr($odd_p); \"><img src=\"/resources/acs-subsite/spacer.gif\" style=\"margin: 0; padding: 0; border-style: none;\" height=\"${bar_height}\" width=\"${bar_width}\" alt=\"${xy_html}\" title=\"${xy_html} \"></div>"

                                # reset values to print last bar in set
                                set xy_html ""
                                set xy_delim ""
                                set batch_y_list [list ]
                                set comb_bar_curv_lol [list $xy_list]
                                set odd_p [expr { 1 + $odd_p - int( ( $odd_p + 1 ) / 2 ) * 2 } ]
                            }
                        } else {
                            set bar_width [expr { round( $bar_width ) } ]
                        }
                        set bars_count [llength $comb_bar_curv_lol]
                        if { $bars_count > 1 } {
                            set bar_list [list $x $y]
                            lappend comb_bar_curv_lol $bar_list 
                            #set bar_height [expr { round([acc_fin::pretti_geom_avg_of_curve $comb_bar_curv_lol]) } ]
                            set bar_height [expr { round( [f::lmax $batch_y_list] / $bars_count ) } ]
                        } else {
                            set bar_height [expr { round( $bar_height ) } ]
                        }
                        append xy_html $xy_delim
                        append xy_html "y=$y x=$x"
                        #ns_log Notice "acc_fin::cobbler_html_view.452 j $j x $x y $y bar_width $bar_width bar_height $bar_height xy_html $xy_html"
                        append cob_html "<div style=\"margin: 0; padding: 0; width: ${bar_width} px; height: ${bar_height} px; display: inline-block; vertical-align: bottom; border-style: none; background-color: $color_arr($odd_p); \">"
                        #append cob_html "<img src=\"/resources/acs-subsite/spacer.gif\" style=\"margin: 0; padding: 0; border-style: none;\" width=\"${bar_width}\" height=\"${bar_height}\" alt=\"${xy_html}\" title=\"${xy_html} \">"
                        append cob_html "<img src=\"/resources/acs-subsite/spacer.gif\" style=\"margin: 0; padding: 0; border-style: none;\" width=\"${bar_width}\" height=\"${bar_height}\" alt=\"${xy_html}\" title=\"${xy_html} \">"
                        append cob_html "</div>"
                        set bar_width 0.
                        set bar_width_accum 0.
                        set comb_bar_curv_lol [list $xy_list]
                        set batch_y_list [list ]
                        set xy_delim ""
                        set xy_html ""
                        set odd_p [expr { 1 + $odd_p - int( ( $odd_p + 1 ) / 2 ) * 2 } ]
                    } else {
                        # keep info to combine bars to match resolution
                        set bar_list [list $bar_width $bar_height]
                        lappend comb_bar_curv_lol $bar_list 
                        lappend batch_y_list $bar_height
                        append xy_html $xy_delim
                        append xy_html "y=$y x=$x"
                        set xy_delim ", \n"
                    }
                    #ns_log Notice "acc_fin::cobbler_html_view.465 j $j bar_width $bar_width bars_count $bars_count"
                }
                set bars_count [llength $comb_bar_curv_lol]

                if { $bars_count > 0 } {
                    #ns_log Notice "acc_fin::cobbler_html_view.470 catching dangling tail bar(s) bar_width $bar_width bars_count $bars_count"
                    set bar_width [f::max 1 [expr { round( $bar_width ) } ]]
                    # catch any dangling tail bars
                    set odd_p [expr { 1 + $j - int( ( $j + 1 ) / 2 ) * 2 } ]
                    set bar_list [list $bar_width $bar_height]
                    lappend comb_bar_curv_lol $bar_list 
                    lappend batch_y_list $bar_height
                    set bar_height [f::max [f::lmin $batch_y_list] [expr { round([acc_fin::pretti_geom_avg_of_curve $comb_bar_curv_lol]) } ]]
                    append cob_html "<div style=\"margin: 0; padding: 0; width: ${bar_width} px; height: ${bar_height} px; display: inline-block; vertical-align: bottom; border-style: none; background-color: $color_arr($odd_p); \"><img src=\"/resources/acs-subsite/spacer.gif\" style=\"margin: 0; padding: 0; border-style: none;\" width=\"${bar_width}\" height=\"${bar_height}\" alt=\"${xy_html}\" title=\"${xy_html} \"></div>"
                }
                append cob_html "</div>"
            }
        }
        # end display html cobbler
    }

    if { $error_p } {
        set cob_html ""
    }
    return $cob_html
}

ad_proc -public acc_fin::pretti_pie_filename {
    table_id
} {
    Returns a consistent pie filename for use with PRETTI tables.
} {
    #ns_log Notice "acc_fin::pretti_pie_filename.521: table_id $table_id"
    # pie chart
    set pie_filename "pretti-dc-${table_id}-pie.png"
    return $pie_filename
}


ad_proc -public acc_fin::pretti_cobbler_filename {
    table_id
} {
    Returns a consistent cobbler filename for use with PRETTI tables.
} {
    #ns_log Notice "acc_fin::pretti_cobbler_filename.515: table_id $table_id"
    # cobbler chart
    set cob_filename "pretti-dc-${table_id}-cob.png"
    return $cob_filename
}

ad_proc -public acc_fin::file_sys_pathname {
    {filename ""}
    {webpath ""}
    {instance_id ""}
} {
    Returns a consistent full system pathname for use with static files such as images. If filename is not empty, includes filename in pathname.
} {
    #ns_log Notice "acc_fin::file_sys_pathname.534: filename $filename webpath $webpath instance_id $instance_id"
    if { $webpath eq "" } {
        set webpath [acc_fin::file_web_pathname $instance_id]
    }
    set acsroot [acs_root_dir]
    set fileroot [file join $acsroot "www"]
    set sys_pathname "${fileroot}${webpath}"
    if { $filename ne "" } {
        append sys_pathname "/"
        append sys_pathname $filename
    }
    return $sys_pathname
}


ad_proc -public acc_fin::file_web_pathname {
    {instance_id ""}
} {
    Returns a consistent web path for use with static files such as images. 
} {
    #ns_log Notice "acc_fin::file_web_pathname.554: instance_id $instance_id"
    if { $instance_id eq "" } {
        set instance_id [ad_conn package_id]
    }
    set pkg_url [apm_package_url_from_id $instance_id]
    if { [string range $pkg_url 0 0] eq "/" } {
        set pkg_url [string range $pkg_url 1 end]
    }
    set webpath [file join "/resources" $pkg_url]
    return $webpath
}


ad_proc -public acc_fin::pie_file_create_from_table {
    table_id
    {user_id ""}
    {instance_id ""}
} {
    This is a wrapper for acc_fin::pie_file_create to conveniently pass data to scheduled proc add_fin::schedule_do. table_id is a qss_simple_table id.
} {
    if { $instance_id eq "" } {
        ns_log Warning "acc_fin::pie_file_create_from_table.566: No instance_id supplied."
        set instance_id [ad_conn package_id]
    }
    if { $user_id eq "" } {
        ns_log Warning "acc_fin::pie_file_create_from_table.570: No user_id supplied."
        set user_id [ad_conn user_id]
    }
    set pie_filename [acc_fin::pretti_pie_filename $table_id]
    set curve_lists [qss_table_read $table_id $instance_id $user_id]
    set return_val [acc_fin::pie_file_create $pie_filename $curve_lists $instance_id]
    return $return_val
}

ad_proc -public acc_fin::pie_file_create {
    pie_filename
    curve_lists
    {instance_id ""}
    {maybe_x_list ""}
    {maybe_y_list ""}
    {x_max_min_px "100"}
    {x_max_max_px "1000"}
    {y_max_min_px "100"}
    {y_max_max_px "1000"}
    {color1 ""}
    {color2 ""}
} {
    returns filepathname or empty string if error. depends on graphicsmagick.  Creates image if it doesn't exist.
    resolution adjusts automatically to fit smallest slice for pixel range of x_max_* by y_max_* where x is angle theta, y is radius.
    defaults: 
    x_max_min_px 100, x_max_max_px 1000, y_max_min_px 100, y_max_max_px 1000, color1 #999999, color2 #cccccc
    If url is anything other than web or list, then a filesystem pathname is returned. 
    If web, the web url is returned.
    If url is 'list', then a list of both filesystem-pathname and web-pathname are returned.
} {
    set error_p 0
    
    # set alternating colors
    if { [regexp {[\#]?([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])} $color1 ] } {
        set color_arr(1) "#$color1"
    } else {
        set color_arr(1) "#cccccc"
    }
    if { [regexp {[\#]?([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])} $color2 ] } {
        set color_arr(1) "#$color2"
    } else {
        set color_arr(0) "#999999"
    }
    if { ![qf_is_natural_number $x_max_min_px] } {
        set x_max_min_px 100
    }
    if { ![qf_is_natural_number $x_max_max_px] } {
        set x_max_max_px 1000
    }
    if { ![qf_is_natural_number $y_max_min_px] } {
        set y_max_min_px 100
    }
    if { ![qf_is_natural_number $y_max_min_px] } {
        set y_max_min_px 1000
    }


    set name_list [acc_fin::chart_file_names $pie_filename $instance_id]
    set pie_pathname [lindex $name_list 0]
    set pie_path [file dirname $pie_pathname]
    if { [file exists $pie_path] } {
        if { ![file isdirectory $pie_path] } {
            ns_log Warning "acc_fin::pie_file_create.480: unable to create filename, because '${pie_path}' is not a directory"
            set error_p 1
        }
    } else {
        file mkdir -p $pie_path
    }

    set pie_tmppathname [lindex $name_list 2]
    set tempdir [file dirname $pie_tmppathname]
    if { [file exists $tempdir] } {
        if { ![file isdirectory $tempdir] } {
            ns_log Warning "acc_fin::pie_file_create.508: unable to create filename, because '${tempdir}' is not a directory"
            set error_p 1
        }
    } else {
        file mkdir -p $tempdir
    }
    
    if { $error_p == 0 } {
        set pie_webpathname [lindex $name_list 1]

        if { ![file exists $pie_pathname] } {
            set success_p [acc_fin::table_data_stats ]
            set error_p [expr { abs( $success_p - 1 ) } ]
            
            if { $error_p == 0 } {
                # style pie (square pie) chart
                # make chart as png image?
                if { ![file exists $pie_pathname] } {

                    set pi [expr { atan2( 0. , -1. ) } ]
                    set 2pi [expr { 2. * $pi } ]
                    # Create canvas image 
                    # to create a solid red canvas image: 
                    # gm convert -size 640x480 "xc:#f00" canvas.png 
                    # from: www.graphicsmagick.org/FAQ.html 
                    # Assume the same border for the farsides. It may be easier for a user to clip than to add margin.
                    # Image 0 point should be at twelve oclock. (subtract 90 from angle)
                    # split any angle over 180 degrees into two angles < 180.
                    # Try to provide image resolution at least one pixel per degree and/or 1% of range of y.

                    # r_case1 is resolution along min size of (x) 1 pixel for min width
                    set r_case1 [f::max $x_max_min_px [f::min $x_max_max_px [expr { $x_sum / $2pi * $x_min } ]]]
                    # r_case2 is resolution along range of y.
                    set r_case2 [f::max $y_max_min_px [f::min $y_max_max_px [expr { $y_max - $y_min } ]]]
                    set r [f::max $r_case1 $r_case2 ]
                    set dim_px [expr { 2 * round( $r + .99 )  } ]
                    exec gm convert -size ${dim_px}x${dim_px} "xc:#ffffff" $pie_tmppathname
                    set x0 [expr { int( $r ) + 1 } ]
                    incr x0
                    set y0 $x0
                    # set theta_d degrees
                    # set theta_r radians
                    set theta_d2 -90.
                    set theta_r2 [expr { -1. * $pi / 2. } ]
                    set x2 $x0
                    set y2 [expr { round( $y0 + $r ) } ]
                    set k1 [expr { 360. / $x_sum } ]
                    set k2 [expr { ( $y_max - $y_min ) } ]
                    set k3 [expr { $k2 * 2. } ]
                    set k4 [expr { $2pi / $x_sum } ]
                    set k5 [expr { $r / $y_max } ]
                    # convert rads to degs:
                    set k0 [expr { 360. / $2pi } ]
                    set maybe_x_list_len [llength $maybe_x_list]
                    for {set j 0} { $j < $maybe_x_list_len } {incr j } {
                        set odd_p [expr { 1 + $j - int( ( $j + 1 ) / 2 ) * 2 } ]
                        set x [lindex $maybe_x_list $j]
                        set y [lindex $maybe_y_list $j]
                        set arc_degs [expr { $k1 * $x } ]
                        set arc_rads [expr { $k4 * $x } ]
                        set ry [expr { $y * $k5 } ]
                        if { $arc_degs > 180. } {
                            set arc_rads [expr { $arc_rads / 2. } ]
                            set angle_list [list $arc_rads $arc_rads]
                        } else {
                            set angle_list [list $arc_rads ]
                        }
                        foreach angle $angle_list {
                            set theta_d1 $theta_d2
                            set theta_r1 $theta_r2
                            set theta_d2 [expr { $theta_d2 + $arc_rads * $k0 } ]
                            set theta_r2 [expr { $theta_r2 + $arc_rads } ]
                            set x1 [expr { round( $ry * cos( $theta_r1 ) + $x0 ) } ]
                            set y1 [expr { round( $ry * sin( $theta_r1 ) + $y0 ) } ]
                            set x2 [expr { round( $ry * cos( $theta_r2 ) + $x0 ) } ]
                            set y2 [expr { round( $ry * sin( $theta_r2 ) + $y0 ) } ]
                            exec gm convert -size ${dim_px}x${dim_px} -fill $color_arr($odd_p) -stroke $color_arr($odd_p) -draw "path 'M $x0 $y0 L $x1 $y1 L $x2 $y2 L $x0 $y0'" $pie_tmppathname $pie_tmppathname
                            exec gm convert -size ${dim_px}x${dim_px} -fill $color_arr($odd_p) -stroke $color_arr($odd_p) -draw "ellipse $x0,$y0 $ry,$ry ${theta_d1},${theta_d2}" $pie_tmppathname $pie_tmppathname
                        }
                    }
                    set y3 [expr { round( $y0 - $ry ) } ]
                    exec gm convert -size ${dim_px}x${dim_px} -strokewidth 1 -stroke $color_arr(0) -draw "path 'M $x0 $y0 L $x0 $y3'" $pie_tmppathname $pie_tmppathname
                    # move on busy servers can cause issues with OS file memory hooks. Use copy.
                    file copy $pie_tmppathname $pie_pathname
                    file delete $pie_tmppathname
                } else {
                    ns_log Notice "acc_fin::pie_file_create.609 Filename already exists for ${pie_pathname}. exiting without processing or error."
                }
            }
        }
    }
    if { $error_p } {
        set return_val 0
    } else {
        set return_val 1
    }
    return $return_val
}


ad_proc -public acc_fin::pie_html_view {
    pie_filename
} {
    Returns image url if available, otherwise empty string.
} {
    #ns_log Notice "acc_fin::pie_html_view.32: pie_filename $pie_filename"
    set pie_html ""
    # acc_fin::file_sys_pathname gets webpath, so let's get it here to save a double
    # trip on a positive case
    # get web pathname
    set web_path [acc_fin::file_web_pathname]

    set filepathname [acc_fin::file_sys_pathname $pie_filename $web_path]
    if { [file exists $filepathname ] } {
        append web_path "/"
        append web_path $pie_filename
        set pie_html $web_path
    }
    return $pie_html
}


ad_proc -public acc_fin::gray_from_color {
    hexcolor
} {
    Converts an html color into it's grey with similar contrast.
} {
    # add brightnesses
    set error_p 0
    if { [string range $hexcolor 0 0] eq "#" } {
        set hexcolor [string range $hexcolor 1 end]
    }
    set hex_list [split $hexcolor ""]
    set dec_list [list ]
    set hexnum_list [list 0 1 2 3 4 5 6 7 8 9 a b c d e f]
    foreach hex_dig $hex_list {
        lappend dec_list [lsearch -exact $hexnum_list $hex_dig]
    }
    set dec_sum 0
    set dec_list_len [llength $dec_list ]
    if { $dec_list_len == 6 } {
        foreach {exp1 exp0} $dec_list {
            set dec_sum [expr { $dec_sum + $exp1 * 16 + $exp0 } ]
        }
    } elseif { $dec_list_len == 3 } {
        foreach exp1 $dec_list {
            set dec_sum [expr { $dec_sum + $exp1 * 16 } ]
        }
    } else {
        # don't understand. Return average grey 3 * 127
        set dec_sum 381
    }

    set dec_avg [expr { round( $dec_sum / 3. ) }]
    set dec1 [expr { int( $dec_avg / 16. ) } ]
    set hex1 [lindex $hexnum_list $dec1 ]
    set dec0 [expr { $dec_avg - $dec1 * 16 } ]
    set hex0 [lindex $hexnum_list $dec0 ]
    set hexgrey "${hex1}${hex0}${hex1}${hex0}${hex1}${hex0}"

    return $hexgrey
}
