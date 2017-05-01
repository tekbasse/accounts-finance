ad_library {

    growth rate based routines used for modeling etc
    @creation-date 23 May 2012
    @cvs-id $Id:
}

namespace eval acc_fin {}

ad_proc -public acc_fin::Fourt_Woodlock {
    hh
    tr
    tu
    mr
    rr
    ru
} {
    Returns the value of purchases per unit time, used in projecting sales revenue.
    HH is the total number of households in the geographic area.
    TR ("trial rate") is the percentage of households that purchase the product for the first time in a given time period. 
    TU ("trial units") is the number of units purchased on the first purchase occasion. 
    MR ("measured repeat") is the percentage of customers who will purchase it at least one more time within the first period of the product's launch. 
    RR ("repeats per repeater") is the number of repeat purchases within that same year. 
    RU ("repeat units") is the number of repeat units purchased for each repeat event.
  See the Fourt-Woodlock equation:     http://en.wikipedia.org/wiki/Fourt-Woodlock_equation
} {
    
    # v = ( hh * tr * tu ) + ( hh * tr * mr * rr * ru )
        # or v = (hh * tr ) * ( tu + mr * rr * ru)
        # where,
        # v = value of purchases per unit time
  
    return $purchase_value
} 

        
ad_proc -public acc_fin::logistic_curve {
    t
} {
    The logistic function is a population growth curve. See http://en.wikipedia.org/wiki/Logistic_curve
    Essentialy, this goes from 0.000 to 0.9999 between t = -10 to 10 with 4 significant digits.
} {
    # p(t) = 1 / ( 1 + pow(e,-t) ) = 1 / (1 + exp( -t)
    # P might be considered to denote a population, where e is Euler's number and the variable t a unit of time
    # the derivative provides a rate number at any point:
    #d/dt P(t) = p(t) * ( 1 - P(t))
    set tminus [expr { -1. * $t } ]
    set p [expr { 1. / ( 1. + exp( $tminus ) ) } ]
    return $p 
}

ad_proc -public acc_fin::logistic_curve_rate {
    t
} {
    The rate of the logistic function  See http://en.wikipedia.org/wiki/Logistic_curve
} {
    # the derivative provides a rate number at any point:
    #d/dt P(t) = p(t) * ( 1 - P(t))
    set tminus [expr { -1. * $t } ]
    set p_of_t [expr { 1. / ( 1. + exp( $tminus ) ) } ]
    set rate [expr { $p_of_t * ( 1. - $p_of_t ) } ]
    return $rate
}


ad_proc -public acc_fin::pos_sine_cycle {
    t
} {
    The sine function is the basis of some patterns in modelling. This function result rises from 0 to 2 and back to 0 along a sine shaped curve between t = 0 and t = 360 degrees.
} {
    set pi [expr { acos(0) * 2. } ]
    set trad [expr { $pi * $t / 180. } ]
    # adjust t so that cycle begins at 0.
    set trad [expr { $trad - ( $pi / 2. ) } ]
    set f [expr { sin( $trad ) + 1. } ]
    return $f
}

ad_proc -public acc_fin::pos_sine_cycle_rate {
    t
} {
    The rate of the pos_sine_cycle at t degrees
} {
    set pi [expr { acos(0) * 2. } ]
    set trad [expr { $pi * $t / 180. } ]
    # adjust t so that cycle begins at 0.
    set trad [expr { $trad - ( $pi / 2. ) } ]
    set f [expr { cos( $trad ) } ]
    return $f
}