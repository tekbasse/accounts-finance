ad_page_contract {
    accounts-finance home page
    @creation-date 2014-09-28
} {
}

set title "Accounts Finance"
set context [list $title]
set user_id [ad_conn user_id]
set admin_p [permission::permission_p -party_id $user_id -object_id [ad_conn package_id] -privilege admin]

