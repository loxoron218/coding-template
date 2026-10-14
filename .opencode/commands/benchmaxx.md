---
description: Ur-Prompt for iterative Rust benchmarking from https://minimaxir.com/2026/09/agentic-iteration/, adapted for opencode
---

Optimize the Rust code in this Rust crate to its maximum potential. Specifically, **you MUST make a breakthrough from this current implementation** that uses modern concepts and knowledge as of 2026 to further improve this crate **without causing ANY significant regressions**.

First, **before making any library changes**, run the Rust benchmarks (and any competitor benchmarks if applicable) to establish a True Performance Baseline for both speed and metric performance. Return the absolute and relative results to the True Performance Baseline to the user as a Markdown table.

Then, optimize the Rust library code such that these benchmarks are **atleast 1.2x faster** from the True Performance Baseline; ideally as fast as possible, without any significant regressions on quality and prediction error. NEVER hack the benchmarks to accomplish this speed increase, only iterate on the library code. Ensure all benchmark iterations are independent, e.g. NEVER reuse a cache built in one iteration within another iteration.

Due to the current highly-optimized state of this repository, this is a very difficult problem and traditional engineering approaches **WILL BE GUARANTEED TO FAIL** to hit the specified metric constraint. Therefore, you have permission and encouragement to investigate more radical fundamental low-level changes to hit the desired metrics. You have permission and encouragement to invent completely new/bespoke algorithms and engineering approaches that have never been before been utilized for this problem in order to hit the specified metric constraint.

To best accomplish innovative implementations, you **MUST** spin up 7-12 independent distinct "subagents" by running a long-duration CLI command (do not use the subagent tool) which can explore and evaluate different feasible hypotheses for improving the performance, usability, and security of this crate. Only have the agents return their response; do not save their full transcript to a file. Instruct them to be **very** picky. These subagents MUST use the default model via opencode, e.g.

```sh
opencode run --agent plan \
  "PROMPT"
```

You must instruct these subagents to NOT run tests/benchmarks, as they will compete for resources and not be valid. After you are done making changes, before handing off to the user, spin up the subagents again to confirm your implementation matches their hypotheses and ask for potential further areas of improvement. Keep iterating until ALL subagents are satisfied with your implementation.

Do not import similar implementations from other Rust crates: you MUST implement from scratch.

You may consider using profiling areas of the codebase to find specific areas and hot paths which scale poorly (e.g. O(n^2)) at large amounts of data.

You may use ANY techniques to do achieve the specified metric constraint (e.g. import new crates, add tuning profiles which are active for larger data) other than adding `unsafe` code. **REPEAT THIS PROCESS UNTIL BENCHMARK PERFORMANCE CONVERGES AND YOU ARE OUT OF OPTIMIZATION IDEAS.** You have permission to keep iterating. After each benchmark iteration, return the absolute and relative results to the True Performance Baseline to the user as a Markdown table.

Prioritize making quick/high-impact wins iteratively and making changes accordingly. Do not overthink the necessary changes.
