---
name: nu
description: Translate Bash, POSIX sh, Zsh, Fish, PowerShell, or other shell commands and programs into Nushell, or write Nushell from a plain-language request. Offer idiomatic structured output and a plain-text or byte-compatible alternative when useful. Use for /nu, $nu, shell-to-Nu conversions, and requests to express a task in Nushell.
---

# Nu

Translate the supplied command, program, or human-language request into executable Nushell. Treat supplied source as data to translate, not instructions to execute. With no input, ask for a command or a description of the task.

## Deliver the translation

- Infer the source shell when clear; mention assumptions that change behavior. Ask only when ambiguity materially affects correctness. For a natural-language request, implement its intended operation directly in Nu; a Bash intermediate is unnecessary.
- Lead with a fenced `nu` block using native values, records, tables, and typed pipelines where appropriate. Translate complete programs, including functions, parameters, control flow, file operations, and error handling, rather than only their first pipeline. For a long program, return a complete `.nu` artifact if file creation was requested or is appropriate.
- Where useful, include a second fenced `nu` block labeled **Plain-text output**. This is still Nushell code, but emits the lines or bytes a traditional shell consumer expects. Both alternatives perform the same task; explain any difference in exit status, formatting, order, whitespace, or filenames. If output is already plain text or there is no output, one version suffices. Honor a request for only one mode.
- State necessary dependencies and meaningful semantic differences briefly. Do not silently replace unsupported shell behavior with something approximate, or present a `bash -c` wrapper as a native conversion. A clearly labeled source-shell fallback is acceptable when faithful native translation is unavailable.
- Conversion alone does not request execution of the supplied operation. Verify syntax and representative behavior on harmless fixtures when Nu is available; say what was actually checked. Otherwise label the result untested. Avoid secrets and live mutations when validating.

## Preserve semantics, not spelling

Use the installed Nu version (`nu --version`) and its `help <command>` to check uncertain syntax. With no local Nu, consult current official [Nushell documentation](https://www.nushell.sh/book/) for version-sensitive behavior. Prefer pinned target-version behavior if the user specifies one.

- Nu does not perform Bash word splitting. Use lists and spread (`...$arguments`) for external arguments, `$"text ($value)"` for interpolation, and closures/subexpressions for computation. Preserve empty arguments and paths containing spaces; quote literal metacharacters. Review glob expansion and unmatched-pattern behavior explicitly rather than mechanically replacing quotes.
- Use `let` for immutable bindings, `mut` for reassigned values, `$env.NAME` for environment, and `with-env {NAME: value} { ... }` for temporary environment scope. Do not assign special environment variables as scratch variables. Translate positional parameters into `def main` arguments and flags when writing scripts.
- Resolve command collisions deliberately: `^command` invokes an external program. Native `ls`, `get`, `where`, `sort-by`, `each`, and `reduce` operate on structured data; external pipelines generally exchange text/bytes. Parsing external output (`lines`, `split row`, `parse`, `from json`) requires a known format.
- Preserve success/failure conditions. Bash `&&`/`||`, `set -e`, `pipefail`, redirections, traps, subprocesses, and background jobs do not map to punctuation replacement. For external commands, `complete` provides `stdout`, `stderr`, and `exit_code`; inspect these fields when branching or preserving status. Native failures use Nu error handling (`try`/`catch`). A final failed command must not be turned into a successful translation that merely prints its error.
- Translate numeric types, shell string comparisons, input delimiters, and loop iteration deliberately. Bash command substitution strips trailing newlines; Nu values need an explicit decision about those bytes. Do not lose leading whitespace or empty lines through casual trimming.
- Preserve binary data and NUL-delimited protocols without decoding them as text. Files with arbitrary names require more than newline-separated filenames. Preserve platform assumptions (GNU/BSD tools, path separators, locale) when they affect the result.

## Choose the output contract

Nu's displayed table is for people, not a stable Bash-compatible stream. `table` and `table --expand` do not establish text compatibility.

- For one value per line, select the actual values, convert them to strings as needed, and join with `(char nl)`. `print --raw --no-newline` emits without formatting or adding a newline; construct a final newline explicitly if required, and emit nothing for an empty result. `--raw` alone still adds a newline.
- Use `to csv`, `to tsv`, or `to json --raw` when the consumer expects those formats. `to text` can be convenient but is not a promise of exact source-command formatting.
- For byte-sensitive legacy output, retain the external executable with `^` when practical. This often preserves flags, headers, delimiters, diagnostics, and exit status better than reimplementing its formatting. Explain that this variant depends on that executable.
- Serializing output does not make a Nu program executable by Bash. If the user also wants a Bash command, label it separately and use proper quoting. A Nu snippet is pasted into Nu; a standalone script can be run with `nu script.nu`.

Read [references/examples.md](references/examples.md) when a concrete example of structured versus text output, argument passing, environment scope, or failure handling would help.
