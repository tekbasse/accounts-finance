<if @table_html@ not nil>
  <h3>@table_title@</h3>

  <if @pie_html@ not nil>
    <div> 
      <p>Pie chart</p>
      <a href="@pie_html;noquote@"><img src="@pie_html;noquote@" width="100" height="100" border="1" alt="pie chart view" title="Pie chart. See table for specific numbers."></a>
    </div>
  </if>

  <if @cob_html@ not nil>
    <div> 
      <p>Cobbler chart</p>
      <a href="@cob_html;noquote@"><img src="@cob_html;noquote@" width="100" height="100" border="1" alt="cobbler chart view" title="Cobbler chart. See table for specific numbers."></a>
    </div>
  </if>

  <pre>name: @table_name@
    tid: @table_tid@
  </pre>

  @table_html;noquote@

  <p>
    @table_comments;noquote@
  </p>

  <if @table_flags@ not nil and @table_flags@ eq "p4">
    <p>Legend</p>
    <include src="/packages/accounts-finance/lib/pretti-p4-legend">
  </if>

</if>
