parameter widgets, env, wid, wcl, mlog.

set widgets:tabs to lex("t", "hlayout", "params", lex("p", recn(5,0)), "child", list(
    lex("t", "button", "params", lex("t", "mission", "oc", mission_cb@, "h", 20, "m", recnn(0,5,0,0))),
    lex("t", "button", "params", lex("t", "tools", "oc", tools_cb@, "h", 20))
)).

function mission_cb {
    set wid:mission:visible to true.
    set wid:tools:visible to false.
}

function tools_cb {
    set wid:mission:visible to false.
    set wid:tools:visible to true.
}