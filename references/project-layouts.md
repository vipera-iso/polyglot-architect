# Finding boundaries in any project

A unit qualifies only if it has an existing seam. This file lists where
seams live per project type.

## Rust
- **Cargo workspace** (`Cargo.toml` → `[workspace.members]`): each member
  is a unit.
- **Single crate** with `src/bin/*.rs` or `[lib]`+`[[bin]]`: each binary
  is a unit; the lib is one unit.
- **Trait boundary**: any `pub trait` in `traits/` or `core/` is a seam.
- **FFI crates** (`*-sys`, `*-bindings`): already a seam.

## JavaScript / TypeScript
- **npm/pnpm/yarn workspaces** (`package.json` → `workspaces`, or
  `pnpm-workspace.yaml`): each workspace package is a unit.
- **Monorepo tools**: Nx (`apps/`, `libs/`), Turborepo (`packages/`,
  `apps/`). Each project/package is a unit.
- **Single package** with subdirectories: `src/` subdirectory with its
  own `index.ts` public export is a candidate.
- **Boundary**: `package.json` `exports` field or a barrel file
  (`index.ts`).

## Go
- **`go.mod` + `cmd/` + `internal/` + `pkg/`**: each `cmd/*` is a unit;
  each top-level `internal/<name>` with stable API is a unit; each
  `pkg/*` is a unit.
- **Multi-module repo**: each `go.mod` is a separate boundary.
- **cgo files** (`*.go` with `import "C"`): already a seam.

## Python
- **pyproject.toml** with `packages = [...]`: each top-level package is a
  unit.
- **uv workspace** (`[tool.uv.workspace]`): each member package is a unit.
- **poetry / setuptools** with multiple top-level modules: each module
  with `__init__.py` is a unit.
- **Boundary**: `__init__.py` public exports or a C-extension module
  (`*.so`, `*.pyd`).

## Java / Kotlin
- **Maven multi-module** (`pom.xml` with `<modules>`): each module is a
  unit.
- **Gradle multi-project** (`settings.gradle` with `include`): each
  subproject is a unit.
- **JAR boundary**: each published JAR is a unit.
- **JNI** native library is a seam.

## C# / .NET
- **Solution** (`*.sln`): each project (`*.csproj`) is a unit.
- **Package reference boundary** (`<ProjectReference>`): each referenced
  project is a unit.
- **P/Invoke** target DLL is a seam.

## C / C++
- **CMake / Bazel / Meson**: each `add_library` / `add_executable` /
  `cc_library` target is a unit.
- **Header boundary**: a public header (`include/*.h`) is a seam.
- **Static/shared library** boundary is a seam.

## Bazel monorepo
- Every `BUILD`/`BUILD.bazel` target with `visibility = public` is a unit.
- `cc_library`, `go_library`, `py_library`, `java_library`, `rust_library`
  targets are units.

## Microservices
- Each service is a unit.
- The inter-service protocol (gRPC, REST, message queue) is the seam.
- Separate deployment = boundary already exists.

## Generic monolith
- Top-level directories with their own README or config are candidates.
- Public entry points: `main.*`, HTTP handler registration, CLI command
  table, router file.
- If no clear boundary exists, **do not propose a swap** — propose
  "create the seam first" in the current language.

## Polyglot repo (already multiple languages)
- Each existing language block is a unit group.
- Focus on the **hot path** rather than proposing new languages: a third
  language in a two-language repo is rarely worth the toolchain tax.
