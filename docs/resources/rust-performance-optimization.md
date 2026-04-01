# Rust Performance Optimization Guide

## Scope and Guardrails

- **Scope:** single-process / single-binary performance (CPU, memory, allocations, cache behavior)
- **Do not:** change externally observable behavior unless explicitly agreed
- **Do not:** introduce undefined behavior, data races, or brittle micro-opts without evidence
- **Default philosophy:** choose the faster alternative **when it doesn't materially harm readability or complexity**; otherwise, measure first

## When to Apply

- Reducing **latency** or improving **throughput**
- Cutting **memory footprint** or **allocation rate**
- Improving **cache locality** / reducing cache misses
- Designing performant **APIs** (bulk ops, view types, threading model)
- Reviewing performance-sensitive Rust changes
- Interpreting a **flat profile** and finding next steps

## Reference Latency Table

| Operation                         | Approx time     |
| --------------------------------- | --------------: |
| L1 cache reference                |          0.5 ns |
| L2 cache reference                |            3 ns |
| Branch mispredict                 |            5 ns |
| Mutex lock/unlock (uncontended)   |           15 ns |
| Main memory reference             |           50 ns |
| Rust function call (non-inlined)  |         1-10 ns |
| HashMap lookup                    |        10-30 ns |
| Vec push (no realloc)             |         2-10 ns |
| String allocation (small)         |        20-50 ns |
| Arc clone                         |        10-20 ns |
| tokio task spawn                  |     200-500 ns |
| async channel send                |      50-200 ns |
| Read 4KB from SSD                 |      20,000 ns |
| Read 1MB sequentially from SSD    |   1,000,000 ns |

## Profiling Tools

- **`perf`** - Linux sampling profiler
- **`flamegraph`** crate - Generating flame graphs
- **`criterion`** - Microbenchmarks
- **`dhat`** - Allocation profiling
- Watch for **async runtime overhead**: too many small tasks can hurt more than help

---

## Optimization Priority

1. **Algorithmic complexity** (O(N²) → O(N log N) or O(N))
2. **Data structure choice / memory layout** (cache locality; fewer cache lines)
3. **Allocation reduction** (fewer allocs, better reuse)
4. **Avoid unnecessary work** (fast paths, precompute, defer)
5. **Compiler friendliness** (simplify hot loops, reduce abstraction overhead)

---

## 1) API Design for Performance

### Use Bulk APIs to Amortize Overhead

```rust
// BAD: N individual operations
for id in ids {
    let result = cache.get(&id)?;
    // ...
}

// GOOD: Batch lookup
let results = cache.get_many(&ids)?;
```

### Prefer View Types for Function Arguments

- Use `&[T]` or `impl AsRef<[T]>` instead of `Vec<T>` when you don't need ownership
- Use `&str` instead of `String` for read-only string access
- Use `Cow<'_, T>` when you might need to own or borrow

### Thread-Compatible vs Thread-Safe Types

- Default to `Send + Sync` for shared state
- Use `Arc<RwLock<T>>` only when needed; prefer message passing
- Consider `dashmap` or sharded maps for high-contention scenarios

---

## 2) Algorithmic Improvements

### Reduce Complexity Class

Common transformations:
- O(N²) → O(N log N) or O(N)
- O(N log N) sorted-list intersection → O(N) using a hash set
- O(log N) tree lookup → O(1) using hash lookup

### Hash Lookup Instead of Nested Iteration

```rust
// BAD: O(N²) - nested iteration
for a in &items_a {
    for b in &items_b {
        if a.key == b.key {
            // ...
        }
    }
}

// GOOD: O(N) - hash lookup
let b_map: HashMap<_, _> = items_b.iter().map(|b| (&b.key, b)).collect();
for a in &items_a {
    if let Some(b) = b_map.get(&a.key) {
        // ...
    }
}
```

---

## 3) Memory Layout and Cache Locality

### Struct Field Ordering (Reduce Padding)

```rust
// BAD: 24 bytes due to padding
struct Item {
    flag: bool,      // 1 byte + 7 padding
    value: i64,      // 8 bytes
    count: i32,      // 4 bytes + 4 padding
}

// GOOD: 16 bytes with reordering
struct Item {
    value: i64,      // 8 bytes
    count: i32,      // 4 bytes
    flag: bool,      // 1 byte + 3 padding
}

// Use #[repr(C)] or #[repr(packed)] when ABI matters
```

### Indices Instead of Pointers

```rust
// Pointer-heavy: 8 bytes per reference, poor cache locality
struct Node {
    data: i32,
    left: Option<Box<Node>>,
    right: Option<Box<Node>>,
}

// Index-based: 4 bytes per reference, better cache locality
struct Tree {
    nodes: Vec<NodeData>,
}
struct NodeData {
    data: i32,
    left: Option<u32>,  // index into nodes
    right: Option<u32>,
}
```

### SmallVec for Small Collections

