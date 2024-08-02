// left column: mission parameters
// payload field
// apoapsis field
// periapsis field
// inclination field (optional)
// lan field (optional)
// altitude field (optional)
// direction popup (optional)

// right column: launch
// popup and field for selecting file
// switch button
// launch button

parameter widgets, env, wid, wcl, mlog.

local directions to list("nearest", "north", "south").

local targets to list(
    "Moon"
).

set widgets:mission to lex("t", "hlayout", "id", "mission", "params", lex("p", recn(5)), "child", list(
    lex("t", "vbox", "params", lex("w", 400, "p", recn(5), "m", recnn(0,5,0,0)), "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "payload")),
            lex("t", "field", "id", "payload", "params", lex("t", "")),
            lex("t", "button", "params", lex("t", "estimate"))
        )),
        lex("t", "label", "params", lex("t", "apsidal parameters", "a", "center")),
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "ap/pe")),
            lex("t", "field", "id", "ap", "params", lex("t", "180")),
            lex("t", "field", "id", "pe", "params", lex("t", "180"))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "sma/ecc")),
            lex("t", "field", "id", "sma", "params", lex("t", "")),
            lex("t", "field", "id", "ecc", "params", lex("t", ""))
        )),
        lex("t", "label", "params", lex("t", "inclination parameters", "a", "center")),
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "inc/lan")),
            lex("t", "field", "id", "inc", "params", lex("t", "")),
            lex("t", "field", "id", "lan", "params", lex("t", "")),
            lex("t", "popup", "params", lex("t", "", "i", -1, "op", targets))
        )),
        lex("t", "label", "params", lex("t", "launch parameters", "a", "center")),
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "insertion altitude")),
            lex("t", "field", "id", "alt", "params", lex("t", ""))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "direction")),
            lex("t", "popup", "id", "dir", "params", lex("t", directions[0], "op", directions))
        ))
    )),
    lex("t", "vlayout", "child", list(
        lex("t", "label", "params", lex("t", "presets")),
        lex("t", "popup", "params", lex("t", "", "i", -1, "op", list("a", "b", "c", "d"))),
        lex("t", "field", "params", lex("t", "")),
        lex("t", "button", "params", lex("t", "load")),
        lex("t", "button", "params", lex("t", "save")),
        lex("t", "label", "params", lex("t", "vehicle")),
        lex("t", "popup", "params", lex("t", "", "i", -1, "op", list("a", "b", "c", "d"))),
        lex("t", "button", "params", lex("t", "launch"))
    ))
)).

function launch_cb {
    global mission to lex(
        "payload", get_payload(),
        "apoapsis", get_apside():ap,
        "periapsis", get_apside():pe,
        "direction", wid:dir:text
    ).
    get_inclination_params().
    if (wid:alt:text <> "") { mission:add("altitude", wid:alt:text:tonumber(0)). }
    print(mission).
    terminal:input:getchar().
}

function get_payload {
    return choose 0 if (not (defined SHIP_MASS)) else ship:mass - SHIP_MASS.
}

function get_apside {
    if (wid:ap:text <> "" and wid:pe:text <> "") {
        return lex(
            "ap", wid:ap:text:tonumber(0),
            "pe", wid:pe:text:tonumber(0)
        ).
    } else if (wid:sma:text <> "" and wid:ecc:text <> "") {
        // calculate ap and pe from sma and ecc
        // for now return default values
        return lex(
            "ap", 180,
            "pe", 180
        ).
    }
    return lex(
        "ap", 180,
        "pe", 180
    ).
}

function get_inclination_params {
    if (wid:inc:text <> "" and wid:lan:text <> "") {
        set mission:inclination to wid:inc:text:tonumber(0).
        set mission:lan to wid:inc:text:tonumber(0).
    }
}