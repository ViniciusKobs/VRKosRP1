// THIS FILE WILL BE LOADED INTO THE PROBE'S MEMORY, SO SOME LIMITATIONS WILL APPLY
// SUCH AS: NO IMPORTS, NO ERROR HANDLING, VARIABLE NAMES MUST BE SHORT, ETC.
// NOT SURE WHAT KIND OF STRUCTURE IS BETTER FOR THIS PURPOSE, SO I MIGHT CHANGE IT LATER
// comments are allowed since they will be removed during instalation into the probe's memory

// data storage for callbacks
local GDT to lex().

// event callbacks
local ECB to list(
    // 0: attitude
    {parameter p. stage. return true.}
).

// events (loaded from the probe's memory)
// id, t, type, data...
local evs to list().

until false {

    local rm to list().
    for e in evs {
        if e[1] >= time:seconds {
            if(ECB[e[2]](e)) {
                rm:append(e).            
            }
        }
    }
    for e in rm {
        evs:remove(evs:find(e)).
    }

    wait 0.
}

// attitude event structure
// 0: id - str
// 1: time - scalar - seconds
// 2: type code - scalar
// 3: disengage? - bool
// 4: fore [
//   0: lock? - bool
//   1: callback code - string
// ]
// 5: up [
//   0: lock? - bool
//   1: callback code - scalar or string
// ]
// 6: spin [
//  0: spin? - bool
//  1: min variation - scalar
//  2: spin rotation - scalar
// ]

function acb {
    parameter p.
    if (p[3]) {
        unlock steering.
        return true.
    }

    if (not GDT:haskey(p[0])) {
        pf("fvf",p[4][1]).
        local fv to fvf().
        if (p[4][0]) {lock fv to fvf().}
        pf("uvf",p[4][1]).
        local uv to uvf().
        if (p[5][0]) {lock uv to uvf().}
        lock steering to lookdirup(fv, uv).
        set GDT[p[0]] to 1.
    }

    if (not p[6][0]) {
        return true.
    }

    // implement spin stabilization
}

// parse function
// this function receives delegate code in string format and creates a global function
// WARNING: this function is not safe, it will try to execute anything passed to it
function pf {
    parameter n, p.
    create("1:zz"):write("function " + n + p).
    runpath("1:zz").
    deletepath("1:zz").
}