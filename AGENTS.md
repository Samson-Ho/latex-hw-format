# Agent guidance

This repository is the single source of truth for the `latex-hw-format` skill. See
`MAINTENANCE.md` for the full workflow.

- Edit the skill only in `latex-hw-format/`. Keep the layout and frontmatter `name` unchanged.
- Never edit installed or cached copies: `~/.claude/skills/synced/`, `~/.codex/plugins/cache/`,
  `~/.codex/.tmp/`, Claude's Application Support folders, or `dist/`. Local discovery paths
  (`~/.claude/skills/latex-hw-format`, `~/.agents/skills/latex-hw-format`) are symlinks to this
  repository, so edit here instead.
- Preserve the homework formatting rules and template content. Don't change the mathematical
  or typographic conventions unless the user explicitly asks.
- After a change, run `python3 scripts/build_dist.py --check`. When a cloud copy needs refreshing,
  run `python3 scripts/build_dist.py` and give the user the upload steps from `MAINTENANCE.md`.
  For the OpenAI plugin, bump `version` in `packaging/openai/plugin.json` first.
- Run `scripts/install_local.sh --check` to verify local links. Do not create additional copies.
- Do not force-push or rewrite history.
