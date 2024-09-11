parameter widgets, env, wid, wcl, mlog.

local EVENTS_PATH to "1:evs/".
local TEMP_PATH to "0:disk/tmp/".

local events_widgets to lex().
runpath("0:/programs/probectrl/components/other", events_widgets, env, wid, wcl, mlog).
runpath("0:/programs/probectrl/components/attitude", events_widgets, env, wid, wcl, mlog).
runpath("0:/programs/probectrl/components/maneuver", events_widgets, env, wid, wcl, mlog).

set widgets:events to lex("t", "hlayout", "id", "events", "params", lex("p", recn(5)), "child", list(
    lex("t", "vlayout", "params", lex("m", recnn(0,5,0,0), "w", 400), "child", list(
        lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
            lex("t", "button", "params", lex("t", "Other", "h", 20, "m", recnn(0,5,0,0), "oc", event_tab_switch("other"))),
            lex("t", "button", "params", lex("t", "Attitude", "h", 20, "m", recnn(0,5,0,0), "oc", event_tab_switch("attitude"))),
            lex("t", "button", "params", lex("t", "Maneuver", "h", 20, "oc", event_tab_switch("maneuver")))
        )),
        lex("t", "vbox", "params", lex("p", recn(5), "m", recnn(0,0,5,0)), "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Event UT", "w", 96)),
                lex("t", "field", "id", "atteventut", "params", lex("t", "", "p", recn(5,0), "w", 98, "m", recnn(0,5,0,0))),
                lex("t", "label", "params", lex("t", "Event ID", "w", 96)),
                lex("t", "field", "id", "atteventid", "params", lex("t", "", "p", recn(5,0), "w", 95))
            ))
        )),
        events_widgets:other,
        events_widgets:attitude,
        events_widgets:maneuver
    )),
    lex("t", "vlayout", "params", lex("m", recnn(0,5,0,0)), "child", list(
        lex("t", "button", "params", lex("t", "Install", "h", 20, "m", recnn(0,0,5,0))), // TODO: make this button only appear if handler is not installed
        lex("t", "button", "params", lex("t", "Add event", "h", 20, "m", recnn(0,0,5,0), "oc", add_event_cb@)),
        lex("t", "button", "params", lex("t", "Exec event", "h", 20, "m", recnn(0,0,5,0)))
    ))
)).

function add_event {
    parameter id, ut, code, _local is true, _time is time:seconds:tostring.
    if (is_datetime(ut)) {
        set ut to datetime_to_sec(ut).
    } else if (is_eta(ut)) {
        set ut to time:seconds + eta_to_sec(ut).
    } else {
        set ut to time:seconds + ut:tonumber(0).
    }

    if (id = "") { 
        mlog:add("Event ID is empty!").
        return.
    }

    write_lf(list(ut, code), choose EVENTS_PATH+id if _local else TEMP_PATH+_time).
    mlog:add("Event added: " + id).
}

function add_event_cb {
    if (wid:other:visible) {
        // implement
    } else if (wid:attitude:visible) {
        local id to wid:atteventid:text.
        local ut to wid:atteventut:text.
        add_event(id, ut, create_attitude_code()).
    } else if (wid:maneuver:visible) {
        local id to wid:maneventid:text.
        local ut to wid:maneventut:text.
        add_event(id, ut, create_maneuver_code()).
    }
}

function execute_event_cb {
    local _time to time:seconds:tostring.

    if (wid:other:visible) {
        // implement
    } else if (wid:attitude:visible) {
        local id to wid:atteventid:text.
        local ut to wid:atteventut:text.
        add_event(id, ut, create_attitude_code(), false, _time).
        print("Executing event: " + id).
        runpath(TEMP_PATH+_time).
    } else if (wid:maneuver:visible) {
        local id to wid:maneventid:text.
        local ut to wid:maneventut:text.
        add_event(id, ut, create_maneuver_code(), false, _time).
        print("Executing event: " + id).
        runpath(TEMP_PATH+_time).
    }
    
    print("Deleting Event: " + id).
    deletepath(TEMP_PATH+_time).
}

function event_tab_switch {
    parameter tab.
    return {
        set wid:other:visible to tab = "other".
        set wid:attitude:visible to tab = "attitude".
        set wid:maneuver:visible to tab = "maneuver".
    }.
}