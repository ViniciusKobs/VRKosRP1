parameter widgets, env, wid, wcl, mlog.

local operators to list("+", "-").
local targets to nlconcat(list("Self", "Target", "Node"), map(list_bodies(), {parameter b. return b:name.})).
local self_vecs to list("Prograde", "Normal", "Radial", "Up", "Fore", "Right").
local body_vecs to list("Position", "East", "North", "Normal").
local tgt_vecs to list("Position", "Velocity", "Relative velocity", "Up", "Fore", "Right").
local node_vecs to list("Magnitude").

set widgets:attitude to lex("t", "hlayout", "id", "mission", "params", lex("p", recn(5)), "child", list(
    lex("t", "vbox", "params", lex("p", recn(5), "m", recnn(0,5,0,0), "w", 350), "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Event ETA")),
            lex("t", "field", "params", lex("t", ""))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Fore Vector")),
            lex("t", "popup", "params", lex("t", "+", "op", operators, "w", 35)),
            lex("t", "popup", "params", lex("t", targets[0], "op", targets, "w", 110, "och", fore_targets_cb@)),
            lex("t", "popup", "id", "forevecs", "params", lex("t", self_vecs[0], "op", self_vecs, "w", 110))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Up Vector")),
            lex("t", "popup", "params", lex("t", "+", "op", operators, "w", 35)),
            lex("t", "popup", "params", lex("t", targets[0], "op", targets, "w", 110, "och", up_targets_cb@)),
            lex("t", "popup", "id", "upvecs", "params", lex("t", self_vecs[0], "op", self_vecs, "w", 110))
        ))
    )),
    lex("t", "vlayout", "child", list(
        lex("t", "button", "params", lex("t", "Add event")),
        lex("t", "button", "params", lex("t", "Execute")),
        lex("t", "button", "params", lex("t", "Execute and hold"))
    ))
)).

function fore_targets_cb {
    parameter op.
    if (op = "Self") {
        set wid:forevecs:options to self_vecs.
        set wid:forevecs:text to self_vecs[0].
    } else if (op = "Target") {
        set wid:forevecs:options to tgt_vecs.
        set wid:forevecs:text to tgt_vecs[0].
    } else if (op = "Node") {
        set wid:forevecs:options to node_vecs.
        set wid:forevecs:text to node_vecs[0].
    } else {
        set wid:forevecs:options to body_vecs.
        set wid:forevecs:text to body_vecs[0].
    }
}

function up_targets_cb {
    parameter op.
    if (op = "Self") {
        set wid:upvecs:options to self_vecs.
        set wid:upvecs:text to self_vecs[0].
    } else if (op = "Target") {
        set wid:upvecs:options to tgt_vecs.
        set wid:upvecs:text to tgt_vecs[0].
    } else if (op = "Node") {
        set wid:upvecs:options to node_vecs.
        set wid:upvecs:text to node_vecs[0].
    } else {
        set wid:upvecs:options to body_vecs.
        set wid:upvecs:text to body_vecs[0].
    }
}