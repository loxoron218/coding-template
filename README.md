# Vibe Code Template

A modern project template for building applications with opencode AI assistance and spec-kit specification tools.

## Quick Start

Download and initialize the template:

```bash
curl -L https://raw.githubusercontent.com/loxoron218/vibe-code-template/refs/heads/main/start.sh -o start.sh && chmod +x start.sh && ./start.sh
```

This script will:
- Clone the template repository
- Move opencode configuration to your home directory
- Initialize a Rust project
- Install and configure spec-kit CLI

## Features

- **opencode Integration**: Pre-configured AI coding assistant with multiple model support
- **spec-kit**: Project specification and planning tools
- **Rust Tooling**: Pre-configured clippy, rustfmt, and lints for code quality and formatting
- **Specialized Review Agents** (`.opencode/agents/`):
  - `git-review`: Git-focused code review
  - `uncommitted-review`: General code quality review
- **Slash Commands** (`.opencode/command/`):
  - `performance-review`: Analyzes code for performance bottlenecks and optimization opportunities
  - `security-review`: Identifies security vulnerabilities and best practice violations
  - `uncommitted-review`: General code quality review with focus on maintainability
- **Active Development Skills** (`.opencode/skills/`):
  - `m10-performance`: Systematic performance optimization techniques
  - `sql-optimization-patterns`: Database query optimization strategies
- **Inactive Skills** (`docs/unused-skills/`): code-review-excellence, frontend-design, gtk-ui-ux-engineer, karpathy-guidelines, performance-optimization, senior-rust-practices, skill-creator

## Documentation

Additional documentation is available in the `docs/` directory:

- **docs/templates/AGENTS.md**: Agent configuration templates
- **docs/templates/CLAUDE.md**: Claude AI integration templates
- **docs/unused-skills/**: Skills that are available but not currently active

## Spec-Kit Slash Commands

| Command | Description |
| --- | --- |
| `/speckit.constitution` | Create or update project governing principles and development guidelines. |
| `/speckit.specify` | Define requirements, user stories, and the scope of what you want to build. |
| `/speckit.plan` | Generate technical implementation plans based on your chosen tech stack. |
| `/speckit.tasks` | Break down the plan into a granular, actionable task list. |
| `/speckit.implement` | Automatically execute tasks to build features according to the approved plan. |

## Configuration Files

### opencode Configuration (`.opencode/opencode.json`)
Main configuration file for the opencode AI assistant, defining:
- Model selection and API settings
- Agent and skill activation
- Context limits and behavior preferences

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
│   │   ├── git-review.md                             # Git-focused code review
│   │   └── uncommitted-review.md                     # General code quality review
│   ├── command/                                      # Slash command implementations
│   │   ├── performance-review.md                     # Performance-focused code review
│   │   ├── security-review.md                        # Security-focused code review
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
├── docs/                                             # Documentation
│   ├── templates/                                    # Template documentation
│   │   ├── AGENTS.md                                 # Agent configuration templates
│   │   └── CLAUDE.md                                 # Claude AI integration templates
│   └── unused-skills/                                # Inactive/skipped skills
│       ├── code-review-excellence/
│       ├── frontend-design/
│       ├── gtk-ui-ux-engineer/
│       ├── karpathy-guidelines/
│       ├── performance-optimization/
│       ├── senior-rust-practices/
│       └── skill-creator/
├── LICENSE                                           # Project license
├── lints.toml                                        # Rust lints configuration
├── README.md                                         # This file
├── rustfmt.toml                                      # Rust formatter configuration
└── start.sh                                          # Setup script
```

## License

See the [LICENSE](LICENSE) file for details.
