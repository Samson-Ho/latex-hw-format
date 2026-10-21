# Maintaining latex-hw-format

## Source of truth

| What | Where |
| --- | --- |
| GitHub repository | https://github.com/Samson-Ho/latex-hw-format (branch `main`) |
| Canonical local checkout | `~/Documents/Codex/latex-hw-format` |
| Editable skill directory | `~/Documents/Codex/latex-hw-format/latex-hw-format/` |
| OpenAI plugin manifest | `packaging/openai/plugin.json` |

Edit only the checkout. Everything else listed below is either a symlink to it or a
generated or app-managed copy.

## Edit, commit, push, pull

```sh
cd ~/Documents/Codex/latex-hw-format
git pull --ff-only                      # start from the current GitHub state
$EDITOR latex-hw-format/SKILL.md        # or references/, assets/
python3 scripts/build_dist.py --check   # validate
git add -A && git commit -m "..." && git push
```

Local Codex and Claude Code read the checkout through symlinks, so a new session sees the
edits immediately. Cloud copies do **not** update on push. Refresh them as described in
"Cloud installations" below.

## Local installations

`scripts/install_local.sh` links the discovery locations to the checkout. It is idempotent.
It moves an identical stray copy to a backup folder, and it refuses to replace a copy that
holds edits the repository does not have. `scripts/install_local.sh --check` reports the
status and exits non-zero if anything is wrong.

| App | Discovery location | How it is connected |
| --- | --- | --- |
| Claude Code (terminal) | `~/.claude/skills/latex-hw-format` | symlink to the canonical skill directory |
| Codex CLI / ChatGPT desktop app (Codex) | `~/.agents/skills/latex-hw-format` | symlink to the canonical skill directory |

Each app also receives an account-level copy (see the table below). Two per-machine settings
keep that copy from showing up as a second `latex-hw-format`:

- `~/.claude/settings.json` contains `"skillOverrides": {"anthropic-skills:latex-hw-format": "off"}`.
  This hides the copy synced from claude.ai in local Claude Code only. The account skill
  stays enabled on claude.ai.
- `~/.codex/config.toml` contains `[plugins."latex-hw-format@created-by-me-remote"]` with
  `enabled = false`. This disables the account plugin in local Codex only. The plugin stays
  installed for ChatGPT. Mention the skill in Codex as `$latex-hw-format`.

`~/.codex/skills/` is the legacy Codex location. Don't put the skill there, because Codex
would then list it twice.

On a new machine: clone the repo to the same path, run `scripts/install_local.sh`, and add
the two settings above.

## Cloud installations

A push to GitHub updates none of these automatically.

| Surface | Mechanism | Update procedure |
| --- | --- | --- |
| claude.ai web, Claude Desktop, Cowork | Account skill (uploaded ZIP) | Run `python3 scripts/build_dist.py`. On claude.ai, open **Customize → Skills**, delete the old `latex-hw-format`, then use **+ → Create skill → Upload a skill** with `dist/latex-hw-format-skill.zip`. |
| Claude Code on the web (cloud sessions) | Loads the claude.ai account skill at session start; also loads `.claude/skills/` committed in the cloned repo | Update the account skill as above. |
| ChatGPT (web/desktop/mobile) and the Codex app via the account | Private "created by me" plugin `latex-hw-format` (currently 0.1.0) | Bump `version` in `packaging/openai/plugin.json`, run `python3 scripts/build_dist.py`, then upload `dist/latex-hw-format-openai-plugin.zip` as the new version of the plugin in ChatGPT's Plugins page. This uses the same layout as the original upload. |
| Codex cloud tasks | Codex loads skills stored in the task's repository. Personal skills on this Mac are not synced. | Add the snippet below to the environment's install/setup script for the homework repo. Each new task fetches the current `main`. |

Codex cloud setup snippet (run from the repository root of the task):

```sh
git clone --depth 1 https://github.com/Samson-Ho/latex-hw-format.git /tmp/latex-hw-format
mkdir -p .agents/skills && rm -rf .agents/skills/latex-hw-format
cp -R /tmp/latex-hw-format/latex-hw-format .agents/skills/latex-hw-format
```

Don't commit that copy into the homework repo. If you need it pinned, clone a tag or SHA instead.

## Distribution packages

```sh
python3 scripts/build_dist.py
```

The command first validates the skill: required files are present, the frontmatter name
matches, and there are no symlinks or machine-specific paths. It then writes two
reproducible ZIPs into `dist/`, which is git-ignored:

- `latex-hw-format-skill.zip` contains `latex-hw-format/{SKILL.md,agents,assets,references}`.
- `latex-hw-format-openai-plugin.zip` contains `latex-hw-format/plugin.json` and
  `latex-hw-format/skills/latex-hw-format/...`.

## Generated or managed copies (do not edit)

| Path | Owner | Role |
| --- | --- | --- |
| `dist/` | `build_dist.py` | Upload artifacts. Regenerate them instead of editing. |
| `~/.claude/skills/synced/*/latex-hw-format` | Claude Code claude.ai sync | Download of the account skill; overwritten on sync. Hidden locally by `skillOverrides`. |
| `~/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin/*/skills/latex-hw-format` | Claude Desktop | Account skill for Desktop/Cowork local sessions. |
| `~/.codex/plugins/cache/created-by-me-remote/latex-hw-format/<version>/` | Codex remote-plugin install | Cache of the ChatGPT account plugin. Use `codex plugin` and the Plugins UI, not manual edits. |
| `~/.codex/.tmp/marketplaces/.staging/marketplace-add-*` | Codex | Leftovers from earlier `codex plugin marketplace add` attempts on this repo. They are not registered, and nothing loads them. |

## Restoring the 2026-10-21 consolidation

Backups live in `~/Documents/Codex/latex-hw-format-backups/consolidation-2026-10-21/`.
`MANIFEST.tsv` there maps each original path to its backup. To undo:

```sh
B=~/Documents/Codex/latex-hw-format-backups/consolidation-2026-10-21
rm ~/.claude/skills/latex-hw-format ~/.agents/skills/latex-hw-format   # symlinks only
mv "$B/dot-claude__skills__latex-hw-format" ~/.claude/skills/latex-hw-format
mv "$B/dot-codex__skills__latex-hw-format"  ~/.codex/skills/latex-hw-format
mv "$B/Downloads__latex-hw-format"           ~/Downloads/latex-hw-format
mv "$B/Downloads__Latex-HW-Format.zip"        ~/Downloads/Latex-HW-Format.zip
mv "$B/Downloads__Latex-HW-Format-Plugin.zip" ~/Downloads/Latex-HW-Format-Plugin.zip
```

Then remove the `skillOverrides` entry from `~/.claude/settings.json` and the
`latex-hw-format@created-by-me-remote` table from `~/.codex/config.toml`. Pre-change copies
of both files are in the backup folder as `*.orig`.
