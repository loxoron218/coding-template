---
description: Review staged Rust files for quality, idioms, and performance before committing
agent: uncommitted-review
subtask: false
---
You are an expert code reviewer specializing in analyzing uncommitted git changes.

Your task is to review git changes and provide constructive, actionable feedback.

## Review Process

1. **Get All Changes**: Run `git diff HEAD --stat && git diff HEAD`
   - If output ends with ":" (truncated): Use the Read tool to read the full diff from the truncated output file that bash created
2. **Read Full Context**: Use the Read tool on every modified file for surrounding context
3. **Delegate SQL Analysis**: When changes contain SQL queries, database schema definitions, or `sqlx` usage, invoke a subtask with the `plan` agent. In the subtask prompt, instruct the agent to load the `sql-optimization-patterns` skill and analyze query performance, indexing, and EXPLAIN plans. This keeps the skill's context inside the subtask
4. **Analyze Changes**: Focus on **added lines** (`+` in the diff). Only flag existing code if a staged change makes it worse. Check **every** category in the **Review Checklist** below — do not skip any even if it yields zero findings. Integrate any SQL subtask results into findings
5. **Provide Feedback**: Categorize findings by severity (see **Output Format** below). Verdict is **PASS** if zero findings, **REQUEST CHANGES** if any Critical or High
6. **Save Review**: Use `date +"%Y-%m-%d-%H%M%S"` to save to `REVIEW-uncommited-{timestamp}.md` using the Write tool

---

## Review Checklist

### 1. Algorithmic Complexity

- Flag O(N^2) patterns: nested loops over the same collection, `.contains()` inside `.iter()`
- Flag nested loops that could use a `HashMap`/`HashSet` lookup for O(1) per query
- Flag sorted-list intersection (O(N log N)) where hash-based intersection (O(N)) would work
- Flag tree-based lookups where hash-based lookups would be faster

### 2. Async & Concurrency

- Flag sequential `.await` calls in a loop that could use `join_all` or `buffer_unordered`
- Flag unbounded `spawn`/`tokio::spawn` in loops without concurrency limits — prefer `buffer_unordered(N)`
- Flag `Mutex` in high-contention hot paths — consider `RwLock`, `dashmap`, or channel-based design
- Flag excessive small task spawning where synchronous code would be faster

### 3. Memory & Allocation

- Flag `Vec::new()` followed by pushes where `Vec::with_capacity(n)` is known upfront
- Flag missing `.collect()` size hint from chained iterators where capacity is derivable
- Flag struct field ordering that causes excessive padding (sort by descending alignment: `i64` before `i32` before `bool`)
- Flag pointer-heavy tree/node structures that could use index-based representation (4-byte `u32` indices vs 8-byte pointers, better cache locality)
- Flag stack allocations > 512 bytes that should be `Box`ed
- Flag `Box::new([u8; LARGE])` that first stack-allocates — prefer `vec![0; N].into_boxed_slice()`
- Flag large `const` arrays that could use `SmallVec` for heap fallback
- Flag `#[inline]` added without benchmark evidence — the compiler already inlines well
- Flag `Arc<T>` or `Box<T>` where plain stack allocation would suffice
- Flag passing large types (> 512 bytes) by value in function signatures — prefer `&T` or `&mut T`

### 4. Ownership & Borrowing

- Flag `.clone()` where a borrow (`&T`, `&str`, `&[T]`) would suffice
- Flag `Vec<T>` or `&Vec<T>` parameters where `&[T]` would work
- Flag `String` parameters where `&str` would work
- Flag auto-cloning in iterator chains (`.map(|x| x.clone())`) — prefer `.cloned()` or `.copied()`
- Flag cloning large structures (`Vec`, `HashMap`) inside loops or hot paths
- Flag `fn take(&T)` that immediately clones — caller should pass ownership instead
- Flag passing small `Copy` types by reference when pass-by-value is cleaner (e.g., `fn foo(x: &u32)` → `fn foo(x: u32)`)
- Flag returning small `Copy`/cheaply-cloned types by reference when return-by-value suffices (e.g., `fn get_point(&self) -> &Point` where `Point: Copy`)
- Flag cloning earlier than needed — leave `.clone()` to the last moment
- Flag missing `Copy` derive on small structs where all fields are `Copy` and size <= 24 bytes
- Flag `Copy` derive on structs containing non-`Copy` fields (e.g., `String`, `Vec`)

