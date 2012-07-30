ad_page_contract {
    model display/edit page
    returns @window_content@
    @author Torben Brosten
    @creation-date 2010-08-10

} {
    {-case_id ""}
    {-iterations_count ""}
    {-action ""}
    {-context ""}
}

# the UI is based on xowiki UI.
# edit - revisions - template - new - delete - search - index..

# action:
#  view...... default (no action)  (standard, html page document/report)
#  viewN..... as table or other options to export in csv or tab delimited format, email, copy to clipboard etc
#  list...... list other current versions of context
#  explore... compact, api-doc like where each symbol links to more info about it
#  edit...... edits current context
#  revisions. shows revisions list of context item with options
#  template.. makes new template based on current context
#  new....... creates new, blank context
#  delete.... removes all versions of current context
#  search.... searches current versions of all contexts
#  compute... compute/process (and cache) output, present post_calc results
#  review.... show computed output

# web only additions: notifications - admin

# context:
#  case....... compute/run (init_conditions,model_id,tracking_vars_id,post_compute_calcs_id,iterations_count), possibly mini graph
#  init....... initial conditions
#  model...... model program
#  tracking... variables to track
#  log........ data logged during run (if computed) 
#  post_calcs. calculations on data after compute
#  graph...... output of table in graph format(s), simple graph showing relative values over iteration with automatic limits


# each revision has author, size, last_modified, notes, current revision?, delete/trash, diff to prev, version_number
# version_number is dynamically created, a trashed revision does not disrupt sequence (a new sequence is displayed)

# create procs that read and  update data (create new if none, or new id where data changes)

set title "Model"
set context [list $title]
set package_id [ad_conn package_id]


set window_content ""


set user_id [ad_conn user_id]
set write_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege write]
set admin_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege admin]


#set model [acc_fin::template_model 0]

if { $action eq "view" } {

    set computed_model [acc_fin::model_compute $model 120]
    set formatting_list [list ]
    set error_table [lindex $computed_model 0]
    set error_table_html [qaf_tcl_list_of_lists_to_html_table $error_table $formatting_list 1 0 0]
    set data_model [lrange $computed_model 1 end]
    set computed_model_html [qaf_tcl_list_of_lists_to_html_table $data_model $formatting_list 1 0 2]

}


if { $action eq "compute" } {
    set computed_model [acc_fin::model_compute $model 120]
    set formatting_list [list ]
    set error_table [lindex $computed_model 0]
    set error_table_html [qaf_tcl_list_of_lists_to_html_table $error_table $formatting_list 1 0 0]
    set data_model [lrange $computed_model 1 end]
    set computed_model_html [qaf_tcl_list_of_lists_to_html_table $data_model $formatting_list 1 0 2]
}

if { $action eq "compile" } {
    set computed_model [acc_fin::model_compute $model 120]
    set error_table [lindex $computed_model 0]
    set error_table_html [qaf_tcl_list_of_lists_to_html_table $error_table $formatting_list 1 0 0]
    set data_model [lrange $computed_model 1 end]
    set computed_model_html [qaf_tcl_list_of_lists_to_html_table $data_model $formatting_list 1 0 2]


}
