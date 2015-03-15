<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h1>@title@</h1>

<if @user_message_html@ not nil>
<ul>
@user_message_html;noquote@
</ul>
</if>

<if @table_tid@ not nil>
  <include src="/packages/accounts-finance/lib/pretti-menu2" mode="@mode@" form_action_url="app" instance_id="@instance_id@" app_name="@app_name" table_tid="@table_tid@" table_flags="@table_flags@" trashed_p="@trashed_p@" user_created_p="@user_created_p@" read_p="@read_p@" create_p="@create_p@" write_p="@write_p@" delete_p="@delete_p@" admin_p="@admin_p@" trash_folder_p="@trashed_p@">
 </if><else>
  <include src="/packages/accounts-finance/lib/pretti-menu2" mode="@mode@" form_action_url="app" instance_id="@instance_id@" app_name="@app_name" read_p="@read_p@" create_p="@create_p@" write_p="@write_p@" delete_p="@delete_p@" admin_p="@admin_p@" trash_folder_p="@trash_folder_p@">
 </else>

 <if @mode@ eq "p">
  <include src="/packages/accounts-finance/lib/pretti-view2" instance_id="@instance_id@" form_action_attr="app" trash_folder_p="@trash_folder_p@">
 </if>


<if @mode@ eq "v">
  <include src="/packages/accounts-finance/lib/pretti-one-view3" instance_id="@instance_id@" table_tid="@table_tid@" table_flags="@table_flags@" trash_folder_p="@trash_folder_p@">
</if>

</form> <!-- from pretti-menu2 -->
