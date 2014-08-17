<if @table_html@ not nil>
  <h3>@table_title@</h3>
  <if @cob_html@ not nil>
    <div> 
      <p>Cobbler chart</p>
      @cob_html;noquote@
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
