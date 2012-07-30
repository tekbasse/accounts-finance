ad_library {

    energy based routines used for modeling cashflows etc
    @creation-date 27 May 2010
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public acc_fin::energy_output {
    base_system_performance
    peak_power_output
    annual_degredation
    year
    intervals_per_year
} {
    Returns the system energy output within an interval.
    Unit returned is in kWh if these units are used:
    base_system_performance (hours of available peak energy / year or kWh/kW ),
    peak_power_output ( kW ),
    annual_degredation ( percent expressed as a decimal number ).  Ten percent is represented as 0.1
} {
    set energy_output [expr { $base_system_performance * $peak_power_output * ( 1. - (( $year - 1. ) * $annual_degredation ) ) / double( $intervals_per_year ) } ]
    return $energy_output
} 

ad_proc -public acc_fin::energy_ppa_revenue {
    energy_output
    ppa_rate
    ppa_escalation
    year
} {
    returns the revenue amount from selling the energy on a purchase power agreement (PPA) during the year specified. 
    Unit returned is in currency of ppa_rate if these units are used:
    energy_output (kWh)
    ppa_rate (currency /kWh)
    ppa_escalation ( percent expressed as a decimal number) 10% is 0.1
} {
    set revenue [expr { $energy_output * $ppa_rate * pow( 1. + $ppa_escalation , $year - 1. ) } ]
    return $revenue
} 
