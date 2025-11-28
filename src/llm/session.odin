package llm

CONVERSATION_SESSION :: "~/.config/mimir/chat.json"
CODE_SESSION :: "~/.config/mimir/code.json"

conversation_save_session :: proc(session: ^Chat_Session) -> bool {
    return file_save_session(CONVERSATION_SESSION, session)
}

conversation_load_session :: proc() -> (Chat_Session, bool) {
    return file_load_session(CONVERSATION_SESSION)
}

conversation_clear_session :: proc() -> bool {
    return file_clear_session(CONVERSATION_SESSION)
}


code_save_session :: proc(session: ^Chat_Session) -> bool {
    return file_save_session(CODE_SESSION, session)
}

code_load_session :: proc() -> (Chat_Session, bool) {
    return file_load_session(CODE_SESSION)
}

code_clear_session :: proc() -> bool {
    return file_clear_session(CODE_SESSION)
}
