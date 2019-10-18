#!/usr/bin/env bash
set -euo pipefail

echo "==============================================================================="
echo "  SAGITTA :: Master Quality Gate and Release Verification Pipeline            "
echo "==============================================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

echo -e "\n[1/7] Enforcing style and zero-em-dash invariant..."
python3 tools/verify_style.py

echo -e "\n[2/7] Validating nesC component syntax and structural invariants..."
python3 tools/nesc_syntax_validator.py

echo -e "\n[3/7] Building simulator and test suite binaries with Clang/GCC..."
make clean
make all

echo -e "\n[4/7] Executing comprehensive unit and integration test suite..."
make test

echo -e "\n[5/7] Executing corridor discrete-event simulator smoke test..."
./bin/sagitta_sim --steps 15 --quiet

echo -e "\n[6/7] Rendering corridor catenary profile visualizer..."
python3 tools/corridor_visualizer.py 3

echo -e "\n[7/7] Checking git commit history and conventional commit rules..."
COMMIT_COUNT=$(git rev-list --count HEAD)
echo "Total commits: $COMMIT_COUNT (minimum required: 48)"
if [ "$COMMIT_COUNT" -lt 48 ]; then
  echo "ERROR: Commit count ($COMMIT_COUNT) is less than required 48."
  exit 1
fi

echo -e "\n==============================================================================="
echo "  ALL QUALITY GATES PASSED! SAGITTA IS 100% VERIFIED AND READY FOR RELEASE.   "
echo "==============================================================================="
