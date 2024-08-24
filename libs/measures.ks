runoncepath("0:/libs/vessel.ks").

global function vessel_acc_loop {
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

function vessel_acc {
    local self to lex(
        "dv", 0,
        "t0", 0,
        "update", {
            local t1 to time:seconds.
            local dt to t1 - self:t0.
            local acc to (ship:thrust/ship:mass)*dt.
            set self:dv to self:dv + acc.
            set self:t0 to t1.
        }
    ).
    set self:t0 to time:seconds.
    return self.
}

global function vessel_rcs_loop {
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

function vessel_rcs_acc {
    local self to lex(
        "dv", 0,
        "t0", 0,
        "f", 0,
        "update", {
            local t1 to time:seconds.
            local dt to t1 - self:t0.
            local acc to (self:f/ship:mass)*dt.
            set self:dv to self:dv + acc.
            set self:t0 to t1.
        }
    ).
    for p in get_active_fore_rcs(ship:rcs) {
        set self:f to self:f + p:availablethrust.
    }
    set self:t0 to time:seconds.
    return self.
}