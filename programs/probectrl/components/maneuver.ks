parameter widgets, env, wid, wcl, mlog.

local ullage_types to list("RCS", "Stage").

local cb_structure to "set RAX to {parameter data. ?code?}.".
local ullage_command to "if (data:?id?[4]) {?ullagetype? set data["+char(34)+"?id?"+char(34)+"][4] to false.}".
local ignition_command to "if (data:?id?[5] and nextnode:eta<=?spoolt?) {?disableullage? ?ignition? set data["+char(34)+"?id?"+char(34)+"][5] to false.} if (data:?id?[5]) {return false.}".

// if not ullage and not ignition = replace with nothing
// if only ullage = replace with ullage + ignition
// if only ignition = replace with ignition
// if both = replace with ullage + ignition
local maneuver_command to (
    "if hasnode and nextnode:eta>?eta? and (not data:haskey("+char(34)+"?id?"+char(34)+")) {return false.} "+
    "if not data:haskey("+char(34)+"?id?"+char(34)+") {set data:?id? to list(0,time:seconds,nextnode:deltav:mag,true,true).} "+

    "?ullageignitioncommand? " +

    "set ship:control:pilotmainthrottle to 1. " +
    "local t1 to time:seconds. " +
    "local dt to t1-data:?id?[1]. " +
    "local acc to (ship:thrust/ship:mass)*dt. " +
    "set data["+char(34)+"?id?"+char(34)+"][0] to data:?id?[0]+acc. " +
    "set data["+char(34)+"?id?"+char(34)+"][1] to t1. " +

    "if data:?id?[0]>=data:?id?[2] {" +
        "set ship:control:pilotmainthrottle to 0. " +
        "return true. " +
    "}"
).

local rcs_maneuver_command to (
    "if hasnode and nextnode:eta>0 and (not data:haskey("+char(34)+"?id?"+char(34)+")) {return false.} " +

    "if not data:haskey("+char(34)+"?id?"+char(34)+") {" +
        "set data:?id? to list(0,time:seconds,nextnode:deltav:mag,0,0). " +
        "for p in ship:rcs {" +
            "if p:enabled {" +
                "local fv to ship:facing:forevector:normalized. " +
                "for tv in p:thrustvectors {" +
                    "if round(tv:normalized*fv, 4)=-1 {" +
                        "set data["+char(34)+"?id?"+char(34)+"][3] to data:?id?[3]+p:availablethrust. " +
                        "break." +
                    "}" +
                "}" +
            "}" +
        "}" +
    "} " +

    "set ship:control:fore to 1. " +
    "local t1 to time:seconds. " +
    "local dt to t1-data:?id?[1]. " +
    "local acc to (data:?id?[3]/ship:mass)*dt. " +
    "set data["+char(34)+"?id?"+char(34)+"][0] to data:?id?[0]+acc. " +
    "set data["+char(34)+"?id?"+char(34)+"][1] to t1. " +

    "if data:?id?[0]>=data:?id?[2] {" +
        "set ship:control:fore to 0. " +
        "return true." +
    "}"
).

set widgets:maneuver to lex("t", "vbox", "id", "maneuver", "params", lex("v", false, "p", recn(5), "m", recnn(0,5,0,0), "w", 400), "child", list(
    lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
        lex("t", "button", "id", "thrust_check", "params", lex("t", "Thrust: Engine", "m", recnn(0,5,0,0), "h", 18, "w", 127, "oc", thrust_check_cb@)),
        lex("t", "button", "id", "ullage_check", "params", lex("t", "Ullage: True", "m", recnn(0,5,0,0), "h", 18, "w", 126, "oc", enabled_check_cb("ullage_check", "ullagebox", "Ullage: "))),
        lex("t", "button", "id", "ignition_check", "params", lex("t", "Ignition: True", "h", 18, "w", 127, "oc", check_cb("ignition_check", "Ignition: ")))
    )),
    lex("t", "hlayout", "id", "ullagebox", "params", lex("m", recnn(0,0,5,0)), "child", list(
        lex("t", "label", "params", lex("t", "Ullage time(s)", "w", 96)),
        lex("t", "field", "id", "ullage_time", "params", lex("t", "5", "p", recn(5,0), "w", 96, "m", recnn(0,5,0,0))),
        lex("t", "label", "params", lex("t", "Ullage type", "w", 96)),
        lex("t", "popup", "id", "ullage_type", "params", lex("t", ullage_types[0], "h", 18, "w", 97, "op", ullage_types))
    )),
    lex("t", "hlayout", "id", "spoolbox", "child", list(
        lex("t", "label", "params", lex("t", "Spool-up time(s)")),
        lex("t", "field", "id", "spool_time", "params", lex("t", "0", "p", recn(5,0), "w", 193))
    ))
)).

function thrust_check_cb {
    if (wid:thrust_check:text = "Thrust: Engine") {
        set wid:thrust_check:text to "Thrust: RCS".
        set wid:ullagebox:enabled to false.
        set wid:spoolbox:enabled to false.
        set wid:ullage_check:enabled to false.
        set wid:ignition_check:enabled to false.
    } else {
        set wid:thrust_check:text to "Thrust: Engine".
        set wid:ullagebox:enabled to true.
        set wid:spoolbox:enabled to true.
        set wid:ullage_check:enabled to true.
        set wid:ignition_check:enabled to true.
    }
}

// DIDN'T TESTED ALL BRANCHES OF THIS FUNCTION
// GONNA FIND OUT IF IT WORKS WHEN I USE IT
function create_maneuver_code {
    local id to wid:eventid:text.    

    if (id = "") {
        mlog:add("Event ID is empty!").
        return "".
    }

    local use_rcs to wid:thrust_check:text = "Thrust: RCS".
    if (use_rcs) {
        return cb_structure:replace("?code?", rcs_maneuver_command:replace("?id?", id)).
    }

    local ullage to wid:ullage_check:text = "Ullage: True".
    local rcs_ullage to wid:ullage_type:text = "RCS".
    local ullage_time to choose wid:ullage_time:text:tonumber(0) if ullage else 0.
    local ignition to wid:ignition_check:text = "Ignition: True".
    local spool_time to wid:spool_time:text:tonumber(0).

    local ullage_ignition_command to "".
    if (ignition and (not ullage)) {
        set ullage_ignition_command to ignition_command
        :replace("?spoolt?", spool_time:tostring)
        :replace("?ignition?", "stage.")
        :replace("?disableullage?", "").
    } else if (ullage) {
        set ullage_ignition_command to (ullage_command + " " + ignition_command)
        :replace("?ullagetype?", choose "set ship:control:fore to 1." if rcs_ullage else "stage.")
        :replace("?spoolt?", spool_time:tostring)
        :replace("?ignition?", choose "stage." if ignition else "")
        :replace("?disableullage?", choose "set ship:control:fore to 0." if rcs_ullage else "").
    }

    return cb_structure:replace("?code?", maneuver_command
        :replace("?eta?", (ullage_time+spool_time):tostring)
        :replace("?ullageignitioncommand?", ullage_ignition_command)
        :replace("?id?", id)
    ).
}