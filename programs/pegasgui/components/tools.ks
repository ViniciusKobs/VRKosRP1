parameter widgets, env, wid, wcl, mlog.

set widgets:tools to lex("t", "hlayout", "id", "tools", "params", lex("p", recn(5), "v", false), "child", list(
    lex("t", "label", "params", lex("t", "tools"))
)).
