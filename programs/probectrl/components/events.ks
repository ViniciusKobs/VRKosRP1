parameter widgets, env, wid, wcl, mlog.

local EVENTS_PATH to "1:evs/".
local HANDLER_PATH to "0:programs/probectrl/handler".
local LOCAL_HANDLER_PATH to "1:handler".
local REFACTOR_PATH to "0:scripts/refactor".

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
                lex("t", "field", "id", "eventut", "params", lex("t", "", "p", recn(5,0), "w", 98, "m", recnn(0,5,0,0))),
                lex("t", "label", "params", lex("t", "Event ID", "w", 96)),
                lex("t", "field", "id", "eventid", "params", lex("t", "", "p", recn(5,0), "w", 95))
            ))
        )),
        events_widgets:other,
        events_widgets:attitude,
        events_widgets:maneuver
    )),
    lex("t", "vlayout", "params", lex("m", recnn(0,5,0,0)), "child", list(
        lex("t", "button", "params", lex("t", "Install", "h", 20, "m", recnn(0,0,5,0), "oc", install_cb@)), // TODO: make this button only appear if handler is not installed
        lex("t", "button", "params", lex("t", "Add event", "h", 20, "m", recnn(0,0,5,0), "oc", add_event_cb@)),
        lex("t", "button", "params", lex("t", "Exec event", "h", 20, "m", recnn(0,0,5,0), "oc", execute_event_cb@))
        // TODO: add button to clear current events
    ))
)).

function install_cb {
    if (exists(LOCAL_HANDLER_PATH)) {
        deletepath(LOCAL_HANDLER_PATH).
    }
    if (not exists(EVENTS_PATH)) {
        createdir(EVENTS_PATH).
    }
    runpath(REFACTOR_PATH, HANDLER_PATH, LOCAL_HANDLER_PATH).
    mlog:add("Handler installed").
}

function add_event {
    parameter id, ut, code.
    if (is_datetime(ut)) {
        set ut to datetime_to_sec(ut).
    } else if (is_eta(ut)) {
        set ut to time:seconds + eta_to_sec(ut).
    } else {
        set ut to time:seconds + ut:tonumber(0).
    }

    if (id = "") { 
        mlog:add("Event ID is empty!").
        return false.
    }

    write_lf(list(ut, code), EVENTS_PATH+id).
    mlog:add("Event added: " + id).
    return true.
}

function add_event_cb {
    local id to wid:eventid:text.
    local ut to wid:eventut:text.
    if (wid:other:visible) {
        // implement
    } else if (wid:attitude:visible) {
        add_event(id, ut, create_attitude_code()).
    } else if (wid:maneuver:visible) {
        add_event(id, ut, create_maneuver_code()).
    }
}

function execute_event_cb {
    local code to "".

    if (wid:other:visible) {
        return.
        // implement
    } else if (wid:attitude:visible) {
        set code to create_attitude_code().
    } else if (wid:maneuver:visible) {
        set code to create_maneuver_code().
    } else {
        return.
    }

    if (code = "") { return. }

    log code to "0:log/dc".

    print("Executing event"). mlog:add("Executing event").
    eval(code).
    local GDT to lex().
    until (RAX(GDT)) { wait 0. }
    mlog:add("Event executed").
}

function event_tab_switch {
    parameter tab.
    return {
        set wid:other:visible to tab = "other".
        set wid:attitude:visible to tab = "attitude".
        set wid:maneuver:visible to tab = "maneuver".
    }.
}