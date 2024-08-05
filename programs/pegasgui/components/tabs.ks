parameter widgets, env, wid, wcl, mlog.

set widgets:tabs to lex("t", "hlayout", "id", "tabs", "params", lex("p", recn(5,0)), "child", list(
    lex("t", "button", "params", lex("t", "Mission", "oc", mission_cb@, "h", 22, "m", recnn(0,5,0,0))),
    lex("t", "button", "params", lex("t", "Tools", "oc", tools_cb@, "h", 22))
)).

function mission_cb {
    set wid:mission:visible to true.
    set wid:tools:visible to false.
}

function tools_cb {
    set wid:mission:visible to false.
    set wid:tools:visible to true.
}