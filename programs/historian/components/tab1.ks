parameter w, env, wid, wcl, mlog.

local FILE_PATH to "0:/programs/historian/file".
local modes to list("Mode: New", "Mode: Modify", "Mode: Delete").
local lstatus to list("in progress", "success", "failure", "pad failure").

set w:tab1 to lex(
    "t", "hlayout",
    "id", "tab1",
    "params", lex(
        "v", true,
        "p", recn(5)
    ),
    "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "vbox", "params", lex("w", 380, "p", recn(5), "m", recnn(0, 5, 0, 0)), "child", list(
            // ----- 1st column -----
                lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                    lex("t", "label", "params", lex("t", "File")),
                    lex("t", "field", "id", "file", "params", lex("t", read_sf(FILE_PATH), "w", 260, "p", recn(5,0))),
                    lex("t", "button", "params", lex("t", "Save", "oc", save_file_cb@, "w", 40))
                )),

                lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Date")),
                    lex("t", "field", "id", "date", "params", lex("t", rssdate(), "w", 300, "p", recn(5,0)))
                )),

                lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Time")),
                    lex("t", "field", "id", "time", "params", lex("t", time:clock, "w", 300, "p", recn(5,0)))
                )),

                lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Vehicle")),
                    lex("t", "field", "id", "vehicle", "params", lex("t", vehicle_name(), "w", 300, "p", recn(5,0)))
                )),

                lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Mission")),
                    lex("t", "field", "id", "mission", "params", lex("t", mission_name(), "w", 300, "p", recn(5,0)))
                )),

                lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Flight")),
                    lex("t", "field", "id", "flight", "params", lex("t", flight_num(), "w", 300, "p", recn(5,0)))
                )),

                lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Attempt")),
                    lex("t", "field", "id", "attempt", "params", lex("t", attempt_num(), "w", 300, "p", recn(5,0)))
                )),

                lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                    lex("t", "label", "params", lex("t", "Status")),
                    lex("t", "field", "id", "status", "params", lex("t", "in progress", "w", 200, "p", recn(5,0))),
                    lex("t", "popup", "id", "statuspop", "params", lex("w", 100, "t", lstatus[0], "op", lstatus, "och", lstatus_cb@))
                )),

                lex("t", "hlayout", "child", list(
                    lex("t", "label", "params", lex("t", "Details")),
                    lex("t", "field", "id", "details", "params", lex("t", "", "w", 300, "p", recn(5,0)))
                ))
            // ----- 1st column -----
            )),

            lex("t", "vlayout", "child", list(
            // ----- 2st column -----
                lex("t", "label", "params", lex("t", "Index", "m", recnn(0,0,5,0))),
                lex("t", "field",  "id", "index",  "params", lex("t", "0", "m", recnn(0,0,5,0), "p", recn(5,0))),
                lex("t", "button", "id", "del", "params", lex("t", "Delete", "oc", del_cb@, "h", 20, "m", recnn(0,0,5,0))),
                lex("t", "button", "id", "mod", "params", lex("t", "Modify", "oc", mod_cb@, "h", 20, "m", recnn(0,0,5,0))),
                lex("t", "button", "id", "new", "params", lex("t", "New", "oc", new_cb@, "h", 20, "m", recnn(0,0,5,0))),
                lex("t", "label", "id", "mode", "params", lex("t", modes[clamp(env:mode, 0, 2)], "m", recnn(0,0,5,0))),
                lex("t", "button", "params", lex("t", "Current", "oc", current_cb@, "h", 20, "m", recnn(0,0,5,0))),
                lex("t", "button", "params", lex("t", "Save", "oc", save_cb@, "h", 20))
            // ----- 2st column -----
            ))
        ))
    )
).

function save_file_cb {
    write_sf(wid:file:text, FILE_PATH).
}

function lstatus_cb {
    parameter p.
    set wid:status:text to p.
}

function new_cb {
    set env:mode to 0.
    set wid:mode:text to modes[0].
}

