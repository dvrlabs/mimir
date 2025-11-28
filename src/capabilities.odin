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
    defer llm.destroy_session(&session)
    defer llm.conversation_save_session(&session)

    message := args[0]
    response := llm.chat(&session, message)
    defer llm.destroy_response(&response)
    fmt.println(response.answer)
}

clear_chat :: proc(args: []string) {
    llm.conversation_clear_session()
    fmt.println("Cleared:", llm.CONVERSATION_SESSION)
}

code :: proc(args: []string) {
    session, loaded := llm.code_load_session()
    system_prompt := `
        You are a code generator.
        You DO NOT converse, you only generate code when requested.
        Your output will directly be entered into a source code file.
        Your output MUST NOT be in a markdown code block.
        When given a block of code, simply analyze it and respond "OK".
    `
    if !loaded {
        session = llm.chat_session_init(system_prompt)
    }
    defer llm.destroy_session(&session)
    defer llm.code_save_session(&session)

    message := args[0]
    response := llm.chat(&session, message)
    defer llm.destroy_response(&response)
    fmt.println(response.answer)
}

clear_code :: proc(args: []string) {
    llm.code_clear_session()
    fmt.println("Cleared:", llm.CODE_SESSION)
}

help :: proc() {
    fmt.println(HELP_TEXT)
}

version :: proc() {
    fmt.println(VERSION_TEXT)
}
