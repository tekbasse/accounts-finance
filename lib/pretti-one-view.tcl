# requires instance_id table_tid
# optional user_id

#set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set read_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege read]

if { [qf_is_natural_number $table_tid] } {
    set table_stats_list [qss_table_stats $table_tid]
    # name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id
    set table_name [lindex $table_stats_list 0]
    set table_title [lindex $table_stats_list 1]
    set table_comments [lindex $table_stats_list 2]
    set table_flags [lindex $table_stats_list 6]
    #    set table_html "<h3>${table_title} (${table_name})</h3>\n"
    set table_lists [qss_table_read $table_tid]
    set table_text [qss_lists_to_text $table_lists]
    set table_tag_atts_list [list border 1 cellpadding 3 cellspacing 0]
    if { $table_flags eq "p4" } {
        set table_html [acc_fin::pretti_table_to_html $table_lists $table_comments]
    } else {
        if { $table_flags eq "dc" } {
            set graph_it_p 1
            set table_titles_list [lindex $table_lists 0]
            set table_data_list [lrange $table_lists 1 end]
            set x_idx [lsearch -exact $table_titles_list "x"]
            set y_idx [lsearch -exact $table_titles_list "y"]
            set row_count [llength $table_data_list]
            if { $x_idx > -1 && $y_idx > -1 && $row_count > 0 } {
                set style pie
                set filename "pretti-dc-${table_tid}-${style}.png"
                set filepathname [acs_root_dir]
                append filepathname "/www/resources/$filename"
                append webpathname "/resources/$filename"
                #append filepathname [file join [apm_package_url_from_id [ad_conn package_id]] pretti resources]

                # find min max x and y values and other preparations
                set row [lindex $table_data_list 0]
                set x_min [lindex $row $x_idx]
                set y_min [lindex $row $y_idx]
                set x_max $x_min
                set y_max $y_min
                set x_sum $x_min
                set y_sum $y_min
                foreach row [lrange $table_data_list 1 end]  {
                    set x [lindex $row $x_idx]
                    set y [lindex $row $y_idx]
                    if { [ad_var_type_check_number_p $x] && [ad_var_type_check_number_p $y] } {
                        set x_sum [expr { $x_sum + abs( $x ) } ]
                        #                        set y_sum [expr { $y_sum + abs( $y ) } ]
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
                        set graph_it_p 0
                    }
                }
                #                set y_avg [expr { $y_sum / $row_count } ]
                #                set y_low_test [expr { ( $y_avg - $y_min ) / $y_min } ]
                #                set y_high_test [expr { ( $y_max - $y_avg ) / $y_max } ]
                #                if { $y_low_test < .1 || $y_high_test < .1 } {
                # consider exagerating by graphing y exponentially etc

                #                }

                if { $graph_it_p } {
                    # set alternating colors
                    set color_arr(0) "#999999"
                    set color_arr(1) "#cccccc"

                    if { $style eq "cobbler" } {
                        # style cobbler (square pie) chart
                        # make chart using html
                        # acs-subsite/www/resources/spacer.gif is a transparent 1 pixel image available by default.
                    } else {
                        # style pie chart
                        # use gm draw elipse ( 100,100 100,150 0,360) <- from unseen example


                        # verify images exist. if not, make them.
                        # from mad-lab-lib
                        if { ![file exists $filepathname] } {
                            # Create canvas image 
                            # to create a solid red canvas image:                                                                                              
                            # gm convert -size 640x480 "xc:#f00" canvas.png                                                                                    
                            # from: www.graphicsmagick.org/FAQ.html                                                                                           
                            # Assume the same border for the farsides. It may be easier for a user to clip than to add margin.
                            # Image 0 point should be at twelve oclock. (subtract 90 from angle)
                            # split any angle over 180 degrees into two angles < 180.
                            # Try to provide image resolution at least one pixel per degree and/or 1% of range of y.
                            set pi [expr { atan2( 0. , -1. ) } ]
                            set 2pi [expr { 2. * $pi } ]
                            # if C = 360, && c = 2*pi*r, r = C / (2 * pi) or circa 57.295779513
                            # if delta y = 100%, r is circa 100
                            #set deg_min [expr { 360. * $x_min / $x_sum } ]
                            #set r_case1 [expr { 360. / ( $2pi * $deg_min ) } ]
                            # r_case1 is resolution along circumference (x)
                            set r_case1 [f::max 100 [f::min 1000 [expr { $x_sum / ( $2pi * $x_min ) } ]]]
                            # r_case2 is resolution along range of y.
                            set r_case2 [f::max 100 [f::min 1000 [expr { $y_max - $y_min } ]]]
                            set r [f::max $r_case1 $r_case2 ]
                            # given origin: x0,y0 arc from x1,y1 to x2,y2 with radius r1, color c1
                            # exec gm convert -size "200x200" -fill $c1 -stroke $c1 -draw "ellipse $x0,$y0 $r1,$r1 0,90" "xc:#ffffff" test19.png
                            # exec gm convert -size "200x200" -fill $c1 -stroke $c1 -draw "path 'M $x0 $y0 L $x1 $y1 L $x2 $y2 L $x0 $y0'" test19.png test19.png
                            set dim_px [expr { 2 * round( $r + .99 )  } ]
                            exec gm convert -size ${dim_px}x${dim_px} "xc:#ffffff" $filepathname
                            set x0 [expr { int( $r ) + 1 } ]
                            incr x0
                            set y0 $x0
                            set i 0
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
                            # convert rads to degs:
                            set k0 [expr { 360. / $2pi } ]
                            # ns_log Notice "accounts-finance/lib/pretti-one-view.tcl k0 $k0 k1 $k1 k2 $k2 k3 $k3"
                            foreach row $table_data_list {
                                incr i
                                set odd_p [expr { $i - int( $i / 2 ) * 2 } ]
                                set x [lindex $row $x_idx]
                                set y [lindex $row $y_idx]
                                set arc_degs [expr { $k1 * $x } ]
                                set arc_rads [expr { $k4 * $x } ]
                                set ry [expr { ( ( $y - $y_min ) / $k3 + .5 ) * $r } ]

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
#                                    ns_log Notice "accounts-finance/lib/pretti-one-view.tcl theta_d2 $theta_d2 ry $ry arc_degs $arc_degs x $x y $y"
#                                    ns_log Notice "accounts-finance/lib/pretti-one-view.tcl x0 $x0 y0 $y0 x1 $x1 y1 $y1 x2 $x2 y2 $y2"
                                    # triangle + ellipse
                                    exec gm convert -size ${dim_px}x${dim_px} -fill $color_arr($odd_p) -stroke $color_arr($odd_p) -draw "path 'M $x0 $y0 L $x1 $y1 L $x2 $y2 L $x0 $y0'" $filepathname $filepathname
                                    exec gm convert -size ${dim_px}x${dim_px} -fill $color_arr($odd_p) -stroke $color_arr($odd_p) -draw "ellipse $x0,$y0 $ry,$ry ${theta_d1},${theta_d2}" $filepathname $filepathname
                                }
                            }
                            set y3 [expr { round( $y0 - $ry ) } ]
                            exec gm convert -size ${dim_px}x${dim_px} -strokewidth 1 -stroke $color_arr(0) -draw "path 'M $x0 $y0 L $x0 $y3'" $filepathname $filepathname

                        }
                    }
                }
            }
        }
        set table_html [qss_list_of_lists_to_html_table $table_lists $table_tag_atts_list]
        #    append table_html "<p>${table_comments}</p>"
        set table_log_messages_list [acc_fin::pretti_log_read $table_tid 3 $user_id $instance_id]
        if { [llength $table_log_messages_list] > 0 } {
            set message_html "<h3>Most Recent Activity Log</h3><ul>"
            foreach message $table_log_messages_list {
                append message_html "<li>"
                append message_html $message
                append message_html "</li>"
            }
            append message_html "</ul>"
            append table_comments $message_html
        }
    }
}
