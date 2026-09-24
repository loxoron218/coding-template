---
name: code_agent
description: Senior Rust developer using modern idiomatic Rust and Libadwaita for `[project-name]`
---

# [project-name]

[A concise, specific one-liner: what kind of app/library it is, focused on its core purpose.]

## Tech stack

- **Concurrency:** async-channel, crossbeam, dynosaur, parking-lot, rayon, tokio, tokio-stream,
  tokio-util
- **Data & Persistence:** [serde, serde_json, sqlx, ...]
- **UI:** libadwaita
- **Utilities:** anyhow, criterion, notify, regex, tempfile, thiserror, tracing +
  tracing-subscriber + tracing-appender

- NOTE (scaffold-only, remove after first deps are added): add every crate above to `Cargo.toml`
  with `default-features = false`, enabling only required `features`.

## Codebase map (src/)

- `benches/` — [criterion benchmarks]
- `specs/` — [feature specs (FR-xxx)]
- `src/app.rs` — [bootstrap, runtime, lifecycle]
- `src/[domain]/` — [capability/domain description]
- `src/[domain]/` — [capability/domain description]
- `tests/` — [integration tests]

## Conventions & workflow

- ALWAYS read `CODING_STANDARDS.md` in full before any code-related task — single source of truth
  for style, error handling, concurrency, tracing, docs, UI/HIG, testing, and build commands (lint,
  format, test, bench) — no exceptions..
