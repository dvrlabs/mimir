# What

This is a very basic CLI tool to interact with a local LLM running gpt-oss via llama.cpp.

It stores the session in `~/.config/mimir`.
There are two different json files to store two independent contexts, each of which can be cleared with a command.

One for code.
One for chatting.

# Why

There are hundreds of other AI CLI programs out there.
I made this one to learn a little about [Odin](https://odin-lang.org/).

# Built with Odin-lang version
	Odin:    dev-2025-11-nightly
	Backend: LLVM 20.1.8
