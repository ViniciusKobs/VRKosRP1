parameter w, env, wid, wcl, mlog.

local PRESETS_PATH to "0:/disk/ascent/presets/".

local EVNUM to 5.

local presets to open(PRESETS_PATH):lex:keys.
local entries to list("Altitude", "Apoapsis").

local tags to tag_parse().
local vehicle to choose ship:name:split("-")[0]:trim:replace(" ", "_"):tolower if not tags:haskey("v") else tags:v.

set w:tab1 to lex("t", "hlayout", "id", "tab1", "params", lex("v", true, "p", recn(5)), "child", list(
    // left column
    lex("t", "vlayout", "id", "paramsbox", "params", lex("w", 400), "child", list(
        // top left
        lex("t", "vbox", "params", lex("p", recn(5)), "child", list(
            lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                lex("t", "label", "params", lex("t", "Altitude")),
                lex("t", "field", "id", "alt", "params", lex("t", "0,500,1e5", "w", 250)),
                lex("t", "popup", "id", "entry", "params", lex("t", entries[0], "op", entries, "och", {parameter _p.}, "w", 80))
            )),
            lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                lex("t", "label", "params", lex("t", "Pitch")),
                lex("t", "field", "id", "pitch", "params", lex("t", "0,0,90", "w", 330))
            )),
            lex("t", "hlayout", "params", lex("m", recnn(0,0,5,0)), "child", list(
                lex("t", "label", "params", lex("t", "Azimuth")),
                lex("t", "field", "id", "azim", "params", lex("t", "0", "w", 330))
            )),
            lex("t", "button", "id", "guid", "params", lex("t", "Disable guidance", "oc", guidance_toggle_cb@, "h", 20, "m", recnn(0,80,0,80)))
        )),
        lex("t", "vbox", "params", lex("p", recn(5)), "child", list(
            lex("t", "label", "params", lex("t", "Callbacks path", "m", recnn(0,0,5,0))),
            lex("t", "field", "id", "cbspath", "params", lex("t", "", "m", recnn(0,0,5,0))),
            lex("t", "label", "params", lex("t", "Events path", "m", recnn(0,0,5,0))),
            lex("t", "field", "id", "evspath", "params", lex("t", "", "m", recnn(0,0,5,0))),
            lex("t", "label", "params", lex("t", "Custom events", "m", recnn(0,0,5,0))),
            lex("t", "field", "id", "ev1", "params", lex("t", "", "m", recnn(0,0,5,0))),
            lex("t", "field", "id", "ev2", "params", lex("t", "", "m", recnn(0,0,5,0))),
            lex("t", "field", "id", "ev3", "params", lex("t", "", "m", recnn(0,0,5,0))),
            lex("t", "field", "id", "ev4", "params", lex("t", "", "m", recnn(0,0,5,0))),
            lex("t", "field", "id", "ev5", "params", lex("t", "", "m", recnn(0,0,5,0)))
        ))
    )),
    // right column
    lex("t", "vlayout", "params", lex("p", recnn(0,0,0,5)), "child", list(
        lex("t", "vlayout", "id", "presetbox", "child", list(
            lex("t", "label", "params", lex("t", "Preset", "m", recnn(0,0,5,0))),
            lex("t", "popup", "id", "presetpop", "params", lex("t", "Presets", "i", -1, "op", presets, "och", presets_pop_cb@, "h", 20, "m", recnn(0,0,5,0))),
            lex("t", "field", "id", "preset", "params", lex("t", vehicle, "m", recnn(0,0,5,0))),
            lex("t", "button", "params", lex("t", "Load", "oc", preset_load_cb@, "h", 20, "m", recnn(0,0,5,0))),
            lex("t", "button", "params", lex("t", "Save", "oc", preset_save_cb@, "h", 20, "m", recnn(0,0,15,0))),
            lex("t", "button", "params", lex("t", "Launch", "oc", launch_cb@, "h", 20, "m", recnn(0,0,15,0)))
        )),
        lex("t", "vlayout", "id", "abortbox", "params", lex("v", false), "child", list(
            lex("t", "button", "id", "switch", "params", lex("t", "Switch", "oc", switch_cb@, "h", 20, "m", recnn(0,0,5,0))),
            lex("t", "button", "id", "disengage", "params", lex("t", "Disengage", "e", false, "oc", disengage_cb@, "h", 20, "m", recnn(0,0,5,0))),
            lex("t", "button", "id", "terminate", "params", lex("t", "TERMINATE", "e", false, "oc", terminate_cb@, "fc", red, "h", 20, "m", recnn(0,0,5,0)))
        ))
    ))
)).

