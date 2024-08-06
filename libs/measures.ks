runoncepath("0:/libs/vessel.ks").

global function vessel_acceleration {
    local parameter cb.

    local dv to 0.
    local t0 to time:seconds.

    wait 0.
    until false {
        local t1 to time:seconds.

        local dt to t1 - t0.

        local acc to (ship:thrust/ship:mass)*dt.
        set dv to dv + acc.

        if (cb(dt, dv, acc)) {return.}

        set t0 to t1.
        wait 0.
    }
}

global function vessel_rcs_acceleration {
    local parameter cb.

    local f to 0.
    for p in get_active_fore_rcs(ship:rcs) {
        set f to f + p:availablethrust.
    }
    local dv to 0.
    local t0 to time:seconds.

    wait 0.
    until false {
        local t1 to time:seconds.

        local dt to t1 - t0.

        local acc to (f/ship:mass)*dt.
        set dv to dv + acc.

        if (cb(dt, dv, acc, f)) {return.}

        set t0 to t1.
        wait 0.
    }
}