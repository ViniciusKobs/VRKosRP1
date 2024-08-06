wait until ship:unpacked.
core:doevent("open terminal").
local defp to "0:/programs/bootmgr/main".
local benv to "1:/env/boot".
local menv to "1:/env/mode".
local t to lex("b", defp, "m", "0").
for i in core:tag:split(",") {
    local j to i:split("=").
    if (j:length > 1) {
        set t[j[0]] to "0:/" + j[1].
    }
}
if (not exists(benv)) {
    create(benv):write(t:b).
}
if (not exists(menv)) {
    create(menv):write(t:m).
}
// this part breaks when simulating directly into orbit
if (t:m >= 0) {
    local bp to open(benv):readall():string.
    if (bp:split(":")[0] = "0") {
        until (ship:connection:isconnected) {
            clearscreen. print("waiting connection").
            wait 5.
        }
    }
    runpath(bp).
}