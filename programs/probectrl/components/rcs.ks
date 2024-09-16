parameter widgets, env, wid, wcl, mlog.

local increment to 0.1.

local rcs_dir_cb to lex(
    "fore", {parameter val is -1. if (val >= 0) {set ship:control:fore      to val.  return val.} wid:rcsback:takepress. },
    "back", {parameter val is -1. if (val >= 0) {set ship:control:fore      to -val. return val.} wid:rcsfore:takepress. },
    "up",   {parameter val is -1. if (val >= 0) {set ship:control:top       to val.  return val.} wid:rcsdown:takepress. },
    "down", {parameter val is -1. if (val >= 0) {set ship:control:top       to -val. return val.} wid:rcsup:takepress.   },
    "right",{parameter val is -1. if (val >= 0) {set ship:control:starboard to val.  return val.} wid:rcsleft:takepress. },
    "left", {parameter val is -1. if (val >= 0) {set ship:control:starboard to -val. return val.} wid:rcsright:takepress.},

    "c+", {parameter vec. set ship:control:fore to vec:x.  set ship:control:top to vec:y.  set ship:control:starboard to vec:z.  wid:rcscm:takepress.},
    "c-", {parameter vec. set ship:control:fore to -vec:x. set ship:control:top to -vec:y. set ship:control:starboard to -vec:z. wid:rcscp:takepress.}
).

set widgets:rcs to lex("t", "hlayout", "id", "rcs", "params", lex("v", false, "p", recn(5)), "child", list(
    lex("t", "vlayout", "params", lex("w", 165, "m", recnn(0,5,0,0)), "child", list(
        lex("t", "label", "params", lex("t", "Throttle", "h", 20, "m", recnn(0,0,5,0))),
        lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
            lex("t", "button", "params", lex("t", "+", "h", 20, "m", recnn(0,5,0,0), "oc", rcs_throttle_cb("+"))),
            lex("t", "field", "id", "rcs_throttle", "params", lex("t", "1.0", "h", 18, "p", recnn(1,0,0,0), "m", recnn(0,5,0,0))),
            lex("t", "button", "params", lex("t", "-", "h", 20, "oc", rcs_throttle_cb("-")))
        )),
        // disabled by now, needs to be implemented in the main file
        //lex("t", "button", "id", "btype_check", "params", lex("t", "Button type: Press", "m", recnn(0,0,5,0), "h", 20, "oc", btype_check_cb@)),
        lex("t", "button", "id", "engaged_check", "params", lex("t", "Engaged: True", "h", 20, "oc", engaged_check_cb@))
    )),
    lex("t", "vlayout", "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "button", "id", "rcsfore", "params", lex("t", "Fore", "h", 40, "w", 80, "tg", true, "ot", rcs_fire_cb("fore"))),
            lex("t", "button", "params", lex("t", "", "e", false, "h", 40, "w", 80)),
            lex("t", "button", "id", "rcsup", "params", lex("t", "Up", "h", 40, "w", 80, "tg", true, "ot", rcs_fire_cb("up"))),
            lex("t", "button", "params", lex("t", "", "e", false, "h", 40, "w", 80))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "button", "id", "rcsback", "params", lex("t", "Back", "h", 40, "w", 80, "tg", true, "ot", rcs_fire_cb("back"))),
            lex("t", "button", "id", "rcsleft", "params", lex("t", "Left", "h", 40, "w", 80, "tg", true, "ot", rcs_fire_cb("left"))),
            lex("t", "button", "id", "rcsdown", "params", lex("t", "Down", "h", 40, "w", 80, "tg", true, "ot", rcs_fire_cb("down"))),
            lex("t", "button", "id", "rcsright", "params", lex("t", "Right", "h", 40, "w", 80, "tg", true, "ot", rcs_fire_cb("right")))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "button", "id", "rcscp", "params", lex("t", "+", "h", 40, "w", 80, "tg", true, "ot", rcs_fire_cb("c+"))),
            lex("t", "field", "id", "rcscx", "params", lex("t", "0", "a", "center", "h", 38, "w", 53)),
            lex("t", "field", "id", "rcscy", "params", lex("t", "0", "a", "center", "h", 38, "w", 54)),
            lex("t", "field", "id", "rcscz", "params", lex("t", "0", "a", "center", "h", 38, "w", 53)),
            lex("t", "button", "id", "rcscm", "params", lex("t", "-", "h", 40, "w", 80, "tg", true, "ot", rcs_fire_cb("c-")))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Fore", "a", "right")),
            lex("t", "label", "params", lex("t", "Up", "a", "center")),
            lex("t", "label", "params", lex("t", "Right"))
        ))
    ))
)).

function btype_check_cb {
    if (wid:btype_check:text = "Button type: Press") {
        set wid:btype_check:text to "Button type: Toggle".
    } else {
        set wid:btype_check:text to "Button type: Press".
    }
}

function engaged_check_cb {
    if (wid:engaged_check:text = "Engaged: True") {
        set wid:engaged_check:text to "Engaged: False".
    } else {
        set wid:engaged_check:text to "Engaged: True".
    }
}

function rcs_throttle_cb {
    parameter p.
    return { set wid:rcs_throttle:text to format_float(clamp(wid:rcs_throttle:text:tonumber(0) + (increment * (choose 1 if (p = "+") else -1)), 0, 1), 1). }.
}

function rcs_fire_cb {
    parameter p.
    if (p[0] = "c") {
        return {
            parameter t.
            if (wid:engaged_check:text = "Engaged: False") { return. }
            local f to wid:rcs_throttle:text:tonumber(0).
            local x to wid:rcscx:text:tonumber(0).
            local y to wid:rcscy:text:tonumber(0).
            local z to wid:rcscz:text:tonumber(0).
            rcs_dir_cb[p](btoi(t)*f*v(x,y,z):normalized).
        }.
    }
    return {
        parameter t.
        if (wid:engaged_check:text = "Engaged: False") { return. }
        local f to wid:rcs_throttle:text:tonumber(0).
        rcs_dir_cb[p](btoi(t)*f).
    }.
}
