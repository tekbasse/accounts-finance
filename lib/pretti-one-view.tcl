# requires instance_id table_tid
# optional user_id

#set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set read_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege read]

if { [qf_is_natural_number $table_tid] } {
    set table_stats_list [qss_table_stats $table_tid]
    # name, title, comments, cell_count, row_count, template_id, flags, trashed, popularity, time last_modified, time created, user_id
    set table_name [lindex $table_stats_list 0]
    set table_title [lindex $table_stats_list 1]
    set table_comments [lindex $table_stats_list 2]
    set table_flags [lindex $table_stats_list 6]
#    set table_html "<h3>${table_title} (${table_name})</h3>\n"
    set table_lists [qss_table_read $table_tid]
    set table_text [qss_lists_to_text $table_lists]
    set table_tag_atts_list [list border 1 cellpadding 3 cellspacing 0]
    if { $table_flags eq "p4" } {
        set table_html [acc_fin::pretti_table_to_html $table_lists $table_comments]
    } else {
        set table_html [qss_list_of_lists_to_html_table $table_lists $table_tag_atts_list]
        #    append table_html "<p>${table_comments}</p>"
        set table_log_messages_list [acc_fin::pretti_log_read $table_tid 3 $user_id $instance_id]
        if { [llength $table_log_messages_list] > 0 } {
            set message_html "<h3>Most Recent Activity Log</h3><ul>"
            foreach message $table_log_messages_list {
                append message_html "<li>"
                append message_html $message
                append message_html "</li>"
            }
            append message_html "</ul>"
            append table_comments $message_html
        }
    }
}
