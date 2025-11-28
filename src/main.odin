package main

import "core:os"

Command :: enum {
    Ask,
    Chat,
    ClearChat,
    Help,
    Version,
}

parse_args :: proc() -> (Command, []string) {
    command := Command.Help
    args: [dynamic]string

    for i := 1; i < len(os.args); i += 1 {
        arg := os.args[i]

        switch arg {
        case "-a", "--ask":
            command = .Ask
        case "-c", "--chat":
            command = .Chat
        case "-clrc", "--clear-chat":
            command = .ClearChat
        case "-v", "--version":
            command = .Version
        case "-h", "--help":
            command = .Help
        case:
            append(&args, arg)
        }
    }

    return command, args[:]
}


main :: proc() {
    command, args := parse_args()
    defer delete(args)

    switch command {
    case .Ask:
        ask(args)
    case .Chat:
        chat(args)
    case .ClearChat:
        clear_chat(args)
    case .Version:
        version()
    case .Help:
        help()
    case:
        help()
    }
}
