package llm

import "core:os"
import "core:strings"

json_escape :: proc(s: string) -> string {
    builder := strings.builder_make()
    defer strings.builder_destroy(&builder)

    for r in s {
        switch r {
        case '"':
            strings.write_string(&builder, "\\\"")
        case '\\':
            strings.write_string(&builder, "\\\\")
        case '\n':
            strings.write_string(&builder, "\\n")
        case '\r':
            strings.write_string(&builder, "\\r")
        case '\t':
            strings.write_string(&builder, "\\t")
        case '\b':
            strings.write_string(&builder, "\\b")
        case '\f':
            strings.write_string(&builder, "\\f")
        case:
            strings.write_rune(&builder, r)
        }
    }

    return strings.clone(strings.to_string(builder))
}

ensure_directory :: proc(path: string) -> bool {
    if os.is_dir(path) {
        return true
    }

    return os.make_directory(path) == nil
}


expand_home :: proc(path: string) -> string {
    if !strings.has_prefix(path, "~") {
        return strings.clone(path)
    }

    home := os.get_env("HOME") // Unix/Linux/Mac
    if home == "" {
        home = os.get_env("USERPROFILE") // Windows
    }

    if len(path) == 1 {
        return strings.clone(home) // Just "~"
    }

    // "~/something" -> "/home/user/something"
    rest := path[2:] // Skip "~/"
    return strings.concatenate({home, "/", rest})
}
