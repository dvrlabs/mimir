package llm

import "core:encoding/json"
import "core:fmt"
import "core:strings"
import "http"

ENDPOINT :: "http://localhost:8000/v1/chat/completions"
DEFAULT_SYSTEM_ROLE :: "You are a helpful assistant."
THOUGHT_ANSWER_DELIMITER :: "<|end|><|start|>assistant<|channel|>final<|message|>"

LLM_Response :: struct {
    response: string,
    thoughts: string,
    answer:   string,
    error:    bool,
}

destroy_response :: proc(resp: ^LLM_Response) {
    delete(resp.response)
    delete(resp.thoughts)
    delete(resp.answer)
}

Message :: struct {
    role:    string,
    content: string,
}

Chat_Session :: struct {
    messages:      [dynamic]Message,
    system_prompt: string,
}


destroy_session :: proc(sesh: ^Chat_Session) {
    for msg in sesh.messages {
        delete(msg.role)
        delete(msg.content)
    }
    delete(sesh.messages)
    delete(sesh.system_prompt)
}

add_message :: proc(sesh: ^Chat_Session, role: string, content: string) {
    append(&sesh.messages, Message{strings.clone(role), strings.clone(content)})
}


chat_session_init :: proc(system_prompt: string) -> Chat_Session {
    session := Chat_Session {
        system_prompt = system_prompt,
    }
    add_message(&session, "system", system_prompt)
    return session
}

chat :: proc(session: ^Chat_Session, user_message: string) -> LLM_Response {
    headers := make(map[string]string)
    headers["Content-Type"] = "application/json"
    defer delete(headers)

    add_message(session, "user", user_message)

    builder := strings.builder_make()
    defer strings.builder_destroy(&builder)

    strings.write_string(&builder, `{"messages":[`)
    for msg, i in session.messages {
        if i > 0 do strings.write_string(&builder, ",")

        escaped_role := json_escape(msg.role)
        defer delete(escaped_role)
        escaped_content := json_escape(msg.content)
        defer delete(escaped_content)

        // Build JSON manually without format specifiers
        strings.write_string(&builder, `{"role":"`)
        strings.write_string(&builder, escaped_role)
        strings.write_string(&builder, `","content":"`)
        strings.write_string(&builder, escaped_content)
        strings.write_string(&builder, `"}`)
    }
    strings.write_string(&builder, `]}`)

    body := strings.to_string(builder)

    // Debug: print the body to verify it's valid JSON
    // fmt.println("Request body:", body)

    response := post_to_llm(ENDPOINT, body, headers)
    add_message(session, "assistant", response.answer)
    return response
}

ask :: proc(question: string) -> LLM_Response {
    headers := make(map[string]string)
    headers["Content-Type"] = "application/json"
    defer delete(headers)

    escaped_system := json_escape(DEFAULT_SYSTEM_ROLE)
    defer delete(escaped_system)
    escaped_question := json_escape(question)
    defer delete(escaped_question)

    // Build JSON manually without format specifiers
    builder := strings.builder_make()
    defer strings.builder_destroy(&builder)

    strings.write_string(&builder, `{"messages":[{"role":"system","content":"`)
    strings.write_string(&builder, escaped_system)
    strings.write_string(&builder, `"},{"role":"user","content":"`)
    strings.write_string(&builder, escaped_question)
    strings.write_string(&builder, `"}]}`)

    body := strings.to_string(builder)

    // Debug: print the body to verify it's valid JSON
    // fmt.println("Request body:", body)

    response := post_to_llm(ENDPOINT, body, headers)
    return response
}

post_to_llm :: proc(url: string, body: string, headers: map[string]string = nil) -> LLM_Response {
    resp := http.pst(url, body, headers)
    defer http.response_destroy(&resp)

    if !resp.ok || resp.status_code != 200 {
        fmt.eprintln("ERROR: response was not okay 200. Status:", resp.status_code)
        err_text := "ERROR: response was not okay 200."
        return LLM_Response {
            response = strings.clone(err_text),
            thoughts = strings.clone(err_text),
            answer = strings.clone(err_text),
            error = true,
        }
    }

    data, err := json.parse_string(resp.body)
    defer json.destroy_value(data)

    if err != .None {
        fmt.eprintln("ERROR: Unable to parse JSON! Error:", err)
        fmt.eprintln("Response body:", resp.body)
        err_text := "ERROR: Unable to parse JSON!"
        return LLM_Response {
            response = strings.clone(err_text),
            thoughts = strings.clone(err_text),
            answer = strings.clone(err_text),
            error = true,
        }
    }

    obj := data.(json.Object)
    choices := obj["choices"].(json.Array)
    first_choice := choices[0].(json.Object)
    message := first_choice["message"].(json.Object)
    content := message["content"].(json.String)

    parts := strings.split(content, THOUGHT_ANSWER_DELIMITER)
    defer delete(parts)

    llm_response := LLM_Response {
        response = strings.clone(content),
        thoughts = strings.clone(parts[0]),
        answer   = strings.clone(parts[1]),
        error    = false,
    }
    return llm_response
}
