@lazyglobal off.

parameter env.

// operators callbacks
local OP_CBS to lex(
    "<", {parameter a, b. return a < b.  },
    ">", {parameter a, b. return a > b.  },
    "=", {parameter a, b. return a = b.  },
    "*", {parameter a, b. return a and b.},
    "+", {parameter a, b. return a or b. }
).

// trigger callbacks
local T_CBS to lex(
    "alt",  { return ship:altitude.             },
    "ap",   { return ship:apoapsis.             },
    "svel", { return ship:velocity:surface:mag. },
    "ovel", { return ship:velocity:orbit:mag.   },
    "t",    { return GET_LAUNCH_TIME().         },
    "f",    { return maxthrust.                 },
    "q",    { return ship:q.                    },
    "stg",  { return ship:stagenum.             },
    // special triggers
    "id", {
        parameter op, val.
        local splt to val:split(",").
        return done_events:haskey(splt[0]) and OP_CBS[op:replace("=", ">")](GET_LAUNCH_TIME(), done_events[splt[0]] + splt[1]:tonumber(0)).
    }
).

// action callbacks
local A_CBS to lex(
    "stage",     { parameter _p. stage. },
    "abort",     { parameter _p. abort on. },
    "disengage", { parameter _p. set env:should_exit to true. },
    "lock",      { parameter _p. lock steering to ship:facing. },
    "unlock",    { parameter _p. unlock steering. },
    "guide",     { parameter _p. lock steering to heading(guidance:yaw, 90 - guidance:pitch, guidance:roll). },
    "throttle",  { parameter p. set ship:control:pilotmainthrottle to p. },
    "range",     { parameter _p. terminate_flight(). },
    "wait",      { parameter p. wait p:tonumber(0). },
    "cb",        { parameter p. if ((defined usercbs) and usercbs:haskey(p)) {usercbs[p](env).} }
).

local ENABLED to env:launch_params:enabled.
local PITCH_PROGRAM_ENTRY to env:launch_params:pitch_program_entry.
local PITCH_PROGRAM to env:launch_params:pitch_program.
local AZIMUTH to env:launch_params:azimuth.
local EVENTS_STR to env:launch_params:events.
function SET_LAUNCH_TIME { parameter t. set env:launch_params:time to t. }.
function GET_LAUNCH_TIME { return env:launch_params:time. }.

local guidance to lex(
    "pitch", 0,
    "yaw", 90 - AZIMUTH,
    "roll", -90
).
local mlog to list().
// TODO: filter out invalid events
local events to map(EVENTS_STR, {parameter e. return parse_event(e).}).
local done_events to lex().

function launch {
    if (ENABLED) { lock steering to heading(guidance:yaw, 90 - guidance:pitch, guidance:roll). }
    local t0 to time:seconds.
    until (env:should_exit) {
        local uptime to time:seconds - t0. SET_LAUNCH_TIME(uptime).

        local msg to (
            "GUIDANCE CONTROL INITIATED" + char(10) + " " + char(10) +
            "UPTIME: " + floor(uptime, 2) + char(10) + " " + char(10) +
            //(map(events,{parameter e. return format_list_il(e).}):join(char(10))) + char(10) + " " + char(10) +
            //format_list_il(done_events:keys) + char(10) + " " + char(10) +
            mlog:join(char(10))
        ). clearscreen. print(msg).

        handle_events().
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

function handle_events {
    local done to list().

    from {local i to 0.} until (i >= events:length) step {set i to i + 1.} do {
        local e to events[i].

        local ts to e[1][0]. 
        local tsops to e[1][1]. 

        local acc to check_trigger(ts[0]).
        from {local j to 1.} until (j > ts:length - 1) step {set j to j + 1.} do {
            set acc to OP_CBS[tsops[j-1]](acc, check_trigger(ts[j])).
        }

        if (acc) {
            local as to e[2].
            for a in as { mlog:add("executing action: " + a[0]). A_CBS[a[0]](a[1]). }
            set e[3] to e[3] - 1.
            if (e[3] <= 0) { done:add(i). }
            if (e[4] <> "") {
                local ids to e[4]:split(",").
                for id in ids {
                    local index to event_index(id).
                    if (index >= 0) { done:add(index). }
                }
            }
        }
    }

    for i in sort(done, {parameter a, b. return a<b.}) {
        set done_events[events[i][0]] to GET_LAUNCH_TIME().
        events:remove(i).
    }
}

function check_trigger {
    parameter t.
    if (t[0] = "id") { return T_CBS[t[0]](t[1],t[2]). }
    return OP_CBS[t[1]](T_CBS[t[0]](), t[2]:tonumber(0)).
}

function event_index {
    parameter id.
    from {local i to 0.} until (i >= events:length) step {set i to i + 1.} do {
        if (events[i][0] = id) { return i. }
    }
    return -1.
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
        esplit[3]:tonumber(0),
        choose "" if esplit:length = 4 else esplit[4]
    ).
}


function trigger_struct {
    parameter tstr.

    local triggers to list(list(), list()).

    for t in tstr:replace("+","*"):split("*") {
        local tsplit to t:split(":").
        local has_op to (tsplit[1][0] = "<" or tsplit[1][0] = ">" or tsplit[1][0] = "=").
        triggers[0]:add(list(
            tsplit[0],
            choose tsplit[1][0] if has_op else "=",
            choose tsplit[1]:substring(1, tsplit[1]:length - 1) if has_op else tsplit[1]
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