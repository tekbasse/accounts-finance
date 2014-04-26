
set type_list [list p1 p2 p3 p4 p5 dc]
set table_attribute_list [list style "border: 1px solid #999999; padding: 5px;"]
foreach type $type_list {
    set all_list [lsort [acc_fin::pretti_columns_list $type]]
    set req_list [lsort [acc_fin::pretti_columns_list $type 1]]
    set var ${type}_html
    set var2 ${type}b_html
    set table_lists [list ]
    foreach column $all_list {
        set row_list [list $column "#accounts-finance.${column}#" "#accounts-finance.${column}_def#"]
        lappend table_lists $row_list
    }
    set $var [qss_list_of_lists_to_html_table $table_lists $table_attribute_list]
    set $var2 ""
    if { $type ne "p4" && $type ne "p5" } {
        set delimiter ""
        foreach req $req_list {
            append $var2 $delimiter
            append $var2 $req
            set delimiter ", "
        }
        if { $var2 ne "" } {
            append $var2 " *"
        }
    }
}