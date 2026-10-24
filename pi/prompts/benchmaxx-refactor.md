---
description: Verbatim refactor prompt from https://minimaxir.com/2026/09/agentic-iteration/
---

The Rust code in `/src` has become particularly bloated, with several source files >1k SLoC. Refactor and reduce the Rust source codebase by **atleast 20% SLoC** through deduplication, pruning redundant code, and following idiomatic DRY Rust principles. Simultanously, refactor and split the code such that no single source file has >1k SLoC, splitting larger files into multiple subfiles in accordance to Rust standards for popular open-source repositories. Ensure **all current tests pass and there are no severe regressions**.

Additionally, ensure there are **zero `criterion` benchmark speed regressions**: if a speed regression occurs on a given benchmark as a result of the refactor, you **MUST** keep iterating afterwards to improve those benchmarks to atleast zero regression. NEVER hack the benchmarks to accomplish this speed increase, only iterate on the library code.