function mod_cb {
    set env:mode to 1.
    set wid:mode:text to modes[1].

    local fulldata to parse().
    if (fulldata:empty) {return.}
    local data to fulldata[clamp(fulldata:length - 1 - wid:index:text:tonumber(0), 0, fulldata:length - 1)].

    set wid:date:text to data:date.
    set wid:time:text to data:time.
    set wid:vehicle:text to data:vehicle.
    set wid:mission:text to data:mission.
    set wid:flight:text to data:flight:tostring.
    set wid:attempt:text to data:attempt:tostring.
    set wid:status:text to data:status.
    set wid:details:text to data:details.
}

function del_cb {
    set env:mode to 2.
    set wid:mode:text to modes[2].
}

function save_cb {
    if (env:mode = 0) {
        write_sf(stringify(), wid:file:text, false).
    } else if (env:mode = 1 and exists(wid:file:text)) {
        local lines to read_lf(wid:file:text).
        if (lines:empty) {return.}
        set lines[clamp(lines:length - wid:index:text:tonumber(0) - 1, 0, lines:length - 1)] to stringify().
        write_lf(lines, wid:file:text).
    } else if (env:mode = 2 and exists(wid:file:text)) {
        local lines to read_lf(wid:file:text).
        if (lines:empty) {return.}
        lines:remove(clamp(lines:length - wid:index:text:tonumber(0) - 1, 0, lines:length - 1)).
        write_lf(lines, wid:file:text).
    }
}

function current_cb {
    set wid:date:text to rssdate().
    set wid:time:text to time:clock.
    set wid:vehicle:text to vehicle_name().
    set wid:mission:text to mission_name().
    set wid:flight:text to flight_num().
    set wid:attempt:text to attempt_num().
    set wid:details:text to "".
}

function vehicle_name {
    return ship:name:split("-")[0]:trim.
}

function mission_name {
    local splited to ship:name:split("-").
    return choose "" if splited:length < 2 else splited[1]:trim.
}

function stringify {
    return (
        format_float(time:seconds) + "; " +
        wid:date:text:trim + "; " +
        wid:time:text:trim + "; " +
        char(34) + wid:vehicle:text:trim + char(34) + "; " +
        char(34) + wid:mission:text:trim + char(34) + "; " +
        wid:flight:text:trim + "; " +
        wid:attempt:text:trim + "; " +
        char(34) + wid:status:text:trim + char(34) + "; " +
        char(34) + wid:details:text:trim + char(34) + char(10)
    ).
}

function parse {
    local datapath to choose read_sf(FILE_PATH) if not wid:haskey("file") else wid:file:text.
    local data to list().
    if (exists(datapath)) {
        local lines to read_lf(datapath).
        for line in lines {
            local parts to line:split("; ").
            if (parts:length = 9) {
                data:add(lex(
                    "ut", parts[0]:tonumber(0),
                    "date", parts[1],
                    "time", parts[2],
                    "vehicle", parts[3]:replace(char(34), ""),
                    "mission", parts[4]:replace(char(34), ""),
                    "flight", parts[5]:tonumber(0),
                    "attempt", parts[6]:tonumber(0),
                    "status", parts[7]:replace(char(34), ""),
                    "details", parts[8]:replace(char(34), "")
                )).
            }
        }
    }
    return data.
}

// IDEA: could fix the issues with filght_num and attempt_num by identifying every launched vessel with a unique id, but the scope of this program is too small for that to be worth
// maybe if this idea become usefull for other programs, then it could be implemented in a more general way

// flight_num gets the total number of flights of the same vehicle correctly, but it may not be the correct current flight number
// eg. if there are 3 launches, the first one has a pad failure, the second one is successful and the third one is the second attempt of the first launch.
// the third one should be flight 1 attempt 2, but will be flight 2 attempt 2
function flight_num {
    return (count(parse(), {parameter d. return d:vehicle = vehicle_name() and d:status <> "pad failure".}) + 1):tostring.
}

// attempt_num doesn't get the correct value at all, but it's better then nothing
// eg. for missions launched multiple times, if one of them has a pad failure then all subsequent launches will be considered an attempt of the failed launch
function attempt_num {
    return (count(parse(), {parameter d. return d:vehicle = vehicle_name() and d:mission = mission_name() and d:status = "pad failure".}) + 1):tostring.
}

