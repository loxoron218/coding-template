# Type-complexity silent aliases — evidence

The `unnecessary_types` lint flags 191 of 199 free type aliases across the 13 surveyed projects. The
7 below stay silent, each for a documented reason. Flagging any of them would be a false positive
against `clippy::type_complexity` (warn iff score > 250).

## Census method

Pristine copies under `/tmp/verify-run/orig/*` (originals untouched). Counts come from complete
`EXIT:0` runs only: full sweeps over `rust-clippy` exceed 90 s, so truncated runs masquerade as
verdict flips. Set differences require `LC_ALL=C comm` (locale sort order breaks `comm`).

| Project             | Universe | Flagged | Silent                                             |
| ------------------- | -------- | ------- | -------------------------------------------------- |
| cpal                | 29       | 28      | `ClosureHandle`                                    |
| dasp                | 29       | 29      | —                                                  |
| karere              | 5        | 5       | —                                                  |
| oxhidifi            | 3        | 0       | `PendingCovers`, `ListenLoopHarness`, `MetaResult` |
| qobuz-api           | 2        | 2       | —                                                  |
| sqlx                | 34       | 32      | `PgTimeTz` ×2                                      |
| rust-clippy         | 97       | 95      | `Alias`, `Wrappers`                                |
| others (6 projects) | 0        | 0       | —                                                  |
| **Total**           | **199**  | **191** | **7 unique**                                       |

## Scoring reference

`clippy_lints/src/types/type_complexity.rs`: `&`/`*` +1; named paths, slices, tuples, arrays
+10·nest (nest+1); Rust `fn` pointers +50·nest; trait objects with `for<>` binders +50·nest
(nest+1), else +20·nest. Bounds visit as trait refs (bound names score nothing); `FnMut()` parens
are trait sugar (nothing); `Output = T` binding names score nothing. The custom scorer mirrors all
of the above node for node.

## Dossiers

### PendingCovers (oxhidifi `src/ui/gallery/columns.rs:60`)

`HashMap<i64, Vec<WeakRef<Picture>>>` (`WeakRef` is glib `WeakRef<T>`, arity 1). Worst site
`&Arc<Mutex<PendingCovers>>` (`columns.rs:78`): `1+10+20+30+40+40+50+60 = 251` in both scorers —
minimal warn, one point over. Bare uses score 250 (clean) but the `&`-wrapped sites govern. To flag:
nothing short of changing the threshold.

### MetaResult (oxhidifi `src/ui/player/sidebar.rs:42`)

`(String, String, String, Option<String>, String, i64)`. Worst site `&Sender<(i64, MetaResult)>`
(`playback_events.rs:158`, `now_playing.rs:53`): 381 in both scorers; an isolated mini-crate
reproduces the `clippy::type_complexity` warning. Bare uses score 160. To flag: nothing — the
wrapper is genuinely complex.

### ListenLoopHarness (oxhidifi `src/ui/gallery/rebuild_debounce.rs:168`)

Five-tuple RHS scores 560 alone. Every use warns. To flag: split the tuple at the source.

### ClosureHandle (cpal `src/host/webaudio/mod.rs:42`)

`Arc<RwLock<Option<Closure<dyn FnMut()>>>>` (`Closure` is `wasm_bindgen::Closure<T>`, arity 1).
`Vec<…>` field (`:74`) and local (`:366`): 270/270. `&[…]` arg (`:823`): 271/271. Bare use (`:424`):
200/200 clean but governed by the rest. Zero diverging nodes between scorers. The module is
additionally wasm-gated (`host/mod.rs:79-84`, default features off), so host-target clippy never
sees it; a `wasm32-unknown-unknown` target check was judged unnecessary given the identical scores.
To flag: nothing.

### clippy Alias (`tests/ui/type_complexity.rs:4`)

`Vec<Vec<Box<(u32, u32, u32, u32)>>>`: 300/300. The definition itself is exempt; every direct
spelling warns. To flag: nothing.

### clippy Wrappers (`tests/ui/use_self_structs.rs:105`)

`Vec<Option<Rc<RefCell<Weak<Vec<Box<T>>>>>>>` applied as `Wrappers<Alias>` (`:108`): 360/360. To
flag: nothing.

### sqlx PgTimeTz ×2 (`tests/postgres/types.rs:304,367`)

`PgTimeTz<NaiveTime,FixedOffset>` / `<Time,UtcOffset>` (scores ~50–90, clean). The only mentions
live inside `test_type!` (`:353`) and `test_prepared_type!` (`:395`) invocations whose macros are
defined outside the file (`sqlx-test/src/lib.rs:43-71,88-103`) and forward `$ty` verbatim to
`try_get::<$ty>`. Invocation interiors stay vetoed anyway: scoring them in general is unsound
(`vec![Token]` must keep vetoing), and over-grab keeps these silent regardless. To flag: macro
expansion, which is out of scope for a syntactic check.

## Veto taxonomy (keeps by design)

- **Over-threshold**: six aliases above; evidence is the site score.
- **Invocation-interior**: `PgTimeTz`; evidence is the macro definition site plus the `vec![Token]`
  precedent (`alias.rs`: `invocation_use_keeps_alias`).
- **Platform-gated overlay**: `ClosureHandle`; evidence is the wasm gate plus the over-threshold
  sites.

## Process notes

- Rebuild the binary before evidence runs: `cargo test` alone does not refresh
  `target/debug/cargo-collate`, and a stale binary once produced a confusing round-trip.
- A prior dummy-struct mini-oracle for `ClosureHandle` reported clean and is discarded as
  unfaithful; the node-by-node audit above supersedes it.
