# file: eq-vs-global-delta-t.tcl
# See specific procedures and file comments for code attributions.

set tcl_version [info tclversion]
puts "Tcl version [info patchlevel]"
if { $tcl_version < 8.5 } {
    # Report TCL environment (version). 
    puts "Tcl version 8.5 or above recommended."
}

proc gm_path_builder { list_of_points } {
    set point_count [expr { [llength $list_of_points] / 2 } ]
    set x [lindex $list_of_points 0]
    set y [lindex $list_of_points 1]
    if { $point_count > 1 } {
        # Move to first point, then draw to each that follows.
        # Number of points is limited by line
        set path_specification "path '"
        set movement_type "M"
        append path_specification "${movement_type} $x $y"
        set movement_type " L"
        foreach {x y} $list_of_points {
            append path_specification "${movement_type} $x $y"
            # set movement_type " L"
        }
        append path_specification "'"
    } else {
        # path is a point
        set path_specification "point $x $y"
    }
    return $path_specification
}

proc draw_image_path_color { imagename x_y_coordinates_list color {opacity 1} } {
    # Move to first point in path, then draw to each that follows.
    # graphicsmagick.org/wand/drawing_wand.html#drawsetstrokeopacity
    # and graphicsmagick.org/1.2/www/GraphicsMagick.html
    # gm comvert infile -operator opacity xor "100%" outfile
    # gm convert infile -operator opacity xor|add|and|or|subtract "60%" outfile
    
    while { [llength $x_y_coordinates_list] > 100  } {
        set path_segment [lrange $x_y_coordinates_list 0 99]
        set x_y_coordinates_list [lrange $x_y_coordinates_list 98 end]
        #puts "exec gm convert -fill none -stroke $color -draw [gm_path_builder $path_segment ] $imagename $imagename"
        exec gm convert -fill none -stroke $color -draw [gm_path_builder $path_segment ] $imagename $imagename
    }
    #puts "exec gm convert -fill none -stroke $color -draw [gm_path_builder $x_y_coordinates_list ] $imagename $imagename"
    exec gm convert -fill none -stroke $color -draw [gm_path_builder $x_y_coordinates_list ] $imagename $imagename
}

proc annotate_image_pos_color { imagename x y color text } {
    # To annotate an image with blue text using font 12x24 at position (100,100), use:
    #    gm convert -font helvetica -fill blue -draw "text 100,100 Cockatoo" bird.jpg bird.miff
    # from: http://www.graphicsmagick.org/convert.html
    # Do not specify font for now. For compatibility between systems, assume there is a gm default.
    # exec gm convert -font "courier new" -fill $color -draw "text $x,$y $text" $imagename $imagename
    exec gm convert -fill $color -draw "text $x,$y $text" $imagename $imagename
}

proc filter_data { filter_list data_list } {
    set new_data_list [list ]
    # y = f(x)
    set filter_len [llength $filter_list]
    if { $filter_len > 0 } {
        set b 0
        set a [expr { $b - $filter_len + 1 } ]
        foreach y $data_list {
            # negative range indexes clip at 0
            set sample_list [lrange $data_list $a $b]
            set sample_len [llength $sample_list]
            set i_start [expr { $filter_len - $sample_len } ]
            
            if { $i_start > 0 } {
                # filter is larger than sample size
                set this_filter_list [lrange $filter_list $i_start end]
            } else {
                set this_filter_list $filter_list
            }
            set factor_sum 0.
            foreach factor $this_filter_list {
                set factor_sum [expr { $factor_sum + $factor } ]
            }
#            puts "filter_data: factor_sum $factor_sum i_start $i_start this_filter_list '$this_filter_list'"
            if { $i_start < 0 || [lindex $sample_list end] ne $y } {
                puts "filter_data error i_start: $i_start for: a $a b $b filter_list $filter_list sample_list $sample_list "
            }
            set c 0
            set sum 0
            foreach factor $sample_list {
                set term [expr { $factor * [lindex $this_filter_list $c] } ]
#                puts "filter_data: sum $sum term $term factor $factor c $c"
                set sum [expr { $sum + $term } ]
            }
            set geometric_avg [expr { $sum / ( $factor_sum + 0. ) } ]
            incr a
            incr b
            lappend new_data_list $geometric_avg
        }
    }
    return $new_data_list
}

proc binary11_series { term_count } {
    set binary_expan_list [list 1 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216 33554432 67108864]
    set binary_expan_len 28
    set i 26
    while { $term_count > $binary_expan_len && $binary_expan_len < 64 } {
        incr i
        lappend binary_expan_list [expr { wide( pow(2,$i) ) } ]
        incr binary_expan_len
    }
    incr term_count -1
    set binary_expan_list [lrange $binary_expan_list 0 $term_count]
    return $binary_expan_list
}

proc fibonacci_series { term_count } {
    set fibonacci_list [list]
    # Is term_count maybe too large?
    if { $term_count < 32767 } {
        set fibonacci_len 12
        set a 89
        set b 144
        lappend fibonacci_list 1 1 2 3 5 8 13 21 34 55 89 144
        while { $term_count > $fibonacci_len } {
            set c [expr { $a + $b } ]
            lappend fibonacci_list $c
            incr fibonacci_len
            set a $b
            set b $c
        }
        # Using lrange to handle low count cases
        incr term_count -1
        set fibonacci_list [lrange $fibonacci_list 0 $term_count]
    }
    return $fibonacci_list
}

proc decay_1_series { term_count } {
    # based on round(x/(x+1/x)) where x = term_count; circa 1/x or inverse proportion
    set decay_list [list ]
    if { $term_count > -1 && $term_count < 10000 } {
        for {set x 0} {$x < $term_count} {incr x} {
            set y [expr { round( $term_count / ($x + 1. / ( $term_count * 1. ) ) ) } ]
            lappend decay_list $y
        }
        incr term_count -1
        set decay_list [lrange $decay_list 0 $term_count]
    }
    return $decay_list
}

proc decay_2_series { term_count } {
    # based on avalance decay; circa -x^2
    set decay_list [list ]
    if { $term_count > -1 && $term_count < 10000 } {
        set k1 [expr { pow($term_count,2) } ]
        for {set x 0} {$x < $term_count} {incr x} {
            set y [expr { round( $k1 - pow($x,2) ) } ]
            lappend decay_list $y
        }
        incr term_count -1
        set decay_list [lrange $decay_list 0 $term_count]
    }
    return $decay_list
}

proc decay_3_series { term_count } {
    # based on avalance decay; -x^3
    set decay_list [list ]
    if { $term_count > -1 && $term_count < 10000 } {
        set k1 [expr { pow($term_count,3) } ]
        for {set x 0} {$x < $term_count} {incr x} {
            set y [expr { round( $k1 - pow($x,3) ) } ]
            lappend decay_list $y
        }
        incr term_count -1
        set decay_list [lrange $decay_list 0 $term_count]
    }
    return $decay_list
}

