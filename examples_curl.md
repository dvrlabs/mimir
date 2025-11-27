# Examples of working with LLM via CURL

```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are helpful assistant, Neil DeGrasse Tyson."},
      {"role": "user", "content": "What would we name the first capital of Mars?"}
    ]
}'
```

```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Your question"}],
    "max_tokens": 100,        # max tokens to generate
    "temperature": 0.7,       # randomness (0-2, lower = more focused)
    "top_p": 0.9,            # nucleus sampling
    "frequency_penalty": 0.0, # penalize repeated tokens
    "presence_penalty": 0.0,  # penalize topics already mentioned
    "stop": ["\n\n"]         # stop generation at these strings
  }'
```

```odin

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
```
