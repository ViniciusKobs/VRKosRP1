// THIS FILE WILL BE LOADED INTO THE PROBE'S MEMORY, SO SOME LIMITATIONS WILL APPLY
// SUCH AS: NO IMPORTS, NO ERROR HANDLING, VARIABLE NAMES MUST BE SHORT, ETC.
// NOT SURE WHAT KIND OF STRUCTURE IS BETTER FOR THIS PURPOSE, SO I MIGHT CHANGE IT LATER
// comments are allowed since they will be removed during instalation into the probe's memory

// data storage for callbacks
local GDT to lex().

function main {
    print("press q to exit").
    local evs to list().
    for f in open("1:evs"):lex:values {
        local c to f:readall:string:split(char(10)).
        log c to "1:log".
        evs:add(list(f:name, c[0]:tonumber(0), eval(c[1]), true)).
    }
    until terminal:input:haschar and terminal:input:getchar = "q" {
        local rm to list().
        for e in evs {
            if e[1] <= time:seconds {
                if e[3] {
                    print("s: " + e[0]).
                    set e[3] to false.
                }
                if(e[2](GDT)) { rm:add(e). }
            }
        }
        for e in rm {
            print("f: " + e[0]).
            evs:remove(evs:find(e)).
            deletepath("1:evs/"+e[0]).
        }
        wait 0.
    }
    local f to open("1:env/boot").
    f:clear(). f:write("0:programs/bootmgr/main").
    reboot.
}

// run string code
// this function will take code in string format and try to run it
// it provides a global variable GVAL to store a return value
// warning: if the code is invalid the program will simply crash
function eval {
    parameter p.
    local n to "1:f"+time:seconds.
    if not (defined RAX) {global RAX to 0.}
    create(n):write(p).
    runpath(n).
    deletepath(n).
    return RAX.
}

main().