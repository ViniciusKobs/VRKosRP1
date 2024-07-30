@lazyglobal off.

parameter env.

// triggers: alt - altitude, ap - apoapsis, sv - surface velocity, ov - orbital velocity, t - time from launch, f - thrust, q - dynamic pressure(Q), id - time from event with id activated 
// triggers operators: <, >, =, *, +
// actions: stage, abort, disengage, range, cb: - callback, throttle:, lock:, debug:
// actions operators: *

//local event to "0; alt:>500 * svel<1000; debug:hello * throttle:.5; 2".
//local eventstrut to list(
    //"0",
    //list(
        //list(
            //list("alt", ">", "500"),
            //list("svel", "<", "1000")
        //),
        //list("*")
    //),
    //list(
        //list("debug", "hello"),
        //list("throttle", ".5")
    //),
    //2
//).

local OP_CBS to lex(
    "<", {parameter a, b. return a < b.  },
    ">", {parameter a, b. return a > b.  },
    "=", {parameter a, b. return a = b.  },
    "*", {parameter a, b. return a and b.},
    "+", {parameter a, b. return a or b. }
).

local T_CBS to lex(
    "alt",  { return ship:altitude.             },
    "ap",   { return ship:apoapsis.             },
    "svel", { return ship:velocity:surface:mag. },
    "ovel", { return ship:velocity:orbit:mag.   },
    "t",    { return time:seconds.              },
    "f",    { return ship:availablethrust.      },
    "q",    { return ship:q.                    }
    // "id", { // not decided how to implement yet }
).

local A_CBS to lex(
    "stage",     { parameter _p. stage.                       },
    "abort",     { parameter _p. abort.                       },
    "disengage", { parameter _p. set env:should_exit to true. },
    //"range",   { flight_termination() },
    //"cb",      { // run user callbacks },
    "throttle",  { parameter p. set guidance:throttle to p.   },
    //"lock",    { parameter p. // not decided what this will do yet },
    "debug",     { parameter p. mlog:add(p).                  }
).

local ENABLED to env:launch_params:enabled.
local PITCH_PROGRAM_ENTRY to env:launch_params:pitch_program_entry.
local PITCH_PROGRAM to env:launch_params:pitch_program.
local AZIMUTH to env:launch_params:azimuth.

local guidance to lex(
    "pitch", 0,
    "yaw", 90 - AZIMUTH,
    "roll", -90,
    "throttle", 0
).
local mlog to list().

local testevent to "0;alt:>750*svel:<200;debug:hello*stage;2".

local events to list().
local done_events to list().

function launch {
    if (ENABLED) { lock steering to heading(guidance:yaw, 90 - guidance:pitch, guidance:roll). }
    local t0 to time:seconds.
    until env:should_exit {
        local uptime to time:seconds - t0.

        // TODO: replace with "report_info()" function
        clearscreen. print(
            "GUIDANCE CONTROL INITIATED" + char(10) + " " + char(10) +
            "UPTIME: " + floor(uptime, 2) + char(10) + " " + char(10) +
            mlog:join(char(10))
        ).

        update_pitch().
        wait 0.
    }
}

function update_pitch {
    local entry to choose altitude if (PITCH_PROGRAM_ENTRY = 0) else apoapsis.

    local i to 0.
    local j to 1.

    until (j >= PITCH_PROGRAM[1]:length - 1) {
        if (entry < PITCH_PROGRAM[1][j]) { break. }
        set i to i + 1.
        set j to j + 1.
    }

    local x1 to PITCH_PROGRAM[1][i].
    local x2 to PITCH_PROGRAM[1][j].
    local y1 to PITCH_PROGRAM[0][i].
    local y2 to PITCH_PROGRAM[0][j].

    local m to (y1 - y2)/(x1 - x2).

    set guidance:pitch to (m*(entry - x1)) + y1.
}

// FUNCTION NOT TESTED YET
function handle_events {
    local done to list().

    from {local i to 0.} until (i >= events:length) step {set i to i + 1.} do {
        local e to events[i].

        local ts to e[1][1]. 
        local tsops to e[1][2]. 

        local acc to check_trigger(ts[0]).
        from {local j to 1.} until (j >= ts:length - 1) step {set j to j + 1.} do {
            set acc to OP_CBS[tsops[j-1]](acc, check_trigger(ts[j])).
        }

        if (acc) {
            local as to e[2].
            for a in as { A_CBS[a[0]](a[1]). }
            set e[3] to e[3] - 1.
            if (e[3] = 0) { done:add(i). }
        }
    }

    from {local i to done:length - 1.} until (i < done:length) step {set i to i - 1.} do {
        set done_events to done_events:add(events[done[i]]).
        set events to events:remove(done[i]).
    }
}

function check_trigger {
    parameter t.
    return OP_CBS[t[1]](T_CBS[t[0]](), t[2]:tonumber(0)).
}

function parse_event {
    parameter estr.
    local esplit to estr:split(";").
    local triggers to trigger_struct(esplit[1]).
    local actions to action_struct(esplit[2]).
    return list(
        esplit[0],
        triggers,
        actions,
        esplit[3]:tonumber(0)
    ).
}

function trigger_struct {
    parameter tstr.

    local triggers to list(list(), list()).

    for t in tstr:replace("+","*"):split("*") {
        local tsplit to t:split(":").
        triggers[0]:add(list(
            tsplit[0],
            choose tsplit[1][0] if (tsplit[1][0] = "<" or tsplit[1][0] = ">") else "=",
            choose tsplit[1] if (tsplit[1][0]:tonumber(-1) >= 0) else tsplit[1]:substring(1, tsplit[1]:length - 1)
        )).
    }

    for c in tstr {
        if (c = "*") { triggers[1]:add("*"). }
        else if (c = "+") { triggers[1]:add("+"). }
    }

    return triggers.
}

function action_struct {
    parameter astr.

    local actions to list().

    for a in astr:split("*") {
        local asplit to a:split(":").
        actions:add(list(asplit[0], choose "" if asplit:length = 1 else asplit[1])).
    }

    return actions.
}

launch().