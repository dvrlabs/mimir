package main

import "core:fmt"
import "llm"

main :: proc() {
    resp := llm.ask("Hello, my name is Jeffrey Gaboogle.")
    fmt.println(resp.answer)
    fmt.println(resp.error)
    fmt.println(resp.thoughts)

}
