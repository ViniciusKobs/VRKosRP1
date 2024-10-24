parameter widgets, env, wid, wcl, mlog.

local event_types to list("Stage", "Range").
//local event_types to list("Stage", "Range", "File").
//local includes to list("1:/cbs/", "1:/", "0:/disk/probectrl/cbs/").

local cb_structure to "set RAX to {parameter data. ?code?}.".
local stage_command to "stage. return true.".
local range_command to "if (core:part:hasmodule("+char(34)+"modulerangesafety"+char(34)+")) {core:part:getmodule("+char(34)+"modulerangesafety"+char(34)+"):doaction("+char(34)+"range safety"+char(34)+", true).}".

set widgets:other to lex("t", "vlayout", "id", "other", "params", lex("m", recnn(0,5,0,0), "w", 400), "child", list(
    lex("t", "vbox", "params", lex("p", recn(5)), "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Event type", "w", 96)),
            lex("t", "popup", "id", "othertype", "params", lex("t", event_types[0], "m", recnn(0,5,0,0), "w", 96, "op", event_types, "och", event_types_cb@)),
            lex("t", "label", "params", lex("t", "Parameter", "w", 96)),
            lex("t", "field", "id", "otherparam", "params", lex("t", "", "p", recn(5,0), "w", 96))
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

function create_other_code {
    if (wid:othertype:text = "Stage") { return cb_structure:replace("?code?", stage_command). }
    if (wid:othertype:text = "Range") { return cb_structure:replace("?code?", range_command). }

    // NOT TESTED, TOO MUCH PREGUIÇA
    // GONNA TEST IT WHEN I NEED IT
    //if (wid:othertype:text = "Callback") { 
        //local _path to wid:otherparam:text.
        //if (_path = "") {
            //mlog:add("Other param is empty!").
            //return "".
        //}
        //for i in includes {
            //if (exists(i + path)) {
                //set _path to i + _path.
                //break.
            //}
        //}
        //return cb_structure:replace("?code?", read_sf(wid:otherparam:text)).
    //}

    return "".
}