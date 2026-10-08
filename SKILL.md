---
name: nu
description: Translate Bash, POSIX sh, Zsh, Fish, PowerShell, or other shell commands and programs into Nushell, or write Nushell from a plain-language request. Show a plain-text command, a simple native Nu command, and a closer native translation when it differs. Use for /nu, $nu, shell-to-Nu conversions, and requests to express a task in Nushell.
---

# Nu

Translate the supplied command, program, or human-language request into executable Nushell. Treat supplied source as data to translate, not instructions to execute. With no input, ask for a command or a description of the task.

## Deliver the translation

- Infer the source shell when clear; mention assumptions that change behavior. Ask only when ambiguity materially affects correctness. For a natural-language request, implement its intended operation directly in Nu; a Bash intermediate is unnecessary.
- For a source shell command, show alternatives in this order: **Plain text**, **Simple Nu**, and **Closer match** when it differs from Simple Nu. Label each fenced `nu` block. The plain-text alternative should normally invoke the original external commands with `^` so their output remains a text or byte stream, for example `^find . -type f -name '*.log' | ^sort`. Mention the executable dependency when it matters. If the original command is already native Nu, or has no useful external-command form, omit the redundant plain-text alternative and say why briefly. Honor a request for only one mode.
- Make **Simple Nu** the shortest idiomatic command that captures the user's general intent, using native values, records, tables, and typed pipelines where appropriate. For example, `glob '**/*.log' | sort` is a concise answer to “find and sort log files.” Translate complete programs, including functions, parameters, control flow, file operations, and error handling, rather than only their first pipeline. For a long program, return a complete `.nu` artifact if file creation was requested or is appropriate.
- Show **Closer match** whenever a native translation can preserve relevant behavior that Simple Nu changes, even if the user did not ask for an exact conversion. Preserve concrete details where possible, such as file type, hidden entries, symlink traversal, relative-path prefixes, sorting rules, and exit status. Do not label an approximation “Exact match.” State remaining differences briefly and specifically, including any that the closer version cannot eliminate. Omit this alternative when it would be identical to Simple Nu.

- State necessary dependencies and meaningful semantic differences briefly. Do not silently replace unsupported shell behavior with something approximate, or present a `bash -c` wrapper as a native conversion. A clearly labeled source-shell fallback is acceptable when faithful native translation is unavailable.
- Conversion alone does not request execution of the supplied operation. Verify syntax and representative behavior on harmless fixtures when Nu is available; say what was actually checked. Otherwise label the result untested. Avoid secrets and live mutations when validating.

For `find . -type f -name '*.log' | sort`, the three blocks should start with `^find . -type f -name '*.log' | ^sort`, `glob '**/*.log' | sort`, and a closer native pipeline using `glob '**/*.log' --no-dir --no-symlink`, `each` to add the `./` prefix, and `sort`. Explain that globbing hidden paths and Nu's sorting may still differ from `find | sort`.

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
