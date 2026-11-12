#!/usr/bin/env bash
# Detect project type(s) and list candidate swappable units.
# Usage: discover-boundaries.sh [root]

set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

declare -a DETECTED=()

detect() {
  local marker="$1" name="$2"
  if find . -maxdepth 3 -name "$marker" -type f 2>/dev/null | head -1 | grep -q .; then
    DETECTED+=("$name")
  fi
}

detect Cargo.toml "Rust (Cargo)"
detect go.mod "Go module"
detect package.json "Node/npm"
detect pnpm-workspace.yaml "pnpm workspace"
detect pyproject.toml "Python (pyproject)"
detect setup.py "Python (setuptools)"
detect pom.xml "Maven"
detect build.gradle "Gradle"
detect build.gradle.kts "Gradle (Kotlin DSL)"
find . -maxdepth 3 -name "*.sln" 2>/dev/null | head -1 | grep -q . && DETECTED+=("C#/.NET")
detect CMakeLists.txt "CMake (C/C++)"
detect WORKSPACE "Bazel"
detect WORKSPACE.bazel "Bazel"
detect Makefile "Makefile"

echo "## Project detection"
if [[ ${#DETECTED[@]} -eq 0 ]]; then
  echo "- Type: unknown (no build system detected in top 3 levels)"
else
  for d in "${DETECTED[@]}"; do echo "- $d"; done
fi
echo

echo "## Candidate units"

if [[ -f Cargo.toml ]] && grep -q '^\[workspace\]' Cargo.toml; then
  echo "### Rust workspace members"
  awk '/^\[workspace\]/{f=1} f && /^members/{m=1} m{print} f && /^\]/{exit}' Cargo.toml \
    | grep -oE '"[^"]+"' | tr -d '"' | while read -r m; do
        echo "- $m  (Rust crate)"
      done
fi

if [[ -f Cargo.toml ]] && ! grep -q '^\[workspace\]' Cargo.toml; then
  grep -E '^\[\[bin\]\]' -A2 Cargo.toml 2>/dev/null | grep -oP '(?<=name = ")[^"]+' \
    | while read -r b; do echo "- bin: $b  (Rust binary)"; done
  echo "- lib  (Rust library)"
fi

if [[ -f package.json ]]; then
  if grep -q '"workspaces"' package.json; then
    echo "### Node workspace packages"
    node -e '
      const p=require("./package.json");
      const ws=p.workspaces;
      const list = Array.isArray(ws) ? ws : (ws && ws.packages) || [];
      for (const w of list) console.log("- "+w+"  (npm workspace)");
    ' 2>/dev/null || echo "- (could not parse package.json workspaces)"
  else
    echo "### Node subdirectories with own package.json"
    find . -maxdepth 3 -name package.json -not -path "*/node_modules/*" -not -path "./package.json" \
      | while read -r f; do echo "- $(dirname "$f")  (npm package)"; done
  fi
fi

if [[ -f go.mod ]]; then
  echo "### Go packages"
  find . -maxdepth 2 -name go.mod | while read -r f; do
    d=$(dirname "$f"); [[ "$d" == "." ]] && d="(root)"
    echo "- $d  (Go module)"
  done
fi

if [[ -f pyproject.toml || -f setup.py ]]; then
  echo "### Python top-level packages"
  find . -maxdepth 2 -name "__init__.py" -not -path "*/.*" | while read -r f; do
    echo "- $(dirname "$f")  (Python package)"
  done
fi

if [[ -f pom.xml ]]; then
  echo "### Maven modules"
  grep -oP '(?<=<module>)[^<]+' pom.xml 2>/dev/null | while read -r m; do
    echo "- $m  (Maven module)"
  done
fi

if [[ -f settings.gradle || -f settings.gradle.kts ]]; then
  echo "### Gradle subprojects"
  grep -oP "(?<=include\()['\"][^'\"]+" settings.gradle* 2>/dev/null \
    | sed "s/^['\"]//" | while read -r m; do echo "- $m  (Gradle project)"; done
fi

find . -maxdepth 3 -name "*.csproj" 2>/dev/null | while read -r f; do
  echo "- $(dirname "$f")  (.NET project)"
done

if [[ -f CMakeLists.txt ]]; then
  echo "### CMake targets"
  grep -oP '(?<=add_library\()[a-zA-Z0-9_]+|(?<=add_executable\()[a-zA-Z0-9_]+' \
    CMakeLists.txt 2>/dev/null | while read -r t; do echo "- $t  (CMake target)"; done
fi

echo
echo "## Next step"
echo "1. Confirm this unit list manually — do not trust the script blindly."
echo "2. Run scripts/profile.sh <unit> for each hot candidate."
echo "3. Fill references/report-template.md."
