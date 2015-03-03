set title "PRETTI Table Task Glossary"
set context [list [list index "Documentation"] $title]

set glossary_html ""

set g_list [list "t  : (crash) duration" \
                "tw : duration at waypoint. " \
                "waypoint :  A task along one path" \
                "node : A task and all its direct and indirect dependents" \
                "tn : (crash) duration at node" \
                "fw : float at waypoint (tn - tw)" \
                "c : cost" \
                "cw : cost at waypoint " \
                "cn : cost at node" \
                "d : dependents" \
                 "e : eco2" \
                 "ew : eco2 at waypoint " \
                 "en : eco2 at node" \
                 ]
set g_list [lsort $g_list]
append glossary_html "<ul>\n"
foreach gl $g_list {
    append glossary_html "<li>$gl</li>\n"
}
append glossary_html "</ul>\n"

set faq_html ""

