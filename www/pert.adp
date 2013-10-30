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
<div style="width: 44%; float: right;">
<h3>Scenario variables</h3>
<table border="0" cellspacing="0" cellpadding="5">
<tr>
<td valign="top"><tt>task_table_name</tt></td>
<td valign="top">Name of table containing task information.</td>
</tr><tr>
<td valign="top"><tt>period_unit</tt></td>
<td valign="top">The unit that represents a measure of time.</td>
</tr><tr>
<td valign="top"><tt>dist_curve_name</tt></td>
<td valign="top">Name of distribution curve to use. Name must be unique.</td>
</tr><tr>
<td valign="top"><tt>dist_curve_tid</tt></td>
<td valign="top">Table ID of dist_curve to use.</td>
</tr></table>
<h3>Task Table columns</h3>
<p>Columns can be in any order. Separate by commas or semicolons.</p>
<table border="0" cellspacing="0" cellpadding="5">
<tr>
<td valign="top"><tt>activity_ref</tt></td>
<td valign="top">The reference for an activity.</td>
</tr><tr>
<td valign="top"><tt>predecessors</tt></td>
<td valign="top">activity_ref of activities this activity directly depends on. activity_refs should be separated by a space.</td>
</tr><tr>
<td valign="top"><tt>time_est_short</tt></td>
<td valign="top">Estimated shortest duration. (Lowest statistical deviation value.)</td>
</tr><tr>
<td valign="top"><tt>time_est_median</tt></td>
<td valign="top">Estimated median duration (Statistically, half of deviations are above or below.)</td>
</tr><tr>
<td valign="top"><tt>time_est_long</tt></td>
<td valign="top">Estimated longest duration. (Highest statistical deviation value.)</td>
</tr><tr>
<td valign="top"><tt>cost_est_low</tt></td>
<td valign="top">Estimated lowest cost. (Lowest statistical deviation value.)</td>
</tr><tr>
<td valign="top"><tt>cost_est_median</tt></td>
<td valign="top">Estimated median cost. (Statistically, half of deviations are above or below.)</td>
</tr><tr>
<td valign="top"><tt>cost_est_high</tt></td>
<td valign="top">Estimated highest cost. (Highest statistical deviation value.)</td>
</tr><tr>
<td valign="top"><tt>time_dist_curv_eq</tt></td>
<td valign="top">Use this time distribution curve equation instead of short/long estimates.</td>
</tr><tr>
<td valign="top"><tt>cost_dist_curv_eq</tt></td>
<td valign="top">Use this cost distribution curve equation instead of low/high estimates.</td>
</tr></table>
<h3>Distribution Curve columns</h3>
<table border="0" cellspacing="0" cellpadding="5">
<tr>
<td valign="top">first column (Y)<tt></tt></td>
<td valign="top">Where Y = f(x). f(x) is a probability mass function of a <a href="http://en.wikipedia.org/wiki/Probability_distribution" target="_blank">probability distribution</a>. The discrete values are the values of Y included in the table.</td>
</tr><tr>
<td valign="top"><tt>second column (x)</tt></td>
<td valign="top">Where X = the probability of Y. These can be counts of a sample or a frequency. When the table is saved, the total area under the distribution is normalized to 1.</td>
</tr><tr>
<td valign="top"><tt>third column label</tt></td>
<td valign="top">Where label is associated with the value of Y at x. This is a reference or short phrase that identifies the location in the distribution.</td>
</tr></table>
</div>
<div style="width: 90%;">
@form_html;noquote@
</div>

</if>

<if @scenario_html@ not nil>
<div style="width: 50%; float: right;">
</div>
@scenario_html;noquote@
</if>

<if @activities_table_html@ not nil>
@activities_table_html;noquote@
</if>

<if @time_dist_curve_html@ not nil>
@time_dist_curve_html;noquote@
</if>
<if @cost_dist_curve_html@ not nil>
@cost_dist_curve_html;noquote@
</if>
<if @dist_curve_html@ not nil>
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
