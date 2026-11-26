#!/usr/bin/env python3
"""Copy a language template into a year/day/language directory."""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path


IGNORED_NAMES = {
    ".bundle",
    ".cpcache",
    ".DS_Store",
    ".git",
    ".lsp",
    ".pytest_cache",
    ".ruby-lsp",
    ".venv",
    ".swiftpm",
    "__pycache__",
    "_build",
    "build",
    "coverage",
    "deps",
    ".build",
    "DerivedData",
    "node_modules",
    "target",
    "vendor",
}


def ignore_generated(_directory: str, names: list[str]) -> list[str]:
    return [
        name
        for name in names
        if name in IGNORED_NAMES
        or name.startswith("input")
        or name.endswith((".beam", ".pyc"))
    ]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Copy a language template into <year>/<day>/<language-code>."
    )
    parser.add_argument("year", help="four-digit year, e.g. 2026")
    parser.add_argument("day", help="day number from 1 to 25")
    parser.add_argument("language", help="template code, e.g. rb or gl")
    args = parser.parse_args()

    if not re.fullmatch(r"\d{4}", args.year):
        parser.error("year must be four digits")
    if not re.fullmatch(r"[a-z][a-z0-9]*", args.language):
        parser.error("language must be a lowercase template code")
    try:
        day = int(args.day)
    except ValueError:
        parser.error("day must be a number from 1 to 25")
    if not 1 <= day <= 25:
        parser.error("day must be from 1 to 25")

    repo_root = Path(__file__).resolve().parent.parent
    template = repo_root / "templates" / args.language
    if not template.is_dir():
        available = sorted(
            path.name
            for path in (repo_root / "templates").iterdir()
            if path.is_dir()
        )
        parser.error(
            f"no template for {args.language!r}; available codes: "
            + ", ".join(available)
        )

    destination = (
        repo_root / args.year / f"{day:02d}" / args.language
    )
    if destination.exists():
        parser.error(f"destination already exists: {destination.relative_to(repo_root)}")

    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(template, destination, ignore=ignore_generated)
    print(f"Created {destination.relative_to(repo_root)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
