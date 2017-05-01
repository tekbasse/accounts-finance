set title "Documentation"
set context [list $title]

set examples_html ""
set examples_list [list ]
set i_max 5
for {set i 1} {$i <= $i_max} {incr i} {
    set a [string range "1abcdefghijklmnopqrstuvwxyz" $i $i]
    set row_list [list "PRETTI Example ${i}" pretti-example-$i [lindex [acc_fin::example_table p20${a}] 0]]
    lappend examples_list $row_list
}
foreach e_list $examples_list {
    lassign $e_list text url description
    regsub -all -- { ([h][t][t][p][s]?[\:][\/][\/][A-Za-z0-9\:\.\-\/\_]+) } $description { <a href="\1">\1</a> } description
    append examples_html "<li>"
    append examples_html "<a href=\"${url}\">${text}</a> "
    append examples_html $description
    append examples_html "</li>"
}
