ad_library {

    general procs with utility elsewhere and first used and thus defined in this package.
    @creation-date 8 August 2014
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public acc_fin::chart_file_names {
    cob_filename
} {
    Returns a list of standard paths used with generated charts. 
    ref 0 is OS pathname, ref 1 is web url, ref 2 is a temporary location while building chart
} {
    set package_id [ad_conn package_id]
    regsub -all -- {[^a-zA-Z0-9\.\_\-]} $cob_filename {_} cob_filename
    if { ![string match -nocase "*.png" $cob_filename] } {
        append cob_filename ".png"
    }
    set acsroot [acs_root_dir]
    set fileroot [file join $acsroot "www"]
    set tempdir [file join $acsroot "tmp"]
    set pkg_url [apm_package_url_from_id $package_id]
    if { [string range $pkg_url 0 0] eq "/" } {
        set pkg_url [string range $pkg_url 1 end]
    }
    set cob_webpath [file join "/resources" $pkg_url]
    set cob_path "${fileroot}${cob_webpath}"
    
    set cob_pathname "${cob_path}/${cob_filename}"
    set cob_webpathname "${cob_webpath}/${cob_filename}"
    set cob_tmppathname "${tempdir}/${cob_filename}"
    return [list $cob_pathname $cob_webpathname $cob_tmppathname]
}

ad_proc -public acc_fin::cobbler_file_create {
    cob_filename
    curve_lists
    maybe_x_list
    maybe_y_list
    {x_max_min_px "100"}
    {x_max_max_px "1000"}
    {y_max_min_px "100"}
    {y_max_max_px "1000"}
    {color1 ""}
    {color2 ""}
    {url "web"}
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
    set package_id [ad_conn package_id]
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

    set name_list [acc_fin::chart_file_names $cob_filename]
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
                    set maybe_x_list [list ]
                    set maybe_y_list [list ]
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
                        # some OSes are less buggy with copy/delete instead of move on busy VMs apparently due to server/OS file memory hooks.
                        file copy $cob_tmppathname $cob_pathname
                        file delete $cob_tmppathname
                    }
                }
            }
        }
    }
    if { $error_p } {
        set return_name ""
    } else {
        if { $url eq "web" } {
            set return_name $cob_pathname
        } elseif { $url eq "list" } {
            set return_name [list $cob_pathname $cob_webpathname]
        } else {
            set return_name $cob_webpathname
        }
    }
    return $return_name
}



