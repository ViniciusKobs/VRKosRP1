parameter env, wid.

function shutdown_cmd {
    parameter _p.
    clearguis().
    shutdown.
}

function reboot_cmd {
    parameter _p.
    clearguis().
    reboot.
}

function exit_cmd {
    parameter _p.
    set env:should_exit to true.
}

function clear_cmd {
    parameter _p.
    return "\clear".
}

function ls_cmd {
    parameter args.

    if (args:length = 0) {
        return format_files(path():tostring).
    }

    if (args:length = 1 and args[0] = "-v") {
        return "[information]".
    }

    if (args:length = 1 and args[0] = "-l") {
        return format_files(path():tostring, true).
    }

    if (args:length = 1 and args[0][0] <> "-") {
        return format_files(args[0]).
    }

    if (args:length = 2 and args[0] = "-l" and args[1][0] <> "-") {
        return format_files(args[1], true).
    }

    return "invalid arguments".
}

function cd_cmd {
    parameter args.

    if (args:length = 0) {
        cd("1:/").
        return "\skipout".
    }

    if (args:length = 1 and args[0] = "-v") {
        return "[information]".
    }

    if (args:length = 1) {
        local path_ to format_path(args[0]).
        if (path_ = "") { return "directory not found". }
        cd(path_).
        return "\skipout".
    }

    return "invalid arguments".
}

function cp_cmd {
    parameter args.

    local path_from to list().
    local path_to to "".
    local override to false.
    local safe to true.

    log args to "0:log/cp".

    if (args:length = 1 and args[0] = "-v") { return "[information]". }

    if (args:length = 2 and args[0][0] <> "-" and args[1][0] <> "-") {
        set path_from to format_path(args[0]).
        set path_to to format_path(args[1]).
        return better_copy(path_from, path_to).
    }

    if (args:length > 2 and args[0][0] = "-" and count(args, {parameter a. return a[0] = "-".}) = 1) {
        for f in args[0]:remove(0, 1) {
            if (f <> "t" and f <> "o" and f <> "u") { return "invalid arguments".}
            if (f = "t") { set path_to to format_path(args[1]). set path_from to map(args:sublist(2, args:length - 2), {parameter arg. return format_path(arg).}). }
            if (f = "o") { set override to true. }
            if (f = "u") { set safe to false. }
        }

        if (path_from:typename = "list") {
            local msg to "".
            for p in path_from {
                set msg to msg + better_copy(p, path_to, override, safe) + char(10).
            }
            return msg.
        }

        return better_copy(path_from, path_to, override, safe).
    }

    return "invalid arguments".
}

function rm_cmd {
    parameter args.

    if (args:length = 1 and args[0] = "-v") { return "[information]". }

    local safe to true.
    local forced to false.

    if (args:length = 1 and args[0][0] <> "-") {
        return better_del(format_path(args[0])).
    }

    if (args:length > 1 and count(args, {parameter a. return a[0] = "-".}) <= 1) {
        if (args[0][0] = "-") {
            for f in args[0]:remove(0, 1) {
                if (f <> "f" and f <> "u") { return "invalid arguments".}
                if (f = "f") { set forced to true. }
                if (f = "u") { set safe to false. }
            }
        }
        local msg to "".
        for p in args:sublist(btoi(args[0][0] = "-"), args:length - btoi(args[0][0] = "-")) {
            set msg to msg + better_del(format_path(p), safe, forced) + char(10).
        }
        return msg.
    }

    return "invalid arguments".
}

function format_path {
    parameter path_.
    if (path_ = "." or path_:find("./") = 0) {
        set path_ to path():tostring + path_:remove(0, 1).
    } else if (path_[0] = "/") {
        set path_ to "0:"+path_.
    } else if (path_[0] = "~") {
        set path_ to "1:"+path_:remove(0, 1).
    } else if (path_:find("0:") = -1 and path_:find("archive:") = -1 and path_:find("1:") = -1) {
        local cur_path to path():tostring.
        set path_ to choose cur_path+path_ if cur_path[cur_path:length-1]="/" else cur_path+"/"+path_.
    }
    if (not exists(path_)) {
        return "".
    }
    return path_.
}

function format_files {
    parameter path_, verb is false.

    set path_ to format_path(path_).

    if (not exists(path_)) {
        return "directory not found: " + path_.
    }

    if (verb) {
        return map(open(path_):lex:values, {parameter f. return (choose "file " if f:isfile else "dir  ") + format_int(f:size, 5) + " " + f:name.}):join(char(10)).
    }

    return open(path_):lex:values:join(" ").
}

function better_copy {
    parameter path_from, path_to, override is false, safe is true.

    log "from: " + path_from to "0:log/cp".
    log "to: " + path_to to "0:log/cp".

    if ((path_to:find("archive:") = 0 or path_to:find("0:") = 0) and safe) {
        return "cannot copy to archive in safe mode".
    }

    if (path_from = "") {
        return "file or directory not found".
    }

    local file_from to open(path_from).

    if (file_from:isfile and path_to = "" and path_to[path_to:length-1] = "/") {
        copypath(path_from, path_to+file_from:name).
        return "\skipout".
    }

    if ((not file_from:isfile) and open(path_to):isfile) {
        return "cannot copy directory to file: " + path_from + " " + path_to.
    }

    if (file_from:isfile and open(path_to):isfile and (not override)) {
        return "file already exists: " + path_to.
    }

    copypath(path_from, path_to).
    return "\skipout".
}

function better_del {
    parameter path_, safe is true, forced is false.

    log path_ to "0:log/rm".

    if (path_ = "") {
        return "file or directory not found".
    }

    if ((path_:find("0:") = 0 or path_:find("archive:") = 0) and safe) {
        return "cannot delete file from archive in safe mode: " + path_.
    }

    if ((not open(path_):isfile) and (not forced)) {
        return "can only delete directories in forced mode: " + path_.
    }

    deletepath(path_).
    return "\skipout".
}