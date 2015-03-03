<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<h3>@title;noquote@</h3>
<p>These are used in each Task represented in a PRETTI P4</p>
@glossary_html;noquote@

<h3>FAQ</h3>
<p>Q1: What is PRETTI?
</p>
<p><a name="a1">A1</a>: <strong>PRETTI</strong> is acronym for 
Project Reporting Evaluation and Track Task Interpretation. 
PRETTI is a network analysis presented as a table  
with each column representing a path. 
Each cell represents a task on a path.
PRETTI supercedes PANERLFPFT: 
Project Activity Network Evaluation by Reporting Low Float Paths in Fast Tracks
</p>
<p>Q2: What is a node?
</p>
<p><a name="a2">A2</a>: A <strong>node</strong> in a network represents 
a task. A task may have multiple dependencies. 
When interpreting 'node' in the context of PRETTI, node refers to the
sum of the values for the task and all it's dependents.
</p>
<p>Q3: What is a waypoint?
</p>
<p><a name="a3">A3</a>: A <strong>waypoint</strong> is a point
along a single path. When interpreting 'waypoint' in the context
of PRETTI, waypoint refers to the 
sum of the values for the task and previous tasks on the same path.
</p><p>
<p>Q4: How can I tell the difference between a node and a path?
</p>
<p><a name="a4">A4</a>: A node considers all dependencies of a task, 
whereas a path considers only one branch of dependents of a task.
For example, consider a network ABC consisting of a task C with dependent
tasks A and B. Node calculations for C would include A and B. 
The network ABC would consist of two paths AC and BC. 
Path AC ( A to C ) would only sum values for A to C ( A and C since there are
only two tasks ). 
Path BC ( B to C ) would only sum values for B to C ( the same as 
the sum of the values of task B and C, since there are only two tasks ).
</p>