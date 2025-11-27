package llm

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

CHAT_HISTORY_FILE :: "~/.config/mimir/chat_history.json"


save_session :: proc(session: ^Chat_Session) -> bool {
    // Expand home directory
    expanded_path := expand_home(CHAT_HISTORY_FILE)
    defer delete(expanded_path)

    // Ensure directory exists
    dir := filepath.dir(expanded_path)
    if !ensure_directory(dir) {
        fmt.eprintln("Failed to create config directory:", dir)
        return false
    }

    // Marshal session to JSON
    data, err := json.marshal(session^, {pretty = true})
    if err != nil {
        fmt.eprintln("Failed to marshal session:", err)
        return false
    }
    defer delete(data)

    // Write to file
    ok := os.write_entire_file(expanded_path, transmute([]byte)data)
    if !ok {
        fmt.eprintln("Failed to write session file:", expanded_path)
    }
    return ok
}

load_session :: proc() -> (Chat_Session, bool) {
    // Expand home directory
    expanded_path := expand_home(CHAT_HISTORY_FILE)
    defer delete(expanded_path)

    // Read file
    data, ok := os.read_entire_file(expanded_path)
    if !ok {
        // File doesn't exist - this is fine for first run
        return {}, false
    }
    defer delete(data)

    // Unmarshal JSON
    session: Chat_Session
    err := json.unmarshal(data, &session)
    if err != nil {
        fmt.eprintln("Failed to unmarshal session:", err)
        return {}, false
    }

    return session, true
}

// Usage in CLI:
example :: proc() {
    // Try to load existing session
    session, loaded := load_session()
    if !loaded {
        // Create new session if none exists
        session = chat_session_init("You are a helpful assistant")
    }
    defer delete(session.messages)
    defer save_session(&session) // Save on exit

    // Get user input
    if len(os.args) < 2 {
        fmt.println("Usage: program <message>")
        return
    }

    user_message := strings.join(os.args[1:], " ")
    defer delete(user_message)

    // Chat and print response
    response := chat(&session, user_message)
    defer destroy_response(&response)

    fmt.println(response.answer)

    // Session automatically saved on exit via defer
}
