parameter w, env, wid, wcl, mlog.

set w:tab1 to lex("t", "hlayout", "id", "tab1", "params", lex("v", true, "p", recn(5)), "child", list(
    // left column
    lex("t", "vlayout", "params", lex("w", 400), "child", list(
        // top left
        lex("t", "vbox", "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "altitude")),
                lex("t", "field", "id", "alt", "params", lex("t", env:launch_params:pitch_program[1]:join(",")))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "pitch")),
                lex("t", "field", "id", "pitch", "params", lex("t", env:launch_params:pitch_program[0]:join(",")))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "azimuth")),
                lex("t", "field", "id", "azim", "params", lex("t", env:launch_params:azimuth:tostring))
            )),
            lex("t", "button", "id", "guid", "params", lex("t", "disable guidance", "oc", guidance_toggle_cb@))
        )),
        lex("t", "vbox", "child", list(
            lex("t", "label", "params", lex("t", "callbacks path")),
            lex("t", "field", "params", lex("t", "")),
            lex("t", "label", "params", lex("t", "events")),
            lex("t", "field", "params", lex("t", "")),
            lex("t", "field", "params", lex("t", "")),
            lex("t", "field", "params", lex("t", "")),
            lex("t", "field", "params", lex("t", "")),
            lex("t", "field", "params", lex("t", "")),
            lex("t", "field", "params", lex("t", "")),
            lex("t", "field", "params", lex("t", ""))
        ))
    )),
    // right column
    lex("t", "vlayout", "child", list(
        lex("t", "label", "params", lex("t", "preset")),
        lex("t", "field", "params", lex("t", "")),
        lex("t", "button", "params", lex("t", "load")),
        lex("t", "button", "params", lex("t", "save")),
        lex("t", "button", "params", lex("t", "launch", "oc", launch_cb@))
    ))
)).

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
    set env:launch to true.
}   
