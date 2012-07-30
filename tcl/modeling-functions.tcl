ad_library {

    standard finance functions 
    @creation-date 16 May 2010
    @cvs-id $Id:
}

namespace eval acc_fin {}


ad_proc -public qaf_ifnif {
    list_of_args
}  {

    This proc is modelled after the decode in sql. Takes the place of
    an if (or switch) statement -- convenient because it's compact and intuitive.
    args: same order as in sql: first the test value, then any
    number of pairs followed by a single value. This function takes a list of arguments, not a list of list pairs.
    If list_of_args is a single string, the string is split by commas.

    The first part of the pair is combined with the test value to form a logical expression.
    If the expression is true, then the second element of pair is returned. If not true,
    then an expression is built from combining the test value with the first element of the next
    pair. This pattern is continued for each pair.
    If none of the patterns are true, the last value is returned.
    Example expressions are "<5" "==3" "<=2".
    
    If the first element of a pair does not include a logical operator, then "==" is assumed, as in "==value"

} {
    set args_length [llength $list_of_args]
    if { $args_length > 1 } {
        set args_list $list_of_args
     } else {
         set args_list [split $list_of_args ","]
     }

    set test_value [lindex $args_list 0]
    
    # Skip the first & last values of args

    set counter 1
    while { $counter < [expr $args_length -2] } {
        set part_expr [lindex $args_list $counter]
        if { ![regexp -- {[=><]+} $part_expr match] } {
            set part_expr "== ${part_expr}"
        }
        set test_expr [expr [string trim "${test_value} ${part_expr}"] ]
        if { $test_expr } {
            return [lindex $args_list [expr $counter + 1]]
        }
        set counter [expr $counter + 2]
    }
    return [lindex $args_list [expr $args_length -1]]
}


