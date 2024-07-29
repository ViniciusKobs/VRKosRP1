function label_field {
    parameter lt, lw, ltip, fid, ft.
    return lex(
        "t", "hlayout",
        "params", lex(
            "h", 20,
            "m", recn(5, 7)
        ),
        "child", list(
            lex(
                "t", "label",
                "params", lex(
                    "t", lt,
                    "tip", ltip,
                    "w", lw,
                    "vs", true
                )
            ),
            lex(
                "t", "field",
                "id", fid,
                "params", lex(
                    "m", recn(2, 0),
                    "p", recnn(2, 5, 0, 5),
                    "t", ft,
                    "vs", true
                )
            )
        )
    ).
}

function label_field_pop {
    parameter lt, lw, ltip, fid, ft, pid, pop, cb.
    return lex(
        "t", "hlayout",
        "params", lex(
            "h", 20,
            "m", recn(5, 7)
        ),
        "child", list(
            lex(
                "t", "label",
                "params", lex(
                    "t", lt,
                    "tip", ltip,
                    "w", lw,
                    "vs", true
                )
            ),
            lex(
                "t", "field",
                "id", fid,
                "params", lex(
                    "t", ft,
                    "m", recn(2, 0),
                    "p", recnn(2, 5, 0, 5),
                    "vs", true
                )
            ),
            lex(
                "t", "popup",
                "id", pid,
                "params", lex(
                    "w", 80,
                    "vs", true,
                    "m", recn(2, 0),
                    "t", pop[0],
                    "op", pop,
                    "och", cb
                )
            )
        )
    ).
}