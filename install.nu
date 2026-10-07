# Install this checkout for the current user. Use --home only for testing/custom homes.
def main [
    --copy # Copy rather than symlink; rerun after pulling updates.
    --home: path # Defaults to the current user's home.
] {
    let source = ($env.FILE_PWD | path expand)
    let user_home = (if $home == null { $nu.home-path } else { $home | path expand })
    let roots = [
        '.agents/skills'
        '.claude/skills'
        '.jcode/skills'
        '.gemini/config/skills'
        '.gemini/antigravity/skills'
        '.gemini/antigravity-cli/skills'
    ]
    let targets = ($roots | each {|root| $user_home | path join $root 'nu' })
    # Preflight every destination before installing anything. Refuse existing copies,
    # different links, and broken links; never remove another skill.
    for target in $targets {
        let occupied = ($target | path exists --no-symlink)
        let same_checkout = (if $occupied { ($target | path expand) == $source } else { false })
        if $occupied and not $same_checkout {
            error make {msg: $"Existing destination requires review: ($target)"}
        }
    }
    for target in $targets {
        if ($target | path exists --no-symlink) {
            print $"Already linked: ($target)"
        } else {
            mkdir ($target | path dirname)
            if $copy or $nu.os-info.name == 'windows' {
                cp --recursive $source $target
                # Keep installation copies independent of repository metadata.
                let copied_git = ($target | path join '.git')
                if ($copied_git | path exists --no-symlink) { rm --recursive --force $copied_git }
                print $"Copied: ($target)"
            } else {
                let result = (^ln -s $source $target | complete)
                if $result.exit_code != 0 {
                    error make {msg: $"Link failed for ($target): ($result.stderr)"}
                }
                print $"Linked: ($target)"
            }
        }
    }
    print 'Restart skill discovery. Claude Code/jcode/Antigravity: /nu; Codex: $nu.'
}
