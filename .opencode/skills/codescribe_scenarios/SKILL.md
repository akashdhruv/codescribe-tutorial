---
name: codescribe.scenarios
description: This skill defines the two supported workflow scenarios and their required inputs.

---

## Scenario Detection

Identify the user's intent from context or ask directly:

| Scenario    | Description                                      |
|-------------|--------------------------------------------------|
| `generate`  | Generate new code from a prompt (no source files)|
| `translate` | Translate Fortran files to C++                   |

### Unsupported Requests

The following are **not supported** by CodeScribe planner/executor. If detected, refuse politely and redirect to default Plan/Build agents:

- Code updates / patches
- Code inspection / analysis
- TOML formatting
- Prompt review against source files

---

## Scenario: `generate`

**Purpose:** Generate new code from a prompt without requiring source files.

**Required inputs:**
- **Prompt** (exactly one of):
  - TOML file path, OR
  - Raw prompt string

**Optional inputs:**
- Reference files: list of paths for `-r` flags

**Validation:**
- If TOML path: validate with `codescribe.shell path_info`
- If reference files: validate each with `codescribe.shell path_info`

**Executor bundle commands (in order):**
1. `codescribe.model` - Resolve model ID
2. `codescribe.codescribe generate <prompt> [-r <refs>...] -m <model>` - Generate code

**CLI command:** `generate`

---

## Scenario: `translate`

**Purpose:** Translate Fortran source files to C++.

**Required inputs:**
- **Seed prompt TOML** file path (required)
- **Fortran target files**: explicit file paths only (no globs, no directories)

**Supported Fortran extensions:**
`.f` `.F` `.f90` `.F90` `.f95` `.F95` `.f03` `.F03` `.f08` `.F08` `.for` `.FOR`

**Validation:**
- Validate seed prompt TOML with `codescribe.shell path_info`
- Validate each Fortran file with `codescribe.shell path_info`
- Read the seed prompt TOML using `read` tool

**Executor bundle commands (in order):**
1. `codescribe.model` - Resolve model ID
2. `codescribe.codescribe index <root_dir>` - Index the project directory
3. `codescribe.codescribe draft <fortran_files>` - Generate .scribe metadata files
4. `codescribe.codescribe translate <fortran_files> -p <prompt> -m <model>` - Translate to C++

**Root directory calculation:**
- Determine `root_dir` as the lowest common ancestor of all Fortran files
- If only one file, use its parent directory

**CLI command:** `translate`

**Constraints:**
- NO `-r` (reference files) allowed for translate
- Fortran files only
