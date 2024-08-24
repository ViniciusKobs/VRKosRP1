parameter widgets, env, wid, wcl, mlog.

local EVENTS_PATH to "1:evs/".

local targets to list("Self", "Surface", "Orbit", "Target", "Node", "Absolute", "Body").
local self_vecs to list("Fore", "Up", "Right").
local surf_vecs to list("North", "Up", "East").
local obt_vecs to list("Prograde", "Normal", "Radial").
local tgt_vecs to list("Position", "Velocity", "Relative", "Fore", "Up", "Right").
local node_vecs to list("Magnitude").
local abs_vecs to list("X", "Y", "Z").
local body_vecs to map(list_bodies(), {parameter b. return b:name.}).

local target_vecs to lex(
    "self_fore", "%ship:facing:forevector", // 0: Self Fore 
    "self_up", "%ship:facing:upvector", // 1: Self Up 
    "self_right", "%ship:facing:rightvector", // 2: Self Right 

    "surface_north", "%north:vector", // 3: Surface North
    "surface_up", "%up:vector", // 4: Surface Up
    "surface_east", "%vcrs(up:vector,north:vector)", // 5: Surface East

    "orbit_prograde", "%prograde:vector", // 6: Orbit Prograde
    "orbit_normal", "%-prograde:rightvector", // 7: Orbit Normal
    "orbit_radial", "%-prograde:upvector", // 8: Orbit Radial

    "target_position", "%target:position-ship:position", // 9: Target Position
    "target_velocity", "%target:velocity:orbit", // 10: Target Velocity
    "target_relative", "%(target:velocity:orbit-ship:velocity:orbit)", // 11: Target Relative Velocity
    "target_fore", "%target:facing:forevector", // 12: Target Fore
    "target_up", "%target:facing:upvector", // 13: Target Up
    "target_right", "%target:facing:rightvector", // 14: Target Right

    "node_magnitude", "choose ship:facing:forevector if (not hasnode) else %node:deltav", // 15: Node Magnitude

    "absolute_x", "%v(1,0,0)", // 16: Absolute X
    "absolute_y", "%v(0,1,0)", // 17: Absolute Y
    "absolute_z", "%v(0,0,1)", // 18: Absolute Z

    "body", "%?body?:position" // 19: Body
).

local cb_structure to "set RAX to {parameter data. ?code?}.".
local unlock_steering_command to "unlock steering.".
local lock_steering_command to "lock steering to lookdirup(?fore?,?up?).".
local set_steering_command to "local _fore to ?fore?. local _up to ?up?. lock steering to lookdirup(_fore,_up).".
local rcs_spin_command to "rcs on. set ship:control:roll to 1.".
local rcs_stage_command to "stage.".
// 500 chars long for each event + handler
local spin_command to (
    "if (not data:haskey("+char(34)+"?id?"+char(34)+")) {?steeringcommand? set data:?id? to list(true, false).} " +
    "if (data:?id?[0] and ship:angularvel:mag<=?maxvariation? and abs(steeringmanager:angleerror)<=?maxerror?) {unlock steering. ?spintypecommand? set data:?id? to list(false, true).} " +
    "if (data:?id?[1] and ship:angularvel:mag>=?spinrate?) {set ship:control:roll to 0. ?stageafter? return true.} return false."
).

