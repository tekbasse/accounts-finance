<master>
<property name="doc(title)">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<h1>@title;noquote@</h1>
<p>Definition: #accounts-finance.task_network_p2_def#</p>

<h2>Example Contents field of table entry form</h2>
<p>Here is an example of comma delimited p2 data as it appears when
being input via the app's form:
</p>
@raw_html;noquote@

<h2>Example resultant p2 table</h2>
<p>Here is the same example of p2 data (as above) shown on a page once the table is saved:
</p>
@raw2_html;noquote@


<h2>Reserved p2 column headings</h2>
<p>
Reserved p2 columns consist of:
</p>
<ul><li>
references to other tables ( *_tid *_name ), 
</li><li>
task attributes for setting default estimate values (time_* cost_* eco2_* ), 
</li><li>
operational constraint attributes for setting default values ( max_* ), and
</li></ul>
<p>Here, an asterisk (*) is used similar to a hyphen in English to denote a prefix or suffix.
</p>
<p>In general with PRETTI processing, <strong>a more specific value takes precedence</strong>. 
This is similar in concept to class inheritance or subtyping in object-oriented computer programming 
--depending on how its portrayed and your perspective etc. 
</p><p>
By using more specificity as a guide, 
a plan may grow in depth at any point at any time without breaking the process or forcing artificial 
constraints on an evolving plan.
</p><p>
For values common between table types, p2 values takes precedence over p3 values, p3 values take precedence over p1 values;
Because p2 contains specific tasks, optional p3 is a library of task templates, and p1 contains scenario parameters.
</p><p>
When a table is revised, new revisions receive a new table ID, but the table name is not changed (unless by the editing user).
</p>
<h3>References to other tables</h3>
<p>When building a model or plan, the initial minimum requirements are one scenario (p1) and task network (p2).
Task attributes may include distribution curve tables (dc) and a library of task types (p3) 
that references might reference other dc tables.
</p><p>When referencing another table, if a specific table id ( *_tid) and ( *_name ) are provided, 
the more specific table ID takes precedence if it exists (and is not trashed).
</p><p>
For example, if activity_table_tid is '100012' and activity_table_name is 'Red Activity Table', 
PRETTI will reference the table with ID '100012'.
</p><p>
For *_dist_curve_tid or *_dist_curve_name, 
the guide of a more specific value (*_tid) takes precedence (over *_name).
If a distribution curve is not available, PRETTI attempts to generate
a standard distribution curve using p2 minimum, maximum and median values over the same variable (cost, time, or eco2).
Values of p2 takes precedence over p3 values, and p3 values take precedence over p1 values.
</p><p>
For example, if cost_dist_curve_tid is '100015' in the scenario (p1), 
but the referenced task network (p2) assigns a specific task a cost_dist_curve_name of "paintingA103", 
then the cost distribution curve 'paintingA103' is used for that task.
</p>
<h3>Task attributes</h3>
<p>Task attributes are mainly used in the context of tasks and task network (p2) tables, 
and so are defined there. 
In p1, task attributes can be assigned defaults for the entire scenario or missing data in p2 or p3 tables.
</p>
<h3>Operational constraint attributes</h3>
<p>Operational constraint attributes are mainly used in the context of tasks and task network (p2) tables, 
and so are defined there.
In p1, operational constraints can be assigned defaults for the entire scenario or missing data in p2 or p3 tables.
</p>
<h3>Statistical points</h3>
<p>
When interpreting *_probability_points, 
a task's distribution curve takes precedence over min/max/median values.
This is similar to how *_tid values takes precedence over *_name values.
</p>
<h3>All reserved @type@ columns</h3>
@p2_html;noquote@
<p>These column headings are required for a @type@ table:
</p>
@p2b_html;noquote@
