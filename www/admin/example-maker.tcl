# generic header for static .adp pages

set instance_id [qc_set_instance_id]
set user_id [ad_conn user_id]
set read_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege read]
if { $read_p } {
    set write_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege write]
    if { $write_p } {
        set delete_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege delete]
        if { $delete_p } {
            set admin_p [permission::permission_p -party_id $user_id -object_id [ad_conn package_id] -privilege admin]
        } else {
            set admin_p 0
        }
    } else {
        set admin_p 0
        set delete_p 0
    }
} else {
    set write_p 0
    set admin_p 0
    set delete_p 0
}

if { $admin_p } {
    acc_fin::pretti_example_maker 
}
set url [ad_conn package_url]
append url "/pretti"
ad_returnredirect $url
