set title "PRETTI #accounts-finance.scenario_p1#"

set type "p1"

set context [list [list index "Documentation"] $title]

set raw_html "<pre>"
set p1_list [acc_fin::example_table p10a]
foreach row $p1_list {
    append raw_html [join $row "," ]
    append raw_html "\n"
}
append raw_html "</pre>"

set table_attribute_list [list border 1 cellspacing 0 cellpadding 3]

set raw2_html [qss_list_of_lists_to_html_table $p1_list $table_attribute_list]





set all_list [acc_fin::pretti_columns_list $type]
set req_list [acc_fin::pretti_columns_list $type 1]
set var ${type}_html
set var2 ${type}b_html
set table_lists [list ]
lappend table_lists [list "#accounts-finance.columns#" "#accounts-finance.title#" "#accounts-finance.description#"]
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


