#!/usr/bin/env python3
"""Append an incremental entry to a journal file with correct header nesting."""

import os
import re
import sys


def adjust_headers(content: str) -> str:
    """Increment all markdown headers by 1 level."""
    lines = content.split("\n")
    result = []
    for line in lines:
        if re.match(r"^(#{1,5})\s", line):
            line = "#" + line
        result.append(line)
    return "\n".join(result)


def count_entries(journal_file: str) -> int:
    """Count existing journal entries by matching H1 headings."""
    if not os.path.exists(journal_file):
        return 0
    with open(journal_file) as f:
        return sum(1 for line in f if re.match(r"^# Journal Entry #\d+", line))


def main() -> None:
    if len(sys.argv) < 3:
        print("Usage: append_journal.py <journal_file> <entry_title> [content_file]")
        print("If content_file is omitted, reads from stdin.")
        sys.exit(1)

    journal_file = sys.argv[1]
    entry_title = sys.argv[2]

    if len(sys.argv) >= 4:
        with open(sys.argv[3]) as f:
            content = f.read()
    else:
        content = sys.stdin.read()

    entry_number = count_entries(journal_file) + 1
    adjusted = adjust_headers(content.strip())

    entry = f"\n# Journal Entry #{entry_number} - {entry_title}\n\n{adjusted}\n"

    with open(journal_file, "a") as f:
        f.write(entry)

    print(f"Appended Journal Entry #{entry_number} to {journal_file}")


if __name__ == "__main__":
    main()
