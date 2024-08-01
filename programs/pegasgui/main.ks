@lazyglobal off.

runoncepath("0:/libs/file").

local env to lex(
    "should_exit", false
).
local wid to lex().
local wcl to lex().
local mlog to list().

runpath("0:/programs/pegasgui/view", env, wid, wcl, mlog).

local window to wid:window.

function main {
    window:show().
    local t0 to time:seconds.
    until env:should_exit {
        local uptime to time:seconds - t0.

        clearscreen. print(
            "UPTIME: " + floor(uptime, 2) + char(10) + " " + char(10) +
            "press:" + char(10) + 
            "q to exit" + char(10) + 
            "r to reboot" + char(10) + 
            "s to shutdown" + char(10) + " " + char(10) +
            "messages:" + char(10) + mlog:join(char(10))
        ).

        if (terminal:input:haschar) {
            local ch to terminal:input:getchar().
            if (ch = "q") {
                break.
            } if (ch = "r") {
                clearguis().
                reboot.
            } if (ch = "s") {
                clearguis().
                shutdown.
            }
        }

        wait 0.
    }
    window:dispose().
    print("program terminated").
}

main().