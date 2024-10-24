parameter w, env, wid, wcl, mlog.

local special_keys_switch to true.
local ps1 to get_ps1().
local last_cmd to "".
local cursor_pos to 0.

runoncepath("0:/programs/terminal/commands", env, wid).

local commands to lex(
    "shutdown", shutdown_cmd@,
    "reboot", reboot_cmd@,
    "exit", exit_cmd@,
    "clear", clear_cmd@,
    "man", {},
    "ls", ls_cmd@,
    "cd", cd_cmd@,
    "cp", cp_cmd@,
    "mv", {},
    "rm", rm_cmd@
).

set w:cmdline to lex("t", "hlayout", "child", list(
    lex("t", "vbox", "params", lex("p", recn(5,0), "w", 600), "child", list(
        lex("t", "label", "id", "history", "params", lex("t", "", "v", false, "f", "consolas bold", "fs", 15)),
        lex("t", "label", "id", "cmdline", "params", lex("m", recnn(0,0,8,0), "t", ps1, "f", "consolas bold", "fs", 15)),
        lex("t", "label", "id", "cursor", "params", lex("t", "^":padleft(ps1:length+1), "f", "consolas bold", "fs", 15))
    )),
    lex("t", "vlayout", "child", list(
        lex("t", "field", "id", "keyinput", "params", lex("t", "", "h", 20, "tip", "Press to Type", "och", key_input_cb@, "ocf", confirm_cb@))
    ))
)).

function key_input_cb {
    parameter t.

    set t to t[0].

    if (special_keys_switch and t = "[") {
        if (wid:cmdline:text:length - ps1:length > 0 and cursor_pos > 0) {
            set wid:cmdline:text to wid:cmdline:text:remove(ps1:length + cursor_pos - 1, 1).
            set cursor_pos to cursor_pos - 1.
        }
    } else if (special_keys_switch and t = "]") {
        if (wid:cmdline:text:length - ps1:length > 0 and cursor_pos < wid:cmdline:text:length - ps1:length) {
            set wid:cmdline:text to wid:cmdline:text:remove(ps1:length + cursor_pos, 1).
        }
    } else if (special_keys_switch and t = "{") {
        set wid:cmdline:text to get_ps1().
        set cursor_pos to 0.
    } else if (special_keys_switch and t = "<") {
        set cursor_pos to max(cursor_pos - 1, 0).
    } else if (special_keys_switch and t = ">") {
        set cursor_pos to min(cursor_pos + 1, wid:cmdline:text:length - ps1:length).
    } else if (special_keys_switch and t = "=") {
        set wid:cmdline:text to ps1 + last_cmd.
        set cursor_pos to last_cmd:length.
    } else if (t = "ç") {
        set special_keys_switch to not special_keys_switch.
    } else {
        set wid:cmdline:text to wid:cmdline:text:insert(ps1:length + cursor_pos, t).
        set cursor_pos to cursor_pos + 1.
    }

    set wid:cursor:text to "^":padleft(mod(ps1:length + cursor_pos + 1, 74)).
    set wid:keyinput:text to "".
}

function confirm_cb {
    parameter _t.

    local output to run_command().
    if (output = "") { return. }

    set wid:history:visible to true and (output <> "\clear").
    local hist to wid:history:text.

    set last_cmd to wid:cmdline:text:remove(0, ps1:length).
    set ps1 to get_ps1().
    set wid:history:text to hist + (choose hist if hist = "" else char(10)) + wid:cmdline:text + (choose "" if output:find("\skipout") >= 0 else char(10) + output).
    set wid:cursor:text to "^":padleft(ps1:length+1).
    set wid:cmdline:text to ps1.
    set cursor_pos to 0.

    if (output = "\clear") { set wid:history:text to "". }
}

function run_command {
    local args to filter(wid:cmdline:text:split(" "), {parameter a. return a:trim <> "".}).
    if (args:length = 1) { return "". }
    if (not commands:haskey(args[1])) {
        return "Command not found: " + args[1].
    }
    return commands[args[1]](args:sublist(2, args:length - 2)).
}

function get_ps1 {
    return "["+path()+"]$ ".
}