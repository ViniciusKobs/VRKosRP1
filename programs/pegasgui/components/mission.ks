parameter widgets, env, wid, wcl, mlog.

local MISSIONS_PATH to "0:/disk/pegas/missions/".
local VEHICLES_PATH to "0:/disk/pegas/vehicles/".

local missions to open(MISSIONS_PATH):lex:keys.
local vehicles to open(VEHICLES_PATH):lex:keys.
local vehicle_name to ship:name:split("-")[0]:trim:replace(" ", "_"):tolower + ".ks".
local directions to list("Nearest", "North", "South").
local targets to get_rdzv_targets().

set widgets:mission to lex("t", "hlayout", "id", "mission", "params", lex("p", recn(5)), "child", list(
    lex("t", "vbox", "id", "mbox", "params", lex("w", 350, "p", recn(5), "m", recnn(0,5,0,0)), "child", list(
        lex("t", "label", "params", lex("t", "Apsidal parameters", "m", recnn(0,0,10,0), "fs", 18)),
        lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
            lex("t", "label", "params", lex("t", "ap/pe(km)")),
            lex("t", "field", "id", "ap", "params", lex("t", "180", "w", 100, "p", recn(3,0))),
            lex("t", "field", "id", "pe", "params", lex("t", "180", "w", 100, "p", recn(3,0)))
        )),
        lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
            lex("t", "label", "params", lex("t", "sma(km)/ecc")),
            lex("t", "field", "id", "sma", "params", lex("t", "", "w", 100, "p", recn(3,0))),
            lex("t", "field", "id", "ecc", "params", lex("t", "", "w", 100, "p", recn(3,0)))
        )),
        lex("t", "label", "params", lex("t", "Inclination parameters", "m", recnn(15,0,10,0), "fs", 18)),
        lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
            lex("t", "label", "params", lex("t", "inc/lan(deg)")),
            lex("t", "field", "id", "inc", "params", lex("t", "", "w", 100, "p", recn(3,0))),
            lex("t", "field", "id", "lan", "params", lex("t", "", "w", 100, "p", recn(3,0)))
        )),
        lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
            lex("t", "label", "params", lex("t", "Target", "m", recnn(0,0,10,0))),
            lex("t", "field", "id", "target", "params", lex("t", "", "w", 170, "p", recn(3,0))),
            lex("t", "popup", "params", lex("t", "Targets", "i", -1, "op", targets, "och", tgt_pop_cb@, "w", 100))
        )),
        lex("t", "label", "params", lex("t", "Flight parameters", "m", recnn(15,0,10,0), "fs", 18)),
        lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
            lex("t", "label", "params", lex("t", "Insertion altitude(km)")),
            lex("t", "field", "id", "alt", "params", lex("t", "", "w", 100, "p", recn(3,0)))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Direction")),
            lex("t", "popup", "id", "dir", "params", lex("t", directions[0], "op", directions, "w", 100))
        ))
    )),
    lex("t", "vlayout", "child", list(
        lex("t", "vlayout", "id", "lbox", "child", list(
            lex("t", "label", "params", lex("t", "Mission", "m", recnn(0,0,5,0))),
            lex("t", "popup", "params", lex("t", "Missions", "i", -1, "op", missions, "och", mission_pop_cb@, "m", recnn(0,0,5,0), "h", 22)),
            lex("t", "field", "id", "mname", "params", lex("t", choose "" if (ship:name:split("-"):length <= 1) else ship:name:split("-")[1]:trim:tolower:replace(" ", "_"), "m", recnn(0,0,5,0), "p", recn(3,0))),
            lex("t", "hlayout", "child", list(
                lex("t", "button", "params", lex("t", "Load", "oc", mission_load_cb@, "m", recnn(0,0,5,0), "h", 22)),
                lex("t", "button", "params", lex("t", "Save", "oc", mission_save_cb@, "m", recnn(0,0,5,0), "h", 22))
            )),
            lex("t", "label", "params", lex("t", "Vehicle", "m", recnn(0,0,5,0))),
            lex("t", "popup", "id", "vehicle", "params", lex("t", (choose vehicle_name if vehicles:find(vehicle_name) >= 0 else "Vehicles"), "i", vehicles:find(vehicle_name), "op", vehicles, "m", recnn(0,0,5,0), "h", 22)),
            lex("t", "label", "params", lex("t", "Wait", "m", recnn(0,0,5,0))),
            lex("t", "field", "id", "wait", "params", lex("t", "10", "m", recnn(0,0,5,0), "p", recn(3,0))),
            lex("t", "button", "params", lex("t", "Launch", "oc", launch_cb@, "m", recnn(0,0,5,0), "h", 22))
        )),
        lex("t", "button", "id", "cancel", "params", lex("t", "Cancel", "v", false, "oc", cancel_cb@, "h", 22))
    ))
)).

