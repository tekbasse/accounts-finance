<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<h1>@title;noquote@</h1>
<p>Definition: #accounts-finance.scenario_p1_def#</p>

<h2>Example Contents field of table entry form</h2>
<p>Here is an example of comma delimited p1 data as it appears when
being input via the app's form:
</p>
@raw_html;noquote@

<h2>Example resultant p1 table</h2>
<p>Here is the same example of p1 data (as above) shown on a page once the table is saved:
</p>
@raw2_html;noquote@


<h2>Reserved p1 column headings</h2>
<p>
Reserved p1 columns consist of:
</p>
<ul><li>
references to other tables ( *_tid *_name ), 
</li><li>
task attributes for setting default estimate values (time_* cost_* eco2_*), 
</li><li>
operational constraint attributes for setting default values ( max_* ), 
</li><li>
report number formatting ( *precision),
</li><li>
statistical points ( *_probability_points), and
</li><li>
process flags ( index_equation, db_format)
</li></ul>
<p>Here, an asterisk (*) is used similar to a hyphen in Engilsh to denote a prefix or suffix.
</p>
<p>In general with PRETTI processing, <strong>a more specific value takes precidence</strong>. 
This is similar in concept to class inheritance or subtyping in object-oriented computer programming 
--depending on how its portrayed and your perspective etc. 
Volumes have been written about it; There's no sense in exploring the depths of it here. 
</p><p>
By using more specificity as a guide, 
a plan may grow in depth at any point at any time without breaking the process or forcing artificial 
constraints on an evolving plan.
</p><p>
For values common between table types, p2 values takes precidence over p3 values, p3 values take precidence over p1 values;
Because p2 contains specific tasks, optional p3 contains templates of tasks, and p1 contains the scenario parameters.
</p>
<h3>References to other tables</h3>
<p>When building a model or plan, the initial minimum requirements are one scenario (p1) and task network (p2).
Task attributes may include up to one unique distribution curve table per task (dc) and a library of task types (p3) 
that references other dc tables.
</p><p>When referencing another table, if a specific table id ( *_tid) and ( *_name ) are provided, 
the more specific table ID takes precedence if it exists (and is not trashed).
</p><p>
For example, if activity_table_tid is '100012' and activity_table_name is 'Red Activity Table', 
PRETTI will reference the table with ID '100012'.
</p><p>
For *_dist_curve_tid or *_dist_curve_name, 
the guide of a more specific value (*_tid) taking precidence (over *_name) still applies.
</p><p>
For example, if cost_dist_curve_tid is '100015' in the scenario (p1), 
but the referenced task network (p2) assigns a specific task a cost_dist_curve_name of "paintingA103", 
then the cost distribution curve for paintingA103 is used for that task.
</p>
<h3>Task attributes</h3>
<p>
</p>
<h3>Operational constraint attributes</h3>

<h3>Report number formatting</h3>

<h3>Statistical points</h3>
<p>
When interpreting *_probability_points, a task's distribution curve takes precidence over min/max/median values similar to how *_tid values takes precidence over *_name values.
</p>
<h3>Process flags</h3>


<h3>All reserved p1 columns</h3>
@p1_html;noquote@
<p>These column headings are required for a p1 table:
</p>
@p1b_html;noquote@
