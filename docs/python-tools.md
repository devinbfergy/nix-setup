# Python and Runtime Management Tools

This configuration includes modern Python development tools and runtime managers that are installed via Nix.

## UV - Fast Python Package Installer

UV is an extremely fast Python package installer and resolver, written in Rust. It's a drop-in replacement for pip and pip-tools.

### Features
- 10-100x faster than pip
- Drop-in replacement for pip, pip-tools, and virtualenv
- Compatible with pip and virtualenv
- Resolves dependencies correctly and quickly

### Basic Usage

```bash
# Create a virtual environment
uv venv

# Install packages
uv pip install requests numpy pandas

# Install from requirements.txt
uv pip install -r requirements.txt

# Compile requirements
uv pip compile pyproject.toml -o requirements.txt

# Sync environment
uv pip sync requirements.txt
```

### Integration with Projects

```bash
# In your Python project
uv venv .venv
source .venv/bin/activate  # or .venv/bin/activate.fish
uv pip install -r requirements.txt
```

## Ruff - Fast Python Linter and Formatter

Ruff is an extremely fast Python linter and code formatter, written in Rust. It replaces Flake8, Black, isort, pydocstyle, and more.

### Features
- 10-100x faster than existing Python linters
- Compatible with Black for formatting
- Supports 700+ lint rules
- Auto-fixes for many issues
- Native editor integrations

### Basic Usage

```bash
# Lint a file or directory
ruff check .
ruff check path/to/file.py

# Auto-fix issues
ruff check --fix .

# Format code (Black-compatible)
ruff format .
ruff format path/to/file.py

# Watch mode
ruff check --watch .
```

### Configuration

Create a `ruff.toml` or add to `pyproject.toml`:

```toml
[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
]
ignore = ["E501"]  # Line too long

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

### Neovim Integration

Ruff is already configured as part of your Neovim LSP setup. It will:
- Show linting errors inline
- Format on save (if configured)
- Provide quick fixes

## Mise - Polyglot Runtime Manager with Nix Integration

Mise (formerly rtx) is a fast runtime manager that replaces asdf, nvm, rbenv, pyenv, and others. **This configuration uses mise's Nix integration for the best of both worlds.**

### Features
- Polyglot: manages versions for Node, Python, Ruby, Go, Java, etc.
- Fast: written in Rust
- Compatible with asdf plugins
- Project-specific versions via `.mise.toml`
- Automatic activation in shell
- **Nix Integration**: Uses Nix packages when available for faster, cached installs

### Already Configured with Nix Integration

Mise is automatically activated in your ZSH shell with Nix integration enabled:

- **Global tools** (uv, ruff, node, python) are managed by Nix in `home/default.nix`
- **Project-specific versions** are managed by mise using Nix as a backend when possible
- Configuration at `~/.config/mise/config.toml` is managed by home-manager
- `use_nix = true` is enabled, allowing mise to leverage nixpkgs

### How Mise + Nix Integration Works

When you run `mise install node@20`, mise will:

1. First check if the tool is available via Nix
2. If yes, install it from nixpkgs (fast, cached, reproducible)
3. If no, fall back to the standard mise installation method

This gives you:
- **Speed**: Nix binary cache means instant installs
- **Reproducibility**: Same tools across machines
- **Flexibility**: Use mise for tools not in nixpkgs
- **Project isolation**: Each project can have different versions

### Basic Usage

```bash
# Install a runtime
mise install node@20
mise install python@3.11

# Set global version
mise use -g node@20
mise use -g python@3.11

# Set project-local version
cd myproject
mise use node@20
mise use python@3.11

# List installed versions
mise list

# List available versions
mise ls-remote node
mise ls-remote python

# Install all tools from .mise.toml
mise install

# Show current versions
mise current
```

### Project Configuration

Create a `.mise.toml` in your project:

```toml
[tools]
node = "20"
python = "3.11"

[env]
DATABASE_URL = "postgresql://localhost/mydb"
```

Or use `.tool-versions` (asdf compatible):

```
node 20.0.0
python 3.11.0
ruby 3.2.0
```

### Per-Project Environment Variables

Mise can also manage environment variables per project:

```toml
# .mise.toml
[tools]
node = "20"

[env]
NODE_ENV = "development"
DATABASE_URL = "postgresql://localhost/mydb"
API_KEY = { file = ".env.secret" }
```

### Tasks

Mise can also run project tasks (like make, npm scripts, etc.):

```toml
# .mise.toml
[tasks.dev]
run = "npm run dev"
description = "Start dev server"

[tasks.test]
run = "npm test"
description = "Run tests"
```

Then run: `mise run dev` or `mise run test`

### Using Nix Backend with Mise

Mise can use Nix as a backend for tool installation. This is already configured with `use_nix = true`.

**Example: Install Node using Nix through mise**

```bash
# This will use nixpkgs if available
mise install node@20

# Check where it came from
mise where node@20
# Output: /nix/store/...

# Use it in a project
cd myproject
mise use node@20
```

**Using Nix-specific tool definitions:**

You can also use the `nix:` prefix to explicitly use Nix:

```toml
# .mise.toml
[tools]
# Use Nix package explicitly
node = "nix:nodejs-20_x"
python = "nix:python311"

