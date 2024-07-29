@lazyglobal off.

parameter env, wid, wcl, mlog.

runoncepath("0:/libs/gui").
runoncepath("0:/programs/bootmgr/components/generic").

local widgets to lex().
runpath("0:/programs/bootmgr/components/titlebar", widgets, env, wid, wcl, mlog).
runpath("0:/programs/bootmgr/components/tab1", widgets, env, wid, wcl, mlog).

create_element(wid, wcl, list(), lex(
    "t", "gui",
    "id", "window",
    "params", lex("w", 500),
    "child", list(
        widgets:titlebar,
        lex("t", "vlayout", "id", "cont", "child", list(
            widgets:tab1
        ))
    )
)).