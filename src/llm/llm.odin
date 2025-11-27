package llm

import "core:encoding/json"
import "core:fmt"
import "core:strings"
import "http"

ENDPOINT :: "http://localhost:8000/v1/chat/completions"
DEFAULT_SYSTEM_ROLE :: "You are a helpful assistant."
THOUGHT_ANSWER_DELIMITER :: "<|end|><|start|>assistant<|channel|>final<|message|>"


LLM_Response :: struct {
    thoughts: string,
    answer:   string,
    error:    bool,
}


ask :: proc(question: string, thoughts_only := false) -> LLM_Response {
    headers := make(map[string]string)
    defer delete(headers)

    headers["Content-Type"] = "application/json"

    template := `{{
        "messages": [
          {{"role": "system", "content": "%s"}},
          {{"role": "user", "content": "%s"}}
        ]
    }}`

    payload := fmt.aprintf(template, DEFAULT_SYSTEM_ROLE, question)
    defer delete(payload)

    // fmt.println(payload)

    resp := http.pst(ENDPOINT, payload, headers)
    defer http.response_destroy(&resp)

    if !resp.ok || resp.status_code != 200 {
        err_text := "ERROR: response was not okay 200."
        return LLM_Response{thoughts = err_text, answer = err_text, error = true}
    }

    data, err := json.parse_string(resp.body)
    defer json.destroy_value(data)

    if err != .None {
        err_text := "ERROR: Unable to parse JSON!"
        return LLM_Response{thoughts = err_text, answer = err_text, error = true}
    }

    obj := data.(json.Object)
    // fmt.println(obj)
    choices := obj["choices"].(json.Array)
    // fmt.println(choices)
    first_choice := choices[0].(json.Object)
    // fmt.println(first_choice)
    message := first_choice["message"].(json.Object)
    // fmt.println(message)
    content := message["content"].(json.String)
    // fmt.println(content)

    parts := strings.split(content, THOUGHT_ANSWER_DELIMITER)
    defer delete(parts)

    llm_response := LLM_Response {
        thoughts = strings.clone(parts[0]),
        answer   = strings.clone(parts[1]),
        error    = false,
    }

    return llm_response
}
