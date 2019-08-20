#!/usr/bin/env python3
"""Syntax and structural validator for nesC components, interfaces, and configurations."""

import os
import re
import sys

def validate_nesc_file(filepath):
    errors = []
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    filename = os.path.basename(filepath)

    if filename.endswith(".nc"):
        # Check if interface, configuration, or module using declaration keywords
        is_interface = bool(re.search(r"^\s*interface\s+\w+", content, re.MULTILINE))
        is_module = bool(re.search(r"^\s*module\s+\w+", content, re.MULTILINE))
        is_configuration = bool(re.search(r"^\s*configuration\s+\w+", content, re.MULTILINE))

        if not (is_interface or is_module or is_configuration):
            errors.append("File does not declare an interface, module, or configuration")

        if is_module:
            if "implementation" not in content:
                errors.append("Module missing 'implementation' block")
            if "provides" not in content and "uses" not in content:
                errors.append("Module missing 'provides' or 'uses' specification")

        if is_configuration:
            if "implementation" not in content:
                errors.append("Configuration missing 'implementation' block")
            if "components" not in content:
                errors.append("Configuration missing 'components' declaration")

        # Verify balanced braces
        open_braces = content.count("{")
        close_braces = content.count("}")
        if open_braces != close_braces:
            errors.append(f"Unbalanced curly braces: {open_braces} open vs {close_braces} close")

    return errors

def main():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    src_dir = os.path.join(root_dir, "src")
    total_files = 0
    total_errors = 0

    for dirpath, _, filenames in os.walk(src_dir):
        for fname in filenames:
            if fname.endswith(".nc"):
                total_files += 1
                fpath = os.path.join(dirpath, fname)
                file_errors = validate_nesc_file(fpath)
                if file_errors:
                    total_errors += len(file_errors)
                    for err in file_errors:
                        print(f"ERROR: {os.path.relpath(fpath, root_dir)}: {err}", file=sys.stderr)

    print(f"Validated {total_files} nesC files. Total structural issues: {total_errors}")
    if total_errors > 0:
        sys.exit(1)

if __name__ == "__main__":
    main()
