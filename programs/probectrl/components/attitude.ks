parameter widgets, env, wid, wcl, mlog.

local targets to list("Self", "Surface", "Orbit", "Target", "Node", "Absolute", "Body").
local self_vecs to list("Fore", "Up", "Right").
local surf_vecs to list("North", "Up", "East").
local obt_vecs to list("Prograde", "Normal", "Radial").
local tgt_vecs to list("Position", "Velocity", "Relative", "Fore", "Up", "Right").
local node_vecs to list("Magnitude").
local abs_vecs to list("X", "Y", "Z").
local body_vecs to map(list_bodies(), {parameter b. return b:name.}).

local targets_callbacks to list(
    "{return %ship:facing:forevector.}", // 0: Self Fore 
    "{return %ship:facing:upvector.}", // 1: Self Up 
    "{return %ship:facing:rightvector.}", // 2: Self Right 

    "{return %north:vector.}", // 3: Surface North
    "{return %up:vector.}", // 4: Surface Up
    "{return %north:rightvector.}", // 5: Surface East

    "{return %prograde:vector.}", // 6: Orbit Prograde
    "{return %-prograde:rightvector.}", // 7: Orbit Normal
    "{return %-prograde:upvector.}", // 8: Orbit Radial

    "{return %target:position-ship:position.}", // 9: Target Position
    "{return %target:velocity:orbit.}", // 10: Target Velocity
    "{return %target:velocity:orbit-ship:velocity:orbit.}", // 11: Target Relative Velocity
    "{return %target:facing:forevector.}", // 12: Target Fore
    "{return %target:facing:upvector.}", // 13: Target Up
    "{return %target:facing:rightvector.}", // 14: Target Right

    "{return choose ship:facing:forevector if (not hasnode) else %node:deltav.}", // 15: Node Magnitude

    "{return %v(1,0,0).}", // 16: Absolute X
    "{return %v(0,1,0).}", // 17: Absolute Y
    "{return %v(0,0,1).}", // 18: Absolute Z

    "{return %?:position.}" // 19: Body
).

set widgets:attitude to lex("t", "hlayout", "id", "attitude", "params", lex("p", recn(5)), "child", list(
    lex("t", "vbox", "params", lex("p", recn(5), "m", recnn(0,5,0,0), "w", 400), "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Event ETA")),
            lex("t", "field", "params", lex("t", "")),
            lex("t", "label", "params", lex("t", "Event ID")),
            lex("t", "field", "params", lex("t", ""))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "button", "id", "type_check", "params", lex("t", "Engage: True", "oc", enabled_check_cb("type_check", "typebox", "Engage: "))),
            lex("t", "button", "id", "spin_check", "params", lex("t", "Spin: False", "oc", enabled_check_cb("spin_check", "spin", "Spin: ")))
        )),
        lex("t", "vlayout", "id", "typebox", "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Fore Vector")),
                lex("t", "button", "id", "foredir", "params", lex("t", "+", "oc", check_cb("foredir", list("+", "-")))),
                lex("t", "button", "id", "foretype", "params", lex("t", "lock", "oc", check_cb("foretype", list("lock", "set")))),
                lex("t", "popup", "params", lex("t", targets[0], "op", targets, "w", 110, "och", targets_cb("forevecs"))),
                lex("t", "popup", "id", "forevecs", "params", lex("t", self_vecs[0], "op", self_vecs, "w", 110))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Up Vector")),
                lex("t", "button", "id", "updir", "params", lex("t", "+", "oc", check_cb("updir", list("+", "-")))),
                lex("t", "button", "id", "uptype", "params", lex("t", "lock", "oc", check_cb("uptype", list("lock", "set")))),
                lex("t", "popup", "params", lex("t", targets[0], "op", targets, "w", 110, "och", targets_cb("upvecs"))),
                lex("t", "popup", "id", "upvecs", "params", lex("t", self_vecs[1], "op", self_vecs, "w", 110))
            ))
        )),
        lex("t", "hlayout", "id", "spin", "params", lex("e", false), "child", list(
            lex("t", "label", "params", lex("t", "Max variation(rad/s)")),
            lex("t", "field", "params", lex("t", "0.004")),
            // rad/s to rpm -> rad * (60 / 2pi)
            lex("t", "label", "params", lex("t", "Spin rate(rpm)")),
            lex("t", "field", "params", lex("t", "50"))
        ))

    )),
    lex("t", "vlayout", "child", list(
        lex("t", "button", "params", lex("t", "Execute")),
        lex("t", "button", "params", lex("t", "Add event"))
    ))
)).

function targets_cb {
    parameter id.
    return {
        parameter op.
        if (op = "Self") {
            set wid[id]:options to self_vecs.
            set wid[id]:text to self_vecs[0].
        } else if (op = "Surface") {
            set wid[id]:options to surf_vecs.
            set wid[id]:text to surf_vecs[0].
        } else if (op = "Orbit") {
            set wid[id]:options to obt_vecs.
            set wid[id]:text to obt_vecs[0].
        } else if (op = "Target") {
            set wid[id]:options to tgt_vecs.
            set wid[id]:text to tgt_vecs[0].
        } else if (op = "Node") {
            set wid[id]:options to node_vecs.
            set wid[id]:text to node_vecs[0].
        } else if (op = "Absolute") {
            set wid[id]:options to abs_vecs.
            set wid[id]:text to abs_vecs[0].
        } else {
            set wid[id]:options to body_vecs.
            set wid[id]:text to body_vecs[0].
        }
    }.
}

function check_cb {
    parameter id_button, states to list("True", "False"), prefix to "".    
    return {
        if (wid[id_button]:text = prefix + states[0]) {
            set wid[id_button]:text to prefix + states[1].
        } else {
            set wid[id_button]:text to prefix + states[0].
        }
    }.
}

function enabled_check_cb {
    parameter id_button, id_box, prefix to "".
    return {
        if (wid[id_button]:text = prefix + "True") {
            set wid[id_button]:text to prefix + "False".
            set wid[id_box]:enabled to false.
        } else {
            set wid[id_button]:text to prefix + "True".
            set wid[id_box]:enabled to true.
        }
    }.
}