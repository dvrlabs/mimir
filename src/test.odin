package main

import "core:fmt"
import "llm"

test :: proc() {
    test_ask()
    test_chat()
    test_code()
}


test_ask :: proc() {
    resp := llm.ask("Hello! Excited to ask some questions. ")
    defer llm.destroy_response(&resp)
    fmt.println(resp.answer)
}

test_chat :: proc() {
    session, loaded := llm.conversation_load_session()
    if !loaded {
        session = llm.chat_session_init("You are a helpful assistant")
    }
    defer delete(session.messages)
    defer llm.conversation_clear_session()
    defer llm.conversation_save_session(&session)

    resp_msg := `
       Nice weather we're having today! 
    `
    response := llm.chat(&session, resp_msg)
    fmt.println(response.answer)
}

test_code :: proc() {
    session, loaded := llm.code_load_session()
    system_prompt := `
        You are a code generator.
        You DO NOT converse, you only generate code when requested.
        Your output will directly be entered into a source code file.
        Your output MUST START with a markdown code designation.
        Your output MUST END by closing the code block.
    `
    if !loaded {
        session = llm.chat_session_init(system_prompt)
    }
    defer delete(session.messages)
    defer llm.code_clear_session()
    defer llm.code_save_session(&session)

    resp_msg := `
        Write a "hello world!" program in the Odin programming language. 
    `
    response := llm.chat(&session, resp_msg)
    fmt.println(response.answer)
}
