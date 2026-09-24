# Coding Template

A modern project template for building applications with opencode AI assistance and spec-kit
specification tools.

## Quick Start

Download and initialize the template:

```bash
curl -L https://raw.githubusercontent.com/loxoron218/coding-template/refs/heads/main/start.sh -o start.sh && chmod +x start.sh && ./start.sh
```

This script will:

- Clone the template repository
- Move opencode configuration to your home directory
- Initialize a Rust project
- Install and configure spec-kit CLI
- Install the `cargo collate` hygiene checker

## Features

- **opencode Integration**: Pre-configured AI coding assistant with multiple model support
- **spec-kit**: Project specification and planning tools
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

## Spec-Kit Slash Commands

| Command | Example |
| --- | --- |
| `/speckit.constitution` | Create principles focused on code quality, testing standards, user experience consistency, and performance requirements |
| `/speckit.specify` | Build an application that can help me organize my photos in separate photo albums. Albums are grouped by date and can be re-organized by dragging and dropping on the main page. Albums are never in other nested albums. Within each album, photos are previewed in a tile-like interface |
| `/speckit.clarify` | Focus on the task card behavior: status changes, comment limits, and who can be assigned |
| `/speckit.plan` | The application uses Vite with minimal number of libraries. Use vanilla HTML, CSS, and JavaScript as much as possible. Images are not uploaded anywhere and metadata is stored in a local SQLite database |
| `/speckit.checklist` | Focus on the Kanban board interactions and comment permissions |
| `/speckit.tasks` | — |
| `/speckit.taskstoissues` | — |
| `/speckit.analyze` | — |
| `/speckit.implement` | Implement only the Setup and Foundational phases: project scaffolding and the project/task data model with basic CRUD. Stop before the user-story features |
| `/speckit.converge` | — |

### Spec-Kit Extensions

| Command               | Example                                                                              |
| --------------------- | ------------------------------------------------------------------------------------ |
| `/speckit.bug.assess` | "TypeError: cannot read properties of undefined (reading 'token') at /auth/callback" |
| `/speckit.bug.fix`    | —                                                                                    |
| `/speckit.bug.test`   | —                                                                                    |

| Command                    | Example                                                |
| -------------------------- | ------------------------------------------------------ |
| `/speckit.assess.intake`   | "Let users work offline and sync when they reconnect." |
| `/speckit.assess.research` | —                                                      |
| `/speckit.assess.define`   | —                                                      |
| `/speckit.assess.shape`    | —                                                      |
| `/speckit.assess.decide`   | —                                                      |

## Configuration Files

### opencode Configuration (`.opencode/opencode.json`)

Main configuration file for the opencode AI assistant, defining:

- Plugin configuration (e.g. `@slkiser/opencode-quota` for usage tracking)
- MCP server connections (e.g. `context7` for library documentation)
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

- **collate** (`collate/`, install once via `cargo install --path collate`, then run via
  `cargo collate`): Project-specific hygiene checks for strict Rust (see `collate/README.md` for the
  full lint list). Pure Rust plus the `rg`/`jscpd` CLIs: `cargo install ripgrep jscpd`. Exits `1` on
  findings, `2` on usage/environment errors.

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
└── collate/                                          # Strict-Rust hygiene checker (no python)
```

## License

See the [LICENSE](LICENSE) file for details.
