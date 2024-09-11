parameter widgets, env, wid, wcl, mlog.

set widgets:tabs to lex("t", "hlayout", "id", "tabs", "params", lex("p", recn(5,0)), "child", list(
    lex("t", "button", "params", lex("t", "Events", "oc", events_cb@, "h", 22, "m", recnn(0,5,0,0))),
    lex("t", "button", "params", lex("t", "RCS", "oc", rcs_cb@, "h", 22, "m", recnn(0,5,0,0))),
    lex("t", "button", "params", lex("t", "Tools", "e", false, "oc", tools_cb@, "h", 22))
)).

function events_cb {
    set wid:events:visible to true.
    set wid:rcs:visible to false.
    //set wid:tools:visible to false.
}

function rcs_cb {
    set wid:events:visible to false.
    set wid:rcs:visible to true.
   //set wid:tools:visible to false.
}

function tools_cb {
    set wid:events:visible to false.
    set wid:rcs:visible to false.
    //set wid:tools:visible to true.
}