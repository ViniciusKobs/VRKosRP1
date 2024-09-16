parameter widgets, env, wid, wcl, mlog.

local events to list("id: eta - type", "id2: eta2 - type2").
local event_types to list("Stage", "Range", "Callback", "Shutdown").

local stage_command to "set RAX to {parameter _d. stage. return true.}.".
local range_command to "set RAX to {parameter _d. if (core:part:hasmodule("+char(34)+"modulerangesafety"+char(34)+")) {core:part:getmodule("+char(34)+"modulerangesafety"+char(34)+"):doaction("+char(34)+"range safety"+char(34)+", true). return true.}".

set widgets:other to lex("t", "vlayout", "id", "other", "params", lex("m", recnn(0,5,0,0), "w", 400), "child", list(
    lex("t", "vbox", "params", lex("p", recn(5), "m", recnn(0,0,5,0)), "child", list(
        lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
            lex("t", "label", "params", lex("t", "Current Events")),
            lex("t", "popup", "params", lex("t", events[0], "h", 18, "w", 193, "op", events))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "button", "params", lex("t", "Edit", "h", 18, "w", 192, "m", recnn(0,5,0,0))),
            lex("t", "button", "params", lex("t", "Remove", "h", 18, "w", 193))
        ))
    )),
    lex("t", "vbox", "params", lex("p", recn(5)), "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Event type", "w", 96)),
            lex("t", "popup", "params", lex("t", event_types[0], "m", recnn(0,5,0,0), "w", 96, "op", event_types, "och", event_types_cb@)),
            lex("t", "label", "params", lex("t", "Event ETA", "w", 96)),
            lex("t", "field", "params", lex("t", "", "p", recn(5,0), "w", 96))
        )),
        lex("t", "vlayout", "id", "cbbox", "params", lex("v", false), "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Usercbs path")),
                lex("t", "field", "params", lex("t", "", "p", recn(5,0)))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Callback name")),
                lex("t", "field", "params", lex("t", "", "p", recn(5,0)))
            ))
        ))
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
