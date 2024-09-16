parameter w, env, wid, wcl, mlog.

local BOOT_PATH to "1:/env/boot".
local MODE_PATH to "1:/env/mode".

// TODO: dynamically create list based off of config file in disk
// TODO: add option to save new boot file
local bootpop_list to lex(
    "bootmgr", "0:/programs/bootmgr/main",
    "historian", "0:/programs/historian/main",
    "ascent", "0:/programs/ascent/main",
    "pegas", "0:/programs/pegasgui/main",
    "probectrl", "0:/programs/probectrl/main",
    "handler", "1:/handler",
    "none", ""
).

set w:tab1 to lex(
    "t", "hlayout",
    "id", "tab1",
    "params", lex(
        "v", true,
        "p", recn(5)
    ),
    "child", list(
        lex(
            "t", "vbox",
            "params", lex(
                "w", 400,
                "m", recnn(0, 5, 0, 0)
            ),
            "child", list(
                label_field_pop("Boot", 40, "boot file path", "boot", read_sf(BOOT_PATH), "bootpop", bootpop_list:keys, bootpop_cb@),
                label_field("Mode", 40, "program mode", "mode", read_sf(MODE_PATH))
            )
        ),
        lex(
            "t", "vlayout",
            "child", list(
                lex(
                    "t", "button",
                    "params", lex(
                        "t", "Reload",
                        "m", recnn(0, 0, 5, 0),
                        "h", 25,
                        "oc", reload_cb@
                    )
                ),
                lex(
                    "t", "button",
                    "params", lex(
                        "t", "Save",
                        "h", 25,
                        "oc", save_cb@
                    )
                )
            )
        )
    )
).

function bootpop_cb {
    parameter val.
    set wid:boot:text to bootpop_list[val].
}

function reload_cb {
    set wid:boot:text to read_sf(BOOT_PATH).
    set wid:mode:text to read_sf(MODE_PATH).
    mlog:add("loaded ship env").
}

function save_cb {
    write_sf(wid:boot:text, BOOT_PATH).
    write_sf(wid:mode:text, MODE_PATH).
    mlog:add("saved changes to ship env").
}