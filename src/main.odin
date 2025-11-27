package main

import "core:fmt"
import "llm"

main :: proc() {
    test_ask()
    test_chat()
}

test_ask :: proc() {
    resp := llm.ask("Hello! Excited to ask some questions. ")
    defer llm.destroy_response(&resp)
    fmt.println(resp.answer)
}

test_chat :: proc() {
    session, loaded := llm.load_session()
    if !loaded {
        session = llm.chat_session_init("You are a helpful assistant")
    }
    defer delete(session.messages)
    defer llm.save_session(&session)

    resp2_msg := `
        Can you help me update this nice code to also be a pyqt5 gui so i can test it? 
    `
    response2 := llm.chat(&session, resp2_msg)
    fmt.println(response2.answer)
}
