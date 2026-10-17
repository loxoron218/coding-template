# Coding Template

A modern project template for building applications with opencode AI assistance and
mattpocock/skills engineering workflows.

## Quick Start

Download and initialize the template:

```bash
curl -L https://raw.githubusercontent.com/loxoron218/coding-template/refs/heads/main/start.sh -o start.sh && chmod +x start.sh && ./start.sh
```

This script will:

- Clone the template repository
- Move opencode configuration to your home directory
- Initialize a Rust project
- Install mattpocock/skills for opencode

## Features

- **opencode Integration**: Pre-configured AI coding assistant with multiple model support
- **REA reverse engineering** (`rea-agents@latest` local MCP `rea` + `reverse-engineer-anything` skill): inspect binaries, apps, and runtime behavior with evidence
- **Ponytail plugin** (`@dietrichgebert/ponytail@latest`, default `full`): always-on lazy-senior-dev ruleset injected every turn via plugin hooks. Deliberately not vendored under `.opencode/skills/` — passive skills self-activate ~never, only the plugin injection produces measurable results.
- **Skills for Real Engineers** (mattpocock/skills):
  composable engineering workflows (grill → spec → tickets → implement + `tdd`)
- **Rust Tooling**: Pre-configured clippy, rustfmt, and lints for code quality and formatting
- **Specialized Review Agents** (`.opencode/agents/`):
  - `uncommitted-review`: General code quality review
- **Slash Commands** (`.opencode/command/`):
  - `uncommitted-review`: General code quality review with focus on maintainability
- **Active Development Skills** (`.opencode/skills/`):
  - `m10-performance`: Systematic performance optimization techniques
  - `sql-optimization-patterns`: Database query optimization strategies
- **Inactive Skills** (`docs/unused-skills/`): code-review-excellence, frontend-design,
  gtk-ui-ux-engineer, karpathy-guidelines, performance-optimization, rust-best-practices,
  senior-rust-practices, skill-creator

## Documentation

Additional documentation is available in the `docs/` directory:

- **CODING_STANDARDS.md**: Style, error handling, concurrency, tracing, and testing conventions
- **docs/templates/AGENTS.md**: Agent configuration templates
- **docs/templates/CLAUDE.md**: Claude AI integration templates
- **docs/unused-skills/**: Skills that are available but not currently active

## Engineering Skills Workflow

| Step | Skill |
| --- | --- |
| Set up repo (once) | `/setup-matt-pocock-skills` |
| Sharpen an idea | `/grill-with-docs` (repo) or `/grill-me` (no repo) |
| Only if too foggy for one session | `/wayfinder` (hands off to `/to-spec`) |
| Spec the work | `/to-spec` |
| Split into tickets | `/to-tickets` |
| Build it | `/implement` (per ticket) or `/implement-spec` (whole spec) |
| Improve the setup after a session | `/retro` |

Optional — only when the situation calls for it:

| Situation | Skill |
| --- | --- |
| Unsure which skill fits | `/ask-matt` |
| Raw bugs/requests piling up | `/triage` (never for `/to-tickets` output) |
| Spare moment for codebase health | `/improve-codebase-architecture` |
| Move work across sessions | `/handoff` |
| Blocked on someone else's input | `/to-questionnaire` |
| Learn a topic | `/teach` |
| A message didn't land | `/wait-what` |

## Configuration Files

### opencode Configuration (`.opencode/opencode.json`)

Main configuration file for the opencode AI assistant, defining:

- Plugin configuration (e.g. `@slkiser/opencode-quota` for usage tracking,
  `@dietrichgebert/ponytail` for the always-on lazy-senior-dev ruleset)
- MCP server connections: `context7` for library documentation, `rea` (`npx -y rea-agents@latest mcp`)
  for reverse engineering
- Agent and skill activation

### Rust Tooling

The template includes pre-configured Rust development tools:

- **clippy.toml**: Configures the Rust linter with sensible defaults:
  - Enforces consistent formatting for format arguments
  - Limits excessive nesting to 3 levels
  - Restricts absolute paths to 1 segment

- **rustfmt.toml**: Configures the Rust code formatter:
  - Organizes imports with `One` granularity
  - Uses 2024 style edition
  - Enables unstable features

- **lints.toml**: Configures project-wide lints for additional code quality rules

## Project Structure

```
.
├── .opencode/                                        # opencode AI assistant configuration
│   ├── agents/                                       # Specialized review agents
│   │   └── uncommitted-review.md                     # General code quality review
│   ├── command/                                      # Slash command implementations
│   │   └── uncommitted-review.md                     # General code quality review
│   ├── skills/                                       # Active development skills
│   │   ├── m10-performance/                          # Performance optimization skill
│   │   │   ├── patterns/
│   │   │   │   └── optimization-guide.md
│   │   │   └── SKILL.md
│   │   └── sql-optimization-patterns/
│   │       └── SKILL.md                              # SQL query optimization
│   └── opencode.json                                 # Main opencode configuration
├── AGENTS.md                                         # Agent configuration documentation
├── clippy.toml                                       # Rust linter configuration
├── CODING_STANDARDS.md                               # Coding standards and conventions
├── docs/                                             # Documentation
│   ├── resources/                                    # Coding references
│   │   ├── rust-performance-optimization.md          # Rust performance optimization guide
│   │   └── writing-a-good-claude.md                  # Guide on how to write AGENTS.md file
│   ├── templates/                                    # Template documentation
│   │   ├── AGENTS.md                                 # Agent configuration templates
│   │   └── CLAUDE.md                                 # Claude AI integration templates
│   └── unused-skills/                                # Inactive/skipped skills
│       ├── code-review-excellence/
│       ├── frontend-design/
│       ├── gtk-ui-ux-engineer/
│       ├── karpathy-guidelines/
│       ├── performance-optimization/
│       ├── rust-best-practices/
│       ├── senior-rust-practices/
│       └── skill-creator/
├── LICENSE                                           # Project license
├── lints.toml                                        # Rust lints configuration
├── README.md                                         # This file
├── rustfmt.toml                                      # Rust formatter configuration
├── start.sh                                          # Setup script
```

## License

See the [LICENSE](LICENSE) file for details.
