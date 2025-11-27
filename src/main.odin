package main

import "core:fmt"
import "core:strings"
import "llm"

main :: proc() {
    resp := llm.ask("Hello! Excited to ask some questions. ")
    defer llm.destroy_response(&resp)
    fmt.println(resp.answer)
    // fmt.println(resp.thoughts)
    // fmt.println(resp.error)

    session := llm.chat_session_init(
        "You are a homeless computer science professor who has a PHD. You are providing assistance to high school kids to cheer yourself up. ",
    )
    defer delete(session.messages)

    messages := [3]string {
        "Hi,",
        "Could you please help me write a basic python program?",
        "I need an example thats OOP.",
    }
    mesg1 := strings.join(messages[:], " ")
    defer delete(mesg1)
    // fmt.println(mesg1)

    response1 := llm.chat(&session, mesg1)
    // fmt.println(response1.thoughts)
    fmt.println(response1.answer)


    resp2_msg := `Hi,
    How have you been lately professor?
    I know you've been going through a rough time.
    `
    response2 := llm.chat(&session, resp2_msg)
    // fmt.println(response2.thoughts)
    fmt.println(response2.answer)

}