proc decay_4_series { term_count } {
    # based on linear decay; circa y = -x + term_count or countdown series
    set decay_list [list ]
    if { $term_count > -1 && $term_count < 10000 } {
        for {set x 0} {$x < $term_count} {incr x} {
            set y [expr { round( $term_count - $x ) } ]
            lappend decay_list $y
        }
        incr term_count -1
        set decay_list [lrange $decay_list 0 $term_count]
    }
    return $decay_list
}

proc sum_of_prev_terms { term_count {first_two_list "1 2"} } {
    if { $first_two_list eq "1 2" } {
        set first_two_list [list 1 2]
    } else {
        set first_two_list [lrange [concat [list 0 1] [split $first_two_list]] end-2 end]
    }
    set terms_len 2
    set terms_list $first_two_list
    while { $term_count > $terms_len } {
        set sum 0
        foreach term $terms_list {
            set sum [expr { $sum + $term } ]
        }
        lappend terms_list $sum
        incr terms_len
    }
    incr $term_count -1
    set terms_list [lrange $terms_list 0 $term_count]
    return $terms_list
}

proc regression_test { original_list test_list } {
    # Returns the sum of the square of the differences between the test values and original.
    # Returns -1 if the lists are not the same length
    set original_len [llength $original_list]
    set test_len [llength $test_list]
    if { $original_len != $test_len } {
        set sum -1
    } else { 
        set sum 0
    }
    if { $sum == 0 } {
        set i 0
        foreach x $original_list {
            set sum [expr { pow( [lindex $test_list $i] - $x , 2) + 0. } ]
            incr i
        }
    }
    return $sum
}

proc sign { number } {
    if { $number == 0 } {
        set sign 0
    } else {
        set sign [expr { round( $number / double( abs ( $number ) ) ) } ]
    }
    return $sign
}

proc minima_maxima_points { data_list } {
    # Returns a set of relative minimums and maximum values, where a minimum point = -1, a maximum point = 1 and all others 0.

    # Changes in the sign of the slope between points is being used to determine highs and lows
    # Use smooth filter on data_list as basis for finding rational maxima minima
    set minomaxima_list [list ]
    set y_prev [lindex $data_list 0]
    set dy_prev 0.
    set dy_sign_prev 0
    foreach y $data_list {
        set dy [expr { $y - $y_prev } ]
        set dy_sign [sign $dy ]
        if { $dy_sign == $dy_sign_prev || $dy_sign == 0 } {
            lappend minomaxima_list 0
            # if dy_sign is zero, signal is flat, don't change prev sign
            set y_prev $y
            set dy_prev $dy

        } elseif { $dy_sign > $dy_sign_prev } {
            # minimum
            lappend minomaxima_list -1
            set y_prev $y
            set dy_prev $dy
            set dy_sign_prev $dy_sign
        } else {
            lappend minomaxima_list 1
            # dy_sign < $dy_sign_prev
            set y_prev $y
            set dy_prev $dy
            set dy_sign_prev $dy_sign            
        }
    }

    # remove the first, false point that begins comparative loop
    set minomaxima_list [lrange $minomaxima_list 1 end]
    # is last point a relative min, max or 0 case?
    lappend minomaxima_list $dy_sign
    return $minomaxima_list
}

proc signal_smoother_1 { data_list {threashold_pct ".25"} } {
    # Returns a list of smoothed data from procedure's choices of filters
    # Assumes a best smooth fit should have 
    # a threashold of fewer than 25% of data points as relative minima or maxima

    set data_len [llength $data_list]

    # First run through a set of filters.
    set filter_list [list ]
    set quarter_data_len [expr { round( $data_len / 4. ) } ]
    for {set f_len $quarter_data_len} {$f_len > 1 } {set f_len [expr { round( $f_len / 2. ) } ] } {
        lappend filter_list [binary11_series $f_len]
        lappend filter_list [fibonacci_series $f_len]
        lappend filter_list [lsort -integer -increasing [decay_1_series $f_len]]
        lappend filter_list [lsort -integer -increasing [decay_2_series $f_len]]
        lappend filter_list [lsort -integer -increasing [decay_3_series $f_len]]
        lappend filter_list [lsort -integer -increasing [decay_4_series $f_len]]
        lappend filter_list [sum_of_prev_terms $f_len]
    }
    
    set threashold_limit [expr { round( $data_len * $threashold_pct * 1. ) } ]
    set f_i 0
    foreach filter $filter_list {
        set test_list_arr($f_i) [filter_data $filter $data_list]
        # collect min count, max count and total maxmin point count for each filter
        set min_max_ima [minima_maxima_points $test_list_arr($f_i) ]
        set min_count [llength [lsearch -exact -all $min_max_ima -1]]
        set max_count [llength [lsearch -exact -all $min_max_ima 1]]
        set sum_min_max_arr($f_i) [expr { $min_count + $max_count } ]
        if { $sum_min_max_arr($f_i) < $threashold_limit } {
            lappend sum_min_max_list [list $sum_min_max_arr($f_i) $f_i]
        }
        # Also track best case, should nothing be within threashold limit
        lappend sum_min_max_bu_list [list $sum_min_max_arr($f_i) $f_i]
        incr f_i
    }

    # What filter returns an average minima and maxima
    # for all cases where min + max count < threashold_pct of total count?

    # Determine median case, if no median, choose closest case

    # Median (slight bias toward fewer points in case of an even count of elements in sum_min_max_list)
    if { [llength $sum_min_max_list] > 0 } {
        set sum_sorted_list [lsort -integer -index 0 $sum_min_max_list]
        set median_i [expr { int( [llength $sum_sorted_list] / 2 ) } ]
        set median_min_max_count [lindex [lindex $sum_sorted_list $median_i] 0]
        set median_f_i [lindex [lindex $sum_sorted_list $median_i] 1]
        set return_list $test_list_arr($median_f_i)
        puts "signal_smoother_1: filter (ref $median_i): $return_list"
    } else {
        # No median exists within threshold. Choose closest to threshold ie fewest.
        set sum_sorted_list [lsort -integer -index 0 $sum_min_max_bu_list]
        set test_list_f_i [lindex [lindex $sum_sorted_list 0] 1]
        set return_list $test_list_arr($test_list_f_i)
    }
    return $return_list
}


# This code features building permutations of case studies of pedosphere
# by using multiple earthquake and global temperature data files.
# Pedosphere: The interface layer between lithosphere and space, 
# and consisting of atmosphere, hydrosphere and biosphere.
# Only one of each data type is required.

# input earthquake data

set eq_fi_list [list "IEB-export-earthquakes-as-an-HTML-table.html"]

