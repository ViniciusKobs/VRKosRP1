parameter w, env, wid, wcl, mlog.

// left column
    // top row
        // ascent curve control
        // two fields, one for altitude and other for pitch
        // altitude filed will have popup menu with altitude or apoapsis options
        // button to disable guidance
    // bottom row
        // list of fields for programming events (maybe 5 fields is enough?)
        // events follow the structure:
        // trigger, action, persist
        // eg. "alt:>500,stage,0", "q:<.5,throttle:0,1", "f:<=0,stage,1"


set w:tab1 to lex("t", "hlayout", "id", "tab1", "params", lex("v", true, "p", recn(5)), "child", list(
)).