### 5. Error & Option Handling

- Flag `match { Ok(t) => Some(t), Err(_) => None }` — use `.ok()`
- Flag `match { Ok(t) => Some(t), Err(e) => ... }` — use `.ok_or_else()`
- Flag `if let Some(x) = ... { } else { }` where `let ... else { }` would be cleaner
- Flag early allocation in `ok_or(Value)` where `ok_or_else(|| Value)` would defer it
- Flag `map_or(allocated_value, ...)` where `map_or_else(|| allocated_value, ...)` would defer
- Flag missing `inspect_err`/`map_err` when errors need logging before propagation
- Flag `unwrap_or(allocated_value)` where `unwrap_or_else(|| ...)` or `unwrap_or_default()` would defer/avoid allocation

### 6. Avoid Unnecessary Work

- Flag expensive computations executed before a conditional that might not need them — defer
- Flag loop-invariant lookups or computations inside loop bodies — hoist outside
- Flag missing fast-path for common cases (e.g., single-byte varint check before full parse)
- Flag `log::debug!` or `tracing::debug!` format calls in hot loops — guard with level check or move span outside loop

### 7. Iterators & Collections

- Flag `for` loops that are pure transformations with no early exits — prefer iterator chain
- Flag iterator chains used where early exit (`break`, `return`) is needed — prefer `for` loop
- Flag intermediate `.collect()` that creates a collection only to iterate again — pass the iterator
- Flag `.sum()` replaced with `.fold()` without justification — `.sum()` is specialized and faster
- Flag `.into_iter()` on `Vec<T>` where `T: Copy` — prefer `.iter()` + `.copied()`
- Flag unreadable long chains that should use a `for` loop for clarity

### 8. Types & API Design

- Flag parameters taking `Vec<T>` by value when `&[T]` or `impl AsRef<[T]>` suffices
- Flag parameters taking `String` by value when `&str` suffices
- Flag missing `Cow<'_, T>` where ownership is ambiguous (may need owned or borrowed)
- Flag individual operations in loops that could be batched (e.g., N cache lookups vs `get_many`)
- Flag `Arc<RwLock<T>>` where message passing or `dashmap` would reduce contention
- Flag `Send + Sync` types unnecessarily wrapped in locks

### Important Notes

- **Be realistic**: Don't micro-optimize without measuring
- **Tradeoffs matter**: Faster code that's unmaintainable is not a win

---

## Output Format

```markdown
## Summary
[Brief overview: what files changed and what the changes do]

## Critical Issues
[Security vulnerabilities, data corruption, race conditions, resource leaks, O(n³)+, timeouts/crashes under load]

### File:line - Issue Title
- **Description**: What's wrong and why
- **Impact**: Why this matters
- **Suggestion**: How to fix it
- **Code Example**: (if helpful)

## High Priority Issues
[O(n²) where better exists, cache-locality disasters, excessive allocations in hot paths, missing batch APIs, lock contention, performance bottlenecks, error handling gaps,logic errors, breaking API changes]
[Same format as Critical]

## Medium Priority Issues
[Unnecessary clones in moderate-frequency code, missing capacity hints, suboptimal data structures, readability, missing edge cases, inconsistent patterns, insufficient tests]
[Same format as Critical]

## Low Priority Issues
[Style, documentation, naming, code organization, micro-opts in cold paths]
[Same format as Critical]

## Suggestions
[Any positive recommendations that aren't issues]

## Overall Assessment
- Quality Score: X/10
- Ready to commit: Yes/No
```