foreach name $eq_fi_list {
    set data_html ""
    # efcount = earthquake file counter
    set efcount 1
    set fileId [open $name r]
    while { ![eof $fileId] } {
        #	append data_html \[read $fileId\]
        gets $fileId line
        append data_html $line
    }
    close $fileId
    
    # remove open TABLE tag and everything before it.
    regsub -nocase -- {^.* <table[^>]+[>]} $data_html {} data_2_html
    # remove close TABLE tag and everything after it.
    regsub -nocase -- {</table>.*$} $data_2_html {} data_3_html
    # convert BR tags to space
    regsub -nocase -all -- {<br>} $data_3_html { } data_4_html
    # remove TBODY tag
    regsub -nocase -all -- {<tbod[^>]+[>]} $data_4_html {} data_5_html
    # remove close TR tags
    regsub -nocase -all -- {</tr>} $data_5_html {} data_6_html
    # remove any existing tabs and newlines
    regsub -nocase -all -- {\t\n} $data_6_html {} data_7_html
    # remove extra spaces
    regsub -nocase -all -- {[ ]+} $data_7_html { } data_8_html
    # convert open TR tags to new lines
    regsub -nocase -all -- {<tr[^>]*[>]} $data_8_html "\n" data_9_html
    # convert TD and TH tags to tab delimiters
    regsub -nocase -all -- {<t[hd][^>]*[>]} $data_9_html "\t" data_10_html
    # remove any remaining close html tags
    regsub -nocase -all -- {</[^>]+[>]} $data_10_html {} data_11_html
    # remove A tags, but leave the wrapped references
    regsub -nocase -all -- {<a[ ]+href[^>]+[>]} $data_11_html {} data_12_txt
    
#    puts "data_12_txt: $data_12_txt"
    set data_12_list [split $data_12_txt "\n"]
    set table_list [list ]
    set line_count 0
    foreach line $data_12_list {
        incr line_count
        set line_v2 [split $line "\t"]
        set line_v2_cols [llength $line_v2]
        if { $line_v2_cols > 8 } {
            # Line contains 9 or 10 cols, including extra blank ones we introduced when removing html above.
            while { $line_v2_cols > 9 && [string trim [lindex $line_v2 0]] eq "" } {
                set line_v2 [lrange $line_v2 1 end]
                incr line_v2_cols -1
            }
            set line_v3 $line_v2
            
            set line_v4 [list ]
            foreach column $line_v3 {
                set val_new [string trim $column]
                lappend line_v4 $val_new
            }
            set line_v4_cols [llength $line_v4]
            if { $line_v4_cols != 9 } {
                puts "Error. $line_v4_cols columns for '$line_v4'"
            } else {
                lappend table_list $line_v4
            }
        } else {
            puts "This line of $line_v2_cols columns was not processed: '$line_v2'"
        }
    }

    # Table columns in this sequence, header, and data format:
    # Magnitude   "Mag"              real number N.N 
    # Depth       "Depth km"         real number N.N
    # Day         "Day"              YYYY-MM-DD
    # Time        "Time UTC"         NN:NN:NN
    # Latitude    "Lat"              real number +N.N
    # Longitude   "Lon"              real number +N.N
    # Region      "Region"           [A-Z0-9, \.\-]
    # Event ID    "Explore Event ID" integer
    # Timestamp   "Timestamp"        wide integer
    
    # epcounter = earthquake-data point count
    set epcount 0
    set has_title_p 0
    set row_list [lindex $table_list 0]
    if { [lindex $row_list 0] eq "Mag" } {
        # ignore. This is a title row
        puts "Ignoring title row: $row_list"
        set table_list [lrange $table_list 1 end]
    }

    # data integrity check
    foreach row_list $table_list {
        set mag [lindex $row_list 0]
        set depth [lindex $row_list 1]
        set day [lindex $row_list 2]
        set time_utc [lindex $row_list 3]
        set lat [lindex $row_list 4]
        set lon [lindex $row_list 5]
        set region [lindex $row_list 6]
        set event_id [lindex $row_list 7]
        set timestamp_epoch [lindex $row_list 8]
        # Error if any data doesn't pass a type check.
        # The checks for real number convert a number to 1, which is "yes" in tcl logic.
        # Each set of depth, lat and lon can have a values of 0,
        #  so adding 1 to numerator and denominator satisfy those cases.
        set mag_ck [expr { round( $mag / $mag ) } ]
        set depth_ck [expr { round( ( 1. + $depth) / ( 1. + $depth ) ) } ]
        set day_ck [regexp -- {^[1-2][0-9][0-9][0-9][\-][0-9][0-9][\-][0-9][0-9]$} $day match]
        set time_utc_ck [regexp {^[0-9][0-9][\:][0-9][0-9][\:][0-9][0-9]$} $time_utc match]
        set lat_ck [expr { round( ( $lat + 1. ) / ( $lat + 1. ) ) } ]
        set lon_ck [expr { round( ( $lon + 1. ) / ( $lon + 1. ) ) } ]
        set region_ck [regexp -nocase -- {^[A-Z0-9 ,\.\-]+$} $region match]
        set event_id_ck [regexp -- {^[0-9]+$} $event_id match]
        set timestamp_epoch_ck [regexp -- {^[0-9]+$} $timestamp_epoch match]
        
        if { $mag_ck && $depth_ck && $day_ck && $time_utc_ck && $lat_ck && $lon_ck && $region_ck && $event_id_ck && $timestamp_epoch_ck } {
            # increment epcount in preparation for next point
            incr epcount
        } else {
            puts "Integrity error for row: $row_list"
            puts "mag $mag_ck, depth $depth_ck, day $day_ck, time $time_utc_ck, lat $lat_ck, lon $lon_ck, region $region_ck, event_id $event_id_ck, timestamp $timestamp_epoch_ck"
            Error
        }
            
    }
    # Sort data chronologically so that changes per unit time can be tracked.
    set table_list [lsort -index 8 -integer -increasing $table_list]

    set row_count [llength $table_list]
    puts "There are $row_count data points."
    set eq_count_arr($efcount) $row_count
    
    set epcount 0
    puts "Calculating earthquake time and energy values for analysis."
    # Since the earthquake energies are so large, we change the energy unit from Ergs to Exajoules,
    # where 10^7 ergs = 1 joule and 10^18 joules = 1 Exajoule
    set eq_unit_conv_factor [expr { pow(10,-25) } ]
    set energy_units "Exajoules"

    foreach row_list $table_list {
        incr epcount
        # Focus on energy, depth, and time interval of occurance.
        # Earthquake energy depends on mag.
        # Time interval (a year_decimal used by climate data) depends on day.
        # Get base values
        set mag [lindex $row_list 0]
        set depth [lindex $row_list 1]
        set day [lindex $row_list 2]
        set t_epoch [lindex $row_list 8]
        # Calculate energy in ergs
        # energy = (10^1.5)^mag (as a ratio comparison) per http://earthquake.usgs.gov/learn/topics/how_much_bigger.php
        # Me = 2/3 log10E - 2.9 from: http://earthquake.usgs.gov/learn/topics/measure.php
        
        # seismic moment, Moment energy (Me) = 10^( (3*$mag/2) + 16.1 ) 
        # where: moment is in dyne-centimeters. 
        #        1 dyne-centimeter = 1 erg
        #        10 000 000 dyne-centimeters = 1 newton-meter
        # from: http://www.ajdesigner.com/phpseismograph/earthquake_seismometer_moment_magnitude_conversion.php
        
        #  set Me [expr { pow(10.,16.1 + 3. * $mag / 2.) } ]
        #  Seismic wave energy (E) = Mo / 2000.
        # since:
        # log E = 1.5 * $mag + 11.8 (Gutenberg-Richter magnitude-energy relation)
        # E = 10 ^ (1.5 * $mag + 11.8 )
        # from: http://www.jclahr.com/alaska/aeic/magnitude/energy_calc.html
        
        # USGS reference uses 16.1 instead of the Gutenberg-Richter magnitude-energy relation use of 11.8.
        # For this exercise, the energy value isn't as important as the change in energy.
        # Therefore, am using '16.1', which might exagerate differences.
        set energy [expr { pow( 10. , 1.5 * $mag + 16.1) * $eq_unit_conv_factor } ]
        # Calculate a year_decimal for $day that is consistent with global temperature data.
        # There are fewer significant digits of year_decimals in the climate data.
        # To match up earthquake and climate time intervals, both time sets are re-calculated using 
        # math from this program by first converting the data to YYYY-MM format, then
        # calculating year_decimal as YYYY + ( MM - 1 )/12 + 1/24.
        regexp {^([1-2][0-9][0-9][0-9])-([0-9][0-9])-[0-9][0-9]$} $day match year month
        # Remove a leading zero digit in a month to avoid tcl interpreting month as an octal number
        regsub -- {^0([1-9])$} $month {\1} month
        set year_decimal [expr { $year + ($month - 1. ) / 12. + 1./24. } ]

        #  Put data in an arrays.
        set eq_mag_arr($efcount,$epcount) $mag
        set eq_depth_arr($efcount,$epcount) $depth
        set eq_day_arr($efcount,$epcount) $day
        set eq_energy_arr($efcount,$epcount) $energy
        # For error, we assume the worst case, which is one significant digit of a higher magnitude
        # since lower magnitudes represent less energy.
        set mag_error_max [expr { $mag + 0.1 } ]
        set mag_error_min [expr { $mag - 0.1 } ]
        set energy_error_max [expr { pow( 10. , 1.5 * $mag_error_max + 16.1) * $eq_unit_conv_factor } ]
        set energy_error_min [expr { pow( 10. , 1.5 * $mag_error_min + 16.1) * $eq_unit_conv_factor } ]
        # energy error is half of range between energy of next higher magnitude - energy at next lower magnitude
        set eq_error_arr($efcount,$epcount) [expr { ( $energy_error_max - $energy_error_min ) / 2. } ]
        set eq_year_dec_arr($efcount,$epcount) $year_decimal
        # Save year and month format.
        # Grouping by year and month avoids introducing possible rounding and number value mismatch errors from 
        # decimal math when using year_decimal values.
        set eq_yyyy_arr($efcount,$epcount) $year
        set eq_mm_arr($efcount,$epcount) $month
        
        #puts "mag: $mag, energy: $energy, depth: $depth, day: $day, year: $year, month: $month, dYear: $year_decimal, t_epoch $t_epoch"
    }
    incr efcount
}
# de-incriment efcount
incr efcount -1

