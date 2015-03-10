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
Reserved p2 columns consist of task attributes. 
Each row defines a task. 
</p>
<h3>Required references</h3>
<ul><li>
Each <strong>activity_ref</strong> must be unique and contain only letters or numbers or underscores or dashes. 
</li><li>
<strong>dependent_tasks</strong> contain the references of activities that activity_ref depend on directly. 
These should be separated by a delimiter that is different than the rest of the table delimiters. 
For example, if the table's row delimiter is a comma, 
a space or semicolon may be appropriate to delimit between dependent each activity_ref listed in dependent_tasks.
</li></ul>
<h3>Constraints on repetative tasks</h3>
<p>
Other p2 columns are either constraints on a sequence of the same task.
</p>
<h3>Dimensions of task</h3>
<p>Pretti tracks up to three different dimensions using distribution curves: 
</p>
<ul><li>
duration ie. time, 
</li><li>
cost, or 
</li><li>
eco2 ie. greenhouse gas equivalents used in tracking environmental footprint. 
</li></ul>
<p>
Other tracked fields accumulate task values without statistical calculations. 
</p>
<p>
Task attributes are organized by a prefix associated by its dimension; Usually: time_* cost_* and eco2_*. 
Here, an asterisk (*) is used similar to a hyphen in English to denote a prefix or suffix.
</p>
<p>
Each prefix has a suffix appended that identifies a specific attribute for the dimension. 
Each reserved combination is listed in the table of reserved p2 column headings (below). 
</p><p>
Each prefix has a unit associated with the dimension that is assumed to be consistent for all values, 
whether it is hours, days, weeks, minutes etc. for time, 
a specific currency or ounce of gold for cost, or 
ghg or tons of co2 et cetera for eco2.
</p><p>
Each suffix also has a datatype associated with it:
</p>
<ul><li>
References to other tables ( *_tid *_name ) are expected to be a number for *_tid or other table name for *_name.
Distribution curves are the only tables that task attributes can refer to directly. 
</li><li>
Operational constraint attributes for setting default values ( max_* ) refer to counts of tasks, a percentage (pct), 
or same unit of dimension used elsewhere. 
See the reserved p2 columns' Description for specifics including example number formats.
</li></ul>

<h3>All reserved @type@ columns</h3>
@p2_html;noquote@
<p>These column headings are required for a @type@ table:
</p>
@p2b_html;noquote@