function mission_load_cb {
    local fullpath to MISSIONS_PATH + wid:mname:text.
    if (exists(fullpath) and open(fullpath):typename = "volumefile") {
        local cont to read_lf_nt(fullpath).
        set wid:ap:text to cont[0].
        set wid:pe:text to cont[1].
        set wid:sma:text to cont[2].
        set wid:ecc:text to cont[3].
        set wid:inc:text to cont[4].
        set wid:lan:text to cont[5].
        set wid:target:text to cont[6].
        set wid:alt:text to cont[7].
        set wid:dir:text to cont[8].
    }
}

function mission_save_cb {
    local fullpath to MISSIONS_PATH + wid:mname:text.
    local data to list(
        wid:ap:text,
        wid:pe:text,
        wid:sma:text,
        wid:ecc:text,
        wid:inc:text,
        wid:lan:text,
        wid:target:text,
        wid:alt:text,
        wid:dir:text
    ).
    write_lf(data, fullpath).
}

function mission_pop_cb {
    parameter p.
    set wid:mname:text to p.
}

function tgt_pop_cb {
    parameter p.
    set wid:target:text to p.
}

function launch_cb {
    if (wid:vehicle:text:trim <> "" and exists(VEHICLES_PATH + wid:vehicle:text)) {
        runpath(VEHICLES_PATH + wid:vehicle:text).
        set env:launch to true.
        set env:wait to env:wait + time:seconds + wid:wait:text:tonumber(0).
        abort off.
        set wid:mbox:enabled to false.
        set wid:lbox:enabled to false.
        set wid:tabs:enabled to false.
        set wid:cancel:visible to true.
    }
}

function cancel_cb {
    set env:launch to false.
    set env:wait to 0.
    set wid:mbox:enabled to true.
    set wid:lbox:enabled to true.
    set wid:tabs:enabled to true.
    set wid:cancel:visible to false.
}

function set_mission {
    global mission to lex(
        "payload", get_payload(),
        "apoapsis", get_apside():ap,
        "periapsis", get_apside():pe,
        "direction", wid:dir:text
    ).
    if (abs(get_inclination():inc) > abs(ship:latitude)) { mission:add("inclination", get_inclination():inc). }
    if (get_inclination():lan >= 0) { mission:add("lan", get_inclination():lan). }
    if (wid:alt:text <> "") { mission:add("altitude", wid:alt:text:tonumber(0)). }
}

function get_payload {
    return choose 0 if (not (defined VEHICLE_MASS)) else (ship:mass*1e3) - VEHICLE_MASS.
}

function get_apside {
    local apt to wid:ap:text.
    local ap to wid:ap:text:tonumber(0).
    local pet to wid:pe:text.
    local pe to wid:pe:text:tonumber(0).
    local smat to wid:sma:text.
    local sma to wid:sma:text:tonumber(0).
    local ecct to wid:ecc:text.
    local ecc to wid:ecc:text:tonumber(0).

    if (apt <> "" and pet <> "") {
        return lex(
            "ap", choose ap if (ap > pe) else pe,
            "pe", choose pe if (pe < ap) else ap
        ).
    }
    if (smat <> "" and ecct <> "") {
        return lex(
            "ap", sma + (sma*ecc),
            "pe", sma - (sma*ecc) 
        ).
    }
    if (ecct <> "" and pet <> "") {
        set sma to pe/(1-ecc).
        return lex(
            "ap", sma + (sma*ecc),
            "pe", pe
        ).
    }
    if (apt <> "" or pet <> "") {
        return lex(
            "ap", choose ap if (apt <> "") else pe,
            "pe", choose ap if (apt <> "") else pe
        ).
    }
    return lex("ap", 180, "pe", 180).
}

function get_inclination {
    if (wid:target:text <> "") {
        if (wid:target:text = "Moon") {
            return lex(
                "inc", moon:orbit:inclination,
                "lan", moon:orbit:lan
            ).
        } else if (count(list_targets(), {parameter t. return t:name = wid:target:text.}) > 0) {
            return lex(
                "inc", vessel(wid:target:text):orbit:inclination,
                "lan", vessel(wid:target:text):orbit:lan
            ).
        }
    }
    return lex(
        "inc", wid:inc:text:tonumber(0),
        "lan", wid:lan:text:tonumber(-1)
    ).
}

function get_rdzv_targets {
    local tgts to map(
        filter(
            list_targets(), {parameter t. return t:body = "earth" and (t:type = "station" or t:type = "ship").}
        ), 
        {parameter t. return t:name.}
    ).
    tgts:insert(0, "Moon").
    return tgts.
}
