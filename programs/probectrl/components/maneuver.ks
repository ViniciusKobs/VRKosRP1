parameter widgets, env, wid, wcl, mlog.

local targets to list("Self", "Surface", "Orbit", "Target", "Absolute", "Body").
local self_vecs to list("Fore", "Up", "Right").
local ullage_types to list("RCS", "Stage", "None").
local ignition_types to list("Throttle", "Stage", "Stage and Throttle", "RCS Fore").

set widgets:maneuver to lex("t", "hlayout", "id", "maneuver", "params", lex("v", false, "p", recn(5)), "child", list(
    lex("t", "vbox", "params", lex("p", recn(5), "m", recnn(0,5,0,0), "w", 400), "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Event ETA")),
            lex("t", "field", "params", lex("t", "")),
            lex("t", "label", "params", lex("t", "Event ID")),
            lex("t", "field", "params", lex("t", ""))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "button", "id", "skip_check", "params", lex("t", "Reorientation: True", "oc", enabled_check_cb("skip_check", "skipbox", "Reorientation: "))),
            lex("t", "button", "id", "ullage_check", "params", lex("t", "Ullage: True", "oc", enabled_check_cb("ullage_check", "ullagebox", "Ullage: "))),
            lex("t", "button", "id", "ignition_check", "params", lex("t", "Ignition: True", "oc", enabled_check_cb("ignition_check", "ignitionbox", "Ignition: ")))
        )),
        lex("t", "vlayout", "id", "skipbox", "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Reorientation time(s)")),
                lex("t", "field", "params", lex("t", "60"))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Up Vector")),
                lex("t", "button", "id", "mnvupdir", "params", lex("t", "+", "oc", check_cb("mnvupdir", list("+", "-")))),
                lex("t", "button", "id", "mnvuptype", "params", lex("t", "lock", "oc", check_cb("mnvuptype", list("lock", "set")))),
                lex("t", "popup", "params", lex("t", targets[0], "op", targets, "w", 110, "och", targets_cb("mnvupvecs"))),
                lex("t", "popup", "id", "mnvupvecs", "params", lex("t", self_vecs[1], "op", self_vecs, "w", 110))
            ))
        )),
        lex("t", "hlayout", "id", "ullagebox", "child", list(
            lex("t", "label", "params", lex("t", "Ullage time(s)")),
            lex("t", "field", "params", lex("t", "5")),
            lex("t", "label", "params", lex("t", "Ullage type")),
            lex("t", "popup", "params", lex("t", ullage_types[0], "op", ullage_types))
        )),
        lex("t", "hlayout", "id", "ignitionbox", "child", list(
            lex("t", "label", "params", lex("t", "Ignition type")),
            lex("t", "popup", "params", lex("t", ignition_types[0], "op", ignition_types))
        ))
    )),
    lex("t", "vlayout", "child", list(
        lex("t", "button", "params", lex("t", "Execute")),
        lex("t", "button", "params", lex("t", "Add event"))
    ))
)).