parameter widgets, env, wid, wcl, mlog.

local operators to list("+", "-").
local targets to nlconcat(list("Self", "Target", "Absolute"), map(list_bodies(), {parameter b. return b:name.})).
local self_vecs to list("Prograde", "Normal", "Radial", "Up", "Fore", "Right", "Current").
local body_vecs to list("Position", "East", "North", "Normal").
local tgt_vecs to list("Position", "Velocity", "Relative velocity", "Up", "Fore", "Right").
local abs_vecs to list("X", "Y", "Z").
local ullage_types to list("RCS", "Stage", "None").
local ignition_types to list("Throttle", "Stage", "Stage and Throttle", "RCS Fore").

set widgets:maneuver to lex("t", "hlayout", "id", "maneuver", "params", lex("v", false, "p", recn(5)), "child", list(
    lex("t", "vbox", "params", lex("p", recn(5), "m", recnn(0,5,0,0), "w", 400), "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Event ETA")),
            lex("t", "field", "params", lex("t", ""))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "button", "id", "skip_check", "params", lex("t", "Reorientation: True", "oc", skip_check_cb@)),
            lex("t", "button", "id", "ullage_check", "params", lex("t", "Ullage: True", "oc", ullage_check_cb@)),
            lex("t", "button", "id", "ignition_check", "params", lex("t", "Ignition: True", "oc", ignition_check_cb@))
        )),
        lex("t", "vlayout", "id", "skipbox", "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Reorientation time(s)")),
                lex("t", "field", "params", lex("t", "60"))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Up Vector")),
                lex("t", "popup", "params", lex("t", "+", "op", operators, "w", 35)),
                lex("t", "popup", "params", lex("t", targets[0], "op", targets, "w", 110, "och", mnv_up_targets_cb@)),
                lex("t", "popup", "id", "mnvupvecs", "params", lex("t", self_vecs[0], "op", self_vecs, "w", 110))
            ))
        )),
        lex("t", "hlayout", "id", "ullagebox", "child", list(
            lex("t", "label", "params", lex("t", "Ullage time(s)")),
            lex("t", "field", "params", lex("t", "5")),
            lex("t", "label", "params", lex("t", "Ullage type")),
            lex("t", "popup", "params", lex("t", ullage_types[0], "op", ullage_types))
        )),
        lex("t", "hlayout", "id", "ignitionbox", "child", list(
            lex("t", "label", "params", lex("t", "Ignition type")),
            lex("t", "popup", "params", lex("t", ignition_types[0], "op", ignition_types))
        ))
    )),
    lex("t", "vlayout", "child", list(
        lex("t", "button", "params", lex("t", "Execute")),
        lex("t", "button", "params", lex("t", "Add event"))
    ))
)).

function skip_check_cb {
    if (wid:skip_check:text = "Reorientation: True") {
        set wid:skip_check:text to "Reorientation: False".
        set wid:skipbox:enabled to false.
    } else {
        set wid:skip_check:text to "Reorientation: True".
        set wid:skipbox:enabled to true.
    }
}

function ullage_check_cb {
    if (wid:ullage_check:text = "Ullage: True") {
        set wid:ullage_check:text to "Ullage: False".
        set wid:ullagebox:enabled to false.
    } else {
        set wid:ullage_check:text to "Ullage: True".
        set wid:ullagebox:enabled to true.
    }
}

function ignition_check_cb {
    if (wid:ignition_check:text = "Ignition: True") {
        set wid:ignition_check:text to "Ignition: False".
        set wid:ignitionbox:enabled to false.
    } else {
        set wid:ignition_check:text to "Ignition: True".
        set wid:ignitionbox:enabled to true.
    }
}

function mnv_up_targets_cb {
    parameter op.
    if (op = "Self") {
        set wid:mnvupvecs:options to self_vecs.
        set wid:mnvupvecs:text to self_vecs[0].
    } else if (op = "Target") {
        set wid:mnvupvecs:options to tgt_vecs.
        set wid:mnvupvecs:text to tgt_vecs[0].
    } else if (op = "Absolute") {
        set wid:mnvupvecs:options to abs_vecs.
        set wid:mnvupvecs:text to abs_vecs[0].
    } else {
        set wid:mnvupvecs:options to body_vecs.
        set wid:mnvupvecs:text to body_vecs[0].
    }
}