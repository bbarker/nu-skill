# User-level installation

Keep the Git checkout at `~/workspace/nu-skill`. Run `nu ~/workspace/nu-skill/install.nu` to link it into all the user skill directories below. No project files or global agent rules are needed.

On another system, clone your published repository into `~/workspace/nu-skill`, then run the same installer. `nu install.nu --copy` installs independent copies instead (also the default on Windows). Copies do not receive Git updates: after pulling, review and remove the old installed `nu` folders before reinstalling. The installer refuses to overwrite any existing unrelated skill or copy. Symlink installations can be rerun safely and update immediately when you pull the checkout.

Run `nu tests/check.nu` for the safe fixture checks. Requires Nushell 0.104 or newer; the bundled examples were exercised on 0.104.0. Symlink installation needs `ln` on Unix; copy installation uses Nu alone.

| Tool | User skill location | Invocation |
| --- | --- | --- |
| Codex | `~/.agents/skills/nu` | `$nu <request>` or select nu in `/skills` |
| Claude Code | `~/.claude/skills/nu` | `/nu <request>` |
| jcode | `~/.jcode/skills/nu` | `/nu <request>` |
| Antigravity IDE / 2.0 | `~/.gemini/config/skills/nu` | `/nu <request>` |
| Antigravity legacy IDE | `~/.gemini/antigravity/skills/nu` | Ask to use nu; slash support varies by version |
| Antigravity CLI | `~/.gemini/antigravity-cli/skills/nu` | `/nu <request>` |

Restart or refresh skill discovery in sessions already open. Codex uses `$nu` for explicit skill invocation; `/nu` is not a portable native slash alias across all hosts. You can also ask any host to use the nu skill in natural language.

Examples: `/nu find the five largest files in this directory`, `/nu convert this Bash program: ...`, or `$nu give structured and plain-text equivalents of ls -l`.

The package uses standard `name`/`description` frontmatter and relative references; it has no host-specific tools or variable substitution dependency. The compatibility links share one copy, so updates reach all hosts. When moving to another machine, copy the package and recreate the links in that user's home. Existing skills should never be overwritten without reviewing them.

Discovery paths and invocation references:

- [Codex skills](https://learn.chatgpt.com/docs/build-skills)
- [Claude Code skills](https://code.claude.com/docs/en/skills)
- [jcode skills](https://jcode.sh/docs#skills)
- [Antigravity skills](https://www.antigravity.google/docs/skills)

Validation on the installation machine covers package format, link integrity, and safe Nu examples. Hosts not installed on that machine require a fresh session on the machine where they run to confirm menu discovery; no remote UI discovery is implied.
