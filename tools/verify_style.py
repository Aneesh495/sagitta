#!/usr/bin/env python3
"""Style and invariant verification script for Sagitta."""

import os
import sys

def verify_file(filepath):
    issues = []
    with open(filepath, "rb") as f:
        raw = f.read()

    # Check for unicode em dash (U+2014)
    if b"\xe2\x80\x94" in raw:
        issues.append("Contains forbidden em dash character (U+2014)")

    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as e:
        issues.append(f"Invalid UTF-8: {e}")
        return issues

    # Skip checking the verification script itself for the pattern string
    if filepath.endswith("verify_style.py"):
        return issues

    forbidden_pattern = " " + "-" * 2 + " "
    lines = text.splitlines()
    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()
        if forbidden_pattern in line and not stripped.startswith("//") and not stripped.startswith("/*") and not stripped.startswith("#"):
            issues.append(f"Line {idx}: Potential em-dash substitution found in prose")

    return issues

def main():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    errors = 0
    scanned = 0

    for dirpath, _, filenames in os.walk(root_dir):
        if "/.git" in dirpath or "/__pycache__" in dirpath:
            continue
        for filename in filenames:
            if filename.endswith((".nc", ".h", ".c", ".md", ".txt", ".py", ".sh", ".yml", ".json")):
                full_path = os.path.join(dirpath, filename)
                rel_path = os.path.relpath(full_path, root_dir)
                scanned += 1
                file_issues = verify_file(full_path)
                if file_issues:
                    errors += len(file_issues)
                    for issue in file_issues:
                        print(f"ERROR: {rel_path}: {issue}", file=sys.stderr)

    print(f"Verified {scanned} files. Total issues: {errors}")
    if errors > 0:
        sys.exit(1)

if __name__ == "__main__":
    main()
