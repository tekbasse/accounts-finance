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

<if @mode@ eq "v">
  <include src="/packages/accounts-finance/lib/pretti-one-view" instance_id="@instance_id@" table_tid="@table_tid@">
</if><else>
 <if @table_html@ not nil>
  @table_html;noquote@
 </if>
</else>

<if @compute_message_html@ not nil>
<ul>
@compute_message_html;noquote@
</ul>
</if>

<if @computation_report_html@ not nil>
@computation_report_html;noquote@
</if>
<if @mode@ eq "p">
  <include src="/packages/accounts-finance/lib/pretti-view" instance_id="@instance_id@" form_action_attr="app">
</if><else>
 <if @table_stats_html@ not nil>
  @table_stats_html;noquote@
 </if>
</else>

