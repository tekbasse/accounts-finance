# file: eq-vs-global-delta-t.tcl
# See specific procedures and file comments for code attributions.

if { [catch {package require TclMagick} err_msg ] } {
    #puts "TclMagick not available. Using graphicsmagick directly."
    set __TclMagick_p 0
} else {
    #puts "Using TclMagick (This feature not implemented)."
    set __TclMagick_p 1
}

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
    set fillcolor "none"
    while { [llength $x_y_coordinates_list] > 100 } {
        set path_segment [lrange $x_y_coordinates_list 0 99]
        set x_y_coordinates_list [lrange $x_y_coordinates_list 98 end]
        #puts "exec gm convert -fill none -stroke $color -draw [gm_path_builder $path_segment ] $imagename $imagename"
        exec gm convert -fill $fillcolor -stroke $color -draw [gm_path_builder $path_segment ] $imagename $imagename
    }
    #puts "exec gm convert -fill none -stroke $color -draw [gm_path_builder $x_y_coordinates_list ] $imagename $imagename"
    set path [gm_path_builder $x_y_coordinates_list ]
    if { [string match "*point*" $path] } {
        set fillcolor $color
    }
    exec gm convert -fill $fillcolor -stroke $color -draw $path $imagename $imagename
}

proc draw_image_rect_color { imagename x0 y0 x1 y1 fillcolor {bordercolor ""} {opacity 1} } {
    if { $bordercolor eq ""} {
        set bordercolor $fillcolor
        set strokewidth 0
    } else {
        set strokewidth 1
    }
    exec gm convert -fill $fillcolor -stroke $bordercolor -draw "rectangle $x0,$y0 $x1,$y1" $imagename $imagename
}

proc annotate_image_pos_color { imagename x y color text } {
    # To annotate an image with blue text using font 12x24 at position (100,100), use:
    #    gm convert -font helvetica -fill blue -draw "text 100,100 Cockatoo" bird.jpg bird.miff
    # from: http://www.graphicsmagick.org/convert.html
    # Do not specify font for now. For compatibility between systems, assume there is a gm default.
    # exec gm convert -font "courier new" -fill $color -draw "text $x,$y $text" $imagename $imagename
    exec gm convert -fill $color -draw "text $x,$y '$text'" $imagename $imagename
}

