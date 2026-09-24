# Initialize Rust (skip when already initialized)
[ -f Cargo.toml ] || cargo init

# Install CLI and init
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
printf "y\nsh\n" | specify init --here --integration opencode
specify extension add bug
specify extension add assess

# Move speckit commands system-wide (spec-kit hardcodes per-project .opencode/commands)
# NOTE: future `specify extension add` / `integration upgrade` runs recreate
# .opencode/commands — re-run this block to move them system-wide again.
TARGET="/home/$(whoami)/.config/opencode"
if [ -d .opencode/commands ]; then
  mkdir -p "$TARGET/commands" "$TARGET/command"
  cp .opencode/commands/speckit.*.md "$TARGET/commands/"
  cp .opencode/commands/speckit.*.md "$TARGET/command/"
  rm -rf .opencode/commands
fi

# Copy template files from coding-template and merge .opencode
# (AGENTS.md is project-specific: keep existing. Everything else reverts to defaults.)
TEMP_DIR=$(mktemp -d)
git clone https://github.com/loxoron218/coding-template.git "$TEMP_DIR"
[ -f AGENTS.md ] || cp "$TEMP_DIR/AGENTS.md" .
cp "$TEMP_DIR"/clippy.toml "$TEMP_DIR"/CODING_STANDARDS.md "$TEMP_DIR"/LICENSE "$TEMP_DIR"/rustfmt.toml "$TEMP_DIR"/lints.toml .
cp -r "$TEMP_DIR"/.opencode/. ./.opencode/

# Reinstall latest template `cargo collate` to ~/.cargo/bin (strict-Rust, no python/alias/per-project copy).
[ -d "$TEMP_DIR/collate" ] && cargo install --force --path "$TEMP_DIR/collate"
rm -rf "$TEMP_DIR"

# Add lints from lints.toml to Cargo.toml (skip when already present)
grep -q '^\[lints' Cargo.toml 2>/dev/null || cat lints.toml >> Cargo.toml
rm -f lints.toml

# Merge opencode files to home
mkdir -p "$TARGET"
cp -r ./.opencode/. "$TARGET"
rm -rf ./.opencode

# Add specify to gitignore (idempotent: only missing lines; explicit files only,
# new machine-local CLI files must show as untracked)
[ -f .gitignore ] || touch .gitignore
[ -z "$(tail -c 1 .gitignore)" ] || echo >> .gitignore
while IFS= read -r line; do
  grep -qxF "$line" .gitignore || echo "$line" >> .gitignore
done << 'EOF'
.specify/.gitignore
.specify/extensions.yml
.specify/extensions/*/README.md
.specify/extensions/*/commands/*.md
.specify/extensions/*/extension.yml
.specify/extensions/*/local-config.yml
.specify/extensions/.registry
.specify/feature.json
.specify/init-options.json
.specify/integration.json
.specify/integrations/opencode.manifest.json
.specify/integrations/speckit.manifest.json
.specify/scripts/bash/check-prerequisites.sh
.specify/scripts/bash/common.sh
.specify/scripts/bash/create-new-feature.sh
.specify/scripts/bash/resolve-template.sh
.specify/scripts/bash/setup-plan.sh
.specify/scripts/bash/setup-tasks.sh
.specify/templates/checklist-template.md
.specify/templates/constitution-template.md
.specify/templates/plan-template.md
.specify/templates/spec-template.md
.specify/templates/tasks-template.md
.specify/workflows/speckit/workflow.yml
.specify/workflows/workflow-registry.json
EOF

# Removes the script file after completion
rm "$0"
