# Examples of working with LLM, gpt-oss, via curl.

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
