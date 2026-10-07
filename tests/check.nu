use std/assert

def main [] {
    let package = ($env.FILE_PWD | path dirname)
    let fixture = ($nu.temp-path | path join $"nu-skill-check-(random uuid)")
    mkdir $fixture
    try {
        let examples = (open --raw ($package | path join 'references/examples.md')
            | split row '```nu' | skip 1 | each {|section| $section | split row '```' | first | str trim })
        assert equal ($examples | length) 8
        # Test the actual fenced examples, including empty collections and arguments.
        cd $fixture
        'aa' | save a.txt
        'bbbb' | save b.txt
        let largest = (^nu --no-config-file -c ($examples.0 + ' | to json --raw') | complete)
        assert equal $largest.exit_code 0
        assert equal ($largest.stdout | from json | get name) ['b.txt' 'a.txt']
        let text = (^nu --no-config-file -c $examples.1 | complete)
        assert equal $text.stdout $"b.txt(char nl)a.txt(char nl)"
        let printf_script = ($fixture | path join 'printf.nu')
        $examples.2 | save $printf_script
        let arguments = (^nu --no-config-file -c ($examples.2 + '; main "with spaces" "" "last"') | complete)
        assert equal $arguments.stdout $"with spaces(char nl)(char nl)last(char nl)"
        let empty_args = (^nu --no-config-file $printf_script | complete)
        assert equal $empty_args.stdout (char nl)
        # Replace only the fictional external executable with an argument printer.
        let environment_code = ('let label = "two words"; let args = ["" "tail"]; ' +
            ($examples.3 | str replace '^tool' '^printf "%s\\n"'))
        let environment = (^nu --no-config-file -c $environment_code | complete)
        assert equal $environment.exit_code 0
        assert equal $environment.stdout $"--label(char nl)two words(char nl)(char nl)tail(char nl)"
        let scoped = (^nu --no-config-file -c 'with-env {MODE: test} { ^nu --no-config-file -c "$env.MODE" }; $env.MODE? | to json --raw' | complete)
        assert equal $scoped.stdout $"test(char nl)null(char nl)"
        let failure_tool = ($fixture | path join 'failure.nu')
        'print --raw --no-newline out; print --stderr --raw --no-newline err; exit 7' | save $failure_tool
        let captured = (^nu --no-config-file -c ($examples.4 | str replace '^tool' $"^nu --no-config-file ($failure_tool | to nuon)") | complete)
        assert equal $captured.exit_code 7
        assert equal (open --raw output.txt) 'out'
        assert equal (open --raw error.txt) 'err'
        # Parsing is checked separately: the fictional tool is not executed.
        let parsed = (^nu --no-config-file -c $"nu-check --as-module ($package | path join 'install.nu' | to nuon)" | complete)
        assert equal $parsed.exit_code 0
        assert equal ($parsed.stdout | str trim) 'true'
        '[{"name":"two words"},{"name":""}]' | save data.json
        let structured = (^nu --no-config-file -c ($examples.5 + ' | to json --raw') | complete)
        assert equal $structured.exit_code 0
        assert equal ($structured.stdout | from json) ['two words' '']
        let plain = (^nu --no-config-file -c $examples.6 | complete)
        assert equal $plain.stdout $"two words(char nl)(char nl)"
        if not (which jq | is-empty) {
            let jq_output = (^nu --no-config-file -c $examples.7 | complete)
            assert equal $jq_output.exit_code 0
            assert equal $jq_output.stdout $plain.stdout
        }
        '[]' | save --force data.json
        let no_names = (^nu --no-config-file -c $examples.6 | complete)
        assert equal $no_names.exit_code 0
        assert equal $no_names.stdout ''
        let installer = ($package | path join 'install.nu')
        let linked_home = ($fixture | path join 'linked-home')
        for attempt in 1..2 {
            let installed = (^nu --no-config-file $installer --home $linked_home | complete)
            assert equal $installed.exit_code 0
        }
        let copied_home = ($fixture | path join 'copied-home')
        let copied = (^nu --no-config-file $installer --copy --home $copied_home | complete)
        assert equal $copied.exit_code 0
        let destinations = ['.agents/skills' '.claude/skills' '.jcode/skills'
            '.gemini/config/skills' '.gemini/antigravity/skills' '.gemini/antigravity-cli/skills']
        for destination in $destinations {
            assert equal (open --raw ($copied_home | path join $destination 'nu/SKILL.md')) (open --raw ($package | path join 'SKILL.md'))
            assert equal (($linked_home | path join $destination 'nu' | path expand)) $package
        }
        let refused = (^nu --no-config-file $installer --copy --home $copied_home | complete)
        assert ($refused.exit_code != 0)
        let blocked_home = ($fixture | path join 'blocked-home')
        let blocker = ($blocked_home | path join '.claude/skills/nu')
        mkdir $blocker
        'keep me' | save ($blocker | path join 'SKILL.md')
        let blocked = (^nu --no-config-file $installer --home $blocked_home | complete)
        assert ($blocked.exit_code != 0)
        assert equal (open --raw ($blocker | path join 'SKILL.md')) 'keep me'
        assert equal ($blocked_home | path join '.agents/skills/nu' | path exists --no-symlink) false
        cd $package
        rm --recursive $fixture
        print 'Passed: examples, exact line output, empty input, installation, repeat install, copy mode, conflict preservation.'
    } catch {|failure|
        cd $package
        rm --recursive $fixture
        $failure | to nuon | print
        error make {msg: $failure.msg}
    }
}
