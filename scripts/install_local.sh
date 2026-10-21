#!/usr/bin/env bash
# Point local agent skill-discovery locations at the canonical skill directory.
#
#   scripts/install_local.sh          link (idempotent; safe to re-run)
#   scripts/install_local.sh --check  report status only; exit 1 if anything is off
#
# Links created:
#   ~/.claude/skills/latex-hw-format  -> <repo>/latex-hw-format   (Claude Code personal skill)
#   ~/.agents/skills/latex-hw-format  -> <repo>/latex-hw-format   (Codex user skill)
# Retired: ~/.codex/skills/latex-hw-format (legacy Codex location; would register a second copy).
#
# An existing real directory is replaced only if it is byte-identical to the canonical
# skill; it is moved (not deleted) to $LHF_BACKUP_DIR. Anything that differs aborts the run
# so local edits can be merged into the repository first.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SRC="$REPO/latex-hw-format"
BACKUP_DIR="${LHF_BACKUP_DIR:-$HOME/Documents/Codex/latex-hw-format-backups/install-$(date +%Y%m%d-%H%M%S)}"
LINKS=("$HOME/.claude/skills/latex-hw-format" "$HOME/.agents/skills/latex-hw-format")
RETIRED=("$HOME/.codex/skills/latex-hw-format")
CHECK=0
[[ "${1:-}" == "--check" ]] && CHECK=1
problems=0

[[ -f "$SRC/SKILL.md" ]] || { echo "ERROR: $SRC/SKILL.md not found" >&2; exit 1; }

backup() {  # move a verified-identical copy out of the discovery path
  local path=$1 rel dest
  rel="${path#"$HOME"/}"
  rel="${rel//\//__}"; rel="${rel/#./dot-}"
  dest="$BACKUP_DIR/$rel"  # flattened and visible, so no .claude/skills or .agents/skills path is recreated
  mkdir -p "$BACKUP_DIR"
  [[ -e "$dest" ]] && { echo "ERROR: backup target exists: $dest" >&2; exit 1; }
  mv "$path" "$dest"
  printf '%s\t%s\n' "$path" "$dest" >> "$BACKUP_DIR/MANIFEST.tsv"
  echo "  moved $path -> $dest"
}

same_as_src() { diff -rq -x .DS_Store "$SRC" "$1" >/dev/null 2>&1; }

for link in "${LINKS[@]}"; do
  if [[ -L "$link" ]]; then
    target="$(cd "$link" 2>/dev/null && pwd -P || true)"
    if [[ "$target" == "$SRC" ]]; then echo "ok      $link -> $SRC"; continue; fi
    echo "WRONG   $link -> $(readlink "$link")"; problems=1
    [[ $CHECK == 1 ]] && continue
    rm "$link"   # a symlink holds no content of its own
  elif [[ -e "$link" ]]; then
    if ! same_as_src "$link"; then
      echo "DIFFERS $link is a real directory with content not in the repo; merge it first:" >&2
      echo "        diff -r '$SRC' '$link'" >&2
      exit 1
    fi
    echo "COPY    $link is an unmanaged identical copy"; problems=1
    [[ $CHECK == 1 ]] && continue
    backup "$link"
  else
    echo "MISSING $link"; problems=1
    [[ $CHECK == 1 ]] && continue
  fi
  mkdir -p "$(dirname "$link")"
  ln -s "$SRC" "$link"
  echo "  linked $link -> $SRC"
done

for old in "${RETIRED[@]}"; do
  [[ -e "$old" || -L "$old" ]] || { echo "ok      $old absent"; continue; }
  if [[ ! -L "$old" ]] && ! same_as_src "$old"; then
    echo "DIFFERS $old has content not in the repo; merge it first: diff -r '$SRC' '$old'" >&2
    exit 1
  fi
  echo "RETIRE  $old would register a duplicate in Codex"; problems=1
  [[ $CHECK == 1 ]] && continue
  if [[ -L "$old" ]]; then rm "$old"; echo "  removed symlink $old"; else backup "$old"; fi
done

# Configuration that keeps the account-level cloud copies from duplicating the local skill.
if grep -q '"anthropic-skills:latex-hw-format"[[:space:]]*:[[:space:]]*"off"' "$HOME/.claude/settings.json" 2>/dev/null; then
  echo "ok      Claude Code hides synced anthropic-skills:latex-hw-format (skillOverrides)"
else
  echo "WARN    ~/.claude/settings.json lacks skillOverrides {\"anthropic-skills:latex-hw-format\": \"off\"}"; problems=1
fi
if awk '/^\[plugins\."latex-hw-format@created-by-me-remote"\]/{f=1;next} /^\[/{f=0} f&&/^enabled *= *false/{found=1} END{exit !found}' "$HOME/.codex/config.toml" 2>/dev/null; then
  echo "ok      Codex disables remote plugin latex-hw-format@created-by-me-remote on this machine"
else
  echo "WARN    ~/.codex/config.toml lacks [plugins.\"latex-hw-format@created-by-me-remote\"] enabled = false"; problems=1
fi

if [[ $CHECK == 1 ]]; then exit $problems; fi
echo "done. Restart Codex / Claude Code sessions to pick up changes."
