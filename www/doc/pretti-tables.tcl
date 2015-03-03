set title "PRETTI Table definitions"
set context [list [list index "Documentation"] $title]

set type_list [list p1 p2 p3 p4 p5 p6 dc]
set table_attribute_list [list style "border: 1px;"]
foreach type $type_list {
    set all_list [acc_fin::pretti_columns_list $type]
    set req_list [acc_fin::pretti_columns_list $type 1]
    set var ${type}_html
    set var2 ${type}b_html
    set table_lists [list ]
    foreach column $all_list {
        set row_list [list $column "#accounts-finance.${column}#" "#accounts-finance.${column}_def#"]
        lappend table_lists $row_list
    }
    set $var [qss_list_of_lists_to_html_table $table_lists $table_attribute_list]
    set $var2 ""
    if { $type ne "p4" && $type ne "p5" && $type ne "p6" } {
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

set eq_vars_lists [acc_fin::pretti_equation_vars]
set eq_vars2_lists [list [list "Custom Equation Variable" "PRETTI Variable" "Description"]]
foreach vars_list $eq_vars_lists {
    set var0 [lindex $vars_list 0]
    set var1 [lindex $vars_list 1]
    set var2 [lindex $vars_list 2]
    set row_lists [list "\$${var0}" $var1 $var2]
    lappend eq_vars2_lists $row_lists
}
set eq_vars_html [qss_list_of_lists_to_html_table $eq_vars2_lists $table_attribute_list]
