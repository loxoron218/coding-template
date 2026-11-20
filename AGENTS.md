---
name: code_agent
description: Senior Rust developer using modern idiomatic Rust and Libadwaita for `[project-name]`
---

# [project-name]

[A concise, specific one-liner: what kind of app/library it is, focused on its core purpose.]

## Core priorities

The core priorities are:

- high-performance, maintainable, idiomatic Rust code
- following the GNOME's Human Interface Guidelines (HIG)
- following modern best practices
- prefer abstractions and generics over boilerplate code
- never hardcode values that should be configurable

These priorities take precedence over preserving existing code. **Do not be afraid of refactoring or
API restructuring** when it serves them; write clean, future-proof code rather than keeping an
awkward interface unchanged.

## Commands

Run before committing:

```bash
cargo collate # project hygiene checks (must pass before committing)
cargo clippy --fix --allow-dirty --all-targets --all-features && cargo fmt
cargo nextest run # all tests must pass before committing
cargo bench   # benchmarks
```

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
- `docs/` — [project documentation]
- `src/app.rs` — [bootstrap, runtime, lifecycle]
- `src/[domain]/` — [capability/domain description]
- `src/[domain]/` — [capability/domain description]
- `tests/` — [integration tests]

## Conventions & workflow

Formatting and lints are enforced by `rustfmt.toml`, `clippy.toml`, and the `[lints.cargo]`,
`[lints.clippy]`, `[lints.rust]` tables in `Cargo.toml` (notably `pedantic` and `nursery` denied).

### 1. Module & File Layout

Group modules by capability/domain. On name collisions, prefer a precise, non-vague synonym; fall
back to a capability-prefixed compound (`alias_collect.rs` vs `group_collect.rs`) only when vague
synonyms are all that is available.

### 2. Error Handling

Library crates use typed `thiserror` enums: `#[derive(Debug, Error)]`, a `#[error("...")]` message
per variant, `#[from]` for source errors:

```rust
/// Error type for repository operations.
#[derive(Debug, Error)]
pub enum RepoError {
    /// Database error.
    #[error("Database error: {0}")]
    Database(String),
    /// Entity not found.
    #[error("Entity not found: {0}")]
    NotFound(String),
}
```

Functional tests return `anyhow::Result` and assert with `ensure!` / `bail!`; trivial tests return
`()` and use `assert!`:

```rust
#[test]
fn process_item_success() -> Result<()> {
    let service = make_service();
    let result = service.process(ItemId(1));
    ensure!(
        result == Some((2, PathBuf::from("/data/item_two"))),
        "expected the next item result"
    );
    Ok(())
}
```

Rules: errors in async (Tokio) tasks must be `Send + Sync + 'static`.

### 3. Concurrency

Use the first abstraction that fits — never reach lower for convenience:

1. `&T` / `&mut T` via `thread::scope`: 0 alloc, 0 cycles. Default.
2. `AtomicT`, `OnceLock` / `LazyLock`: 0 alloc, ~1–10 cycles. Flags, counters, globals.
3. `parking_lot::RwLock` (read-heavy) / `Mutex`: 0 alloc, ~3–15 cycles.
4. `Cow<'a, T>`: 0 alloc on borrowed path. Read-heavy, rarely mutated.
5. `Box<T>`: 1 alloc. Only to transfer large `Send` values across threads.
6. `Arc<T>`: 1 alloc + ~10–30 cycles per clone/drop. Last resort for dynamic lifetimes only.

Keep lock scopes minimal and explicit — short critical sections in `{ ... }` blocks, `drop(lock)`
before further work. Do not perform I/O or event dispatch while holding a lock:

```rust
{
    let mut state = shared.state.lock();
    state.current_id = Some(next_id);
    // ...
    drop(state);
}
```

Traits whose methods run on async tasks declare `Send + Sync + 'static` supertraits and return futures that are themselves
`Send`:

```rust
/// Interface for all persistent storage operations.
pub trait Storage: Send + Sync + 'static {
    /// Insert a new track, returning its id.
    fn insert_track(&self, track: NewTrack) -> impl Future<Output = Result<i64>> + Send;
}
```

### 4. Tracing & Observability

The binary entry point initializes `tracing-subscriber` with an `EnvFilter`, a JSON file appender,
and a human-readable stderr layer.

### 5. Documentation

Function docs require `# Arguments` and `# Returns`, but only where applicable:

```rust
//! Item processing engine.

/// Loads an item for processing.
///
/// # Arguments
///
/// * `item_path` - Path to the item file
///
/// # Returns
///
/// * `Result<Self, ParseError>` - Loaded item or parse error
pub fn open<P: AsRef<Path>>(path: P) -> Result<Self, ParseError> { ... }
```

### 6. UI (GTK / Libadwaita, GNOME HIG)

**Never block the GTK main thread.** Freezes compound — every synchronous main-thread op
accumulates over repetitions. Apply all of these:

1. Never open/close/drop I/O resources on main thread; a worker owns drop + open, main only sends
   commands.
2. Never heavy sync work on main thread (image decode, JSON parse, file read, subprocess); decode
   off-thread, reconstruct the UI object on main.
3. Never `spawn_local` + `recv().await` for UI updates or async I/O; poll state via
   `timeout_add_local` (100–500 ms) and drain `mpsc` with `try_recv`. Run async I/O on dedicated
   threads with a shared `Arc<Runtime>`.
4. Never shared broadcast with mixed-speed subscribers; per-subscriber unbounded channels. On
   `Lagged` continue, on `Closed` break.
5. Never stale-thread writes; set new state before spawn, workers check id / `is_abandoned()` before
   cleanup.
6. Never `yield_now()` spins; `sleep(1 ms)`, `Condvar`, or blocking `recv`.

### 7. Testing & Benchmarking

- Use `tempfile` for test fixtures; for technical tasks use deterministic simulation testing.
- GTK-main-thread tests import `libadwaita::gtk::{self, test}` so plain `#[test]` (which runs on
  the main thread) can be used instead of a dedicated `#[gtk::test]` attribute.
- Integration/acceptance tests live in `tests/` and carry a `//!` header referencing the
  originating GitHub issue / spec (e.g., `No-hardware-at-startup acceptance test (#123)`).
- Benchmarks live in `benches/` using `criterion`.
