// read string file
global function read_sf {
    parameter fpath.
    return open(fpath):readall():string.
}

// write string file
global function write_sf {
    parameter cont, fpath, cl is true.
    local f to open(fpath).
    if (not exists(fpath)) {
        set f to create(fpath).
    }
    if (cl) {
        f:clear().
    }
    f:write(cont).
}

// read list file
global function read_lf {
    parameter fpath, sp is char(10).
    local c to open(fpath):readall():string:trim.
    return choose list() if c = "" else c:split(sp).
}

//global function read_lf {
    //parameter fpath, sp is char(10).
    //local c to open(fpath):readall():string:trim:split(sp).
//}

// read list file without trimming
global function read_lf_nt {
    parameter fpath, sp is char(10).
    return open(fpath):readall():string:split(sp).
}

// write list file
global function write_lf {
    parameter cont, fpath, sp is char(10), cl is true.
    local f to open(fpath).
    if (not exists(fpath)) {
        set f to create(fpath).
    }
    if (cl) {
        f:clear().
    }
    f:write(cont:join(sp)).
}

global function tag_parse {
    local tag to lex().
    for p in core:tag:split(",") {
        local kv to p:split("=").
        if (kv:length > 1) {
            set tag[kv[0]] to kv[1].
        }
    }
    return tag.
}