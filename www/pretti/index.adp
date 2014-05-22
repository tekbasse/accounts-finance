<master>
    <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h1>@title@</h1>

<if @table_tid@ not nil>
  <include src="/packages/accounts-finance/lib/pretti-menu1" mode="@mode@" form_action_url="app" instance_id="@instance_id@" app_name="@app_name" table_tid="@table_tid@" table_flags="@table_flags@">
</if><else>
  <include src="/packages/accounts-finance/lib/pretti-menu1" mode="@mode@" form_action_url="app" instance_id="@instance_id@" app_name="@app_name">
</else>

<if @user_message_html@ not nil>
<ul>
@user_message_html;noquote@
</ul>
</if>

<if @mode@ eq "v">
  <include src="/packages/accounts-finance/lib/pretti-one-view" instance_id="@instance_id@" table_tid="@table_tid@" table_flags="@table_flags@">
</if>

<if @mode@ eq "p">
  <include src="/packages/accounts-finance/lib/pretti-view" instance_id="@instance_id@" form_action_attr="app">
</if>


