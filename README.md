# BASH-LIBRARY

A comprehensive collection of reusable bash functions and scripts for common DevOps and system administration tasks, designed to make shell scripting more efficient and maintainable.

![GitHub Release](https://img.shields.io/github/v/release/hperezrodal/bash-library?style=flat-square)
[![GitHub Issues](https://img.shields.io/github/issues/hperezrodal/bash-library)](https://github.com/hperezrodal/bash-library/issues)
[![GitHub Stars](https://img.shields.io/github/stars/hperezrodal/bash-library)](https://github.com/hperezrodal/bash-library/stargazers)
![Code Style: ShellCheck](https://img.shields.io/badge/code%20style-shellcheck-brightgreen?style=flat-square)
![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos-lightgrey?style=flat-square)
[![License](https://img.shields.io/github/license/hperezrodal/bash-library)](LICENSE)

## 🚀 Features

- Modular design for easy integration
- Reusable functions for common operations
- Well-documented code with examples
- Cross-platform compatibility
- Easy installation and setup
- Docker-based development environment
- Comprehensive DevOps tool integration

## 📋 Prerequisites

### Required Tools

- **Docker** (20.10.0 or higher)
- **Git**
- **Basic Shell Scripting knowledge**
- **Development Environment** (VS Code, Vim, etc.)

### System Requirements

- **OS**: Linux, macOS, or Windows with WSL2
- **CPU**: 2+ cores recommended
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 10GB free space minimum
- **Network**: Stable internet connection

## 📦 Installation

### Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/hperezrodal/bash-library/main/install-remote.sh | bash
```

### Zsh Installation

If you're using zsh on macOS, you'll need to add the following to your `~/.zshrc` file:

```bash
# Add bash-library to your PATH
export PATH="$PATH:/path/to/bash-library"

# Source the library
source /path/to/bash-library/lib-loader.sh
```

After adding these lines, reload your zsh configuration:
```bash
source ~/.zshrc
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/hperezrodal/bash-library.git
cd bash-library
```

2. Run the installation script:
```bash
./install.sh
```

### Update

#### Remote Update

```bash
curl -sSL https://raw.githubusercontent.com/hperezrodal/bash-library/main/update-remote.sh | bash
```

For system-wide installations:
```bash
curl -sSL https://raw.githubusercontent.com/hperezrodal/bash-library/main/update-remote.sh | SYSTEM_INSTALL=true sudo -E bash
```

### Uninstallation

#### System-wide Uninstallation (requires root)

```bash
sudo ./uninstall.sh
```

#### Remote Uninstallation

```bash
curl -sSL https://raw.githubusercontent.com/hperezrodal/bash-library/main/uninstall-remote.sh | bash
```

#### Zsh Uninstallation

For zsh users, remove the bash-library related lines from your `~/.zshrc` file and run:
```bash
source ~/.zshrc
```

After uninstallation, you may need to restart your shell or run `source ~/.zshrc` for changes to take effect.

## 🔧 Git Hooks Setup

### Pre-commit Hook Setup

The repository includes a pre-commit hook that runs `shfmt` and `shellcheck` on all shell scripts. To set it up:

1. **Install Required Tools**:

   For Linux (Debian/Ubuntu):
   ```bash
   sudo apt-get update
   sudo apt-get install shellcheck
   sudo snap install shfmt
   ```

   For macOS (using Homebrew):
   ```bash
   brew install shellcheck
   brew install shfmt
   ```

2. **Make the Hook Executable**:
   ```bash
   chmod +x .git/hooks/pre-commit
   ```

The pre-commit hook will automatically:
- Format all shell scripts using `shfmt`
- Check for potential issues using `shellcheck`
- Prevent commits if any issues are found

## 🛠️ Project Structure

```
bash-library/
├── modules/               # Core function modules
├── scripts/               # Utility scripts
├── examples/              # Usage examples
├── lib-loader.sh          # Library entry point and module loader
├── version                # Current version
├── install.sh             # Local installation script (requires root)
├── install-remote.sh      # Remote installation script
├── update-remote.sh       # Remote update script
├── uninstall.sh           # Local uninstallation script (requires root)
├── uninstall-remote.sh    # Remote uninstallation script
└── CONTRIBUTING.md        # Contribution guidelines
```

## 📚 Available Modules

#### Core Utilities

| Module | Description |
|--------|-------------|
| `logging.sh` | Logging functions for bash scripts |
| `datetime.sh` | Timestamp utilities |
| `validate_params.sh` | Parameter validation for bash functions |
| `files.sh` | File and directory copy operations |
| `git.sh` | Git repository operations |
| `docker.sh` | Docker image build and push operations |

#### Infrastructure

| Module | Description |
|--------|-------------|
| `ssh.sh` | SSH tunnel management |
| `psql.sh` | PostgreSQL client operations via Docker |
| `mongosh.sh` | MongoDB shell client via Docker |
| `redis_cli.sh` | Redis CLI client via Docker |
| `ansible.sh` | Ansible automation and configuration management |

#### Deployment & Operations

| Module | Description |
|--------|-------------|
| `bluegreen.sh` | Blue-green deployment for Docker + Traefik environments |
| `smoke.sh` | HTTP health checks with retry logic |
| `state.sh` | Deployment history recording and querying |
| `pipeline.sh` | CI/CD pipeline orchestration for build, setup, and deployment |

#### Cloud & Blockchain

| Module | Description |
|--------|-------------|
| `aws.sh` | AWS-related functions |
| `kubernetes.sh` | Kubernetes cluster management and operations |
| `eth_rpc.sh` | Ethereum RPC interaction |

Each module is designed to be self-contained and can be used independently.

## 🛠️ Usage

### Basic Usage

To use the library in your scripts, source the main functions file:

```bash
source /path/to/bash-library/lib-loader.sh
```

### Available Modules

See the [Available Modules](#-available-modules) section for the full list.

### Available Scripts

After installation, scripts are automatically available in your PATH:

| Script | Description |
|--------|-------------|
| `aws-secrets` | AWS secrets management |
| `mkp` | Deterministic password generator from a seed phrase |
| `sql-client` | SQL client via kubectl port-forward |

#### Using Scripts

```bash
# Direct execution (available after installation)
aws-secrets --help
mkp --help

# Or source in your script
source /path/to/bash-library/scripts/aws-secrets.sh
```

## 📚 Examples

Check out the `examples/` directory for practical usage examples of the library functions.

## Contributing

Contributions are always welcome! Please read the [contribution guidelines](CONTRIBUTING.md) first.

## License

MIT License - See [LICENSE](LICENSE) file for details

---

Made with ❤️ by [hperezrodal](https://github.com/hperezrodal) 