set widgets:attitude to lex("t", "hlayout", "id", "attitude", "params", lex("v", false, "p", recn(5)), "child", list(
    lex("t", "vbox", "params", lex("p", recn(5), "m", recnn(0,5,0,0), "w", 400), "child", list(
        lex("t", "hlayout", "child", list(
            lex("t", "label", "params", lex("t", "Event UT (s|date)")),
            lex("t", "field", "id", "atteventut", "params", lex("t", "")),
            lex("t", "label", "params", lex("t", "Event ID")),
            lex("t", "field", "id", "atteventid", "params", lex("t", ""))
        )),
        lex("t", "hlayout", "child", list(
            lex("t", "button", "id", "engage_check", "params", lex("t", "Engage: True", "oc", enabled_check_cb("engage_check", "typebox", "Engage: "))),
            lex("t", "button", "id", "lock_check", "params", lex("t", "Lock: True", "oc", check_cb("lock_check", "Lock: "))),
            lex("t", "button", "id", "spin_check", "params", lex("t", "Spin: False", "oc", enabled_check_cb("spin_check", "spin", "Spin: ")))
        )),
        lex("t", "vlayout", "id", "typebox", "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Fore Vector")),
                lex("t", "button", "id", "foredir", "params", lex("t", "+", "oc", check_cb("foredir", "", list("+", "-")))),
                lex("t", "popup", "id", "foretgt", "params", lex("t", targets[0], "op", targets, "w", 110, "och", targets_cb("forevecs"))),
                lex("t", "popup", "id", "forevecs", "params", lex("t", self_vecs[0], "op", self_vecs, "w", 110))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Up Vector")),
                lex("t", "button", "id", "updir", "params", lex("t", "+", "oc", check_cb("updir", "", list("+", "-")))),
                lex("t", "popup", "id", "uptgt", "params", lex("t", targets[0], "op", targets, "w", 110, "och", targets_cb("upvecs"))),
                lex("t", "popup", "id", "upvecs", "params", lex("t", self_vecs[1], "op", self_vecs, "w", 110))
            ))
        )),
        lex("t", "vlayout", "id", "spin", "params", lex("e", false), "child", list(
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Max variation(rad/s)")),
                lex("t", "field", "id", "maxvar", "params", lex("t", "0.004")),
                // rad/s to rpm -> rad * (60 / 2pi)
                lex("t", "label", "params", lex("t", "Max error(deg)")),
                lex("t", "field", "id", "maxerr", "params", lex("t", "0.4"))
            )),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "params", lex("t", "Spin rate(rpm)")),
                lex("t", "field", "id", "spinrate", "params", lex("t", "10")),
                lex("t", "button", "id", "spintype", "params", lex("t", "Spin type: RCS", "oc", check_cb("spintype", "Spin type: ", list("RCS", "stage")))),
                lex("t", "button", "id", "stageafter", "params", lex("t", "Stage after: True", "oc", check_cb("stageafter", "Stage after: ")))
            ))
        ))

    )),
    lex("t", "vlayout", "child", list(
        lex("t", "button", "params", lex("t", "Execute", "oc", execute_attitude_cb@)),
        lex("t", "button", "params", lex("t", "Add event", "oc", add_attitude_event_cb@))
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

function execute_attitude_cb {
    mlog:add(create_attitude_code()).
}

function check_cb {
    parameter id_button, prefix to "", states to list("True", "False").    
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

function add_event {
    parameter id, ut, code.
    if (is_datetime(ut)) {
        set ut to datetime_to_sec(ut).
    } else if (is_eta(ut)) {
        set ut to time:seconds + eta_to_sec(ut).
    } else {
        set ut to time:seconds + ut:tonumber(0).
    }

    if (id = "") { 
        mlog:add("Event ID is empty!").
        return.
    }

    write_lf(list(ut, code), EVENTS_PATH+id).
    mlog:add("Event added: " + id).
}

function add_attitude_event_cb {
    local id to wid:atteventid:text.
    //local ut to choose wid:eventut:text:tonumber(0) if is_datetime(wid:eventut:text) else datetime_to_sec(wid:eventut:text).
    local ut to wid:atteventut:text.
    add_event(id, ut, create_attitude_code()).
}

function create_attitude_code {
    local disengage to wid:engage_check:text = "Engage: False".

    if (disengage) { return unlock_steering_command. }

    local id to wid:eventid:text.
    local _lock to wid:lock_check:text = "Lock: True".
    local spin to wid:spin_check:text = "Spin: True".
    local maxvariation to wid:maxvar:text.
    local maxerror to wid:maxerr:text.
    local rpm to wid:spinrate:text:tonumber(10).
    local spinrate to format_float(rpm * ((2*constant:pi)/60)).
    local rcsspin to wid:spintype:text = "Spin type: RCS".
    local stageafter to wid:stageafter:text = "Stage after: True".

    local foredir to wid:foredir:text = "+".
    local foretgt to wid:foretgt:text.
    local forevec to wid:forevecs:text.

    local fore_vector to target_vecs[foretgt + (choose "" if foretgt = "body" else "_" + forevec)]:replace("%", choose "" if foredir else "-").
    if (foretgt = "body") {
        set fore_vector to fore_vector:replace("?body?", forevec).
    }

    local updir to wid:updir:text = "+".
    local uptgt to wid:uptgt:text.
    local upvec to wid:upvecs:text.

    local up_vector to target_vecs[uptgt + (choose "" if uptgt = "body" else "_" + upvec)]:replace("%", choose "" if updir else "-").
    if (uptgt = "body") {
        set up_vector to up_vector:replace("?body?", upvec).
    }

    local steering_command to choose lock_steering_command if _lock else set_steering_command.
    set steering_command to steering_command:replace("?fore?", fore_vector):replace("?up?", up_vector).

    return cb_structure:replace("?code?", choose (steering_command + " return true.") if (not spin) else 
        spin_command:replace("?id?", id)
        :replace("?steeringcommand?", steering_command)
        :replace("?maxvariation?", maxvariation)
        :replace("?maxerror?", maxerror)
        :replace("?spintypecommand?", choose rcs_spin_command if rcsspin else rcs_stage_command)
        :replace("?spinrate?", spinrate)
        :replace("?stageafter?", choose rcs_stage_command if stageafter else "")
    ).
}