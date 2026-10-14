---
description: Verbatim competition prompt from https://minimaxir.com/2026/09/agentic-iteration/
---

Create an additional comparison script containing **atleast 10** `criterion` benchmarks which compare the performance speed and quality metrics between this crate and the following crates:

- askama
- minijinja
- tera

These benchmarks **ALL MUST**:

- be perfectly fair, containing apples-to-apples comparisons of ALL frameworks, with no bespoke advantage for any tested framework
- be based around real-world use cases instead of highly-synthetic use cases
- be independent and distinct, covering as many sailent hot paths of the code as possible
- cover data input sizes small and large, simple and complex

Then, optimize the Rust library code such that this crate MUST be:

- **atleast 2.0x faster** than **ALL** competing Rust crates in all benchmarks on apples-to-apples comparisons; ideally as fast as possible.
