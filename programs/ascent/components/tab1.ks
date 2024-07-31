parameter w, env, wid, wcl, mlog.

local PRESETS_PATH to "0:/disk/ascent/presets/".

local presets to open(PRESETS_PATH):lex:keys.

set w:tab1 to lex("t", "hlayout", "id", "tab1", "params", lex("v", true, "p", recn(5)), "child", list(
    // left column
    lex("t", "vlayout", "params", lex("w", 400), "child", list(
        // top left
        lex("t", "vbox", "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "altitude")),
                lex("t", "field", "id", "alt", "params", lex("t", "0,500,1e5"))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "pitch")),
                lex("t", "field", "id", "pitch", "params", lex("t", "0,0,90"))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "azimuth")),
                lex("t", "field", "id", "azim", "params", lex("t", "0"))
            )),
            lex("t", "button", "id", "guid", "params", lex("t", "disable guidance", "oc", guidance_toggle_cb@))
        )),
        lex("t", "vbox", "child", list(
            lex("t", "label", "params", lex("t", "callbacks path")),
            lex("t", "field", "id", "cbspath", "params", lex("t", "")),
            lex("t", "label", "params", lex("t", "events path")),
            lex("t", "field", "id", "evspath", "params", lex("t", "")),
            lex("t", "label", "params", lex("t", "custom events")),
            lex("t", "field", "id", "ev1", "params", lex("t", "")),
            lex("t", "field", "id", "ev2", "params", lex("t", "")),
            lex("t", "field", "id", "ev3", "params", lex("t", "")),
            lex("t", "field", "id", "ev4", "params", lex("t", "")),
            lex("t", "field", "id", "ev5", "params", lex("t", ""))
        ))
    )),
    // right column
    lex("t", "vlayout", "child", list(
        lex("t", "label", "params", lex("t", "preset")),
        lex("t", "popup", "id", "presetpop", "params", lex("t", presets[0], "op", presets, "och", presets_pop_cb@)),
        lex("t", "field", "id", "preset", "params", lex("t", presets[0])),
        lex("t", "button", "params", lex("t", "load", "oc", preset_load_cb@)),
        lex("t", "button", "params", lex("t", "save", "oc", preset_save_cb@)),
        lex("t", "button", "params", lex("t", "launch", "oc", launch_cb@))
    ))
)).

function presets_pop_cb {
    parameter p.
    set wid:preset:text to p.
}

function preset_load_cb {
    local fullpath to PRESETS_PATH + wid:preset:text.
    if (exists(fullpath) and open(fullpath):typename = "volumefile") {
        local preset to read_lf_nt(fullpath).
        if ((preset[0] = "true" and (not env:launch_params:enabled)) or (preset[0] = "false" and env:launch_params:enabled) ) { guidance_toggle_cb(). }
        set wid:pitch:text to preset[1].
        set wid:alt:text to preset[2].
        set wid:azim:text to preset[3].
        set wid:cbspath:text to preset[4].
        set wid:evspath:text to preset[5].
    }
}

function preset_save_cb {
    local fullpath to PRESETS_PATH + wid:preset:text.
    write_lf(list(
        env:launch_params:enabled,
        wid:pitch:text,
        wid:alt:text,
        wid:azim:text,
        wid:cbspath:text,
        wid:evspath:text
    ), fullpath).
}

function guidance_toggle_cb {
    set env:launch_params:enabled to not env:launch_params:enabled.
    set wid:guid:text to choose "disable guidance" if env:launch_params:enabled else "enable guidance".
    set wid:alt:enabled to env:launch_params:enabled.
    set wid:pitch:enabled to env:launch_params:enabled.
    set wid:azim:enabled to env:launch_params:enabled.
}

function launch_cb {
    set env["launch_params"]["pitch_program"][0] to map(wid:pitch:text:split(","), {parameter p. return p:tonumber(0).}).
    set env["launch_params"]["pitch_program"][1] to map(wid:alt:text:split(","), {parameter p. return p:tonumber(0).}).
    set env:launch_params:azimuth to wid:azim:text:tonumber(0).

    if (exists(wid:evspath:text:trim)) {
        set env:launch_params:events to read_lf(wid:evspath:text:trim).
    } else if (wid:evspath:text:trim <> "") {
        mlog:add("invalid events path").
        return.
    }
    
    set env:launch to true.
}   
