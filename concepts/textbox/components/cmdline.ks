parameter w, env, wid, wcl, mlog.

local special_keys_switch to true.
local cursor_pos to 0.
local cursor_pos_x to 0.
local cursor_pos_y to 0.

set w:cmdline to lex("t", "vlayout", "child", list(
    lex("t", "vbox", "params", lex("p", recn(5)), "child", list(
        lex("t", "vlayout", "child", list(
            lex("t", "label", "id", "xpos", "params", lex("m", recnn(0,0,10,25), "t", "v", "f", "consolas bold", "fs", 15)),
            lex("t", "hlayout", "child", list(
                lex("t", "label", "id", "ypos", "params", lex("w", 10, "m", recnn(0,10,0,0), "t", ">", "f", "consolas bold", "fs", 15)),
                lex("t", "label", "id", "cmdline", "params", lex("t", "", "f", "consolas bold", "fs", 15))
            ))
        ))
    )),
    lex("t", "field", "id", "keyinput", "params", lex("t", "", "w", 20, "och", key_input_cb@))
)).

function key_input_cb {
    parameter t.

    set t to t[0].

    if (special_keys_switch and t = "[") {
        if (wid:cmdline:text:length > 0 and cursor_pos > 0) {
            set wid:cmdline:text to wid:cmdline:text:remove(cursor_pos - 1, 1).
            set cursor_pos to cursor_pos - 1.
        }
    } else if (special_keys_switch and t = "]") {
        set wid:cmdline:text to wid:cmdline:text:insert(cursor_pos, char(10)).
        set cursor_pos to cursor_pos + 1.
    } else if (special_keys_switch and t = "{") {
        set wid:cmdline:text to "".
        set cursor_pos to 0.
    } else if (special_keys_switch and t = "<") {
        set cursor_pos to max(cursor_pos - 1, 0).
    } else if (special_keys_switch and t = ">") {
        set cursor_pos to min(cursor_pos + 1, wid:cmdline:text:length).
    } else if (t = "ç") {
        set special_keys_switch to not special_keys_switch.
    } else {
        set wid:cmdline:text to wid:cmdline:text:insert(cursor_pos, t).
        set cursor_pos to cursor_pos + 1.
    }

    update_cursor_xy().
    set wid:keyinput:text to "".
}

function update_cursor_xy {
    local i to 0.
    local x to 0.
    local y to 0.
    until (i >= cursor_pos) {
        if (wid:cmdline:text[i] = char(10)) {
            set x to 0.
            set y to y + 1.
        } else {
            set x to x + 1.
        }
        set i to i + 1.
    }
    set cursor_pos_x to x.
    set cursor_pos_y to y.
    draw_cursors().
}

function draw_cursors {
    set wid:xpos:text to "v":padleft(cursor_pos_x + 1).
    set wid:ypos:text to ">":padleft(cursor_pos_y + 1):replace(" ", char(10)).
}