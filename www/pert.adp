<master>
    <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h1>@title@</h1>
<if @menu_html@ not nil>
@menu_html;noquote@
</if>

<if @user_message_html@ not nil>
<ul>
@user_message_html;noquote@
</ul>
</if>


<if @form_html@ not nil>
@form_html;noquote@
</if>

<if @scenario_html@ not nil>
<div style="width: 60%; float: right;">
<table border="0" cellspacing="0" cellpadding="5">
<tr>
<td valign="top"><tt>*_dist_curve_eq</tt></td>
<td valign="top">0 = ignore. 1 = Logistic curve, 2 = Positive Sign curve. 
These equations are set to take intervals anywhere between 0 to 12 inclusive. Fractional decimals are fine. 
For the Logistic curve, the target_value is reached at about 12. 
For the Positive Sign curve, target_value is reached at interval 6 and decreases to 0% at 12 --useful to test extreme negative growth scenarios.
 </td>
</tr><tr>
<td valign="top"><tt>interpolate_last_band_p</tt></td>
<td valign="top">Set this to 1 to have the largest tier in the curve iterpolated. (default = 0)
This is useful for modeling infrequent, large volumes with varying, significant quantities. </td>
</tr><tr>
<td valign="top"><tt>interval_count</tt></td>
<td valign="top">Number of intervals iterated.</td>
</tr><tr>
<td valign="top"><tt>interval_size</tt></td>
<td valign="top">added to period_start for each interval </td>
</tr><tr>
<td valign="top"><tt>interval_start</tt></td>
<td valign="top">The value for the first period's interval  </td>
</tr><tr>
<td valign="top"><tt>period_unit</tt></td>
<td valign="top">The unit that represents each period.</td>
</tr><tr>
<td valign="top"><tt>dist_curve_name</tt></td>
<td valign="top">Name of distribution curve to use. Name must be unique.</td>
</tr><tr>
<td valign="top"><tt>dist_curve_tid</tt></td>
<td valign="top">Table ID of dist_curve to use.</td>
</tr><tr>
<td valign="top"><tt>sample_rate</tt></td>
<td valign="top">Percentage of rows per period to be sampled. (The percent is represented as decimal: 100% = 1).  </td>
</tr></table>
</div>
@scenario_html;noquote@
</if>

<if @activities_table_html@ not nil>
@activities_table_html;noquote@
</if>

<if @time_dist_curve_html@ not nil>
@dist_curve_html;noquote@
</if>
<if @cost_dist_curve_html@ not nil>
@dist_curve_html;noquote@
</if>

<if @compute_message_html@ not nil>
<ul>
@compute_message_html;noquote@
</ul>
</if>

<if @computation_report_html@ not nil>
@computation_report_html;noquote@
</if>

<if @table_stats_html@ not nil>
@table_stats_html;noquote@
</if>