ad_proc -public qaf_tcl_list_of_lists_to_html_table {
    tcl_list_of_lists
    {formatting_list ""}
    {first_are_titles "0"}
    {watch_print_row "1"}
    {separate_uniques "1"}
} {
    returns an html table where each cell is an item from a tcl list of lists, where 
    the first item of each list is the first row, the second item of each list is the second row etc etc.
    the table has the same number of rows as the maximum count of list items, and
    the same number of columns as there are lists.  Lists with too few list items are filled with empty cells.
    Converts first row to titles if first_are_titles is true (1).
    converts first 2 rows to titles if first_are_titles is set to 2, etc etc.
    If watch_print_row is 1, and the first item in one of the lists is "print_row", the column will not be printed and subsequent rows where the value of column print_row is 0 will be ignored.
    Formatting_list items are tcl format specifications applied to the values in the cooresponding tcl_list_of_list columns, one spec per column.
    If separate_uniques is 1 (default), columns that have only 1 row are presented as a separate table, oriented as a column of values
    If separate_uniques is 2, columns that have only 1 row *and* columns where all rows (but the title row) are constant, are presented as a separate table, oriented as a column of values.
} {
    set columns_count [llength $tcl_list_of_lists]
    set formatting_p [expr { [llength $formatting_list] == $columns_count } ]
    set column_to_hide -1
    set column_number 0
    set rows_count 0

    foreach column_list $tcl_list_of_lists {
        # determine table's row size by examining row size for each column
        set row_count($column_number) [llength $column_list]
        set row $first_are_titles
        set row_prev [lindex $column_list $first_are_titles]

        set is_constant 1

        while { $row < $row_count($column_number) && $is_constant } {
            set row_now [lindex $column_list $row]
            # examine the data of each column's row, if constant, maybe display as a constant.
            set is_constant [expr { $is_constant && ( $row_prev == $row_now ) } ]
            set row_prev $row_now
            incr row
        }
        # title_row_count = the number of rows dedicated to the title
        set title_row_count [expr { $first_are_titles + 1 } ]

        set true_column($column_number) [expr { ( $separate_uniques == 1 && $row_count($column_number) > $title_row_count ) || ( $separate_uniques == 0 ) || ( $separate_uniques == 2 && ( ( $row_count($column_number) > $title_row_count ) && !$is_constant ) ) } ]
#        ns_log Notice "qaf_tcl_list_of_lists_to_html_table, ref 49: true_column(${column_number}) =  $true_column(${column_number}), row_count(${column_number}) = $row_count(${column_number}), is_constant = ${is_constant}"

        set rows_count [expr { [f::max $rows_count $row_count($column_number) ] } ]
        if { $watch_print_row } {
            if { [lindex $column_list 0] eq "print_row" } {
                set column_to_hide $column_number
            }
        }
        if { $formatting_p } {
            set format_spec($column_number) [lindex $formatting_list $column_number]
        }
        incr column_number
    }
    # rows_count now contains max rows
    set table_html "<table class=\"list-table\" border=\"1\" cellspacing=\"0\" cellpadding=\"3\">\n"
    if { $first_are_titles } {
        set cell_tag "th"
    } else {
        set cell_tag "td"
    }

    for {set row_index 0} { $row_index < $rows_count } { incr row_index 1 } {
        # check to see if we should be ignoring this row
        if { $column_to_hide == -1 || ( $column_to_hide > -1 && [expr { round( [lindex [lindex $tcl_list_of_lists $column_to_hide ] $row_index] ) } ] != 0 ) } {
            # process row
            if { [expr {( $row_index / 2. ) == ( round( $row_index / 2. ) ) } ] } {
                set row_html "<tr class=\"even\">"
            } else {
                set row_html "<tr class=\"odd\">"
            }
            set format_row_p [expr { ( $first_are_titles != 0 && $row_index > 0 ) || ( $first_are_titles == 0 ) } ]
            for {set column_index 0} { $column_index < $columns_count } { incr column_index 1 } {
                if { $column_index != $column_to_hide && $true_column($column_index) } {
                    # process this column / cell
                    set cell_format ""
                    set cell_value [lindex [lindex $tcl_list_of_lists $column_index ] $row_index]
                    set cell_value_is_number [ad_var_type_check_number_p $cell_value ]
                    if { $cell_value_is_number } {
                        set cell_format " align=\"right\""
                        if { $cell_value < 0 } {
                            append cell_format " style=\"color: red;\""
                        }
                        if { [expr { abs( $cell_value ) } ] > 99 } {
                            set cell_value [format "%15.3f" $cell_value]
                        }
                    } elseif { $row_index == 0 } {
                        regsub -all -- {_} $cell_value { } cell_value
                    }
                    if { $formatting_p && $format_row_p && $cell_value_is_number } {
                        if { [catch { set cell_value [format $format_spec($column_index) $cell_value] } result_msg] } {
                            set cell_value "format error(spec,value): $format_spec(${column_index}) ${cell_value}"
                        } 
                    } 
                    set cell_html "<${cell_tag}${cell_format}>${cell_value}</${cell_tag}>"
                    append row_html $cell_html
                }
            }
            append row_html "</tr>\n"
            append table_html $row_html
        } else {
            append table_html "<tr><td colspan=\"$columns_count\">(blank row ${row_index})</td></tr>"
        }
        # next row
        set cell_tag "td"
    }

    append table_html "</table>\n"
    # now we handle the data with unique (only one value) in a column

    set table_2_html "<table border=\"1\" cellspacing=\"0\" cellpadding=\"3\">\n"
    set row_html ""
    set format_row_p [expr { ( $first_are_titles != 0 && $row_index > 0 ) || ( $first_are_titles == 0 ) } ]
    for {set column_index 0 } { $column_index < $columns_count } { incr column_index 1 } {
        if { ( $column_index != $column_to_hide ) && ( $true_column($column_index) == 0 ) } {
            # process this column / cell
            set cell_heading [lindex [lindex $tcl_list_of_lists $column_index ] 0]
            set cell_value [lindex [lindex $tcl_list_of_lists $column_index ] 1]
            if { $formatting_p && $format_row_p } {
                if { [catch { set cell_value [format $format_spec($column_index) $cell_value] } result_msg] } {
                    set cell_value "format error(spec,value): $format_spec(${column_index}) ${cell_value}"
                } 
            } 
            set cell_html "<tr><td>${cell_heading}</td><td>${cell_value}</td></tr>"
            append row_html $cell_html
        }
    }
    append table_2_html $row_html
    append table_2_html "</table>"

    append table_2_html $table_html

    return $table_2_html
} 


