ad_library {

    general procs with utility elsewhere and first used and thus defined in this package.
    @creation-date 8 August 2014
    @cvs-id $Id:
}

namespace eval acc_fin {}

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
} {
    returns filepathname or empty string if error. depends on graphicsmagick.
    resolution adjusts automatically to fit smallest slice for pixel range of x_max_* by y_max_* 
    defaults: 
    x_max_min_px 100, x_max_max_px 1000, y_max_min_px 100, y_max_max_px 1000, color1 #999999, color2 #cccccc
} {
    set error 0
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

    # set cob_filename "pretti-dc-${table_tid}-cob.png"
    # scrub cob_filename. based on template::data::validate::filename
    regsub -all -- {[^a-zA-Z0-9\.\_\-]} $cob_filename {_} cob_filename
    if { ![string match -nocase "*.png" $cob_filename] } {
        append cob_filename ".png"
    }
    set fileroot [file join [acs_root_dir] "www"]
    set webroot [file join resources [apm_package_url_from_id $package_id]] 
    set cob_webpath "/{$webroot}"
    set cob_path "${fileroot}${cob_webpath}"
    #append filepathname [file join [apm_package_url_from_id [ad_conn package_id]] pretti resources]
    if { [file exists $cob_path] } {
        if { ![file isdirectory $cob_path] } {
            ns_log Warning "acc_fin::cobbler_file_create.38: unable to create filename, because '${cob_path}' is not a directory"
            set error 1
        }
    } else {
        file mkdir -p $cob_path
    }

    if { $error == 0 } {
        set cob_pathname "${cob_path}/${cob_filename}"
        set cob_webpathname "${cob_webpath/${cob_filename}"

        set maybe_x_list_len [llength $maybe_x_list_len ]
        set maybe_y_list_len [llength $maybe_y_list_len ]

        if { $curve_lists ne "" && maybe_x_list eq "" & maybe_y_list eq "" } {
            set table_titles_list [lindex $table_lists 0]
            set table_data_list [lrange $table_lists 1 end]
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
                        set maybe_x_list_len [llength $maybe_x_list_len ]
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
                        error 1
                    }
                }
            } else {
                set error 1
            }
        } elseif { $maybe_x_list_len > 0 && $maybe_y_list_len > 0 && $maybe_x_list_len == $maybe_y_list_len } {
            set y_p 1
            set x_p 1
            foreach x $maybe_x_list {
                if { ![qf_is_decimal $x] } {
                    set x_p 0
                    set error 1
                }
            }
            foreach y $maybe_y_list {
                if { ![qf_is_decimal $y] } {
                    set y_p 0
                    set error 1
                }
            }
            if { $error == 0 } {
                set row_count $maybe_x_list_len
                set x_max [f::lmax $maybe_x_list]
                set y_max [f::lmax $maybe_y_list]
                set x_min [f::lmin $maybe_x_list]
                set y_min [f::lmin $maybe_y_list]
                set x_sum [f::sum $maybe_x_list]
                set y_sum [f::sum $maybe_y_list]
            }
        } else {
            set error 1
        }
        
        if { $error == 0 } {
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
                exec gm convert -size ${dim_px}x${dim_py} "xc:#ffffff" $cob_pathname
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
                    exec gm convert -size ${dim_px}x${dim_py} -fill $color_arr($odd_p) -stroke $color_arr($odd_p) -draw "rectangle $x1,$y1 $x2,$y2" $cob_pathname $cob_pathname
                }
            }
        }
    }
    if { $error } {
        set cob_pathname ""
    }
    return $cob_pathname
}



ad_proc -public acc_fin::cobbler_html_create {
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
    set error 0
    set package_id [ad_conn package_id]
    set user_id [ad_conn user_id]
    set cob_html ""
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
        set x_max_max_px 500
    }
    if { ![qf_is_natural_number $y_max_min_px] } {
        set y_max_min_px 100
    }
    if { ![qf_is_natural_number $y_max_min_px] } {
        set y_max_min_px 500
    }

    if { $error == 0 } {
        #set cob_pathname "${cob_path}/${cob_filename}"
        #set cob_webpathname "${cob_webpath/${cob_filename}"

        set maybe_x_list_len [llength $maybe_x_list_len ]
        set maybe_y_list_len [llength $maybe_y_list_len ]

        if { $curve_lists ne "" && maybe_x_list eq "" & maybe_y_list eq "" } {
            set table_titles_list [lindex $table_lists 0]
            set table_data_list [lrange $table_lists 1 end]
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
                        set maybe_x_list_len [llength $maybe_x_list_len ]
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
                        error 1
                    }
                }
            } else {
                set error 1
            }
        } elseif { $maybe_x_list_len > 0 && $maybe_y_list_len > 0 && $maybe_x_list_len == $maybe_y_list_len } {
            set y_p 1
            set x_p 1
            foreach x $maybe_x_list {
                if { ![qf_is_decimal $x] } {
                    set x_p 0
                    set error 1
                }
            }
            foreach y $maybe_y_list {
                if { ![qf_is_decimal $y] } {
                    set y_p 0
                    set error 1
                }
            }
            if { $error == 0 } {
                set row_count $maybe_x_list_len
                set x_max [f::lmax $maybe_x_list]
                set y_max [f::lmax $maybe_y_list]
                set x_min [f::lmin $maybe_x_list]
                set y_min [f::lmin $maybe_y_list]
                set x_sum [f::sum $maybe_x_list]
                set y_sum [f::sum $maybe_y_list]
            }
        } else {
            set error 1
        }
        
        if { $error == 0 } {
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
                #exec gm convert -size ${dim_px}x${dim_py} "xc:#ffffff" $cob_pathname
                set cob_html "<div style=\"margin: 3px; padding-bottom: 0; width: ${dim_px}px ; height: ${dim_py}px; display: inline-block; border-style: solid; border-width: 1px; border-color: #000000; \">\n"
                
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
                    set x2_pct [expr { round( $bar_width / $dim_px ) } ]
                    set y2_pct [expr { round( $bar_height / $dim_py ) } ]
                    #set x2 [expr { round( $x1 + $bar_width ) } ]
                    #set y2 [expr { round( $y0 - $bar_height ) } ]
                    #ns_log Notice "accounts-finance/lib/pretti-one-view.tcl x0 $x0 y0 $y0 x1 $x1 y1 $y1 x2 $x2 y2 $y2"
                    #exec gm convert -size ${dim_px}x${dim_py} -fill $color_arr($odd_p) -stroke $color_arr($odd_p) -draw "rectangle $x1,$y1 $x2,$y2" $cob_pathname $cob_pathname
                    append cob_html "<img border=\"0\" src=\"../resources/pixel-[string range $color_arr($odd_p) 1 end].png\" width=\"${bar_width}\" height=\"${bar_height}\" alt=\"y=$y @ x=$x\" title=\"y=$y @ x=$x\">\n"
                }
                append cob_html "</div>\n"
            }
        }
    }
    if { $error } {
        set cob_html ""
    }
    return $cob_html
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