proc filter_factor { filter_list data_list } {
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
#            puts "filter_factor: factor_sum $factor_sum i_start $i_start this_filter_list '$this_filter_list'"
            if { $i_start < 0 || [lindex $sample_list end] ne $y } {
                puts "filter_factor error i_start: $i_start for: a $a b $b filter_list $filter_list sample_list $sample_list "
            }
            set c 0
            set sum 0
            foreach factor $sample_list {
                set term [expr { $factor * [lindex $this_filter_list $c] } ]
#                puts "filter_factor: sum $sum term $term factor $factor c $c"
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
    foreach {year gt error_amt} $data_set_list {
        # data integrity check (minimal, because file is in a standard, tab delimited format).
        if { $year ne "" && $gt ne "" && $error_amt ne "" } {
            set year_ck [expr { ( 1. + $year ) / ( $year + 1. ) } ]
            set gt_ck [expr { ( 1. + $gt ) / ( $gt + 1. ) } ]
            # error_amt is a positive real number > 0
            set error_amt_ck [expr { round( $error_amt /  abs( $error_amt ) ) == 1 } ]
            if { $year < 1978 || $year > 2013 } {
                set year_ck 0
            }
            if { $year_ck && $gt_ck && $error_amt_ck } {
                set line_v2 [list $year $gt $error_amt]
                lappend table_list $line_v2
                incr line_count
            } else {
                puts "This data point did not pass integrity check. Ignored:"
                puts "year $year, gt $gt, error $error_amt"
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
    # gt      = offset of temperature in Celsius from reference temperature.
    # error_amt     = measurement error.
    set cpcount 0
    foreach row_list $table_list {
        incr cpcount 
        set year_dec_input [lindex $row_list 0]
        set gt [lindex $row_list 1]
        set error_amt [lindex $row_list 2]
        # Calculations
        # Re-calculate year_decimal
        set year [expr { int( $year_dec_input ) } ]
        set numerator_over_24 [expr { round( ( $year_dec_input - $year ) * 24. ) } ]
        set month [expr  { round( ( $numerator_over_24 + 1. ) / 2. ) } ]
        # Following is consistent with earthquake year_decimal calculation:
        set year_decimal [expr { $year + ($month - 1. ) / 12. + 1./24. } ]
#        puts "year_dec $year_dec_input, gt $gt, error_amt $error_amt, year $year, numerator/24 $numerator_over_24, month $month, year_decimal $year_decimal"
        set ct_year_dec_arr($cfcount,$cpcount) $year_decimal
        set ct_gt_arr($cfcount,$cpcount) $gt
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
# ct_gt_arr(cfc,cpc) temperature realative to an arbitrary fixed value
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
        set eq_file [lindex $eq_fi_list $efc-1]
        set ct_file [lindex $t_fi_list $cfc-1]
        puts "Current earthquake data set from: $eq_file"
        puts "Current climate data set from: $ct_file"

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
        set ct_gt $ct_gt_arr($cfc,1)
        set eq_energy_max $eq_energy
        set eq_energy_min $eq_energy
        set eq_energy_tot $eq_energy
        set ct_gt_max $ct_gt
        set ct_gt_min $ct_gt
        set ct_gt_tot $ct_gt
        set eq_energy_yyyy_mm_diff_max 0
        set eq_energy_yyyy_mm_diff_min 0
        set ct_gt_diff_max 0
        set ct_gt_diff_min 0


        for {set cpc3 2} {$cpc3 <= $cpcount} {incr cpc3} {

            set eq_energy_prev $eq_energy
            set ct_gt_prev $ct_gt
            set eq_energy $eq_energy_yyyy_mm_arr($cfc,$cpc3)
            # Auditing energy
            # puts "cpc3 $cpc3 energy $eq_energy"
            set ct_gt $ct_gt_arr($cfc,$cpc3)
            set eq_energy_yyyy_mm_diff  [expr { $eq_energy - $eq_energy_prev } ]
            set ct_gt_diff [expr { $ct_gt - $ct_gt_prev } ]

            # Build an array of difference from last interval's eq energy
            set eq_energy_yyyy_mm_diff_arr($cfc,$cpc3) $eq_energy_yyyy_mm_diff
            # Build an array of difference from last interval's delta t
            set ct_gt_diff_arr($cfc,$cpc3) $ct_gt_diff
            # Adjust maximum or minimum values?
            if { $eq_energy > $eq_energy_max } {
                # new eq_energy_max
                set eq_energy_max $eq_energy
            } elseif { $eq_energy < $eq_energy_min } {
                # new eq_energy_min
                set eq_energy_min $eq_energy
            }
            if { $ct_gt > $ct_gt_max } {
                # new ct_gt_max
                set ct_gt_max $ct_gt
            } elseif { $ct_gt < $ct_gt_min } {
                # new ct_gt_min
                set ct_gt_min $ct_gt
            }

            # Adjust maximum or minimum diff values?
            if { $eq_energy_yyyy_mm_diff > $eq_energy_yyyy_mm_diff_max } {
                # new eq_energy_diff_max
                set eq_energy_yyyy_mm_diff_max $eq_energy_yyyy_mm_diff
            } elseif { $eq_energy_yyyy_mm_diff < $eq_energy_yyyy_mm_diff_min } {
                # new eq_energy_diff_min
                set eq_energy_yyyy_mm_diff_min $eq_energy_yyyy_mm_diff
            }
            if { $ct_gt_diff > $ct_gt_diff_max } {
                # new ct_gt_diff_max
                set ct_gt_diff_max $ct_gt_diff
            } elseif { $ct_gt_diff < $ct_gt_diff_min } {
                # new ct_gt_diff_min
                set ct_gt_diff_min $ct_gt_diff
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

        puts "Min temperature (C): $ct_gt_min"
        puts "Max temperature (C): $ct_gt_max"
        set y_ct_range [expr { $ct_gt_max - $ct_gt_min } ]
        puts "Temperature range: $y_ct_range"
        set y_ct_diff_range [expr { $ct_gt_diff_max - $ct_gt_diff_min } ]


        # Find minima and maxima of climate data
        set ct_gt_list [list ]
        set eq_energy_yyyy_mm_list [list ]
        for {set cpc 1} {$cpc <= $cpcount} {incr cpc} {
            lappend ct_gt_list $ct_gt_arr($cfc,$cpc)
            # puts "cpc $cpc ct_detla_t_arr($cpc) $ct_gt_arr($cfc,$cpc)"
            # make a similar 1:1 list of earthquake data.. might come in handy in later analysis
            lappend eq_energy_yyyy_mm_list $eq_energy_yyyy_mm_arr($cfc,$cpc)
        }
        
        # Split data into climate temperature moving down and up curves

        # dcounter = slope or delta t change counter
        set dcounter 1
        set cpc 1
        set ct_gt_dy_arr($dcounter) 0.
        set eq_energy_yyyy_mm_dy_arr($dcounter) 0.
        set ct_months_dy_arr($dcounter) 0

        set gt_month_prev [lindex $ct_gt_list 0]
        set delta_t_prev 0
        foreach gt_month [lrange $ct_gt_list 1 end] {
            set delta_t [expr { $gt_month - $gt_month_prev } ]
            set delta_factor [expr {  $delta_t * $delta_t_prev } ]
            if { $delta_factor < 0. } {
               # puts "ct dy     eq dy             ct counter"
               # puts "$ct_gt_dy_arr($dcounter)   $eq_energy_yyyy_mm_dy_arr($dcounter) $ct_months_dy_arr($dcounter) delta factor: $delta_factor "
                incr dcounter
                set ct_gt_dy_arr($dcounter) 0.
                set eq_energy_yyyy_mm_dy_arr($dcounter) 0.
                set ct_months_dy_arr($dcounter) 0

            }
            set ct_gt_dy_arr($dcounter) [expr { $ct_gt_dy_arr($dcounter) + $ct_gt_arr($cfc,$cpc) } ]
            set eq_energy_yyyy_mm_dy_arr($dcounter) [expr { $eq_energy_yyyy_mm_dy_arr($dcounter) + $eq_energy_yyyy_mm_arr($cfc,$cpc) } ]
            set ct_months_dy_arr($dcounter) [expr { $ct_months_dy_arr($dcounter) + 1 } ]
            # puts "factor $delta_factor adding ct $ct_gt_arr($cfc,$cpc) eq $eq_energy_yyyy_mm_arr($cfc,$cpc)"
            incr cpc
            set delta_t_prev $delta_t
            set gt_month_prev $gt_month
        }
        if { $ct_gt_dy_arr($dcounter) == 0. } {
            # last min/max point was at end of data and contains no accumulations
            incr dcounter -1
        }

        # Calculate earthquake energy on delta_t down and up trends
        # and average earthquake energy per delta_t
        # Earthquake energy per month during decreasing delta t period
        set eq_neg_sum_per_mm 0.
        # Earthquake energy per month during increasing delta t period
        set eq_pos_sum_per_mm 0.
        # Earthquake energy per degree change in temperature during decreasing delta t period
        set eq_neg_sum_per_ct 0.
        # Earthquake energy per degree change in temperature during increasing delta t period
        set eq_pos_sum_per_ct 0.
        # Sum of months with positive (increasing) change in temperature (delta t)
        set eq_pos_mm_count 0
        # Sum of months with negative (decreasing) change in temperature (delta t)
        set eq_neg_mm_count 0
        for {set dc 1} {$dc <= $dcounter} {incr dc} {
            set eq_per_ct_arr($dc) [expr { $eq_energy_yyyy_mm_dy_arr($dc) / ( $ct_gt_dy_arr($dc) * 1. ) } ]
            set eq_per_mm_arr($dc) [expr { $eq_energy_yyyy_mm_dy_arr($dc) / ( $ct_months_dy_arr($dc) * 1. ) } ]
            if { $eq_per_ct_arr($dc) > 0. } {
                set eq_pos_sum_per_mm [expr { $eq_pos_sum_per_mm + $eq_per_mm_arr($dc) } ]
                set eq_pos_sum_per_ct [expr { $eq_pos_sum_per_ct + $eq_per_ct_arr($dc) } ]
                set eq_pos_mm_count [expr { $eq_pos_mm_count + $ct_months_dy_arr($dc) } ]
            } else {
                set eq_neg_sum_per_mm [expr { $eq_neg_sum_per_mm + $eq_per_mm_arr($dc) } ]
                set eq_neg_sum_per_ct [expr { $eq_neg_sum_per_ct + $eq_per_ct_arr($dc) } ]
                set eq_neg_mm_count [expr { $eq_neg_mm_count + $ct_months_dy_arr($dc) } ]
            }
            # puts "dc   months_count  eq_energy/delta_t  eq_energy/month"
            # puts "$dc  $ct_months_dy_arr($dc)  $eq_per_ct_arr($dc)  $eq_per_mm_arr($dc)"
        }
        puts "eq_pos_sum_per_mm $eq_pos_sum_per_mm  eq_neg_sum_per_mm $eq_neg_sum_per_mm "
        puts "eq_pos_sum_per_ct $eq_pos_sum_per_ct  eq_neg_sum_per_ct $eq_neg_sum_per_ct "
        puts "eq_pos_mm_count $eq_pos_mm_count  eq_neg_mm_count $eq_neg_mm_count"
        puts "overall averages:"
        puts "eq_pos_per_mo avg [expr { $eq_pos_sum_per_mm / ( $eq_pos_mm_count * 1. ) } ] "
        puts "eq_pos_per_t c avg [expr { $eq_pos_sum_per_ct / ( $eq_pos_mm_count * 1. ) } ] "
        puts "eq_neg_per_mo avg [expr { $eq_neg_sum_per_mm / ( $eq_neg_mm_count * 1. ) } ] "
        puts "eq_neg_per_t c avg [expr { $eq_neg_sum_per_ct / ( $eq_neg_mm_count * 1. ) } ] "


        # ..............................................................
        # Graph results.
        set timestamp [clock format [clock seconds] -format "%Y%m%dT%H%M%S"]
        set chart_name "/home/head/eq-$efc-ct-$cfc-chart-$timestamp.png"

        # Determine dimensions, origins and scales
        # Create canvas image
        #set width_px [expr { 72 * 8 } ]
        set width_px [expr { $cpcount * 2.9 } ]
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
            set x_px_width [expr { int( $width_px / $cpcount ) } ]
            set x_padding [expr { int( ( $width_px - $x_px_width * $cpcount ) / 2 ) } ]
        set x_plot_start_arr($c_i) $x_padding
            set x_plot_end_arr($c_i) [expr { $x_px_width * $cpcount + $x_padding } ]
            set x_plot_range_arr($c_i) [expr { $x_plot_end_arr($c_i) - $x_plot_start_arr($c_i) } ]
            # y image references
            set y_plot_range_arr($c_i) [expr { ( $height_px ) / ( $chart_count + 1. ) } ]
            set y_padding [expr { $y_plot_range_arr($c_i) / ( $chart_count + 1. ) } ]
            set y_plot_low_limit_arr($c_i) [expr {  ( $c_i - 1 ) * ( $y_plot_range_arr($c_i) + $y_padding ) + $y_padding } ]
            set y_plot_high_limit_arr($c_i)  [expr { $y_plot_low_limit_arr($c_i) + $y_plot_range_arr($c_i) - 1 } ]
            # boundary of this graph: x_plot_start_arr,x_plot_end_arr, y_plot_low_limit_arr, y_plot_high_limit_arr
        }

        # ..............................................................
        # Chart 1
        # Showing accumulated earthquake energy and global temperature per month
        puts "Chart 1"

        puts "Started at [clock format [clock seconds]]"
        set c_i 1
        # set plot constants x_plot_start x_plot_end x_plot_range y_plot_range y_plot_low y_plot_high
        set x_plot_start $x_plot_start_arr($c_i)
        set x_plot_end $x_plot_end_arr($c_i)
        set x_plot_range $x_plot_range_arr($c_i)
        set y_plot_range $y_plot_range_arr($c_i)
        set y_plot_low_limit $y_plot_low_limit_arr($c_i)
        set y_plot_high_limit $y_plot_high_limit_arr($c_i)

        # statistics of data for plot transformations
        set x_ct_start $ct_year_dec_arr($cfc,1)
        set x_ct_end $ct_year_dec_arr($cfc,$cpcount)
        set x_ct_range [expr { $x_ct_end - $x_ct_start } ]
        set x_eq_start $eq_year_dec_arr($cfc,1)
        set x_eq_end $eq_year_dec_arr($cfc,$cpcount)
        set x_eq_range [expr { $x_eq_end - $x_eq_start } ]

        # puts "x_ct_plot y_eq_low_err_plot y_eq_high_err_plot y_ct_low_err_plot y_ct_high_err_plot y_ct_plot y_eq_plot"
        set t0 $ct_year_dec_arr($cfc,1)
        annotate_image_pos_color $chart_name $x_plot_start $y_plot_low_limit "#0000ff" "Global Temperature(GT) per Month"
        annotate_image_pos_color $chart_name $x_plot_start [expr { $y_plot_low_limit + 15 } ] "#99ccff" "Global Temperature Error(GTE) Range"
        annotate_image_pos_color $chart_name $x_plot_start [expr { $y_plot_low_limit + 30 } ] "#ff0000" "Earthquake Energy in $energy_units"
        annotate_image_pos_color $chart_name $x_plot_start [expr { $y_plot_low_limit + 45 } ] "#ffcc99" "Earthquake Energy Error(EEE) Range"

        for {set cpc 1} {$cpc <= $cpcount} {incr cpc} {            
            # x_plot is a function of ct_year_dec_arr which is a function of i
            set x $ct_year_dec_arr($cfc,$cpc)
            set y $ct_gt_arr($cfc,$cpc)
            set ct_err_diff $ct_error_arr($cfc,$cpc)
            set y_low [expr { $y - $ct_err_diff } ]
            set y_high [expr { $y + $ct_err_diff } ]
            set y_eq $eq_energy_yyyy_mm_arr($cfc,$cpc)
            set eq_err_diff $eq_energy_yyyy_mm_err_arr($efc,$cpc)
            set y_eq_low [expr { $y_eq - $eq_err_diff } ]
            set y_eq_high [expr { $y_eq + $eq_err_diff } ]

            set x_ct_plot [expr { round( $x_plot_range * ( $x - $t0 ) / $x_ct_range + $x_plot_start ) } ]
            set y_ct_plot [expr { round( $y_plot_high_limit - $y_plot_range * ( $y - $ct_gt_min ) / $y_ct_range ) } ] 
            set y_ct_low_err_plot [expr { round( $y_plot_high_limit - $y_plot_range * ( $y_low  - $ct_gt_min ) / $y_ct_range ) } ]
            set y_ct_high_err_plot [expr { round( $y_plot_high_limit - $y_plot_range * ( $y_high  - $ct_gt_min ) / $y_ct_range ) } ] 

            # x_eq_plot is same as x_ct_plot
            set x_eq_plot $x_ct_plot
            set y_eq_plot [expr { round( $y_plot_high_limit - $y_plot_range * ( $y_eq - $eq_energy_min ) / $y_eq_range ) } ] 
            set y_eq_low_err_plot [expr { round( $y_plot_high_limit - $y_plot_range * ( $y_eq_low  - $eq_energy_min ) / $y_eq_range ) } ]
            set y_eq_high_err_plot [expr { round(  $y_plot_high_limit - $y_plot_range * ( $y_eq_high  - $eq_energy_min ) / $y_eq_range ) } ] 

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
        #  set ct_gt_diff_arr($cfc,$cpc3) [expr { $ct_gt - $ct_gt_prev } ]
        puts "Chart 2"
        puts "Started at [clock format [clock seconds]]"
        set c_i 2
        # set constants x_plot_start x_plot_end x_plot_range y_plot_range y_plot_low_limit y_plot_high
        set x_plot_start $x_plot_start_arr($c_i)
        set x_plot_end $x_plot_end_arr($c_i)
        set x_plot_range $x_plot_range_arr($c_i)
        set y_plot_range $y_plot_range_arr($c_i)
        set y_plot_low_limit $y_plot_low_limit_arr($c_i)
        set y_plot_high_limit $y_plot_high_limit_arr($c_i)
        # statistics of data for plot transformations
        set x_ct_start $ct_year_dec_arr($cfc,2)
        set x_ct_end $ct_year_dec_arr($cfc,$cpcount)
        set x_ct_range [expr { $x_ct_end - $x_ct_start } ]
        set x_eq_diff_start $eq_year_dec_arr($cfc,2)
        set x_eq_diff_end $eq_year_dec_arr($cfc,$cpcount)
        set x_eq_diff_range [expr { $x_eq_end - $x_eq_start } ]

        set y_ct_zero_plot [expr { round(  $y_plot_high_limit - $y_plot_range * ( 0. - $ct_gt_diff_min ) / $y_ct_diff_range ) } ]
        set y_eq_zero_plot [expr { round(  $y_plot_high_limit - $y_plot_range * ( 0. - $eq_energy_yyyy_mm_diff_min ) / $y_eq_diff_range ) } ]
        set y_ct_eq_plot_diff [expr { $y_eq_zero_plot - $y_ct_zero_plot } ]
        # following is basically the same as setting y_eq_zero_plot to y_ct_zero_plot
        set y_eq_zero_plot [expr { $y_eq_zero_plot - $y_ct_eq_plot_diff } ]
        set t0 $ct_year_dec_arr($cfc,1)

        annotate_image_pos_color $chart_name $x_plot_start $y_plot_low_limit "#0000ff" "Relative Global Temperature(GT) Change per Month (Up is increasing.)"
        annotate_image_pos_color $chart_name $x_plot_start [expr { $y_plot_low_limit + 15 } ] "#ff0000" "Relative Earthquake Energy per Month oriented with temperature change."



        # Start at cpc=2 instead of 1, because a difference is between 2 values..
        for {set cpc 2} {$cpc <= $cpcount} {incr cpc} {            
            # plot x_ct_plot
            set t $ct_year_dec_arr($cfc,$cpc)
            set x_ct_plot [expr { round( $x_plot_range * ( $t - $t0 ) / $x_ct_range + $x_plot_start ) } ]

            # plot y_ct_diff_plot
            set ct_gt_diff $ct_gt_diff_arr($cfc,$cpc)
            set y_ct_diff_plot [expr { round(  $y_plot_high_limit - $y_plot_range * ( $ct_gt_diff - $ct_gt_diff_min ) / $y_ct_diff_range ) } ]
            if { $ct_gt_diff > 0 } {
                set ct_gt_diff_sign 1.
            } else {
                set ct_gt_diff_sign -1.
            }
            # plot y_eq_diff_plot
            set y_eq_diff_plot [expr { round(  $y_plot_high_limit - $y_plot_range * ( $ct_gt_diff_sign * $eq_energy_yyyy_mm_arr($cfc,$cpc) - $eq_energy_yyyy_mm_diff_min ) / $y_eq_diff_range ) - $y_ct_eq_plot_diff } ]
            # puts "$x_ct_plot $y_ct_diff_plot $y_eq_diff_plot"
            # add a constant to the eq plot to set zero the same for ct and eq

            draw_image_path_color $chart_name [list $x_ct_plot $y_ct_diff_plot $x_ct_plot $y_ct_zero_plot] "#0000ff"
            draw_image_path_color $chart_name [list $x_ct_plot $y_eq_diff_plot $x_ct_plot $y_eq_zero_plot] "#ff0000"
        }

        # ..............................................................
        # Chart 3. 
        # Showing average earthquake energy per day for periods of global temperature rises and fall
        # Make a light colored square denoting a block of time and change in temperature or earthquake energy quantity.
        # Blue = delta t downward
        # Green = delta t upward
        # Red = earthquake energy for same block of time.
        puts "Chart 3"
        puts "Started at [clock format [clock seconds]]."
        set c_i 3       
        # set constants x_plot_start x_plot_end x_plot_range y_plot_range y_plot_low_limit y_plot_high
        set x_plot_start $x_plot_start_arr($c_i)
        set x_plot_end $x_plot_end_arr($c_i)
        set x_plot_range $x_plot_range_arr($c_i)
        set y_plot_range $y_plot_range_arr($c_i)
        set y_plot_low_limit $y_plot_low_limit_arr($c_i)
        set y_plot_high_limit $y_plot_high_limit_arr($c_i)


        set x_ct_start $ct_year_dec_arr($cfc,1)
        set x_ct_end $ct_year_dec_arr($cfc,$cpcount)
        set x_ct_range [expr { $x_ct_end - $x_ct_start } ]
        set x_eq_start $eq_year_dec_arr($cfc,1)
        set x_eq_end $eq_year_dec_arr($cfc,$cpcount)
        set x_eq_range [expr { $x_eq_end - $x_eq_start } ]

        # loop through 1 to cpcount 
        set dcounter 1
        set ct_gt  $ct_gt_arr($cfc,1)
        set ct_gt_prev $ct_gt
        set delta_t [expr { $ct_gt - $ct_gt_prev }]
        set delta_t_prev $delta_t
        set cpc_prev 1
        set cpc 2
        set t0 $ct_year_dec_arr($cfc,1)
        set x0 $t0
        set y0 $ct_gt
        set y0_eq_plot $y_plot_high_limit

        annotate_image_pos_color $chart_name $x_plot_start $y_plot_low_limit "#0000ff" "Global Temperature(GT) trending downward"
        annotate_image_pos_color $chart_name $x_plot_start [expr { $y_plot_low_limit + 15 } ] "#ff0000" "Global Temperature(GT) trending upward"
        annotate_image_pos_color $chart_name $x_plot_start [expr { $y_plot_low_limit + 30 } ] "#99ff66" "Relative Earthquake Energy during downtrend"
        annotate_image_pos_color $chart_name $x_plot_start [expr { $y_plot_low_limit + 45 } ] "#ff9966" "Relative Earthquake Energy during uptrend"


        for {set cpc 2} {$cpc <= $cpcount} {incr cpc} { 
            set x $ct_year_dec_arr($cfc,$cpc)

            set ct_gt $ct_gt_arr($cfc,$cpc)
            set delta_t [expr { $ct_gt - $ct_gt_prev }]
            set delta_factor [expr { $delta_t * $delta_t_prev } ]
            if { $delta_factor < 0. } {
                # change in direction of delta t
                
                # Mark start of ct box
                set x0_ct_plot [expr { round( $x_plot_range * ( $x0 - $t0 ) / $x_ct_range + $x_plot_start ) } ]
                set y0_ct_plot [expr { round( $y_plot_high_limit - $y_plot_range * ( $y0 - $ct_gt_min ) / $y_ct_range ) } ] 
                # Mark end of ct box
                set x1 $x_prev
                set y1 $ct_gt_prev
                set x1_ct_plot [expr { round( $x_plot_range * ( $x1 - $t0 ) / $x_ct_range + $x_plot_start ) } ]
                set y1_ct_plot [expr { round( $y_plot_high_limit - $y_plot_range * ( $y1 - $ct_gt_min ) / $y_ct_range ) } ]

                # grab earthquake data for same period
                # eq_per_ct = earthquake energy per unit temperature change
                #set eq_per_ct $eq_per_ct_arr($dcounter)
                # eq_per_mm = earthquake energy per month average during period
                set eq_per_mm $eq_per_mm_arr($dcounter)
                set y_eq_plot [expr { round( $y_plot_high_limit - $y_plot_range * ( $eq_per_mm ) / $y_eq_range ) } ]

                # graph rectangle
                if { $delta_t_prev < 0 } {

                    draw_image_rect_color $chart_name $x0_ct_plot $y0_ct_plot $x1_ct_plot $y1_ct_plot "#0000ff"
                    #puts "ct x0,y0 $x0_ct_plot,$y0_ct_plot x1,y1 $x1_ct_plot,$y1_ct_plot -"

                    # x range is same as ct rectangle
                    draw_image_rect_color $chart_name $x0_ct_plot $y_eq_plot $x1_ct_plot $y0_eq_plot "#99ff66"

                } else {
                    draw_image_rect_color $chart_name $x0_ct_plot $y0_ct_plot $x1_ct_plot $y1_ct_plot "#ff0000"
                    #puts "ct x0,y0 $x0_ct_plot,$y0_ct_plot x1,y1 $x1_ct_plot,$y1_ct_plot +"

                    # x range is same as ct rectangle
                    draw_image_rect_color $chart_name $x0_ct_plot $y_eq_plot $x1_ct_plot $y0_eq_plot "#ff9966"


                }
                #puts "eq x0,y0 $x0_ct_plot,$y_eq_plot x1,y1 $x1_ct_plot,$y0_eq_plot "
                # cpc-1 should equal # of months in eq_pos_mm_count or eq_neg_mm_count (depending on sign ie direction of ct)

                # graph average earthquake energy over $x0 $x1:
                # eq_per_ct_arr($dc) \[expr { $eq_energy_yyyy_mm_dy_arr($dc) / ( $ct_gt_dy_arr($dc) * 1. ) } \]
                # eq_per_mm_arr($dc) \[expr { $eq_energy_yyyy_mm_dy_arr($dc) / ( $ct_months_dy_arr($dc) * 1. ) } \]

                incr dcounter                
                # new x0,y0
                set x0 $x
                set y0 $ct_gt_prev
            }

            set delta_t_prev $delta_t
            set ct_gt_prev $ct_gt
            set cpc_prev $cpc
            set x_prev $x
        }
        # complete last rectangle
        set x1 $x_prev
        set y1 $ct_gt
        set x1_ct_plot [expr { round( $x_plot_range * ( $x1 - $t0 ) / $x_ct_range + $x_plot_start ) } ]
        set y1_ct_plot [expr { round( $y_plot_high_limit - $y_plot_range * ( $y1 - $ct_gt_min ) / $y_ct_range ) } ]


            
        # Later graphs consider checking:
        # The curve of each of the change in temperature cases to see if there are any noticeable patterns.
        # For a common eq energy rate at various fixed temperatures based on up or down trending ct.

        puts "Ended at [clock format [clock seconds]]."
        # Begin next permutation of climate and earthquake data..
    }
}



# Check for patterns:
#1.   change in global temperature vs change in earthquake energy
#2.   earthquake energy per month vs. global temperature change
#3.   global temperature trend upward or downward vs. average earthquake energy per trend period
#5.   try sorting by maximum earthquake energy in each month, to see if it reveals a seasonal or temperature pattern


