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

set p1b_html {<pre>name: PRETTI example scenario 1
 tid: 10412
</pre>

<table border="1" cellpadding="3" cellspacing="0">
<tr><td>name</td><td>value</td></tr>
<tr><td>activity_table_name</td><td>PRETTI Example 1</td></tr>
<tr><td>activity_table_tid</td><td>10352</td></tr>
<tr><td>time_est_short</td><td>5</td></tr>
<tr><td>time_est_median</td><td>8</td></tr>
<tr><td>time_est_long</td><td>12</td></tr>
<tr><td>time_probability_moment</td><td>0.5</td></tr>
<tr><td>db_format</td><td>expand</td></tr>
<tr><td>pert_omp</td><td>strict</td></tr>
<tr><td>precision</td><td>0.001</td></tr>
<tr><td>tprecision</td><td>0.01</td></tr>
</table>
}

set p4_html {<h3>PRETTI Example 1.p4</h3>

<pre>name: PRETTI Example 1.p4
 tid: 10415
</pre>

<h3>Computation report</h3><table>
<tr><td>path_1</td><td>path_2</td><td>path_3</td></tr>
<tr><td style="vertical-align: top; background-color: #efef0f;">A <br>  t:4.0 <br> tw:4.0 <br> tn:4.0 <br> fw:0.0 <br> &nbsp;c:1.0 <br> cw:1.0 <br> cn:1.0 <br> d:() <br> <!-- 0 2 --> </td><td style="vertical-align: top; background-color: #0fef0f;">B <br>  t:5.33 <br> tw:5.33 <br> tn:5.33 <br> fw:0.0 <br> &nbsp;c:1.0 <br> cw:1.0 <br> cn:1.0 <br> d:() <br> <!-- 0 1 --> </td><td style="vertical-align: top; background-color: #efef0f;">A <br>  t:4.0 <br> tw:4.0 <br> tn:4.0 <br> fw:0.0 <br> &nbsp;c:1.0 <br> cw:1.0 <br> cn:1.0 <br> d:() <br> <!-- 0 2 --> </td></tr>
<tr><td style="vertical-align: top; background-color: #ffff0f;">C <br>  t:5.17 <br> tw:9.17 <br> tn:9.17 <br> fw:0.0 <br> &nbsp;c:1.0 <br> cw:2.0 <br> cn:2.0 <br> d:(A) <br> <!-- 0 1 --> </td><td style="vertical-align: top; background-color: #ffff0f;">E <br>  t:5.17 <br> tw:10.5 <br> tn:14.33 <br> fw:3.83 <br> &nbsp;c:1.0 <br> cw:2.0 <br> cn:4.0 <br> d:(B C) <br> <!-- 0 2 --> </td><td style="vertical-align: top; background-color: #1fef1f;">D <br>  t:6.33 <br> tw:10.33 <br> tn:10.33 <br> fw:0.0 <br> &nbsp;c:1.0 <br> cw:2.0 <br> cn:2.0 <br> d:(A) <br> <!-- 0 1 --> </td></tr>
<tr><td style="vertical-align: top; background-color: #efef0f;">E <br>  t:5.17 <br> tw:14.33 <br> tn:14.33 <br> fw:0.0 <br> &nbsp;c:1.0 <br> cw:3.0 <br> cn:4.0 <br> d:(B C) <br> <!-- 0 2 --> </td><td style="vertical-align: top; background-color: #efef0f;">G <br>  t:5.17 <br> tw:15.67 <br> tn:19.5 <br> fw:3.83 <br> &nbsp;c:1.0 <br> cw:3.0 <br> cn:5.0 <br> d:(E) <br> <!-- 0 2 --> </td><td style="vertical-align: top; background-color: #0fef0f;">F <br>  t:4.5 <br> tw:14.83 <br> tn:14.83 <br> fw:0.0 <br> &nbsp;c:1.0 <br> cw:3.0 <br> cn:3.0 <br> d:(D) <br> <!-- 0 1 --> </td></tr>
<tr><td style="vertical-align: top; background-color: #ffff0f;">G <br>  t:5.17 <br> tw:19.5 <br> tn:19.5 <br> fw:0.0 <br> &nbsp;c:1.0 <br> cw:4.0 <br> cn:5.0 <br> d:(E) <br> <!-- 0 2 --> </td><td style="vertical-align: top; background-color: #999999;">&nbsp;</td><td style="vertical-align: top; background-color: #999999;">&nbsp;</td></tr>
</table>


<p>
Scenario report for PRETTI example scenario 1: scenario_name PRETTI Example 1 , cp_duration_at_pm 19.500000000000004 , cp_cost_pm 4.0 , max_act_count_per_track 4 , time_probability_moment 0.5 , cost_probability_moment 0.5 , setup_time 0 , main_processing_time 0 seconds , time/date finished processing 2014 Aug 02 21:30:17 , _tDcSource 3.1 , _cDcSource 6 , precision 0.001 , tprecision 0.01 , cprecision 0.001 , color_mask_sig_idx 3 , color_mask_oth_idx 5 , colorswap_p 0
</p>}
