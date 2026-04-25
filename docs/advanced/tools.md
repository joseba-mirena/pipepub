[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Local Tools Guide

> *Run PipePub locally using the included toolset*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![tools](https://img.shields.io/badge/DOC-tools-white)](/docs/advanced/tools.md "Local tools guide") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🛠️ Tool overview](#tool-overview) |
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
├── pipepub.sh          # Main entry point (interactive menu)
├── commands/           # Direct CLI commands
│   ├── publish.sh      # Publish articles
│   ├── secrets.sh      # Manage API tokens
│   ├── check.sh        # Verify dependencies
│   ├── test.sh         # Run tests
│   └── help.sh         # Show documentation
├── config/             # Configuration files
│   ├── services.sh     # Service definitions
│   └── services.yaml   # Service configuration
├── lib/                # Core libraries
│   ├── common.sh       # Environment and services
│   ├── panel.sh        # UI rendering
│   ├── options.sh      # Footer handling
│   ├── keychain.sh     # OS keychain abstraction
│   └── setup.sh        # Initial setup
└── tests/              # Test suite
    ├── run_all_tests.sh
    ├── unit/
    ├── integration/
    └── e2e/
```

📖 **[Interactive menu guide →](/docs/advanced/cli-interactive.md)**

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
- Dry run confirmation
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
1. Add secret for a service
2. List configured services
3. Remove secret
4. Export secrets (for CI/CD)
5. Back to main menu

### Direct commands

| Command | Description |
|---------|-------------|
| `./tools/commands/secrets.sh add devto` | Add Dev.to token |
| `./tools/commands/secrets.sh add hashnode` | Add Hashnode credentials |
| `./tools/commands/secrets.sh add medium` | Add Medium token (legacy) |
| `./tools/commands/secrets.sh add github` | Add GitHub token (gist scope) |
| `./tools/commands/secrets.sh list` | List configured services |
| `./tools/commands/secrets.sh export` | Export as environment variables |
| `./tools/commands/secrets.sh delete devto` | Remove Dev.to token |

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
| **Dependencies** | `git`, `curl`, `jq`, `openssl` |
| **Keychain** | OS keychain availability (`security` or `secret-tool`) |
| **Configuration** | `.env` file presence and validity |
| **Secrets** | Which services have configured secrets |

### Example output

```text
✓ git found (version 2.42.0)
✓ curl found (version 8.4.0)
✓ jq found (version 1.7)
✓ openssl found (version 3.1.4)
✓ Keychain available (macOS security)

Configuration:
  .env file: present and valid

Secrets:
  ✅ Dev.to: configured
  ✅ Hashnode: configured
  ❌ Medium: missing
  ❌ GitHub: missing
```

<br>

<a id="test-tools"></a>

## 🧪 Test tools

> *Comprehensive test suite for validation and CI/CD.*

### Main test runner

```bash
./tools/tests/run_all_tests.sh
```

### Test categories

| Command | Description |
|---------|-------------|
| `./tools/tests/run_all_tests.sh` | Full test suite (unit + integration) |
| `./tools/tests/run_unit_tests.sh` | Unit tests only |
| `./tools/tests/run_dry_run.sh` | Dry run integration test |
| `./tools/tests/clean_test_files.sh` | Clean up test artifacts |

### Running specific unit tests

```bash
./tools/tests/unit/test_frontmatter.sh
./tools/tests/unit/test_tags.sh
./tools/tests/unit/test_content.sh
./tools/tests/unit/test_devto_api.sh
./tools/tests/unit/test_hashnode_api.sh
./tools/tests/unit/test_medium_api.sh
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
├── config/                    # Configuration files
│   ├── services.sh            # Service definitions
│   └── services.yaml          # Service YAML config
│
├── lib/                       # Core libraries
│   ├── common.sh              # Environment, services, secrets
│   ├── panel.sh               # UI rendering
│   ├── options.sh             # Footer handling
│   ├── keychain.sh            # OS keychain abstraction
│   └── setup.sh               # Initial setup
│
└── tests/                     # Test suite
    ├── run_all_tests.sh
    ├── run_unit_tests.sh
    ├── run_dry_run.sh
    ├── clean_test_files.sh
    ├── unit/
    │   ├── test_frontmatter.sh
    │   ├── test_tags.sh
    │   ├── test_content.sh
    │   ├── test_devto_api.sh
    │   ├── test_hashnode_api.sh
    │   └── test_medium_api.sh
    ├── integration/
    │   ├── test_multipost.sh
    │   └── test_pipeline_behavior.sh
    ├── e2e/
    │   └── run_dry_run.sh
    ├── fixtures/
    │   ├── input/
    │   └── snapshots/
    └── lib/
        ├── assertions.sh
        ├── fixtures.sh
        ├── tap.sh
        └── test_runner.sh
```

📖 **[Full folder structure reference →](/docs/advanced/reference.md#file-paths-reference)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Commands](https://img.shields.io/badge/DOC-commands-white)](/docs/advanced/commands.md "CLI commands reference")
[![Interactive Menu](https://img.shields.io/badge/DOC-cli--interactive-white)](/docs/advanced/cli-interactive.md "Interactive menu guide")
[![Environment](https://img.shields.io/badge/DOC-environment-white)](/docs/advanced/environment.md "Environment setup")
[![Tests](https://img.shields.io/badge/DOC-tests-white)](/docs/advanced/tests.md "Test suite")