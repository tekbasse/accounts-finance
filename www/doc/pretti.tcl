set title "PRETTI Table definitions"
set context [list [list index "Documentation"] $title]

set glossary_html ""

set g_list [list "t  : (crash) duration" \
                "tw : duration at waypoint. " \
                "waypoint :  A task along one path" \
                "node : A task and all its direct and indirect dependents" \
                "tn : (crash) duration at node" \
                "c : cost" \
                "cw : cost at waypoing " \
                "cn : cost at node" \
                "d : dependents" \
                "float at task : tn - tw "]
set g_list [lsort $g_list]
append glossary_html "<ul>\n"
foreach gl $g_list {
    append glossary_html "<li>$gl</li>\n"
}
append glossary_html "</ul>\n"

set faq_html ""

