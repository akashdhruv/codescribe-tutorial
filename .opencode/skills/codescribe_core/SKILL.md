---
name: codescribe.core
description: This skill defines non-negotiable constraints that apply to ALL CodeScribe agents (planner and executor).

---

## Tool Restrictions

**Forbidden tools (never use):**
- `bash` - No shell command execution
- `write` - No direct file writing
- `edit` - No direct file editing

**Allowed tools:**
- `read` - Read file contents
- `codescribe.shell` - Path validation and directory listing only
- `codescribe.model` - Resolve model ID to CLI flag
- `codescribe.codescribe` - Execute CodeScribe CLI commands

## Path Validation Protocol

All path validation MUST use `codescribe.shell`:

```
codescribe.shell(command="path_info", path="<path>")
```

Returns: `{ path, exists: bool, kind: "file"|"dir"|"symlink"|null }`

Other shell commands:
- `codescribe.shell(command="pwd")` - Get current working directory
- `codescribe.shell(command="ls", path="<dir>")` - List directory contents

## Model Resolution Protocol

**Before ANY `codescribe.codescribe` call, you MUST:**

1. Call `codescribe.model(model_id="<agent frontmatter model>")`
2. Check the response:
   - If `ok=false`: STOP and report `error_code` + `message` to user
   - If `ok=true`: Use `codescribe_model` value for the `-m` flag

Example:
```
codescribe.model(model_id="argo_proxy/argo:gpt-5.2")
// Returns: { ok: true, codescribe_model: "argo-gpt4o" }
// Use: -m argo-gpt4o
```

## Input Restrictions

**No glob patterns:**
- If user provides globs (e.g., `src/*.F90`): respond with:
  > "I cannot expand glob patterns. Please provide explicit file paths."

**No directory scanning:**
- If user provides a directory instead of files: respond with:
  > "I cannot scan directories. Please provide explicit file paths."

## Loop Prevention

1. **One question at a time:** When inputs are invalid or missing, ask exactly ONE clarifying question, then wait for the response.

2. **Never re-ask:** If the user's answer doesn't resolve the issue, explain clearly what went wrong and wait. Do not repeat the same question.

3. **Maximum 2 attempts:** After 2 failed resolution attempts, STOP and summarize:
   - What was requested
   - What validation failed
   - What the user needs to provide

## Executor Command Bundle Contract

A "bundle" is the handoff format between planner and executor. It is a numbered list of tool calls:

```
1. codescribe.model(model_id="<agent-model-id>")
2. codescribe.codescribe(command="<cmd>", args=[...])
3. codescribe.codescribe(command="<cmd>", args=[...])
...
```

**Rules:**
- Step 1 is ALWAYS `codescribe.model`
- Subsequent steps are `codescribe.codescribe` calls
- Each step includes the exact `command` and `args` array
- No placeholders; all values must be concrete

**Translate bundle ordering (mandatory):**
For `translate` scenario bundles, the command order MUST be:
1. `codescribe.model` - Resolve model ID
2. `codescribe.codescribe index` - Index the project directory
3. `codescribe.codescribe draft` - Generate .scribe metadata files
4. `codescribe.codescribe translate` - Translate Fortran to C++
