package llm

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:path/filepath"


file_save_session :: proc(file_path: string, session: ^Chat_Session) -> bool {
    expanded_path := expand_home(file_path)
    defer delete(expanded_path)

    dir := filepath.dir(expanded_path)
    if !ensure_directory(dir) {
        fmt.eprintln("Failed to create config directory:", dir)
        return false
    }
    defer delete(dir)

    data, err := json.marshal(session^, {pretty = true})
    if err != nil {
        fmt.eprintln("Failed to marshal session:", err)
        return false
    }
    defer delete(data)

    ok := os.write_entire_file(expanded_path, transmute([]byte)data)
    if !ok {
        fmt.eprintln("Failed to write session file:", expanded_path)
    }
    return ok
}

file_load_session :: proc(file_path: string) -> (Chat_Session, bool) {
    expanded_path := expand_home(file_path)
    defer delete(expanded_path)

    data, ok := os.read_entire_file(expanded_path)
    if !ok {
        return {}, false
    }
    defer delete(data)

    session: Chat_Session
    err := json.unmarshal(data, &session)
    if err != nil {
        fmt.eprintln("Failed to unmarshal session:", err)
        return {}, false
    }

    return session, true
}

file_clear_session :: proc(file_path: string) -> bool {
    expanded_path := expand_home(file_path)
    defer delete(expanded_path)

    if !os.exists(expanded_path) {
        return false
    }

    err := os.remove(expanded_path)
    if err != nil {
        fmt.eprintln("Failed to clear session:", err)
        return false
    }

    return true
}
