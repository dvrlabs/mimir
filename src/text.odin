package main

HELP_TEXT :: `
Mimir - AI Chat CLI to talk with gpt-oss LLM via llama.cpp

Usage:
  mimir --ask (-a)              Ask a one-off question.
  mimir --chat (-c)             Chat in a conversation.
  mimir --code (-co)            Ask for code, or provide it via shell command substitution.
  mimir --clear-chat (-clrc)    Clear the chat session data, makes the LLM 'Forget'.
  mimir --clear-code (-clrco)   Clear the code session data, makes the LLM 'Forget'.
  mimir --help (-h)             Show this help
  mimir --version (-v)          Show version
`

VERSION_TEXT :: "Mimir v0.2.0"
