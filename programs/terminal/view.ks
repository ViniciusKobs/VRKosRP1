@lazyglobal off.

parameter env, wid, wcl, mlog.

runoncepath("0:/libs/gui").
runoncepath("0:/libs/util").

local widgets to lex().
runpath("0:/programs/terminal/components/titlebar", widgets, env, wid, wcl, mlog).
runpath("0:/programs/terminal/components/cmdline", widgets, env, wid, wcl, mlog).

create_element(wid, wcl, list(), lex(
    "t", "gui",
    "id", "window",
    "params", lex("w", 700),
    "child", list(
        widgets:titlebar,
        lex("t", "vlayout", "id", "content", "params", lex("p", recn(5)), "child", list(
            widgets:cmdline
        ))
    )
)).