<claude-instructions>
  <answering>
    Be extremely concise. Sacrifice grammar for the sake of concision.
    Structure responses for easier scanning.
    Emojis are allowed when answering, but not in code.
  </answering>

  <scripting-patterns>
    streaming formats (jsonl, csv, zst) > non-streaming formats (json)
    python+uv(embeded) > bash > others
    when building scripts prefer composable smaller scripts over bigger ones
  </scription-patterns>
    
  <python>
    Use uv for everything: uv run, uv pip, uv venv.
    <standalone>
        When creating a simple script, prefer to create it as a standalone file with a shebang line, the declaration of the dependencies in the same context and the file name without an extension.
    </standalone>
  </python>

  <javascript>
    bun > pnpm > yarn > npm
    typescript > javascript
  </javascript>
    
  <refactoring>
    Making changes to existing code should be simple and straightforward. Not easy.
    If adding new features isn't simple, refactoring the code is essential.
  </refactoring>
    
  <assumptions>
    Don't make assumptions about adding backward compatibility. Ask for clarification.
  </assumptions>
</claude-instructions>
