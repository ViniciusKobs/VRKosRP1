parameter widgets, env, wid, wcl, mlog.

local events to list("id: eta - type", "id2: eta2 - type2").
local event_types to list("Stage", "Range", "Callback", "Shutdown").

set widgets:events to lex("t", "hlayout", "id", "events", "params", lex("v", false, "p", recn(5)), "child", list(
    lex("t", "vlayout", "params", lex("m", recnn(0,5,0,0), "w", 400), "child", list(
        lex("t", "vbox", "params", lex("p", recn(5), "m", recnn(0,0,5,0)), "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Current Events")),
                lex("t", "popup", "params", lex("t", events[0], "op", events))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "ID")),
                lex("t", "field", "params", lex("t", "")),
                lex("t", "label", "params", lex("t", "ETA")),
                lex("t", "field", "params", lex("t", ""))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "button", "params", lex("t", "Edit")),
                lex("t", "button", "params", lex("t", "Remove"))
            ))
        )),
        lex("t", "vbox", "params", lex("p", recn(5)), "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Event type")),
                lex("t", "popup", "params", lex("t", event_types[0], "op", event_types, "och", event_types_cb@)),
                lex("t", "label", "params", lex("t", "Event ETA")),
                lex("t", "field", "params", lex("t", ""))
            )),
            lex("t", "vlayout", "id", "cbbox", "params", lex("v", false), "child", list(
                lex("t", "hlayout", "child", list(
                    lex("t", "label", "params", lex("t", "Usercbs path")),
                    lex("t", "field", "params", lex("t", ""))
                )),
                lex("t", "hlayout", "child", list(
                    lex("t", "label", "params", lex("t", "Callback name")),
                    lex("t", "field", "params", lex("t", ""))
                ))
            ))
        ))
    )),
    lex("t", "vlayout", "child", list(
        lex("t", "button", "params", lex("t", "Install handler")), // TODO: make this button only appear if handler is not installed
        lex("t", "button", "params", lex("t", "Add event")),
        lex("t", "button", "params", lex("t", "Execute event"))
    ))
)).

function event_types_cb {
    parameter t.
    if (t = "Callback") {
        set wid:cbbox:visible to true.
    } else {
        set wid:cbbox:visible to false.
    }
}