ad_proc -public acc_fin::cobbler_html_view {
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
    set package_id [ad_conn package_id]
    set user_id [ad_conn user_id]
    set cob_html ""
    set name_list [acc_fin::chart_file_names $cob_filename]
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
            set maybe_x_list_len [llength $maybe_x_list ]
            set maybe_y_list_len [llength $maybe_y_list ]

            if { $curve_lists ne "" && $maybe_x_list eq "" && $maybe_y_list eq "" } {
                set table_titles_list [lindex $curve_lists 0]
                set table_data_list [lrange $curve_lists 1 end]
                #ns_log Notice "acc_fin::cobbler_html_view.329 table_data_list $table_data_list "
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
                    set maybe_x_list [list ]
                    set maybe_y_list [list ]
                    foreach row [lrange $table_data_list 0 end]  {
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
                set bars_count 1
                #ns_log Notice "acc_fin::cobbler_html_view.432 maybe_x_list_len $maybe_x_list_len "
                for {set j 0} { $j < $maybe_x_list_len } {incr j } {
                    set odd_p [expr { 1 + $j - int( ( $j + 1 ) / 2 ) * 2 } ]
                    set x [lindex $maybe_x_list $j]
                    set y [lindex $maybe_y_list $j]
                    set bar_width [expr { round( $x * $k1 ) } ]
                    set bar_height [expr { round( $y * $k2 ) } ]

                    set bar_width [expr { $x * $k1 + $bar_width } ]
                    set bar_height [expr { $y * $k2 } ]
                    #ns_log Notice "acc_fin::cobbler_html_view.433 j $j x $x y $y bar_width $bar_width bar_height $bar_height"
                    if { $bar_width >= 1. } {
                        if { $bar_width > 3 } {
                            set bar_width [expr { int( $bar_width ) } ]
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
                        append cob_html "<div style=\"margin: 0; padding: 0; width: ${bar_width} px; height: ${bar_height} px; display: inline-block; vertical-align: bottom; border-style: none; background-color: $color_arr($odd_p); \"><img src=\"/resources/acs-subsite/spacer.gif\" style=\"margin: 0; padding: 0; border-style: none;\" width=\"${bar_width}\" height=\"${bar_height}\" alt=\"${xy_html}\" title=\"${xy_html} \"></div>"
                        set bar_width 0.
                        set comb_bar_curv_lol [list $xy_list]
                        set batch_y_list [list ]
                        set xy_delim ""
                        set xy_html ""
                    } else {
                        # keep info to combine bars to match resolution
                        set bar_list [list $bar_width $bar_height]
                        lappend comb_bar_curv_lol $bar_list 
                        lappend batch_y_list $bar_height
                        append xy_html $xy_delim
                        append xy_html "y=$y x=$x"
                        set xy_delim ", \n"
                    }
                    ns_log Notice "acc_fin::cobbler_html_view.465 j $j bar_width $bar_width bars_count $bars_count"
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


ad_proc -public acc_fin::pie_file_create {
    pie_filename
    curve_lists
    maybe_x_list
    maybe_y_list
    {x_max_min_px "100"}
    {x_max_max_px "1000"}
    {y_max_min_px "100"}
    {y_max_max_px "1000"}
    {color1 ""}
    {color2 ""}
    {url "web"}
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
    set package_id [ad_conn package_id]
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

    set name_list [acc_fin::chart_file_names $pie_filename]

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
                    set maybe_x_list [list ]
                    set maybe_y_list [list ]
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
                    # some OSes are less buggy with copy/delete instead of move on busy VMs apparently due to server/OS file memory hooks.
                    file copy $pie_tmppathname $pie_pathname
                    file delete $pie_tmppathname
                } else {
                    ns_log Notice "acc_fin::pie_file_create.609 Filename already exists for ${pie_pathname}. exiting without processing or error."
                }
            }
        }
    }
    if { $error_p } {
        set return_name ""
    } else {
        if { $url eq "web" } {
            set return_name $pie_pathname
        } elseif { $url eq "list" } {
            set return_name [list $cob_pathname $cob_webpathname]
        } else {
            set return_name $pie_webpathname
        }
    }
    return $return_name
}



ad_proc -public acc_fin::pie_html_view {
    pie_filename
} {
    returns html string if image exists, or an alternate "image not available try again shortly" if unavailable
} {
    set error_p 0
    set package_id [ad_conn package_id]
    set user_id [ad_conn user_id]
    set pie_html ""
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
        #set pie_pathname "${pie_path}/${pie_filename}"
        #set pie_webpathname "${pie_webpath}/${pie_filename}"

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
                set maybe_x_list [list ]
                set maybe_y_list [list ]
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
        
        if { $error_p == 0 } {
            # style pie (square pie) chart

            # Try to provide image resolution at least one pixel per degree and/or 1% of range of y.

            # r_case1 is resolution along min size of (x) 1 pixel for min width
            set rx [f::max $x_max_min_px [f::min $x_max_max_px [expr { $x_sum / ( $x_min + 0. )} ]]]
            # r_case2 is resolution along range of y.
            set ry [f::max $y_max_min_px [f::min $y_max_max_px [expr { $y_max - $y_min + 0. } ]]]
            set dim_px [expr { round( $rx + .99 )  } ]
            set dim_py [expr { round( $ry / 3.6 ) } ]
            #exec gm convert -size ${dim_px}x${dim_py} "xc:#ffffff" $pie_pathname
            set pie_html "<div style=\"margin: 3px; padding-bottom: 0; width: ${dim_px} px ; height: ${dim_py} px ; display: inline-block; border-style: solid; border-width: 1 px ; border-color: #000000; \">\n"
            
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

            for {set j 0} { $j < $maybe_x_list_len } {incr j } {
                set odd_p [expr { 1 + $j - int( ( $j + 1 ) / 2 ) * 2 } ]
                set x [lindex $maybe_x_list $j]
                set y [lindex $maybe_y_list $j]
                set bar_width [expr { round( $x * $k1 ) } ]
                set bar_height [expr { round( $y * $k2 ) } ]

                set bar_width [expr { $x * $k1 + $bar_width } ]
                set bar_height [expr { $y * $k2 } ]
                if { $bar_width >= 1. } {
                    if { $bar_width > 3 } {
                        set bar_width [expr { int( $bar_width ) } ]
                    } else {
                        set bar_width [expr { round( $bar_width ) } ]
                    }
                    set bars_count [llength $comb_bar_curv_lol]
                    if { $bars_count > 1 } {
                        set bar_list [list $x $y]
                        lappend comb_bar_curv_lol $bar_list 
                        set bar_height [expr { round([acc_fin::pretti_geom_avg_of_curve $comb_bar_curv_lol]) } ]
                    } else {
                        set bar_height [expr { round( $bar_height ) } ]
                    }
                    append xy_html $xy_delim
                    append xy_html "y=$y x=$x"
                    append pie_html "<div style=\"margin: 0; padding: 0; width: ${bar_width} px; height: ${bar_height} px; display: inline-block; vertical-align: bottom; border-style: none; background-color: $color_arr($odd_p); \"><img src=\"/resources/acs-subsite/spacer.gif\" style=\"margin: 0; padding: 0; border-style: none;\" width=\"${bar_width}\" height=\"${bar_height}\" alt=\"${xy_html}\" title=\"${xy_html} \"></div>"
                    set bar_width 0.
                    set comb_bar_curv_lol [list $xy_list]
                    set batch_y_list [list ]
                    set xy_delim ""
                    set xy_html ""
                } else {
                    # keep info to combine bars to match resolution
                    set bar_list [list $bar_width $bar_height]
                    lappend comb_bar_curv_lol $bar_list 
                    lappend batch_y_list $bar_height
                    append xy_html $xy_delim
                    append xy_html "y=$y x=$x"
                    set xy_delim ", \n"
                }
            }
            set bars_count [llength $comb_bar_curv_lol]
            if { $bars_count > 1 } {
                set bar_width [f::max 1 [expr { round( $bar_width ) } ]]
                # catch tail bars

                set odd_p [expr { $i - int( $i / 2 ) * 2 } ]
                set bar_list [list $bar_width $bar_height]
                lappend comb_bar_curv_lol $bar_list 
                lappend batch_y_list $bar_height
                set bar_height [f::max [f::lmin $batch_y_list] [expr { round([acc_fin::pretti_geom_avg_of_curve $comb_bar_curv_lol]) } ]]
                append pie_html "<div style=\"margin: 0; padding: 0; width: ${bar_width} px; height: ${bar_height} px; display: inline-block; vertical-align: bottom; border-style: none; background-color: $color_arr($odd_p); \"><img src=\"/resources/acs-subsite/spacer.gif\" style=\"margin: 0; padding: 0; border-style: none;\" width=\"${bar_width}\" height=\"${bar_height}\" alt=\"${xy_html}\" title=\"${xy_html} \"></div>"
            }
            append pie_html "</div>"
        }
    }
    if { $error_p } {
        set pie_html ""
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
