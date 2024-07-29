function activate_self_destruction {
    core:part:getmodule("modulerangesafety"):doaction("range safety", true).
}

function active_engines {
    local engs to list().
    for e in ship:engines {
        if (e:maxthrust > 0 and not e:flameout) {
            engs:add(e).
        }
    }
    return engs.
}

function engines_isp {
    parameter engs to list().
    local isp to 0.
    for e in engs {
        set isp to isp + e:visp.
    }
    return isp / engs:length.
}

function engines_thrust {
    parameter engs to list().
    local thrust to 0.
    for e in engs {
        set thrust to thrust + e:maxthrust.
    }
    return thrust.
}

function check_engine_failure {
    parameter engs to list().
    local fail to false. 
    for e in engs {
        local m to e:getmodule("moduleenginesrf").
        if (m:getfield("status"):contains("Failed")) {
            set fail to true.
            break.
        }
    }
    return fail.
}

function ignite_engines {
    parameter engs to list().
    for e in engs {
        local m to e:getmodule("moduleenginesrf").
        if (m:hasevent("activate engine")) {
            m:doevent("activate engine").
        }
    }
}

function shutdown_engines {
    parameter engs to list().
    for e in engs {
        local m to e:getmodule("moduleenginesrf").
        if (m:hasevent("shutdown engine")) {
            m:doevent("shutdown engine").
        }
    }
}

function get_active_fore_rcs {
    parameter rcss to list().
    local act_rcss to list().
    for p in rcss {
        if (p:enabled) {
            local f to ship:facing:forevector:normalized.
            local tvs to p:thrustvectors.
            for tv in tvs {
                if (round(tv:normalized*f, 4) = -1) {
                    act_rcss:add(p).
                    break.
                }
            }
        }
    }
    return act_rcss.
}