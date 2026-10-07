# Examples

These are patterns, not literal rewrites for every platform. Check against the target Nu version.

## Natural-language request: five largest regular files in this folder

Structured:

```nu
ls -a | where type == file | sort-by size --reverse | first 5 | select name size
```

Plain text, one filename per line (size is used for ordering):

```nu
let names = (ls -a | where type == file | sort-by size --reverse | first 5 | get name)
if not ($names | is-empty) {
    print --raw --no-newline (($names | str join (char nl)) + (char nl))
}
```

The native result uses Nu's file metadata and ordering. Filenames containing newlines are ambiguous in this text format; use structured data or a specified NUL-delimited protocol for that case. If GNU `ls` byte formatting itself is required, keep that external tool and its relevant flags instead.

## Bash: `printf '%s\n' "$@"`

Nu script:

```nu
def main [...arguments: string] {
    if ($arguments | is-empty) {
        print --raw --no-newline (char nl)
    } else {
        print --raw --no-newline (($arguments | str join (char nl)) + (char nl))
    }
}
```

No arguments still emits a newline, as Bash `printf` does. Spaces and empty arguments are retained by the function. Nu 0.104's script CLI can discard empty positional arguments before `main` receives them; callers requiring those exact empty arguments need a verified target version or a structured input channel. The fixture checks call `main` with Nu values to test the function independently of that CLI behavior.

## Bash: `MODE=test tool --label "$label" "${args[@]}"`

```nu
with-env {MODE: test} {
    ^tool --label $label ...$args
}
```

Assumes `label` is a string and `args` is a Nu list of arguments. The environment change is scoped to the block. The executable's output is already external output, so a duplicate text variant is unnecessary.

## Bash: `tool >output.txt 2>error.txt; status=$?; exit "$status"`

```nu
let result = (^tool | complete)
$result.stdout | save --force --raw output.txt
$result.stderr | save --force --raw error.txt
exit $result.exit_code
```

This captures output before writing, so it buffers instead of streaming. For large or binary output use Nu's target-version external redirection syntax directly, preserve the exit code, and verify it with fixtures. `exit` belongs in a standalone script here, since it would exit an interactive Nu session.

## Bash: `cat data.json | jq -r '.[].name'`

Structured:

```nu
open data.json | get name
```

For an array whose `name` fields are all strings, line output:

```nu
let names = (open data.json | get name)
if not ($names | is-empty) {
    print --raw --no-newline (($names | str join (char nl)) + (char nl))
}
```

For jq's exact behavior on missing fields, nulls, numbers, and mixed types, retain jq:

```nu
open --raw data.json | ^jq -r '.[].name'
```

The text variant's precondition matters: `get name` can fail where jq would emit `null`.
