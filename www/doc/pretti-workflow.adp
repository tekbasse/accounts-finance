<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<h3>@title;noquote@</h3>
<p>
The purpose of the workflow is to create a PRETTI chart. 
A PRETTI chart is a table of type <a href="pretti-tables#p4">p4</a>. 
</p><p>
To create a PRETTI chart, create a <strong>task network</strong> table (<a href="pretti-tables#p2">type p2</a>)
and a <strong>scenario</strong> table (<a href="pretti-tables#p1">type p1</a>). 
</p>

<h4><a name="p2">#accounts-finance.task_network_p2#</a> *</h4>
<p>Definition: #accounts-finance.task_network_p2_def#</p>
<h4>How to create a #accounts-finance.task_network_p2# table</h4>
<ol><li>
    Browse to a PRETTI app. A local one may be at <a href="../pretti/index">accounts-finance-subsite/pretti</a>.
  </li><li>
    Click the "#accounts-finance.new#" button. 
    If you don't see the button, you might not be logged in as a user
    that has adequate permission.
  </li><li>
    Fill in the form. 
    <ul><li>
        #accounts-finance.name# becomes the tail part of the url as in 
        @example_url;noquote@pretti/{name}
      </li><li>
        #accounts-finance.title# becomes the title of the table's page.
      </li><li>
        #accounts-finance.comments# is a place to store optional comments 
        on the page displaying the table and list of tables.
      </li><li>
        #accounts-finance.contents# is where the table is defined.
        Set the first row to a list of titles. 
        Subsequent rows contain data.
        Most any common delimiters may be used to separate fields, 
        so long as they are consistently applied.
        Titles must include the required fields (@p2_required_fields_html@) 
        for the system to recognize the table as a type p2.
    </li></ul>
  </li><li>
    Click #accounts-finance.Save# button to save the table.
  </li><li>
    If the system recognizes the table as being of type "p2" or another type, 
    the type will be displayed in the #accounts-finance.type# column.
    Tables can be edited.
    Prior revisions are automatically moved to #accounts-finance.trash#, 
    where they may be recovered using #accounts-finance.untrash#.
</li></ol>

<h4><a name="p1">#accounts-finance.scenario_p1#</a> *</h4>
<p>Definition: #accounts-finance.scenario_p1_def#</p>
<h4>How to create a #accounts-finance.scenario_p1# table</h4>
<ol><li>
    Browse to a PRETTI app. A local one may be at <a href="../pretti/index">accounts-finance-subsite/pretti</a>.
  </li><li>
    Click the "#accounts-finance.new#" button. 
    If you don't see the button, you might not be logged in as a user
    that has adequate permission.
  </li><li>
    Fill in the form. 
    <ul><li>
        #accounts-finance.name# becomes the tail part of the url as in 
        @example_url;noquote@pretti/{name}
      </li><li>
        #accounts-finance.title# becomes the title of the table's page.
      </li><li>
        #accounts-finance.comments# is a place to store optional comments 
        on the page displaying the table and list of tables.
      </li><li>
        #accounts-finance.contents# is where the table is defined.
        Set the first row to a list of titles. 
        Subsequent rows contain data.
        Most any common delimiters may be used to separate fields, 
        so long as they are consistently applied.
        Titles must include the required field (@p1_required_fields_html@) 
        for the system to recognize the table as a type p1.
    </li></ul>
  </li><li>
    Click #accounts-finance.Save# button to save the table.
  </li><li>
    If the system recognizes the table as being of type "p1" or another type, 
    the type will be displayed in the #accounts-finance.type# column.
    Tables can be edited.
    Prior revisions are automatically moved to #accounts-finance.trash#, 
    where they may be recovered using #accounts-finance.untrash#.
</li></ol>


<h4><a name="p3">#accounts-finance.task_types_p3#</a></h4>
<p>Definition: #accounts-finance.task_types_p3_def#</p>
<p>This table is optional. 
If multiple tasks use similar specifications, 
it may be practical to refer to task-types in a p2 table column 'aid_type', 
and then list the task-types in column 'type' in a p3 table.
Any p3 table used by a scenario must be referred to in the p1 scenario.
</p>
<h4>How to create a #accounts-finance.task_types_p3# table</h4>
<ol><li>
    Browse to a PRETTI app. A local one may be at <a href="../pretti/index">accounts-finance-subsite/pretti</a>.
  </li><li>
    Click the "#accounts-finance.new#" button. 
    If you don't see the button, you might not be logged in as a user
    that has adequate permission.
  </li><li>
    Fill in the form. 
    <ul><li>
        #accounts-finance.name# becomes the tail part of the url as in 
        @example_url;noquote@pretti/{name}
      </li><li>
        #accounts-finance.title# becomes the title of the table's page.
      </li><li>
        #accounts-finance.comments# is a place to store optional comments 
        on the page displaying the table and list of tables.
      </li><li>
        #accounts-finance.contents# is where the table is defined.
        Set the first row to a list of titles. 
        Subsequent rows contain data.
        Most any common delimiters may be used to separate fields, 
        so long as they are consistently applied.
        Titles must include the required field (@p3_required_fields_html@) 
        for the system to recognize the table as a type p3.
    </li></ul>
  </li><li>
    Click #accounts-finance.Save# button to save the table.
    
  </li><li>
    If the system recognizes the table as being of type "p3" or another type, 
    the type will be displayed in the #accounts-finance.type# column.
    Tables can be edited.
    Prior revisions are automatically moved to #accounts-finance.trash#, 
    where they may be recovered using #accounts-finance.untrash#.
</li></ol>


