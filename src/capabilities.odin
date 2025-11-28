package main

import "core:fmt"
import "llm"


ask :: proc(args: []string) {
    question := args[0]
    resp := llm.ask(question)
    defer llm.destroy_response(&resp)
    fmt.println(resp.answer)
}

chat :: proc(args: []string) {
    session, loaded := llm.conversation_load_session()
    if !loaded {
        session = llm.chat_session_init("You are a helpful assistant")
    }
    defer delete(session.messages)
    defer llm.conversation_save_session(&session)

    message := args[0]
    response := llm.chat(&session, message)
    fmt.println(response.answer)
}

clear_chat :: proc(args: []string) {
    llm.conversation_clear_session()
}

help :: proc() {
    fmt.println(help_text)
}

version :: proc() {
    fmt.println("Mimir v0.1.0")
}
