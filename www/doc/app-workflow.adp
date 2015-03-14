<master>
<property name="doc(title)">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<h3>@title;noquote@</h3>
<p>
The purpose of the application is to facilitate workflow using tabular data.

</p><p>

</p><p>
To create a table from the app url <a href="@package_url@pretti">@package_url;noquote@pretti</a>, 
</p>
<ul><li>
click the #accounts-finance.new# button.
</li><li>

    Fill in the form. 
    <ul><li>
        #accounts-finance.name# becomes the tail part of the url as in 
        @package_url;noquote@pretti/{name}
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
    </li></ul>
  </li><li>
    Click #accounts-finance.Save# button to save the table.
  </li><li>
    If the system recognizes the table as a type, 
    the type will be displayed in the #accounts-finance.type# column.
    Tables can be edited.
    Prior revisions are automatically moved to #accounts-finance.trash#, 
    where they may be recovered using #accounts-finance.untrash#.
</li></ul>

<p>
If a table is a process specification, such as a PRETTI Scenario (p1), 
a process button will appear in the menu with specification's view when the table meets minimum process requirements. 
Click the #accounts-finance.process# button to begin a process that results in some process output, usually a table.
</p>

