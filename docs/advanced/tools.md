<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Local Tools Guide

> *Run PipePub locally using the included toolset*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![tools](https://pipepub.github.io/cdn/image/badge/doc/tools.svg)](/docs/advanced/tools.md "Local tools guide") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🛠️ Tool overview](#tool-overview) |
| [🗂️ Service loading](#service-loading) |
| [🚀 Main entry point](#main-entry-point) |
| [📤 Publish tool](#publish-tool) |
| [🔑 Secrets tool](#secrets-tool) |
| [🔍 Check tool](#check-tool) |
| [🧪 Test tools](#test-tools) |
| [📁 Directory structure](#directory-structure) |

</details>

---

<br>

<a id="tool-overview"></a>

## 🛠️ Tool overview

> *PipePub includes a complete local toolset for development and power users.*

All tools are located in the `tools/` directory:

```text
tools/
├── pipepub.sh              # Main entry point (interactive menu)
├── commands/               # Direct CLI commands
│   ├── publish.sh          # Publish articles
│   ├── secrets.sh          # Manage API tokens
│   ├── check.sh            # Verify dependencies
│   ├── test.sh             # Run tests
│   └── help.sh             # Show documentation
├── config/                 # Development configuration (git ignored)
│   ├── registry-dev.conf   # Dev registry overrides
│   └── services-dev/       # Dev service configs
├── handlers-dev/           # Development handler scripts (git ignored)
├── lib/                    # Core libraries
│   ├── common.sh           # Environment and services
│   ├── panel.sh            # UI rendering
│   ├── options.sh          # Footer handling
│   ├── keychain.sh         # OS keychain abstraction
│   └── services.sh         # Service loading from pipeline configs
└── tests/                  # Test suite
    ├── run.sh
    ├── unit/
    ├── integration/
    ├── e2e/
    ├── dev/                # Dev tests (git ignored)
    └── lib/
```

📖 **[Interactive menu guide →](/docs/advanced/cli-interactive.md)**

<br>

<a id="service-loading"></a>

## 🗂️ Service loading

> *Tools load service definitions directly from pipeline configuration files.*

### Single source of truth

Tools read service configurations from:

| Source | Location | Purpose |
|--------|----------|---------|
| **Production** | `.github/config/registry.conf` | Service registry |
| **Production** | `.github/config/services/*.conf` | Service configs |
| **Production** | `.github/scripts/handlers/*.sh` | Handler scripts |
| **Development** | `tools/config/registry-dev.conf` | Dev registry overrides (git ignored) |
| **Development** | `tools/config/services-dev/` | Dev service configs (git ignored) |
| **Development** | `tools/handlers-dev/*.sh` | Dev handler scripts (git ignored) |

### Priority order

1. Production configs (`.github/config/`)
2. Development overrides (`tools/config/`)

This allows developing new services (e.g., Ghost) without modifying production files.

### Available services

To list all available services:

```bash
./tools/pipepub.sh secrets list
```

### Adding a new service for development

> **Example:** See `docs/assets/example/dev/service/` for a complete working example (Ghost service).

1. Create `tools/config/registry-dev.conf`:

```text
myservice|myservice.sh|MYSERVICE_TOKEN
```

2. Create `tools/config/services-dev/myservice.conf`:

```bash
SERVICE_DISPLAY="My Service"
SERVICE_AUTH_TYPE="Bearer"
SERVICE_ENDPOINT="https://api.myservice.com/posts"
SERVICE_HANDLER_FUNC="publish_to_myservice"
SERVICE_MAX_TAGS=5
```

3. Create `tools/handlers-dev/myservice.sh` with the handler function.

4. Create `tools/tests/dev/test_myservice_dev.sh` with tests.

5. Run tests with `--dev` flag to validate.

📖 **[Full example →](/docs/assets/example/dev/service/)**

<br>

<a id="main-entry-point"></a>

## 🚀 Main entry point

> *`tools/pipepub.sh` is the primary interface for local usage.*

### Launch interactive menu

```bash
./tools/pipepub.sh
```

### Direct command mode

| Command | Description |
|---------|-------------|
| `./tools/pipepub.sh publish` | Publish articles |
| `./tools/pipepub.sh secrets` | Manage secrets |
| `./tools/pipepub.sh check` | Check system dependencies |
| `./tools/pipepub.sh test` | Run tests |
| `./tools/pipepub.sh help` | Show help |
| `./tools/pipepub.sh --version` | Show version |
| `./tools/pipepub.sh --man` | Show full manual |

<br>

<a id="publish-tool"></a>

## 📤 Publish tool

> *`tools/commands/publish.sh` - Publish articles to configured platforms.*

### Interactive mode

```bash
./tools/commands/publish.sh
```

Prompts for:
- File selection (which articles to publish)
- Publishing confirmation

### Direct usage with environment variables

```bash
# Publish specific file
MANUAL_FILENAMES="article.md" ./tools/commands/publish.sh

# Dry run (no API calls)
DRY_RUN=true ./tools/commands/publish.sh

# Debug mode
LOG_LEVEL=debug ./tools/commands/publish.sh
```

<br>

<a id="secrets-tool"></a>

## 🔑 Secrets tool

> *`tools/commands/secrets.sh` - Manage API tokens in OS keychain.*

### Interactive mode

```bash
./tools/commands/secrets.sh
```

Menu options:
1. Add/update secrets
2. Remove secrets
3. List all configured services
4. Export secrets (for GitHub Actions)

### Direct commands

| Command | Description |
|---------|-------------|
| `./tools/commands/secrets.sh add devto` | Add DEV.to token |
| `./tools/commands/secrets.sh add hashnode` | Add Hashnode credentials |
| `./tools/commands/secrets.sh add medium` | Add Medium token (legacy) |
| `./tools/commands/secrets.sh add github` | Add GitHub token (gist scope) |
| `./tools/commands/secrets.sh list` | List configured services |
| `./tools/commands/secrets.sh export` | Export as environment variables |
| `./tools/commands/secrets.sh delete devto` | Remove DEV.to token |

📖 **[Secrets management guide →](/docs/advanced/environment.md#secrets-management)**

<br>

<a id="check-tool"></a>

## 🔍 Check tool

> *`tools/commands/check.sh` - Verify system dependencies and configuration.*

### Usage

```bash
./tools/commands/check.sh
```

### What it checks

| Category | Items |
|----------|-------|
| **Operating System** | macOS / Linux detection |
| **Dependencies** | `git`, `curl`, `jq`, `openssl` |
| **Keychain** | OS keychain availability (`security` or `secret-tool`) |
| **Keychain Access** | Read/write permissions |
| **Python** | Optional (for OAuth flows) |

### Example output

```text
✓ git found (version 2.42.0)
✓ curl found (version 8.4.0)
✓ jq found (version 1.7)
✓ openssl found (version 3.1.4)
✓ Keychain available (macOS security)
✓ Read/Write access: success
```

<br>

<a id="test-tools"></a>

## 🧪 Test tools

> *Comprehensive test suite for validation and CI/CD.*

### Main test runner

```bash
./tools/tests/run.sh
```

### Test flags

| Flag | Description |
|------|-------------|
| `--quick` | Run unit + integration tests (skip e2e) |
| `--unit` | Run only unit tests |
| `--integration` | Run only integration tests |
| `--e2e` | Run only e2e tests |
| `--filter=NAME` | Run only test file matching NAME |
| `--update-snapshots` | Update snapshot files |
| `--debug` | Enable debug logging |
| `--dev` | Run dev tests with service overlay |

### Usage examples

```bash
# Run all tests
./tools/tests/run.sh

# Run quick tests (unit + integration)
./tools/tests/run.sh --quick

# Run with dev service overlay
./tools/tests/run.sh --dev

# Update snapshots
./tools/tests/run.sh --update-snapshots

# Run specific test file
./tools/tests/run.sh --filter=test_tags.sh
```

📖 **[Test suite documentation →](/docs/advanced/tests.md)**

<br>

<a id="directory-structure"></a>

## 📁 Directory structure

> *Complete local tools directory layout.*

```text
tools/
├── pipepub.sh                 # Main entry point
│
├── commands/                  # CLI commands
│   ├── publish.sh
│   ├── secrets.sh
│   ├── check.sh
│   ├── test.sh
│   └── help.sh
│
├── config/                    # Development config (git ignored)
│   ├── registry-dev.conf      # Dev registry overrides
│   └── services-dev/          # Dev service configs
│
├── handlers-dev/              # Dev handler scripts (git ignored)
│   └── ghost.sh               # Example: Ghost dev handler
│
├── lib/                       # Core libraries
│   ├── common.sh              # Environment, services, secrets
│   ├── panel.sh               # UI rendering
│   ├── options.sh             # Footer handling
│   ├── keychain.sh            # OS keychain abstraction
│   └── services.sh            # Service loading from pipeline
│
└── tests/                     # Test suite
    ├── run.sh                 # Main test runner
    ├── unit/
    │   ├── test_content.sh
    │   ├── test_devto_api.sh
    │   ├── test_frontmatter.sh
    │   ├── test_frontmatter_config.sh
    │   ├── test_hashnode_api.sh
    │   ├── test_medium_api.sh
    │   ├── test_smoke.sh
    │   └── test_tags.sh
    ├── integration/
    │   ├── test_gist_integration.sh
    │   ├── test_multipost.sh
    │   └── test_pipeline_behavior.sh
    ├── e2e/
    │   └── run_dry_run.sh
    ├── dev/                   # Dev tests (git ignored)
    │   └── test_ghost_dev.sh  # Example: Ghost dev test
    ├── fixtures/
    │   ├── input/posts/       # Test fixtures
    │   └── snapshots/json/    # API payload snapshots
    └── lib/
        ├── assertions.sh      # TAP assertions
        ├── deps.sh            # Test dependencies
        ├── fixtures.sh        # Fixture management
        ├── hooks.sh           # Test hooks
        ├── isolation.sh       # Test isolation
        ├── logger.sh          # Test logging
        ├── setup.sh           # Test environment setup
        ├── tags.sh            # Test tagging
        ├── test_runner.sh     # TAP test runner
        └── timeout.sh         # Timeout protection
```

📖 **[Full folder structure reference →](/docs/advanced/reference.md#file-paths-reference)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Commands](https://pipepub.github.io/cdn/image/badge/doc/commands.svg)](/docs/advanced/commands.md "CLI commands reference")
[![Interactive Menu](https://img.shields.io/badge/DOC-cli--interactive-white)](/docs/advanced/cli-interactive.md "Interactive menu guide")
[![Environment](https://pipepub.github.io/cdn/image/badge/doc/environment.svg)](/docs/advanced/environment.md "Environment setup")
[![Tests](https://pipepub.github.io/cdn/image/badge/doc/tests.svg)](/docs/advanced/tests.md "Test suite")