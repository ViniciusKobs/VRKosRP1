parameter widgets, env, wid, wcl, mlog.

set widgets:tools to lex("t", "vlayout", "id", "tools", "params", lex("p", recn(5), "v", false), "child", list(
    lex("t", "hlayout", "child", list(
        lex("t", "vlayout", "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "vlayout", "params", lex("w", 135, "m", recnn(0,5,0,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Thrust(kn)", "m", recnn(0,0,3,0))),
                    lex("t", "field", "id", "f", "params", lex("t", "", "p", recn(3,0)))
                )),
                lex("t", "vlayout", "params", lex("w", 135, "m", recnn(0,5,0,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Isp", "m", recnn(0,0,3,0))),
                    lex("t", "field", "id", "isp", "params", lex("t", "", "p", recn(3,0)))
                )),
                lex("t", "vlayout", "params", lex("w", 135), "child", list(
                    lex("t", "label", "params", lex("t", "Flow", "m", recnn(0,0,3,0))),
                    lex("t", "field", "id", "flow", "params", lex("t", "", "p", recn(3,0)))
                ))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "vlayout", "params", lex("w", 135, "m", recnn(0,5,0,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Wet mass(t)", "m", recn(0,3))),
                    lex("t", "field", "id", "m0", "params", lex("t", "", "p", recn(3,0)))
                )),
                lex("t", "vlayout", "params", lex("w", 135, "m", recnn(0,5,0,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Dry mass(t)", "m", recn(0,3))),
                    lex("t", "field", "id", "mf", "params", lex("t", "", "p", recn(3,0)))
                )),
                lex("t", "vlayout", "params", lex("w", 135, "m", recnn(0,5,0,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Burn time(s)", "m", recn(0,3))),
                    lex("t", "field", "id", "burnt", "params", lex("t", "", "p", recn(3,0)))
                ))
            ))
        )),
        lex("t", "vlayout", "child", list(
            lex("t", "button", "params", lex("t", "Engines", "oc", engines_cb@, "w", 70, "h", 22, "m", recnn(20,0,5,0))),
            lex("t", "button", "params", lex("t", "Calculate", "oc", calculate_cb@, "w", 70, "h", 22))
        ))
    )),
    lex("t", "label", "params", lex("t", "Ship mass: " + ship:mass:tostring + "t", "m", recnn(0,5,5,0)))
)).

function engines_cb {
    local engs to unique(map(ship:engines, {
        parameter e.
        return ("name: " + e:title + ", thrust: " + format_float(e:possiblethrustat(0)) + ", isp: " + format_float(e:visp)).
    })).
    for e in engs {
        mlog:add(e).
    }
}

function calculate_cb {
    local f to wid:f:text:tonumber(-1)*1e3.
    local isp to wid:isp:text:tonumber(-1).
    local ve to isp * constant:g0.
    local flow to wid:flow:text:tonumber(-1).
    local m0 to wid:m0:text:tonumber(-1)*1e3.
    local mf to wid:mf:text:tonumber(-1)*1e3.
    local burnt to wid:burnt:text:tonumber(-1).

    if (f > 0 and ve > 0) {
        set flow to f / ve.
    } else if (ve > 0 and flow > 0) {
        set f to ve * flow.
    } else if (f > 0 and flow > 0) {
        set ve to f / flow.
        set isp to ve / constant:g0.
    } else {
        mlog:add("not enough engine data, at least two are required.").
    } 

    if (m0 > 0 and mf > 0) {
        set burnt to (m0 - mf) / flow.
    } else if (m0 > 0 and burnt > 0) {
        set mf to m0 - (burnt * flow).
    } else if (mf > 0 and burnt > 0) {
        set m0 to mf + (burnt * flow).
    } else {
        mlog:add("not enough mass data, at least two are required.").
    }

    set wid:f:text to choose "" if f < 0 else format_float(f/1e3).
    set wid:isp:text to choose "" if isp < 0 else format_float(isp).
    set wid:flow:text to choose "" if flow < 0 else format_float(flow).
    set wid:m0:text to choose "" if m0 < 0 else format_float(m0/1e3).
    set wid:mf:text to choose "" if mf < 0 else format_float(mf/1e3).
    set wid:burnt:text to choose "" if burnt < 0 else format_float(burnt).
}