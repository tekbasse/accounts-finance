<if @table_html@ not nil>
<h3>@table_title@</h3>
<if @pie_webpathname@ not nil>
<div>
<p>PIE chart</p>
<img border="1" src="@pie_webpathname@" title="@table_title@" alt="@table_title@" width="200" height="200" style="margin: 5px;">
</div>
</if>
<if @cob_webpathname@ not nil>
<div> 
<p>Cobbler chart</p>
<img border="1" src="@cob_webpathname@" title="@table_title@" alt="@table_title@" width="360" height="100" style="margin: 5px;">
</div>
</if>
<pre>name: @table_name@
 tid: @table_tid@
</pre>

@table_html;noquote@

<p>
@table_comments;noquote@
</p>
</if>
