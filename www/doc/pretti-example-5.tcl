set title "PRETTI example 5"
set context [list [list index "Documentation"] $title]

set p1_html "<pre>"
set p1_list [acc_fin::example_table p10e]
foreach row $p1_list {
    append p1_html [join $row "," ]
    append p1_html "\n"
}
append p1_html "</pre>"

set p2_html "<pre>"
set p2_list [lindex [acc_fin::example_table p20e]]
append p2_html [lindex $p2_list 2]
append p2_html "</pre>"
set subtitle_html [lindex $p2_list 0]
set comments_html [lindex $p2_list 1]
regsub -all -- { ([h][t][t][p][s]?[\:][\/][\/][A-Za-z0-9\.\-\/\_]+) } $comments_html { <a href="\1">\1</a> } comments_html

set p3_html "<p>* not used<p>"

set p1b_html {<pre>name: PRETTI example 5 fedora20 scenario
 tid: 10088
</pre>

<table border="1" cellpadding="3" cellspacing="0">
<tr><td>name</td><td>value</td></tr>
<tr><td>activity_table_name</td><td>fedora20scenario</td></tr>
</table>
}

#set p4_html {  }
