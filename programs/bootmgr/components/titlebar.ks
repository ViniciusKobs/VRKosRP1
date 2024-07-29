parameter w, env, wid, wcl, mlog.

set w:titlebar to lex(
    "t", "hlayout",
    "params", lex(
        "h", 30,
        "p", recn(5)
    ),
    "child", list(
        lex(
            "t", "label",
            "params", lex(
                "t", "Boot File",
                "fs", 15,
                "vs", true
            )
        ),
        lex(
            "t", "button",
            "params", lex(
                "t", "R",
                "m", recnn(0, 0, 0, 5),
                "w", 22,
                "h", 22,
                "oc", reb_cb@
            )
        ),
        lex(
            "t", "button",
            "params", lex(
                "t", "S",
                "m", recnn(0, 0, 0, 5),
                "w", 22,
                "h", 22,
                "oc", shut_cb@
            )
        ),
        lex(
            "t", "button",
            "params", lex(
                "t", "_",
                "m", recnn(0, 0, 0, 5),
                "w", 22,
                "h", 22,
                "oc", min_cb@
            )
        ),
        lex(
            "t", "button",
            "params", lex(
                "t", "X",
                "m", recnn(0, 0, 0, 5),
                "w", 22,
                "h", 22,
                "oc", exit_cb@
            )
        )
    )
).

function reb_cb {
    clearguis().
    reboot.
}

function shut_cb {
    clearguis().
    shutdown.
}

function min_cb {
    toggle_widget(wid:cont).
}

function exit_cb {
    set env:should_exit to true.
}