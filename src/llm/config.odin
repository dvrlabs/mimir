package llm

import "base:runtime"
import "core:encoding/json"
import "core:fmt"
import "core:os"

CONFIG_PATH :: "~/.config/mimir/settings.json"
THOUGHT_ANSWER_DELIMITER :: "<|end|><|start|>assistant<|channel|>final<|message|>"

Config :: struct {
    endpoint:            string,
    default_system_role: string,
}

DEFAULT_CONFIG :: Config {
    endpoint            = "http://localhost:8000/v1/chat/completions",
    default_system_role = "You are a helpful assistant.",
}

CONFIG: Config


@(init)
load_config :: proc "contextless" () {
    context = runtime.default_context() // Need context for file I/O, allocations, etc.
    conf_file := expand_home(CONFIG_PATH)

    if !os.exists(conf_file) {
        data, marshal_err := json.marshal(DEFAULT_CONFIG, {pretty = true})
        if marshal_err != nil {
            fmt.eprintln("ERROR: Failed to marshal default config")
            return
        }
        defer delete(data)

        write_ok := os.write_entire_file(conf_file, data)
        if !write_ok {
            fmt.eprintln("ERROR: Failed to write default config")
            return
        }

        CONFIG = DEFAULT_CONFIG
        fmt.println("Created", conf_file)
        return
    }

    // Load existing config
    data, read_ok := os.read_entire_file(conf_file)
    if !read_ok {
        fmt.eprintln("ERROR: Failed to read config!")
        CONFIG = DEFAULT_CONFIG
        return
    }
    defer delete(data)

    unmarshal_err := json.unmarshal(data, &CONFIG)
    if unmarshal_err != nil {
        fmt.eprintln("ERROR: Failed to parse JSON, using defaults")
        CONFIG = DEFAULT_CONFIG
        return
    }
}
