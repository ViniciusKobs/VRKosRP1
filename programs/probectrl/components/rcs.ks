parameter widgets, env, wid, wcl, mlog.

set widgets:rcs to lex("t", "hlayout", "id", "rcs", "params", lex("v", false, "p", recn(5)), "child", list(
    lex("t", "vlayout", "params", lex("w", 165, "m", recnn(0,5,0,0)), "child", list(
        lex("t", "label", "params", lex("t", "Throttle", "h", 20, "m", recnn(0,0,5,0))),
        lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
            lex("t", "button", "params", lex("t", "+", "h", 20, "m", recnn(0,5,0,0))),
            lex("t", "field", "params", lex("t", "1.0", "h", 18, "p", recnn(1,0,0,0), "m", recnn(0,5,0,0))),
            lex("t", "button", "params", lex("t", "-", "h", 20))
        )),
        lex("t", "button", "id", "btype_check", "params", lex("t", "Button type: Press", "m", recnn(0,0,5,0), "h", 20, "oc", btype_check_cb@)),
        lex("t", "button", "id", "engaged_check", "params", lex("t", "Engaged: True", "h", 20, "oc", engaged_check_cb@))
    )),
    lex("t", "vlayout", "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "button", "params", lex("t", "Fore", "h", 40, "w", 80)),
            lex("t", "button", "params", lex("t", "", "e", false, "h", 40, "w", 80)),
            lex("t", "button", "params", lex("t", "Up", "h", 40, "w", 80)),
            lex("t", "button", "params", lex("t", "", "e", false, "h", 40, "w", 80))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "button", "params", lex("t", "Back", "h", 40, "w", 80)),
            lex("t", "button", "params", lex("t", "Left", "h", 40, "w", 80)),
            lex("t", "button", "params", lex("t", "Down", "h", 40, "w", 80)),
            lex("t", "button", "params", lex("t", "Right", "h", 40, "w", 80))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "button", "params", lex("t", "-", "h", 40, "w", 80)),
            lex("t", "field", "params", lex("t", "0", "a", "center", "h", 38, "w", 53)),
            lex("t", "field", "params", lex("t", "0", "a", "center", "h", 38, "w", 54)),
            lex("t", "field", "params", lex("t", "0", "a", "center", "h", 38, "w", 53)),
            lex("t", "button", "params", lex("t", "+", "h", 40, "w", 80))
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