# input global temperature data
set t_fi_list [list \
                   www-users.york.ac.uk-tildekdc3-papers-coverage2013-had4_krig_std.temp.txt \
                   www-users.york.ac.uk-tildekdc3-papers-coverage2013-had4_hybrid_std.temp.txt]
# data files from www-users.york.ac.uk/~kdc3/papers/coverage2013/
# had4_hybrid_st.temp and had4_krig_std.temp formats are identical and tab delimited:
# Year_decimal Delta_temperature_oC Error_range
# example: 1979.04166667	-0.293750393543	0.0440333616436
# The decimal portions of years are in increments of 1/12 starting with 1/24.
# For example, "March 1980" is "1980 + 1/24 + 2 x 1/12 = 5/24" or 1980.208333
# 
# The temperatures are delta t in Celsius/Centigrade/Kelvin from a statistically normalized reference point

foreach filename $t_fi_list {
    set data_txt ""
    # cfcount = climate file counter
    set cfcount 1
    set fileId [open $filename r]
    while { ![eof $fileId] } {
#        gets $fileId line
#        append data_txt "$line"
        # Read entire file. 
        append data_txt [read $fileId]
    }
    close $fileId
    # split is unable to split lines consistently with \n or \r
    # so, splitting by everything, and recompiling each line of file.
    set data_set_list [split $data_txt "\n\r\t"]
    set table_list [list ]
    set line_count 0
    foreach {year delta_t error_amt} $data_set_list {
        # data integrity check (minimal, because file is in a standard, tab delimited format).
        if { $year ne "" && $delta_t ne "" && $error_amt ne "" } {
            set year_ck [expr { ( 1. + $year ) / ( $year + 1. ) } ]
            set delta_t_ck [expr { ( 1. + $delta_t ) / ( $delta_t + 1. ) } ]
            # error_amt is a positive real number > 0
            set error_amt_ck [expr { round( $error_amt /  abs( $error_amt ) ) == 1 } ]
            if { $year < 1978 || $year > 2013 } {
                set year_ck 0
            }
            if { $year_ck && $delta_t_ck && $error_amt_ck } {
                set line_v2 [list $year $delta_t $error_amt]
                lappend table_list $line_v2
                incr line_count
            } else {
                puts "This data point did not pass integrity check. Ignored:"
                puts "year $year, delta_t $delta_t, error $error_amt"
            }
        }
    }
    # table_list is a list of lists.
    puts "$filename has $line_count data points."
    
    # Sort data chronologically so that changes per unit time can be tracked.
    # Sort table_list by year_dec_input. There should only be one per interval.
    set table_list [lsort -index 0 -real -increasing $table_list]

    # Data in this format:
    # year_decimal = YYYY + (MM-1)/12 + 1/24, where YYYY-MM is year and month
    # delta_t      = offset of temperature in Celsius from reference temperature.
    # error_amt     = measurement error.
    set cpcount 0
    foreach row_list $table_list {
        incr cpcount 
        set year_dec_input [lindex $row_list 0]
        set delta_t [lindex $row_list 1]
        set error_amt [lindex $row_list 2]
        # Calculations
        # Re-calculate year_decimal
        set year [expr { int( $year_dec_input ) } ]
        set numerator_over_24 [expr { round( ( $year_dec_input - $year ) * 24. ) } ]
        set month [expr  { round( ( $numerator_over_24 + 1. ) / 2. ) } ]
        # Following is consistent with earthquake year_decimal calculation:
        set year_decimal [expr { $year + ($month - 1. ) / 12. + 1./24. } ]
#        puts "year_dec $year_dec_input, delta_t $delta_t, error_amt $error_amt, year $year, numerator/24 $numerator_over_24, month $month, year_decimal $year_decimal"
        set ct_year_dec_arr($cfcount,$cpcount) $year_decimal
        set ct_delta_t_arr($cfcount,$cpcount) $delta_t
        set ct_error_arr($cfcount,$cpcount) $error_amt
        # Save year and month format.
        # Grouping by year and month avoids introducing possible rounding and number value mismatch errors from
        # decimal math when using year_decimal values.
        set ct_yyyy_arr($cfcount,$cpcount) $year
        set ct_mm_arr($cfcount,$cpcount) $month
        # create a reverse pointer array
        set ct_cpc_arr($cfcount,$year,$month) $cpcount
    }
    puts "$cpcount data points calculated."
    set ct_count_arr($cfcount) $cpcount
    incr cfcount
}
# de-increment cfcount 
incr cfcount -1


