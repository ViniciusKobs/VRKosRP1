if (not (defined NL)) {
    global NL to char(10).
}

// intended for use with angles
function abs_mod {
    local parameter a, b is 360.
    local abs_b to abs(b).
    local mod_a to mod(a, abs_b).
    local abs_a to choose mod_a if a >= 0 else abs_b + mod_a.
    return abs_a.
}

function btoi {
    parameter b.
    return choose 1 if b else 0.
}

function itob {
    parameter i.
    return not (i = 0).
}

function stob {
    parameter s.
    return s = "true".
}

function map {
    local parameter l, cb.
    local nl to list().
    for i in l {
        nl:add(cb(i)).
    }
    return nl.
}

function filter {
    local parameter l, cb.
    local fl to list().
    for i in l {
        if (cb(i)) {
            fl:add(i).
        }
    }
    return fl.
}

function count {
    local parameter l, cb.
    local c to 0.
    for i in l {
        if (cb(i)) {
            set c to c + 1.
        }
    }
    return c.
}

function clamp {
    parameter n, mn, mx.
    return max(mn, min(mx, n)).
}

function in_range {
    parameter n, mn, mx.
    return (n >= mn) and (n <= mx).
}

function format_int {
    parameter num, lp is 2.
    local nstr to num:tostring.
    return "":padright(max(0, lp - nstr:length)):replace(" ", "0") + nstr.
}

function format_float {
    parameter num,      // decimal number
              rp is 2,  // number of digits on the right side of the dot
              lp is 1.  // max number of digits on the left side of the dot

    local nsplt to num:tostring:split(".").
    if (nsplt:length = 1) {
        nsplt:add("0").
    }

    local clp to nsplt[0]:length.
    local crp to nsplt[1]:length.

    local whole to "":padright(max(0, lp - clp)) + nsplt[0].
    local frac to nsplt[1]:substring(0, min(crp, rp)) + "":padright(max(0, rp - crp)):replace(" ", "0").

    return whole+"."+frac.
}

function format_vector {
    parameter vec, rp is 2.
    return "[ " + format_float(vec:x, rp) + ", " + format_vector(vec:y, rp) + ", " + format_float(vec:z, rp) + " ]".
}

function is_leap_year {
    parameter y.
    return ((mod(y,4) = 0) and (mod(y, 100) <> 0)) or (mod(y, 400) = 0).
}

function days_in_month {
    parameter m, y is -1.
    local days to list(31, 28 + btoi(is_leap_year(y)), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31).
    return days[clamp(m-1, 0, 11)].
}

function rssdate {
    parameter s is time:seconds.

    local year to 1951.
    local mon to 1.
    local day to 1.
    local hour to 0.
    local mins to 0.
    local sec to 0.

    set sec to sec + s.

    set mins to mins + floor(sec / 60).
    set sec to mod(sec, 60).

    set hour to hour + floor(mins / 60).
    set mins to mod(mins, 60).

    set day to day + floor(hour / 24).
    set hour to mod(hour, 24).

    until (day <= days_in_month(mon, year)) {
        set day to day - days_in_month(mon, year).
        set mon to mon + 1.
        if (mon > 12) {
            set mon to 1.
            set year to year + 1.
        }
    }   

    return year + "-" + format_int(mon) + "-" + format_int(day).
}

// ------------ OLD UTIL FUNCTIONS ---------------
// TODO: review, rewrite and remove functions as needed

// boolean to integer
// (bool) -> int
function utl_btoi {
    parameter b.
    return choose 1 if b else 0.
}

// string to boolean
// (string) -> bool
function utl_stob {
    parameter s.
    return choose true if (s = "True") else false.
}

// () -> void
function utl_opent {
    core:doevent("Open Terminal").
}

// () -> void
function utl_closet {
    core:doevent("Close Terminal").
}

// () -> void
function utl_terminate {
    local parameter m.
    clearscreen.
    print(m).
    local _good_bye_ to 1 / 0.
}

// TODO: REMOVE COMPLETLY AND REPLACE WITH ARCTAN2 (didn't know about it when I made this function)
// returns the angle of the given cosine and sine values
// (scalar(deg), scalar(deg)) -> scalar(deg)
function utl_cstoa {
    local parameter c, s.
    return choose arccos(c) if s >= 0 else 360 - arccos(c).
}

function utl_nlconcat {
    local parameter l1, l2.
    local l3 to l1:copy.
    for i in l2 {
        l3:add(i).
    }
    return l3.
}

function utl_lconcat {
    local parameter l1, l2.
    for i in l2 {
        l1:add(i).
    }
}

function utl_nlfilter {
    local parameter l, cb.
    local fl to list().
    for i in l {
        if (cb(i)) {
            fl:add(i).
        }
    }
    return fl.
}

function utl_bsort {
    local parameter l, asc is true.
    local i to 0.
    until (i >= l:length) {
        local swp to false.
        local j to 0.
        until (j >= (l:length - 1)) {
            if (choose l[j] > l[j + 1] if asc else l[j] < l[j + 1]) {
                local tmp to l[j].
                set l[j] to l[j + 1].
                set l[j + 1] to tmp.
                set swp to true.
            }
            set j to j + 1.
        }
        if (not swp) {
            break.
        }
        set i to i + 1.
    }
}

function utl_lprint {
    local parameter t, x, y.
    print("":padright(terminal:width - ("" + t):length):insert(x, t)) at(0, y).
}