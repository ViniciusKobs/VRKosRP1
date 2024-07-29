runoncepath("0:/libs/vessel.ks").

global function vessel_rotation {
    parameter cb.
    
    local t0 to time:seconds.
    local f0 to ship:facing.

    wait 0.
    until false {
        local t1 to time:seconds.
        local f1 to ship:facing.

        local dt to t1 - t0.

        local dtop to arccos(min(f0:topvector:normalized * f1:topvector:normalized, 1))/dt.
        local dfore to arccos(min(f0:forevector:normalized * f1:forevector:normalized, 1))/dt.
        local dright to arccos(min(f0:rightvector:normalized * f1:rightvector:normalized, 1))/dt.

        if (cb(dt, dtop, dfore, dright)) {return.}

        set t0 to t1.
        set f0 to f1.
        wait 0.
    }
}

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

global function vessel_measurements {
    parameter cb.
    
    local dv to 0.
    local t0 to time:seconds.
    local f0 to ship:facing.

    wait 0.
    until false {
        local t1 to time:seconds.
        local f1 to ship:facing.

        local dt to t1 - t0.

        local acc to (ship:thrust/ship:mass)*dt.
        set dv to dv + acc.

        local dtop to arccos(min(f0:topvector:normalized * f1:topvector:normalized, 1))/dt.
        local dfore to arccos(min(f0:forevector:normalized * f1:forevector:normalized, 1))/dt.
        local dright to arccos(min(f0:rightvector:normalized * f1:rightvector:normalized, 1))/dt.

        if (cb(dt, dv, acc, dtop, dfore, dright)) {return.}

        set t0 to t1.
        set f0 to f1.
        wait 0.
    }
}