puts "Analyzing."
# ..............................................................
# ..............................................................
# Analyze
# ..............................................................

# cfc = climate-data file counter (or index)
# efc = earthquake-data file counter (or index)
# cpc = climate-data point counter (or index)
# epc = earthquake-data point counter (or index)
# epcount = number of earthquake-data points for a specific epc
# efcount = number of earthquake-data files (or index)
# cpcount = number of climate-data points for a specific cpc
# cfcount = number of climate-data files (or index)

# timeline_arr(month_nbr), where month_nbr is yyyy-Year_min + MM - Year_min_month : easiest to calculate using delta year_decimal

# ..............................................................
# Climate data
# first time interval ct_year_dec_arr($cfc,1)
# last time interval ct_year_dec_arr($cfc,$ct_count_arr($cfc))
# temperature is a Celsius/Centrigrade/Kelvin value relative to an "arbitrary" value.

# Arrays:
# ct_year_dec_arr(cfc,cpc) a month ie interval of time
# ct_delta_t_arr(cfc,cpc) temperature realative to an arbitrary fixed value
# ct_error_arr(cfc,cpc) pre-analysis temperature value error
# ct_yyyy_arr(cfc,cpc) the year of this interval
# ct_mm_arr(cfc,cpc) the month of this interval
# ct_cpc_arr(cfc,$year,$month) cpc counter reference for reverse referencing

# ..............................................................
# Earthquake data
# first time interval eq_year_dec_arr($efc,1)
# last time interval eq_year_dec_arr($efc,$eq_count_arr($efc))
# eq_mag_arr(efc,epc) earthquake magnitude
# eq_depth_arr(efc,epc) depth of earthquake
# eq_day_arr(efc,epc) day of earthquake (UTC in form YYYY-MM-DD)
# eq_energy_arr(efc,epc) energy of earthquake derived from magnitude. See notes for details.
# eq_error_arr(efc,epc) half the energy range of the next highest and next lowest magnitude earthquakes
# eq_year_dec_arr(efc,epc) year decimal of earthquake, consistent with ct_year_dec_arr values
# eq_yyyy_arr(efc,epc) year of earthquake
# eq_mm_arr(efc,epc) month of earthquake

