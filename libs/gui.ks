// WARNING: THERE ARE NO ERROR HANDLERS. USE WITH CAUTION

// default width for gui
local DEFW to 500.

local createw_cbs to lex(
    "gui",     { parameter wdgt. local w to gui(DEFW). wdgt:add(w). return w. },
    "hbox",    { parameter wdgt. return wdgt:addhbox().        },
    "vbox",    { parameter wdgt. return wdgt:addvbox().        },
    "hlayout", { parameter wdgt. return wdgt:addhlayout().     },
    "vlayout", { parameter wdgt. return wdgt:addvlayout().     },
    "label",   { parameter wdgt. return wdgt:addlabel("").     },
    "tip",     { parameter wdgt. return wdgt:addtipdisplay().  },
    "field",   { parameter wdgt. return wdgt:addtextfield(""). },
    "button",  { parameter wdgt. return wdgt:addbutton("").    },
    "popup",   { parameter wdgt. return wdgt:addpopupmenu().   },
    "hslider", { parameter wdgt. return wdgt:addhslider(0,0,1).},
    "vslider", { parameter wdgt. return wdgt:addvslider(0,0,1).},
    "check",  { parameter wdgt. return wdgt:addcheckbox("", true).    }
    // TODO: implement more parameters to suport these widgets
    // "check", { parameter wdgt. }, 
    // "radio", { parameter wdgt. },
).

local rect_cbs to lex(
    "l", { parameter rect, val. set rect:left to val.   },
    "r", { parameter rect, val. set rect:right to val.  },
    "t", { parameter rect, val. set rect:top to val.    },
    "b", { parameter rect, val. set rect:bottom to val. },
    "h", { parameter rect, val. set rect:h to val.      },
    "v", { parameter rect, val. set rect:v to val.      }
).

local params_cbs to lex(
    "t",  { parameter wdgt, val. set wdgt:text to val.             },
    "val",{ parameter wdgt, val. set wdgt:value to val.            },
    "min",{ parameter wdgt, val. set wdgt:min to val.              },
    "min",{ parameter wdgt, val. set wdgt:max to val.              },
    "tip",{ parameter wdgt, val. set wdgt:tooltip to val.          },
    "a",  { parameter wdgt, val. set wdgt:style:align to val.      },
    "oc", { parameter wdgt, val. set wdgt:onclick to val.          },
    "ocb",{ parameter wdgt, val. set wdgt:onclick to {val(wdgt).}. },
    "och",{ parameter wdgt, val. set wdgt:onchange to val.         },
    "tg", { parameter wdgt, val. set wdgt:toggle to val.           },
    "ot", { parameter wdgt, val. set wdgt:ontoggle to val.         },
    "pr", { parameter wdgt, val. set wdgt:pressed to val.          },
    "op", { parameter wdgt, val. set wdgt:options to val.          },
    "i",  { parameter wdgt, val. set wdgt:index to val.            },
    "v",  { parameter wdgt, val. set wdgt:visible to val.          },
    "e",  { parameter wdgt, val. set wdgt:enabled to val.          },
    "f",  { parameter wdgt, val. set wdgt:style:font to val.       },
    "fs", { parameter wdgt, val. set wdgt:style:fontsize to val.   },
    "fc", { parameter wdgt, val. set wdgt:style:textcolor to val.  },
    "sf", { parameter wdgt, val. set wdgt:skin:font to val.        },
    "w",  { parameter wdgt, val. set wdgt:style:width to val.      },
    "h",  { parameter wdgt, val. set wdgt:style:height to val.     },
    "hs", { parameter wdgt, val. set wdgt:style:hstretch to val.   },
    "vs", { parameter wdgt, val. set wdgt:style:vstretch to val.   },

    "m",  { parameter wdgt, val. for k in val:keys { rect_cbs[k](wdgt:style:margin, val[k]).  }},
    "p",  { parameter wdgt, val. for k in val:keys { rect_cbs[k](wdgt:style:padding, val[k]). }}
).

// set widged params
local function set_wparams {
    parameter wdgt, params, rec0 is false.
    if (rec0) {
        params_cbs:m(wdgt, recn(0)).
        params_cbs:p(wdgt, recn(0)).
    }
    for k in params:keys {
        params_cbs[k](wdgt, params[k]).
    }
}

global function create_element {
    // widget id map: lex, widget class map: lex, parent: widget or list if elm:t = gui, element, rec0 (true = no padding/margin false = default padding/margin)
    parameter wid, wcl, wdgt, elm, rec0 is true.
    local w to createw_cbs[elm:t](wdgt).
    if (elm:haskey("params")) {
        set_wparams(w, elm:params, rec0).
    }
    if (elm:haskey("child")) {
        for c in elm:child {
            create_element(wid, wcl, w, c, rec0).
        }
    }
    if (elm:haskey("id")) {
        set wid[elm:id] to w.
    }
    if (elm:haskey("cl")) {
        if (wcl:haskey(elm:cl)) {
            wcl[elm:cl]:add(w).
        } else {
            set wcl[elm:cl] to list(w).
        }
    }
    return w.
}

global function toggle_widget {
    parameter wdgt.
    set wdgt:visible to not wdgt:visible.
}

global function recn {
    parameter h, ve is -1.
    return lex("h", h, "v", choose ve if ve >= 0 else h).
}

global function recnn {
    parameter t, r_, b, l.
    return lex("t", t, "r", r_, "b", b, "l", l).
}