set title "PRETTI Example 1"
set context [list [list index "Documentation"] $title]

set p1_html "<pre>"
set p1_list [acc_fin::example_table p10a]
foreach row $p1_list {
    append p1_html [join $row "," ]
    append p1_html "\n"
}
append p1_html "</pre>"

set p2_html "<pre>"
append p2_html [lindex [acc_fin::example_table p20a] 2]
append p2_html "</pre>"

set p3_html "<p>* not used<p>"