# ..............................................................
# Loop through the various permutations of earthquake data and climate data separately.
# Each analysis only uses one earthquake and one climate data set.
puts "Looping through permuations of earthquake and climate data."
for {set efc 1} {$efc <= $efcount} {incr efc} {
    for {set cfc 1} {$cfc <= $cfcount} {incr cfc} {
        puts "Current earthquake data set from: [lindex $eq_fi_list $efc-1]"
        puts "Current climate data set from: [lindex $t_fi_list $cfc-1]"

        # First, set eq_yyyy_mm_energy(for all ct_year_decimal cases) to 0
        for {set cpc 1} {$cpc <= $cpcount} {incr cpc} {
            set eq_energy_yyyy_mm_arr($cfc,$cpc) 0.0
            set eq_energy_yyyy_mm_err_arr($cfc,$cpc) 0.0
        }

        # build a table of earthquake energy per month (for earthquakes of 6.5 and above).
        # Loop throuth all eq_year_decimal cases to add each eq energy approptriate interval
        for {set epc 1} {$epc <= $epcount} {incr epc} {
            set year $eq_yyyy_arr($efc,$epc)
            set mm $eq_mm_arr($efc,$epc)
            if { [info exists ct_cpc_arr($cfc,$year,$mm) ] } {
                set cpc2 $ct_cpc_arr($cfc,$year,$mm)
                set eq_energy_yyyy_mm_arr($cfc,${cpc2}) [expr { $eq_energy_yyyy_mm_arr($cfc,${cpc2}) + $eq_energy_arr($efc,$epc) } ]
                set eq_energy_yyyy_mm_err_arr($cfc,${cpc2}) [expr { $eq_energy_yyyy_mm_err_arr($cfc,${cpc2}) + $eq_error_arr($efc,$epc) } ]
            } else {
                #puts "(ref393)eq_energy for interval $year-$mm-15 of $eq_energy_arr($efc,$epc) ignored. Out of climate data range."
            }
        }

        # Find the average, minimum and maximum, and difference from prior month
        # Loop through all eq_yyyy_mm_energy cases, to find min,max,total,average
        set eq_energy $eq_energy_yyyy_mm_arr($cfc,1)
        set ct_delta_t $ct_delta_t_arr($cfc,1)
        set eq_energy_max $eq_energy
        set eq_energy_min $eq_energy
        set eq_energy_tot $eq_energy
        set ct_delta_t_max $ct_delta_t
        set ct_delta_t_min $ct_delta_t
        set ct_delta_t_tot $ct_delta_t
        set eq_energy_yyyy_mm_diff_max 0
        set eq_energy_yyyy_mm_diff_min 0
        set ct_delta_t_diff_max 0
        set ct_delta_t_diff_min 0


        for {set cpc3 2} {$cpc3 <= $cpcount} {incr cpc3} {

            set eq_energy_prev $eq_energy
            set ct_delta_t_prev $ct_delta_t
            set eq_energy $eq_energy_yyyy_mm_arr($cfc,$cpc3)
            # Auditing energy
            # puts "cpc3 $cpc3 energy $eq_energy"
            set ct_delta_t $ct_delta_t_arr($cfc,$cpc3)
            set eq_energy_yyyy_mm_diff  [expr { $eq_energy - $eq_energy_prev } ]
            set ct_delta_t_diff [expr { $ct_delta_t - $ct_delta_t_prev } ]

            # Build an array of difference from last interval's eq energy
            set eq_energy_yyyy_mm_diff_arr($cfc,$cpc3) $eq_energy_yyyy_mm_diff
            # Build an array of difference from last interval's delta t
            set ct_delta_t_diff_arr($cfc,$cpc3) $ct_delta_t_diff
            # Adjust maximum or minimum values?
            if { $eq_energy > $eq_energy_max } {
                # new eq_energy_max
                set eq_energy_max $eq_energy
            } elseif { $eq_energy < $eq_energy_min } {
                # new eq_energy_min
                set eq_energy_min $eq_energy
            }
            if { $ct_delta_t > $ct_delta_t_max } {
                # new ct_delta_t_max
                set ct_delta_t_max $ct_delta_t
            } elseif { $ct_delta_t < $ct_delta_t_min } {
                # new ct_delta_t_min
                set ct_delta_t_min $ct_delta_t
            }

            # Adjust maximum or minimum diff values?
            if { $eq_energy_yyyy_mm_diff > $eq_energy_yyyy_mm_diff_max } {
                # new eq_energy_diff_max
                set eq_energy_yyyy_mm_diff_max $eq_energy_yyyy_mm_diff
            } elseif { $eq_energy_yyyy_mm_diff < $eq_energy_yyyy_mm_diff_min } {
                # new eq_energy_diff_min
                set eq_energy_yyyy_mm_diff_min $eq_energy_yyyy_mm_diff
            }
            if { $ct_delta_t_diff > $ct_delta_t_diff_max } {
                # new ct_delta_t_diff_max
                set ct_delta_t_diff_max $ct_delta_t_diff
            } elseif { $ct_delta_t_diff < $ct_delta_t_diff_min } {
                # new ct_delta_t_diff_min
                set ct_delta_t_diff_min $ct_delta_t_diff
            }

            # accumulate energy
            set eq_energy_tot [expr { $eq_energy_tot + $eq_energy } ]
            
        }
        puts "Min energy (${energy_units}): $eq_energy_min"
        puts "Max energy (${energy_units}): $eq_energy_max"
        puts "Total energy (${energy_units}): $eq_energy_tot"
        set y_eq_range [expr { $eq_energy_max - $eq_energy_min } ]
        puts "Energy range: $y_eq_range"
        set y_eq_diff_range [expr { $eq_energy_yyyy_mm_diff_max - $eq_energy_yyyy_mm_diff_min } ]

        puts "Min temperature (C): $ct_delta_t_min"
        puts "Max temperature (C): $ct_delta_t_max"
        set y_ct_range [expr { $ct_delta_t_max - $ct_delta_t_min } ]
        puts "Temperature range: $y_ct_range"
        set y_ct_diff_range [expr { $ct_delta_t_diff_max - $ct_delta_t_diff_min } ]


        # Find minima and maxima of climate data
        set ct_delta_t_list [list ]
        set eq_energy_yyyy_mm_list [list ]
        for {set cpc 1} {$cpc <= $cpcount} {incr cpc} {
            lappend ct_delta_t_list $ct_delta_t_arr($cfc,$cpc)
            # make a similar 1:1 list of earthquake data.. might come in handy in later analysis
            lappend eq_energy_yyyy_mm_list $eq_energy_yyyy_mm_arr($cfc,$cpc)
        }

        set smooth_data_list [signal_smoother_1 $ct_delta_t_list] 
        set extremes_list [minima_maxima_points $smooth_data_list ]
 
        # Split data into climate temperature moving down and up curves

        # dcounter = slope or delta t change counter
        set dcounter 1
        set cpc 1
        set ct_delta_t_dy_arr($dcounter) 0.
        set eq_energy_yyyy_mm_dy_arr($dcounter) 0.
        set ct_months_dy_arr($dcounter) 0
        foreach minmax_q $extremes_list {
            # minmax_q = 0  no change in y direction
            # minmax_q = 1  max point reached, heading downward next point
            # minmax_q = -1 min point reached, heading upward next point
            set ct_delta_t_dy_arr($dcounter) [expr { $ct_delta_t_dy_arr($dcounter) + $ct_delta_t_arr($cfc,$cpc) } ]
            set eq_energy_yyyy_mm_dy_arr($dcounter) [expr { $eq_energy_yyyy_mm_dy_arr($dcounter) + $eq_energy_yyyy_mm_arr($cfc,$cpc) } ]
            set ct_months_dy_arr($dcounter) [expr { $ct_months_dy_arr($dcounter) + 1 } ]
            if { $minmax_q ne 0 } {
                incr dcounter
                set ct_delta_t_dy_arr($dcounter) 0.
                set eq_energy_yyyy_mm_dy_arr($dcounter) 0.
                set ct_months_dy_arr($dcounter) 0
            }
            incr cpc
        }
        if { $ct_delta_t_dy_arr($dcounter) == 0. } {
            # last min/max point was at end of data and contains no accumulations
            incr dcounter -1
        }

        # Calculate earthquake energy on delta_t down and up trends
        # and average earthquake energy per delta_t
        for {set dc 1} {$dc <= $dcounter} {incr dc} {
            set eq_per_ct_arr($dc) [expr { $eq_energy_yyyy_mm_dy_arr($dc) / ( $ct_delta_t_dy_arr($dc) * 1. ) } ]
            set eq_per_mm_arr($dc) [expr { $eq_energy_yyyy_mm_dy_arr($dc) / ( $ct_months_dy_arr($dc) * 1. ) } ]
            puts "eq_energy/delta_t for $ct_months_dy_arr($dc) months: $eq_per_ct_arr($dc)"
            puts "eq_energy/month: $eq_per_mm_arr($dc)\n"
        }
        

        # ..............................................................
        # Graph results.

        set chart_name "/home/head/eq-$efc-ct-$cfc-chart-[clock seconds].png"
        # Determine dimensions, origins and scales
        # Create canvas image
        set width_px [expr { $cpcount * 4 } ]
        # height setting is somewhat arbitrary.
        set height_px [expr { $cpcount * 4 } ]
        # to create a solid red canvas image:
        #gm convert -size 640x480 "xc:#f00" canvas.png
        # from: www.graphicsmagick.org/FAQ.html
        exec gm convert -size ${width_px}x${height_px} "xc:#ffffff" $chart_name

        set chart_count 3
        # draw a dark contrast path for data, and a light contrast path for error range. 
        # split the image in $graph_count horizontal segments
        # 1. for data
        # 2. for data changes in chronological order
        # 3+ re sorted to show proportional or inversely proportional patterns (if any)

        # set charting constants
        for {set c_i 1} {$c_i <= $chart_count} {incr c_i} {
            # x image references
            set x_plot_start_arr($c_i) [expr { $cpcount / 2 } ]
            set x_plot_end_arr($c_i) [expr { $x_plot_start_arr($c_i) + $cpcount - 1 } ]
            set x_plot_range_arr($c_i) [expr { $x_plot_end_arr($c_i) - $x_plot_start_arr($c_i) } ]
            # y image references
            set y_plot_range_arr($c_i) [expr { $height_px / ( $chart_count + 1. ) } ]
            set y_plot_low_limit_arr($c_i) [expr { $y_plot_range_arr($c_i) / 2. + ( $c_i - 1) * $y_plot_range_arr($c_i) } ]
            set y_plot_high_limit_arr($c_i)  [expr { $y_plot_low_limit_arr($c_i) + $y_plot_range_arr($c_i) - 1 } ]
            # boundary of this graph: x_plot_start_arr,x_plot_end_arr, y_plot_low_limit_arr, y_plot_high_limit_arr
        }

        # ..............................................................
        # Chart 1
        # Showing accumulated earthquake energy and global temperature per month

        set c_i 1
        set x_ct_start $ct_year_dec_arr($cfc,1)
        set x_ct_end $ct_year_dec_arr($cfc,$cpcount)
        set x_ct_range [expr { $x_ct_end - $x_ct_start } ]
        set x_eq_start $eq_year_dec_arr($cfc,1)
        set x_eq_end $eq_year_dec_arr($cfc,$cpcount)
        set x_eq_range [expr { $x_eq_end - $x_eq_start } ]

        # loop through 1 to cpcount 
        puts "x_ct_plot y_eq_low_err_plot y_eq_high_err_plot y_ct_low_err_plot y_ct_high_err_plot y_ct_plot y_eq_plot"
        for {set cpc 1} {$cpc <= $cpcount} {incr cpc} {            
            # x_plot is a function of ct_year_dec_arr which is a function of i
            set x_ct_plot [expr { round( $x_plot_range_arr($c_i) * ( $ct_year_dec_arr($cfc,$cpc) - $ct_year_dec_arr($cfc,1) ) / $x_ct_range + $x_plot_start_arr($c_i) ) } ]
            # y_plot is a function of x, which is a function of i
            set y_ct_plot [expr { round( $y_plot_high_limit_arr($c_i) - $y_plot_range_arr($c_i) * ( $ct_delta_t_arr($cfc,$cpc) - $ct_delta_t_min ) / $y_ct_range ) } ] 
            # x_ct_low_err_plot and x_ct_high_err_plot is same as x_plot
            # y_ct_low_err_plot is a function of x, which is a function of i
            set y_ct_low_err_plot [expr { round( $y_plot_high_limit_arr($c_i) - $y_plot_range_arr($c_i) * ( ( $ct_delta_t_arr($cfc,$cpc) - $ct_error_arr($cfc,$cpc) )  - $ct_delta_t_min ) / $y_ct_range ) } ]
            set y_ct_high_err_plot [expr { round( $y_plot_high_limit_arr($c_i) - $y_plot_range_arr($c_i) * ( ( $ct_delta_t_arr($cfc,$cpc) + $ct_error_arr($cfc,$cpc) )  - $ct_delta_t_min ) / $y_ct_range ) } ] 

            # x_eq_plot is same as x_ct_plot
#            set x_eq_plot [expr { round( $x_plot_range_arr($c_i) * ( $eq_year_dec_arr($cfc,$cpc) - $x_start ) / $x_eq_range + $x_plot_start_arr($c_i) ) } ]
            set x_eq_plot $x_ct_plot
            # y_plot is a function of x, which is a function of i
            #set y_eq_plot [expr { round( $y_plot_range_arr($c_i) * ( $eq_energy_yyyy_mm_arr($cfc,$cpc) - $eq_energy_min ) / $y_eq_range + $y_plot_low_limit_arr($c_i) ) } ] 
            # y graphs postive values in Carteasian Quadrant 4, converting to Quandrant 1
            set y_eq_plot [expr { round( $y_plot_high_limit_arr($c_i) - $y_plot_range_arr($c_i) * ( $eq_energy_yyyy_mm_arr($cfc,$cpc) - $eq_energy_min ) / $y_eq_range ) } ] 
            # x_eq_low_err_plot and x_eq_high_err_plot is same as x_plot
            # y_eq_low_err_plot is a function of x, which is a function of i
            set y_eq_low_err_plot [expr { round( $y_plot_high_limit_arr($c_i) - $y_plot_range_arr($c_i) * ( ( $eq_energy_yyyy_mm_arr($efc,$cpc) - $eq_energy_yyyy_mm_err_arr($efc,$cpc) )  - $eq_energy_min ) / $y_eq_range ) } ]
            set y_eq_high_err_plot [expr { round(  $y_plot_high_limit_arr($c_i) - $y_plot_range_arr($c_i) * ( ( $eq_energy_yyyy_mm_arr($efc,$cpc) + $eq_energy_yyyy_mm_err_arr($efc,$cpc) )  - $eq_energy_min ) / $y_eq_range ) } ] 

            # plot in this sequence to minimize amibiguity due to overlaps: eq error band, ct error band, ct, eq
            # puts "$x_ct_plot $y_eq_low_err_plot $y_eq_high_err_plot $y_ct_low_err_plot $y_ct_high_err_plot $y_ct_plot $y_eq_plot"
            # eq error band
            draw_image_path_color $chart_name [list $x_ct_plot $y_eq_low_err_plot $x_ct_plot $y_eq_high_err_plot] "#ffcc99"
            # ct error band
            draw_image_path_color $chart_name [list $x_ct_plot $y_ct_low_err_plot $x_ct_plot $y_ct_high_err_plot] "#99ccff"
            # ct
            draw_image_path_color $chart_name [list $x_ct_plot $y_ct_plot] "#0000ff"
            # eq
            draw_image_path_color $chart_name [list $x_ct_plot $y_eq_plot] "#ff0000"
        }

        # ..............................................................
        # Chart 2
        # Showing change of accumulated earthquake energy and global temperature per month

        # Following calculated in Chart 1 loop:
        #  set eq_energy_yyyy_mm_diff_arr($cfc,$cpc3) [expr { $eq_energy - $eq_energy_prev } ]
        # Build an array of difference from last interval's delta t
        #  set ct_delta_t_diff_arr($cfc,$cpc3) [expr { $ct_delta_t - $ct_delta_t_prev } ]

        set c_i 2
        set x_ct_start $ct_year_dec_arr($cfc,2)
        set x_ct_end $ct_year_dec_arr($cfc,$cpcount)
        set x_ct_range [expr { $x_ct_end - $x_ct_start } ]
        set x_eq_diff_start $eq_year_dec_arr($cfc,2)
        set x_eq_diff_end $eq_year_dec_arr($cfc,$cpcount)
        set x_eq_diff_range [expr { $x_eq_end - $x_eq_start } ]
        set y_ct_zero_plot [expr { round(  $y_plot_high_limit_arr($c_i) - $y_plot_range_arr($c_i) * ( 0. - $ct_delta_t_diff_min ) / $y_ct_diff_range ) } ]
        set y_eq_zero_plot [expr { round(  $y_plot_high_limit_arr($c_i) - $y_plot_range_arr($c_i) * ( 0. - $eq_energy_yyyy_mm_diff_min ) / $y_eq_diff_range ) } ]

        # Start at cpc=2 instead of 1, because a difference is between 2 values..
        for {set cpc 2} {$cpc <= $cpcount} {incr cpc} {            

            set x_ct_plot [expr { round( $x_plot_range_arr($c_i) * ( $ct_year_dec_arr($cfc,$cpc) - $ct_year_dec_arr($cfc,1) ) / $x_ct_range + $x_plot_start_arr($c_i) ) } ]

            # plot y_ct_diff_plot
            set y_ct_diff_plot [expr { round(  $y_plot_high_limit_arr($c_i) - $y_plot_range_arr($c_i) * ( $ct_delta_t_diff_arr($cfc,$cpc) - $ct_delta_t_diff_min ) / $y_ct_diff_range ) } ]

            # plot y_eq_diff_plot
            set y_eq_diff_plot [expr { round(  $y_plot_high_limit_arr($c_i) - $y_plot_range_arr($c_i) * ( $eq_energy_yyyy_mm_diff_arr($cfc,$cpc) - $eq_energy_yyyy_mm_diff_min ) / $y_eq_diff_range ) } ]
            # puts "$x_ct_plot $y_ct_diff_plot $y_eq_diff_plot"
            draw_image_path_color $chart_name [list $x_ct_plot $y_eq_diff_plot $x_ct_plot $y_eq_zero_plot] "#ff0000"
            draw_image_path_color $chart_name [list $x_ct_plot $y_ct_diff_plot $x_ct_plot $y_ct_zero_plot] "#0000ff"
        }

        # ..............................................................
        # Chart 3. 
        # Showing average earthquake energy per day for periods of global temperature rises and fall
        # Assumption:
        # Each interval is approximately the same size ie 1/12th of a year.

        # First build a new set of data points: p = period pp = per_period stot = subtotal, where period is a positive integer number of intervals
        # p_start(i) p_end(i) p_interval_count(i) ct_diff_stot(i) eq_stot(i) eq_diff_stot(i) eq_avg_pp(i) eq_diff_pp(i) ct_avg_diff_pp(i)
        # References from earlier calculations:
        #    $ct_delta_t_arr($cfc,$cpc)
        #    $eq_energy_yyyy_mm_arr($cfc,$cpc)
        #    $ct_delta_t_diff_arr($cfc,$cpc)
        #    $eq_energy_yyyy_mm_diff_arr($cfc,$cpc)

        set x_ct_start $ct_year_dec_arr($cfc,2)
        set x_ct_end $ct_year_dec_arr($cfc,$cpcount)
        set x_ct_range [expr { $x_ct_end - $x_ct_start } ]
        set p_start $x_ct_start

        set p_interval_count 1

        # p_count is zero. First period (of 0) is ignored later because period might extend beyond available data.
        set p_count 0

        set ct_diff_stot 0.
        set eq_stot $eq_energy_yyyy_mm_arr($cfc,1)
        set eq_diff_stot 0.
        set ct_diff_lt_0 [expr { $ct_delta_t_diff_arr($cfc,2) < 0. } ]
        set ct_diff_sign_same 1
        puts "ct_diff_stot eq_stot eq_diff_stot eq_avg_pp eq_diff_pp ct_avg_diff_pp"

        for {set cpc 1} {$cpc <= $cpcount} {incr cpc} {
            lappend 

        }
            set ct_diff_lt_0_prev $ct_diff_lt_0
            set ct_delta_t_diff $ct_delta_t_diff_arr($cfc,$cpc)
            set ct_diff_lt_0 [expr { $ct_delta_t_diff < 0. } ]
            set ct_diff_sign_same [expr { $ct_diff_lt_0 == $ct_diff_lt_0_prev } ]
            # Instead of temperature diff, what about using a trend in order to catch minor variations..?  how to determine?
            # is this really working?  240 period?  out of 408
            # try geometric averaging of the progression, where significance of digits base on:
            # binary expansion:       (1-x)(1-2*x) ?
            # Fibonacci          
            # power of 2 expans.               10^a(n)+1
            # 100*e/(x+1))  round(271.8/(x+1))
            # or term_count / ( x + 1/term_count ) 
            # Graph vs. actual data. and check best fit...

            if { $ct_diff_sign_same } {
                # Add to current subtotals
                set ct_diff_stot [expr { $ct_diff_stot + $ct_delta_t_diff } ]
                set eq_stot [expr { $eq_stot + $eq_energy_yyyy_mm_arr($cfc,$cpc) } ]
                set eq_diff_stot [expr { $eq_diff_stot + $eq_energy_yyyy_mm_diff_arr($cfc,$cpc) } ]
                incr p_interval_count
            } else {
                # Calculate additional info
                set eq_avg_pp [expr { $eq_stot / $p_interval_count } ]
                set eq_diff_pp [expr { $eq_diff_stot / $p_interval_count } ]
                set ct_avg_diff_pp [expr { $ct_diff_stot / $p_interval_count } ]

                # Mark and save end of period
                set ct_diff_stot_arr($p_count) $ct_diff_stot
                set eq_stot_arr($p_count) $eq_stot
                set eq_diff_stot_arr($p_count) $eq_diff_stot
                set eq_avg_pp_arr($p_count) $eq_avg_pp
                set eq_diff_pp_arr($p_count) $eq_diff_pp
                set ct_avg_diff_pp_arr($p_count) $ct_avg_diff_pp
                puts "$ct_diff_stot $eq_stot $eq_diff_stot $eq_avg_pp $eq_diff_pp $ct_avg_diff_pp"
                # Start a new period
                incr p_count
                set p_interval_count 0
                set ct_diff_stot 0.
                set eq_stot 0.
                set eq_diff_stot 0.
                # Add to current subtotals
                set ct_diff_stot [expr { $ct_diff_stot + $ct_delta_t_diff } ]
                set eq_stot [expr { $eq_stot + $eq_energy_yyyy_mm_arr($cfc,$cpc) } ]
                set eq_diff_stot [expr { $eq_diff_stot + $eq_energy_yyyy_mm_diff_arr($cfc,$cpc) } ]
                incr p_interval_count
            }

        }
        # Calculate additional info for last (perhaps incomplete) period
        set eq_avg_pp [expr { $eq_stot / $p_interval_count } ]
        set eq_diff_pp [expr { $eq_diff_stot / $p_interval_count } ]
        set ct_avg_diff_pp [expr { $ct_diff_stot / $p_interval_count } ]

        # mark and save end of last period
        set ct_diff_stot_arr($p_count) $ct_diff_stot
        set eq_stot_arr($p_count) $eq_stot
        set eq_diff_stot_arr($p_count) $eq_diff_stot
        set eq_avg_pp_arr($p_count) $eq_avg_pp
        set eq_diff_pp_arr($p_count) $eq_diff_pp
        set ct_avg_diff_pp_arr($p_count) $ct_avg_diff_pp
        puts "ct_diff_stot eq_stot eq_diff_stot eq_avg_pp eq_diff_pp ct_avg_diff_pp"

        set c_i 3

        # Begin next permutation of climate and earthquake data..
    }
}



# Check for patterns:
#1.   change in Delta_t vs change in earthquake energy
#2.   earthquake energy per month vs. Delta_T
#3.   earthquake energy per month vs. average earthquake energy per month
#4.   average earthquake energy per month for decreasing Temp. vs. average earthquake energy per month for increasing Temp.
#5.   try sorting by maximum earthquake energy in each month, to see if it reveals a seasonal or temperature pattern
#6.   Acceleration continuity? check change of change of eq and ct data