ad_proc -public qaf_model_output_to_qss_list {
    tcl_list_of_lists
} {
    returns a table that is in a list_of_lists format usable by qss_*  spreadsheets
} {
    set columns_count [llength $tcl_list_of_lists]
    set column_number 0
    set rows_count 0

    foreach column_list $tcl_list_of_lists {
        # determine table's row size by examining row size for each column
        set row_count($column_number) [llength $column_list]
        set row $first_are_titles
        set row_prev [lindex $column_list $first_are_titles]

        set is_constant 1

        while { $row < $row_count($column_number) && $is_constant } {
            set row_now [lindex $column_list $row]
            # examine the data of each column's row, if constant, maybe display as a constant.
            set is_constant [expr { $is_constant && ( $row_prev == $row_now ) } ]
            set row_prev $row_now
            incr row
        }
        # title_row_count = the number of rows dedicated to the title, 1 row for spreadsheets
        set title_row_count [expr { $first_are_titles + 1 } ]
        set true_column($column_number) [expr { !$is_constant } ]
        set rows_count [expr { [f::max $rows_count $row_count($column_number) ] } ]
        incr column_number
    }
    # rows_count now contains max rows
    set table_list [list ]
    if { !$first_are_titles } {
        # qss spreadsheet requires first row to be column titles
        return $table_list
    }

    for {set row_index 0} { $row_index < $rows_count } { incr row_index 1 } {
        set row_list [list ]
        # process row
        for {set column_index 0} { $column_index < $columns_count } { incr column_index 1 } {
            if { $true_column($column_index) } {
                # process this column / cell
                set cell_value [lindex [lindex $tcl_list_of_lists $column_index ] $row_index]
            } else {
                set cell_value [lindex [lindex $tcl_list_of_lists $column_index ] 1]
            }
            lappend row_list $cell_value
        }
        append table_list $row_list
    } 
    # next row
    
    return $table_list
} 


ad_proc -public acc_fin::list_set {
    list_of_values
    {delimiter " "}
} {
    Returns a list_of_values in tcl list format. This allows the model to use tcl list without complicating permissions.
} {
    if { [string length $delimiter] == 0} {
        set delimiter " "
    }
    set max_index [llength $list_of_values]
    if { $max_index > 1 } {
        set values_list $list_of_values
     } else {
         set values_list [split $list_of_values $delimiter]
     }
    return $list_of_values
} 


ad_proc -public acc_fin::list_index {
    list_of_values
    index_ref
    {default_value "0"}
} {
    Returns the value of the list at index_ref where the first value is 0. If the reference is not valid or out of range, returns the default value ( 0 by default), or the last value of the list if default is blank.
} {
    set index_ref [expr { round( $index_ref ) } ]
    set max_index [llength $list_of_values]
    if { $max_index > 1 } {
        set values_list $list_of_values
     } else {
         set values_list [split $list_of_values]
     }
     set values_list_count [llength $values_list]
    if { $index_ref > -1 && $index_ref < $values_list_count } {
        set return_value [lindex $values_list $index_ref]
    } elseif { [string length $default_value] > 0 } {
        set return_value $default_value
    } else {
        set return_value [lindex $values_list end]
    }
} 

