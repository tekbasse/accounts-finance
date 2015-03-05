set title "PRETTI Workflow"
set context [list [list index "Documentation"] $title]

set p1_required_fields_list [acc_fin::pretti_columns_list p1 1]

set p1_required_fields_html [join $p1_required_fields_list ", "]

set p2_required_fields_list [acc_fin::pretti_columns_list p2 1]

set p2_required_fields_html [join $p2_required_fields_list ", "]

set p3_required_fields_list [acc_fin::pretti_columns_list p3 1]

set p3_required_fields_html [join $p3_required_fields_list ", "]

set example_url [ad_conn package_url]