```rust
use smallvec::SmallVec;

// Stack allocation for up to 8 elements, heap only if larger
let mut items: SmallVec<[Item; 8]> = SmallVec::new();
```

---

## 4) Reduce Allocations

### Pre-allocate with Capacity

```rust
// BAD: Multiple reallocations
let mut results = Vec::new();
for item in items {
    results.push(transform(item));
}

// GOOD: Single allocation
let mut results = Vec::with_capacity(items.len());
for item in items {
    results.push(transform(item));
}

// BETTER: Use collect with size hint
let results: Vec<_> = items.iter().map(transform).collect();
```

### Avoid Cloning When Borrowing Suffices

```rust
// BAD: Unnecessary clone
fn process(data: &Data) -> String {
    let s = data.name.clone();  // allocation
    format!("Hello, {}", s)
}

// GOOD: Borrow
fn process(data: &Data) -> String {
    format!("Hello, {}", &data.name)
}
```

---

## 5) Avoid Unnecessary Work

### Fast Paths for Common Cases

```rust
// Fast path for single-byte varint (common case)
fn parse_varint(data: &[u8]) -> (u64, usize) {
    if data[0] < 128 {
        return (data[0] as u64, 1);  // 90% of cases
    }
    parse_varint_slow(data)  // Rare multi-byte
}
```

### Defer Expensive Computations

```rust
// BAD: Always computes expensive value
fn process(data: &Data, config: &Config) {
    let expensive = compute_expensive(data);  // Always runs
    if config.needs_expensive {
        use(expensive);
    }
}

// GOOD: Defer until needed
fn process(data: &Data, config: &Config) {
    if config.needs_expensive {
        let expensive = compute_expensive(data);  // Only when needed
        use(expensive);
    }
}
```

### Move Loop-Invariant Code Outside Loops

```rust
// BAD: Repeated computation in loop
for item in items {
    let result = config.transform_fn(item);  // lookup per iteration
}

// GOOD: Hoist invariant lookups
let transform = &config.transform_fn;
for item in items {
    let result = transform(item);
}
```

---

## 6) Async Optimization

### Concurrent vs Sequential Await

```rust
// BAD: Sequential await
async fn fetch_all(urls: Vec<Url>) -> Vec<Response> {
    let mut results = Vec::new();
    for url in urls {
        results.push(fetch(&url).await);  // Sequential
    }
    results
}

// GOOD: Concurrent with join_all
async fn fetch_all(urls: Vec<Url>) -> Vec<Response> {
    futures::future::join_all(urls.iter().map(fetch)).await
}

// BETTER: Bounded concurrency with buffer_unordered
use futures::stream::{self, StreamExt};

async fn fetch_all(urls: Vec<Url>) -> Vec<Response> {
    stream::iter(urls)
        .map(|url| fetch(url))
        .buffer_unordered(10)  // Max 10 concurrent
        .collect()
        .await
}
```

---

## 7) Reduce Logging Costs in Hot Paths

```rust
// BAD: log! macro overhead in hot loop
for item in items {
    log::debug!("Processing {:?}", item);  // Format even if disabled
}

// GOOD: Check level outside loop
if log::log_enabled!(log::Level::Debug) {
    for item in items {
        log::debug!("Processing {:?}", item);
    }
}

// BETTER: Use tracing with static filtering
#[tracing::instrument(skip_all)]
fn process_batch(items: &[Item]) {
    // Span created once, not per item
    for item in items {
        // Hot loop without logging
    }
}
```

---

## Quick Review Checklist

- [ ] Any O(N²) behavior on realistic N?
- [ ] Missing `with_capacity()` for known-size collections?
- [ ] Unnecessary `.clone()` where borrow would work?
- [ ] String allocation in hot loops (use `&str` or `Cow`)?
- [ ] Box/Arc where stack allocation would work?
- [ ] Excessive async task spawning for small operations?
- [ ] Poor struct field ordering (padding waste)?
- [ ] Missing `#[inline]` on critical small functions?
- [ ] Lock contention in concurrent code?
- [ ] Logging format overhead in hot paths?

---

## Flat-Profile Playbook

If no single hotspot dominates:

1. Don't discount many small wins (twenty 1% improvements can matter)
2. Look for loops closer to the top of call stacks (flame graphs help)
3. Consider structural refactors (one-shot construction instead of incremental mutation)
4. Replace overly general abstractions with specialized code
5. Reduce allocations (allocation profiles help)
6. Use hardware counters (cache misses, branch misses) to find invisible costs
7. **Rust-specific:** Look for excessive async overhead, unnecessary clones, poor cache locality

---

## Example: Unnecessary Clones

**Problem:**
```rust
fn build_response(data: &ResponseData) -> String {
    let name = data.name.clone();
    let id = data.id.clone();
    format!("User {} ({})", name, id)
}
```

**Fix:**
```rust
fn build_response(data: &ResponseData) -> String {
    format!("User {} ({})", &data.name, &data.id)
}
```

**Expected impact:** 2 fewer allocations per call.
