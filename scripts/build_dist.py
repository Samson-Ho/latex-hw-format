#!/usr/bin/env python3
"""Validate the canonical skill and build portable distribution packages.

Outputs (in dist/, which is git-ignored):
  latex-hw-format-skill.zip          Claude.ai / Claude Desktop "Upload a skill" package
  latex-hw-format-openai-plugin.zip  ChatGPT / Codex plugin package (plugin.json + skills/)

Usage:
  python3 scripts/build_dist.py           # validate and build
  python3 scripts/build_dist.py --check   # validate only
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import zipfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SKILL_NAME = "latex-hw-format"
SKILL_DIR = REPO / SKILL_NAME
PLUGIN_MANIFEST = REPO / "packaging" / "openai" / "plugin.json"
DIST = REPO / "dist"

# Files the skill instructions reference; packages are useless without them.
REQUIRED = ["SKILL.md", "assets/homework-template.tex", "references/format-spec.md"]
IGNORED_NAMES = {".DS_Store"}
# Machine-specific paths that must never ship in a portable package.
LOCAL_PATH = re.compile(r"(/Users/|/home/[a-z]|[A-Za-z]:\\Users\\|~/\.(claude|codex|agents)/)")
FIXED_DATE = (2026, 1, 1, 0, 0, 0)  # deterministic zip timestamps


def fail(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def skill_files() -> list[Path]:
    files = []
    for p in sorted(SKILL_DIR.rglob("*")):
        if p.is_symlink():
            fail(f"symlink inside skill directory: {p.relative_to(REPO)}")
        if p.is_file() and p.name not in IGNORED_NAMES:
            files.append(p)
    return files


def validate() -> tuple[list[Path], dict]:
    if not SKILL_DIR.is_dir():
        fail(f"missing skill directory {SKILL_DIR}")
    for rel in REQUIRED:
        if not (SKILL_DIR / rel).is_file():
            fail(f"missing required file {SKILL_NAME}/{rel}")

    text = (SKILL_DIR / "SKILL.md").read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        fail("SKILL.md has no YAML frontmatter")
    front = m.group(1)
    name = re.search(r"^name:\s*(.+)$", front, re.M)
    if not name or name.group(1).strip().strip("\"'") != SKILL_NAME:
        fail(f"SKILL.md frontmatter name must be '{SKILL_NAME}'")
    if not re.search(r"^description:\s*\S", front, re.M):
        fail("SKILL.md frontmatter has no description")

    files = skill_files()
    for p in files:
        try:
            body = p.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if LOCAL_PATH.search(body):
            fail(f"machine-specific path in {p.relative_to(REPO)}")

    manifest = json.loads(PLUGIN_MANIFEST.read_text(encoding="utf-8"))
    if manifest.get("name") != SKILL_NAME:
        fail("packaging/openai/plugin.json name must match the skill name")
    if not re.fullmatch(r"\d+\.\d+\.\d+", str(manifest.get("version", ""))):
        fail("packaging/openai/plugin.json needs a semantic version")
    return files, manifest


def write_zip(target: Path, entries: list[tuple[str, bytes]]) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as zf:
        for arcname, data in entries:
            info = zipfile.ZipInfo(arcname, FIXED_DATE)
            info.external_attr = 0o644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            zf.writestr(info, data)
    digest = hashlib.sha256(target.read_bytes()).hexdigest()
    print(f"built {target.relative_to(REPO)}  sha256={digest[:16]}  files={len(entries)}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true", help="validate only; do not build")
    args = parser.parse_args()

    files, manifest = validate()
    print(f"validated {SKILL_NAME}: {len(files)} files, plugin version {manifest['version']}")
    if args.check:
        return

    rel = [(p.relative_to(SKILL_DIR).as_posix(), p.read_bytes()) for p in files]
    write_zip(DIST / f"{SKILL_NAME}-skill.zip", [(f"{SKILL_NAME}/{r}", b) for r, b in rel])
    plugin_entries = [(f"{SKILL_NAME}/plugin.json", PLUGIN_MANIFEST.read_bytes())]
    plugin_entries += [(f"{SKILL_NAME}/skills/{SKILL_NAME}/{r}", b) for r, b in rel]
    write_zip(DIST / f"{SKILL_NAME}-openai-plugin.zip", plugin_entries)


if __name__ == "__main__":
    main()