ad_proc -public acc_fin::list_indexes {
    list_of_values
    list_of_indexes
    {default_value "0"}
} {
    Returns a list of  values of the list_of_values for each index in list_of_indexes.  The first value is at index  0. If an index reference is not valid or out of range, returns the default value ( 0 by default), or the last value of the list_of_values if default is blank.
} {

    if { [llength $list_of_values] > 1 } {
        set values_list $list_of_values
    } else {
        set values_list [split $list_of_values]
    }
    set values_list_count [llength $values_list]
    
    if { [llength $list_of_indexes] > 1 } {
        set indexes_list $list_of_indexes
    } else {
        set indexes_list [split $list_of_indexes]
    }
    set indexes_list_count [llength $indexes_list]
    
    set new_list_of_values [list]
    foreach index $list_of_indexes {
        lappend new_list_of_values [acc_fin::list_index $list_of_values $index $default_value]
    }
    return $new_list_of_values
} 

ad_proc -public acc_fin::list_sorted_indexes {
    list_of_values 
    {sort_type "-real"}
} {
    Returns a list of indexes of the list_of_values that puts the list_of_values in sorted order. This is useful for reports, where the same sort needs to be applied on multiple lists. This output, when supplied to list_indexes, returns a list of sorted values. see tcl lsort for sort_type options.
} {
    if { [llength $list_of_values] > 1 } {
        set values_list $list_of_values
    } else {
        set values_list [split $list_of_values]
    }
    set values_list_count [llength $values_list]
    set values_sorted_list [lsort $sort_type $values_list]
    set index_sorted_list [list]
    foreach value $values_sorted_list {
        set propose_index [lsearch -exact $values_list $value]
        while { [lsearch -exact $propose_index $index_sorted_list] > -1 } {
            incr propose_index
            set propose_index [lsearch -exact -start $propose_index  $values_list $value]
        }
        lappend index_sorted_list $propose_index
    }
    return $index_sorted_list
}

ad_proc -public acc_fin::list_summary_indexes {
    list_of_values
} {
    Returns a list of indexes of the list_of_values, where only the last value in a sequence of same numbers is used. This is useful for identifying  end_of_period iterations in a list where multiple iterations occur within the same period. For example, in a list of years, year "10" may be for iterations 120 through 131 when iterated monthly. For this example, the value 131 is returned for this year as the last in the index for that year. A second value for "10" is added, if "10" appears in a sequence later in the list. 
} {
    if { [llength $list_of_values] > 1 } {
        set values_list $list_of_values
    } else {
        set values_list [split $list_of_values]
    }
    set values_list_count [llength $values_list]
    set indexes_unique_list [list]
    if { $values_list_count > 1 } {
        set last_value [lindex $values_list 0]
        for {set index 1} {$index < $values_list_count } { incr index 1} {
            set last_index [expr $index - 1]
            set value [lindex $values_list $index]
            if { $value ne $last_value && $last_index > -1  } {
                lappend indexes_unique_list $last_index
            }
            set last_value $value
        }
        lappend indexes_unique_list $index
        
    } elseif { $values_list_count == 1 } {
       lappend indexes_unique_list 0
    }
    return $indexes_unique_list
}

ad_proc -public acc_fin::compress_eq {
    func
} {
    Returns an equation compressed (without spaces). No other substitutions are made.
} {
    regsub -all -- { } $func {} func2
    return $func2
}

ad_proc -public acc_fin::de_compress_eq {
    func
} {
    Returns an equation uncompressed (with spaces). Each comma is converted to a space. A semicolon is converted to a close bracket/
} {
proc qaf_decompress_eq { func } {
    regsub -all -- {;} $func {\]} func
    regsub -all -- {,} $func { } func
    regsub -all -- {([\>\<\/\*\)])} $func { \1 } func
    regsub -all -- {([\+\-])([^0-9.])} $func { \1 \2} func
    regsub -all -- {([^a-zA-Z])[\(]} $func {\1 ( } func
    regsub -all -- {[\&][\&]} $func { \&\& } func
    regsub -all -- {([a-zA-Z0-9_\.])([\)\+\-\/\=\*])} $func {\1 \2} func
    regsub -all -- {([\(\+\-\/\=\*])([a-zA-Z0-9_])} $func {\1 \2} func
    regsub -all -- {[ ]+} $func { } func
    return $func
}


