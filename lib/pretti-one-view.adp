<if @table_html@ not nil>
<h3>@table_title@</h3>
<if @webpathname@ not nil>
<img border="1" src="@webpathname@" title="@table_title@" alt="@table_title@" align="right" width="200" height="200">
</if>
<pre>name: @table_name@
 tid: @table_tid@
</pre>

@table_html;noquote@

<p>
@table_comments;noquote@
</p>
</if>
