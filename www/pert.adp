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
