@lazyglobal off.

runoncepath("0:/libs/file").

local BOOT_PATH to "1:/env/boot".
local HOME_PATH to "0:/programs/bootmgr/main".
local PEGAS_PATH to "0:/programs/pegas/main".

local env to lex(
    "should_exit", false,
    "wait", 0,
    "launch", false
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
            "messages:" + char(10) +
            (choose "" if time:seconds > env:wait else ("waiting for: " + format_float(env:wait - time:seconds))) + char(10) +
            mlog:join(char(10))
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

        if (env:wait > time:seconds) {
        }

        if (env:launch and time:seconds >= env:wait) {
            set_mission().
            clearguis().
            runpath(PEGAS_PATH).
            write_sf(HOME_PATH, BOOT_PATH).
            reboot.
        }

        wait 0.
    }
    window:dispose().
    print("program terminated").
}

main().