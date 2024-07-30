parameter w, env, wid, wcl, mlog.

set w:tab2 to lex("t", "vlayout", "id", "tab2", "params", lex("v", false, "p", recn(5)), "child", list(
    lex("t", "hlayout", "child", list(
        lex("t", "button", "params", lex("t", "switch")),
        lex("t", "button", "params", lex("t", "disengage")),
        lex("t", "button", "params", lex("t", "switch"))
    )),
    lex("t", "hlayout", "child", list(
        lex("t", "button", "params", lex("t", "switch")),
        lex("t", "button", "params", lex("t", "abort")),
        lex("t", "button", "params", lex("t", "switch"))
    )),
    lex("t", "hlayout", "child", list(
        lex("t", "button", "params", lex("t", "switch")),
        lex("t", "button", "params", lex("t", "switch")),
        lex("t", "button", "params", lex("t", "switch"))
    ))
)).