# Or use regular mise version (will try Nix first)
ruby = "3.2"
```

**Combining with direnv:**

For even better integration, use mise with direnv:

```bash
# .envrc in your project
use mise
```

This automatically activates mise tools when you cd into the directory.

### Mise + Nix Best Practices

1. **Global tools via Nix**: Install tools you use everywhere in `home/default.nix`
   ```nix
   home.packages = [ pkgs.nodejs pkgs.python3 pkgs.uv pkgs.ruff ];
   ```

2. **Project-specific versions via mise**: Use mise for per-project versions
   ```toml
   [tools]
   node = "18"  # This project needs Node 18
   python = "3.11"  # While your global is 3.12
   ```

3. **Let mise use Nix**: With `use_nix = true`, mise will leverage Nix when possible

4. **Development shells for team projects**: Create a `flake.nix` for reproducibility
   ```nix
   {
     inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
     outputs = { nixpkgs, ... }: {
       devShells.x86_64-darwin.default = nixpkgs.legacyPackages.x86_64-darwin.mkShell {
         buildInputs = [ nixpkgs.legacyPackages.x86_64-darwin.nodejs-20_x ];
       };
     };
   }
   ```

## OpenCode - AI Development Tool

OpenCode is included in your PATH if installed. Configuration is managed at `~/.config/opencode/opencode.json`.

### Usage

```bash
# Start OpenCode
opencode

# With a specific file
opencode path/to/file.py

# With a project
opencode path/to/project
```

Configuration is automatically symlinked from this repository.

## Combining Tools

Here's how these tools work together in a typical Python project:

```bash
# Set up a new Python project
cd myproject

# Set Python version with mise
mise use python@3.11

# Create virtual environment with uv
uv venv

# Activate environment
source .venv/bin/activate

# Install dependencies
uv pip install -r requirements.txt

# Add development dependencies
uv pip install ruff pytest

# Lint and format
ruff check .
ruff format .

# Run tests
pytest

# Create .mise.toml for the team
cat > .mise.toml << EOF
[tools]
python = "3.11"

[tasks.lint]
run = "ruff check ."

[tasks.format]
run = "ruff format ."

[tasks.test]
run = "pytest"
EOF

# Now anyone can run
mise install  # Install correct Python version
mise run lint
mise run format
mise run test
```

## Integration with Nix

This configuration uses a sophisticated integration between Nix and mise:

### Three-Layer Architecture

1. **Nix Layer (System/User Level)**
   - Installs core tools: `uv`, `ruff`, `mise` itself
   - Managed in `home/default.nix`
   - Reproducible across machines
   - Uses binary cache for instant installs

2. **Mise Layer (Project Level)**
   - Manages project-specific runtime versions
   - **Uses Nix as backend** (`use_nix = true`)
   - Falls back to traditional installation if needed
   - Configured in `home/default.nix` via `programs.mise`

3. **UV Layer (Python Packages)**
   - Manages Python packages within virtual environments
   - Works with mise-managed Python versions
   - Fast, reliable dependency resolution

### How They Work Together

```
┌─────────────────────────────────────────┐
│  Nix (System Level)                     │
│  ├─ mise (tool manager)                 │
│  ├─ uv (Python package manager)         │
│  └─ ruff (linter/formatter)             │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  Mise (Project Level - uses Nix!)      │
│  ├─ Python 3.11 (from Nix)              │
│  ├─ Node 20 (from Nix)                  │
│  └─ Ruby 3.2 (from Nix or plugin)       │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  UV (Virtual Environment)               │
│  ├─ requests                            │
│  ├─ numpy                               │
│  └─ pandas                              │
└─────────────────────────────────────────┘
```

### Benefits of This Integration

1. **Speed**: Mise uses Nix binary cache when available
2. **Reproducibility**: Nix ensures exact versions
3. **Flexibility**: Mise provides per-project versions
4. **Simplicity**: One configuration for everything
5. **Offline-friendly**: Nix caches everything locally

### Example Workflow

```bash
# 1. Nix provides the tools (already installed)
which mise uv ruff
# All available system-wide

# 2. Mise uses Nix to install project-specific versions
cd myproject
mise use python@3.11 node@20
# Mise uses nixpkgs to provide these versions

# 3. UV manages Python packages
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt

# 4. Ruff checks code quality
ruff check .
```

### Configuration Files

- **System level**: `home/default.nix` (Nix packages)
- **User level**: `home/default.nix` (mise config with `use_nix = true`)
- **Project level**: `.mise.toml` (project-specific versions)
- **Environment level**: `.venv/` (Python packages via uv)

## Migration from Older Tools

### From pip to uv
```bash
# Old way
pip install -r requirements.txt

# New way (drop-in replacement)
uv pip install -r requirements.txt
```

### From Black/Flake8 to Ruff
```bash
# Old way
black .
flake8 .
isort .

# New way (all-in-one)
ruff format .  # Replaces black + isort
ruff check .   # Replaces flake8 and more
```

### From asdf/nvm/rbenv to Mise
```bash
# Old way
asdf install node 20.0.0
asdf local node 20.0.0

# New way
mise use node@20
```

Mise can read your existing `.tool-versions` files from asdf.

## Performance Comparisons

Based on typical projects:

**UV vs pip:**
- 10-100x faster package installs
- Example: Install numpy+pandas+requests in ~1 second vs ~10-30 seconds

**Ruff vs Black+Flake8:**
- 10-100x faster linting
- Example: Lint 100k lines in ~100ms vs ~10 seconds

**Mise vs asdf:**
- Faster shell activation
- Faster runtime switching
- Written in Rust instead of bash

## Resources

- [UV Documentation](https://github.com/astral-sh/uv)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Mise Documentation](https://mise.jdx.dev/)
- [Mise Nix Backend](https://mise.jdx.dev/dev-tools/backends/nix.html)
- [OpenCode Documentation](https://opencode.ai/)
- [Nix + Mise Integration Guide](https://mise.jdx.dev/integrations/nix.html)