function presets_pop_cb {
    parameter p.
    set wid:preset:text to p.
}

function preset_load_cb {
    local fullpath to PRESETS_PATH + wid:preset:text.
    if (exists(fullpath) and open(fullpath):typename = "volumefile") {
        local preset to read_lf(fullpath).
        if ((preset[0] = "true" and (not env:launch_params:enabled)) or (preset[0] = "false" and env:launch_params:enabled) ) { guidance_toggle_cb(). }
        set wid:entry:text to choose "Apoapsis" if preset[1] = "1" else "Altitude".
        set wid:pitch:text to preset[2].
        set wid:alt:text to preset[3].
        set wid:azim:text to preset[4].
        set wid:cbspath:text to choose "" if preset:length <= 5 else preset[5].
        set wid:evspath:text to choose "" if preset:length <= 6 else preset[6].
        from {local i to 1.} until (i >= EVNUM) step {set i to i + 1.} do {
            if (preset:length > 6+i) {
                set wid["ev" + i]:text to preset[6+i].
            } else {
                set wid["ev" + i]:text to "".
            }
        }
    }
}

function preset_save_cb {
    local fullpath to PRESETS_PATH + wid:preset:text.
    local data to list(
        env:launch_params:enabled,
        wid:entry:text,
        wid:pitch:text,
        wid:alt:text,
        wid:azim:text,
        wid:cbspath:text,
        wid:evspath:text
    ).
    from {local i to 1.} until (i >= EVNUM) step {set i to i + 1.} do {
        data:add(wid["ev" + i]:text:trim).
    }
    write_lf(data, fullpath).
}

function guidance_toggle_cb {
    set env:launch_params:enabled to not env:launch_params:enabled.
    set wid:guid:text to choose "Disable guidance" if env:launch_params:enabled else "Enable guidance".
    set wid:alt:enabled to env:launch_params:enabled.
    set wid:pitch:enabled to env:launch_params:enabled.
    set wid:azim:enabled to env:launch_params:enabled.
}

function launch_cb {
    set env:launch_params:pitch_program_entry to btoi(wid:entry:text = "Apoapsis").
    set env["launch_params"]["pitch_program"][0] to map(wid:pitch:text:split(","), {parameter p. return p:tonumber(0).}).
    set env["launch_params"]["pitch_program"][1] to map(wid:alt:text:split(","), {parameter p. return p:tonumber(0).}).
    set env:launch_params:azimuth to wid:azim:text:tonumber(0).

    if (wid:evspath:text:trim <> "" and exists(wid:evspath:text:trim)) {
        set env:launch_params:events to read_lf(wid:evspath:text:trim).
    } else if (wid:evspath:text:trim <> "") {
        mlog:add("invalid events path").
        return.
    }

    if (wid:cbspath:text:trim <> "" and exists(wid:cbspath:text:trim)) {
        runpath(wid:cbspath:text:trim).
    } else if (wid:cbspath:text:trim <> "") {
        mlog:add("invalid callbacks path").
        return.
    }

    from {local i to 1.} until (i >= EVNUM) step {set i to i + 1.} do {
        if (wid["ev" + i]:text:trim <> "") {
            env:launch_params:events:add(wid["ev" + i]:text:trim).
        }
    }
    
    set env:launch to true.
    set wid:paramsbox:enabled to false.
    set wid:presetbox:enabled to false.
    set wid:abortbox:visible to true.
}   

function switch_cb {
    set wid:disengage:enabled to not wid:disengage:enabled.    
    set wid:terminate:enabled to not wid:terminate:enabled.    
}

function disengage_cb {
    set env:should_exit to true.
}

function terminate_cb {
    terminate_flight().
}