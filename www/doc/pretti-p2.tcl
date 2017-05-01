set title "PRETTI #accounts-finance.task_network_p2#"

set type "p2"

set context [list [list index "Documentation"] $title]

set p2_text [lindex [acc_fin::example_table p20a] 2]
set raw_html "<pre>"
append raw_html $p2_text
append raw_html "</pre>"


#raw2_html

set p2_list [list ]
set p2_text_list [split $p2_text "\n"]
foreach row $p2_text_list {
    regsub -all -- " " $row ";" row2
    set row_list [split $row2 ","]
    set new_row_list [list ]
    foreach element $row_list {
        regsub -all -- ";" $element " " new_element
        lappend new_row_list $new_element
    }
    lappend p2_list $new_row_list
}




set table_attribute_list [list border 1 cellspacing 0 cellpadding 3]

set raw2_html [qss_list_of_lists_to_html_table $p2_list $table_attribute_list]





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


