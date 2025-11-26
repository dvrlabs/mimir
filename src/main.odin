package main

import "core:fmt"
import "http"

main :: proc() {
    // Simple GET request
    {
        resp := http.get("http://httpbin.org/get")
        defer http.response_destroy(&resp)

        if resp.ok {
            fmt.println("Status:", resp.status_code)
            fmt.println("Body:", resp.body)
        }
    }

    // GET with custom headers
    {
        headers := make(map[string]string)
        defer delete(headers)

        headers["User-Agent"] = "OdinHTTP/1.0"
        headers["Accept"] = "application/json"

        resp := http.get("http://httpbin.org/headers", headers)
        defer http.response_destroy(&resp)

        if resp.ok {
            fmt.println("\nHeaders test:")
            fmt.println(resp.body)
        }
    }


    // // POST with JSON to local LLM (Ollama)
    // {
    //
    //     headers := make(map[string]string)
    //     defer delete(headers)
    //
    //     headers["Content-Type"] = "application/json"
    //
    //     payload := `{
    //         "model": "llama2",
    //         "prompt": "Tell me a short joke",
    //         "stream": false
    //     }`
    //
    //     resp := http.pst("http://localhost:11434/api/generate", payload, headers)
    //     defer http.response_destroy(&resp)
    //
    //     if resp.ok && resp.status_code == 200 {
    //         fmt.println("\nLLM Response:")
    //         fmt.println(resp.body)
    //     } else {
    //         fmt.println("Request failed. Status:", resp.status_code)
    //     }
    // }

}
