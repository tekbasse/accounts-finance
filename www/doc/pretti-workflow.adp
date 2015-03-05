<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<h3>@title;noquote@</h3>
<p>
The purpose of the workflow is to create a PRETTI chart. 
A PRETTI chart is a table of type <a href="pretti-tables#p4">p4</a>. 
</p><p>
To create a PRETTI chart, create a task network table (<a href="pretti-tables#p2">type p2</a>)
and a scenario table (<a href="pretti-tables#p1">type p1</a>). 
</p>
<h4>How to create a task network table</h4>
<ol><li>
    Browse to a PRETTI app. The local one is <a href="../pretti/index">here</a>.
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


<h4>How to create a scenario table</h4>
<ol><li>
    Browse to a PRETTI app. The local one is <a href="../pretti/index">here</a>.
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

