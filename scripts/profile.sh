#!/usr/bin/env bash
# Language-agnostic profiler dispatcher.
# Usage: profile.sh [unit-dir]

set -euo pipefail
UNIT="${1:-.}"
cd "$UNIT"

echo "== Profiling $UNIT =="
echo

has() { command -v "$1" >/dev/null 2>&1; }

# ---- Rust ----
if [[ -f Cargo.toml ]]; then
  echo "[Rust detected]"
  if has cargo-flamegraph; then
    echo "  Running cargo flamegraph..."
    cargo flamegraph 2>/dev/null || echo "  (need --bin or --example; run manually)"
  else
    echo "  Install: cargo install flamegraph"
  fi
  if has hyperfine; then
    echo "  Cold/warm macro: hyperfine '<run command>'"
  fi
  exit 0
fi

# ---- Go ----
if [[ -f go.mod ]]; then
  echo "[Go detected]"
  echo "  Benchmarks:  go test -bench=. -benchmem -cpuprofile=cpu.prof"
  echo "  Profile:     go tool pprof -http=:8080 cpu.prof"
  echo "  Trace:       go test -trace=trace.out && go tool trace trace.out"
  exit 0
fi

# ---- Node / TypeScript ----
if [[ -f package.json ]]; then
  echo "[Node detected]"
  if has clinic; then
    echo "  Running clinic doctor..."
    clinic doctor -- node "$(node -p "require('./package.json').main || 'index.js'" 2>/dev/null || echo index.js)" 2>/dev/null || true
  else
    echo "  Install clinic: npm i -g clinic"
    echo "  Or:            node --prof <entry> && node --prof-process isolate-*.log"
  fi
  exit 0
fi

# ---- Python ----
if [[ -f pyproject.toml || -f setup.py || -f requirements.txt ]]; then
  echo "[Python detected]"
  if has py-spy; then
    echo "  py-spy record -o profile.svg -- python <entry>"
  else
    echo "  Install: pip install py-spy memray"
  fi
  echo "  Or: python -m cProfile -o out.prof <entry>"
  exit 0
fi

# ---- Maven / Gradle (JVM) ----
if [[ -f pom.xml || -f build.gradle || -f build.gradle.kts ]]; then
  echo "[JVM detected]"
  echo "  async-profiler:  https://github.com/async-profiler/async-profiler"
  echo "  JFR:             java -XX:StartFlightRecording=duration=60s,filename=rec.jfr -jar app.jar"
  exit 0
fi

# ---- .NET ----
if compgen -G "*.csproj" >/dev/null || compgen -G "*.sln" >/dev/null; then
  echo "[.NET detected]"
  echo "  Install: dotnet tool install -g dotnet-trace"
  echo "  Run:     dotnet-trace collect -- <app>"
  exit 0
fi

# ---- C/C++ ----
if [[ -f CMakeLists.txt || -f Makefile ]]; then
  echo "[C/C++ detected]"
  if has perf; then
    echo "  perf record -g -- <bin> && perf report"
  fi
  if has valgrind; then
    echo "  valgrind --tool=callgrind <bin>"
  fi
  exit 0
fi

echo "[unknown project type]"
echo "See references/profiling-tools.md"
echo "Universal fallback: hyperfine '<run command>'"
