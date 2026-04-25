[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Environment Setup Guide

> *Configure PipePub for local development and advanced usage*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![environment](https://img.shields.io/badge/DOC-environment-white)](/docs/advanced/environment.md "Environment guide") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [📋 Prerequisites](#prerequisites) |
| [⚙️ Environment configuration](#environment-configuration) |
| [🔑 Secrets management](#secrets-management) |
| [🖥️ Keychain setup by OS](#keychain-setup-by-os) |
| [🐛 Debugging](#debugging) |
| [🔄 CI/CD environment](#cicd-environment) |

</details>

---

<br>

<a id="prerequisites"></a>

## 📋 Prerequisites

> *Required dependencies for local PipePub usage.*

### macOS

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install git curl jq openssl
```

### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install git curl jq openssl libsecret-tools
```

### Linux (Fedora)

```bash
sudo dnf install git curl jq openssl libsecret
```

### Linux (Arch)

```bash
sudo pacman -S git curl jq openssl libsecret
```

### Windows (WSL)

Use any of the Linux distributions above via WSL2. The keychain integration requires a Linux environment.

<br>

<a id="environment-configuration"></a>

## ⚙️ Environment configuration

> *The `.env` file controls local PipePub behavior.*

### Auto-creation

If `.env` doesn't exist, PipePub automatically copies `.env.example` to `.env` on first run.

### Configuration variables

```text
# ============================================================================
# Application Configuration
# ============================================================================

APP_NAME="PipePub"
APP_VERSION="v1.0.0"
APP_ICON="⮻"

# ============================================================================
# Logging Configuration
# ============================================================================

# Log level: debug, info, warning, error
LOG_LEVEL=info

# Log output: console, file, both
LOG_OUTPUT=console

# Suppress all log output (for tests)
# LOG_QUIET=false

# Disable icons in logs (for CI/plain text)
# LOG_NO_ICONS=false

# ============================================================================
# Publisher Defaults
# ============================================================================

# Language: en-us, es-es, etc.
PUBLISHER_LANG=en-us

# Default publish status: draft, public
PUBLISHER_STATUS=draft

# Auto-publish: true, false
PUBLISHER_AUTO=true

# Gist table conversion: true, false
PUBLISHER_GIST=false

# ============================================================================
# DRY RUN Mode (test without making real API calls)
# ============================================================================
DRY_RUN=false
```

### Variable reference

| Variable | Values | Default | Description |
|----------|--------|---------|-------------|
| `APP_NAME` | string | `PipePub` | Application display name |
| `APP_VERSION` | string | `v1.0.0` | Version shown in UI |
| `APP_ICON` | string | `⮻` | Icon in menu header |
| `LOG_LEVEL` | `debug`, `info`, `warning`, `error` | `info` | Verbosity level |
| `LOG_OUTPUT` | `console`, `file`, `both` | `console` | Log destination |
| `LOG_QUIET` | `true`, `false` | `false` | Suppress all output |
| `LOG_NO_ICONS` | `true`, `false` | `false` | Plain text logs (no emoji) |
| `PUBLISHER_LANG` | locale string | `en-us` | Content language |
| `PUBLISHER_STATUS` | `draft`, `public` | `draft` | Default publish status |
| `PUBLISHER_AUTO` | `true`, `false` | `true` | Auto-publish on push |
| `PUBLISHER_GIST` | `true`, `false` | `false` | Table-to-Gist conversion |
| `DRY_RUN` | `true`, `false` | `false` | Test mode (no API calls) |

<br>

<a id="secrets-management"></a>

## 🔑 Secrets management

> *API tokens are stored in your OS keychain, NOT in `.env`.*

### Why keychain?

- Secrets never appear in plain text files
- No risk of committing secrets to git
- OS-level encryption
- Separate storage per user account

### Interactive secrets management

```bash
# Launch interactive menu
./tools/pipepub.sh secrets
```

Or direct commands:

| Command | Description |
|---------|-------------|
| `./tools/pipepub.sh secrets add devto` | Add Dev.to token |
| `./tools/pipepub.sh secrets add hashnode` | Add Hashnode credentials |
| `./tools/pipepub.sh secrets add medium` | Add Medium token (legacy) |
| `./tools/pipepub.sh secrets add github` | Add GitHub token (gist scope) |
| `./tools/pipepub.sh secrets list` | List configured services |
| `./tools/pipepub.sh secrets export` | Export secrets as env vars |
| `./tools/pipepub.sh secrets delete <service>` | Remove service secrets |

### Service requirements

| Service | Required secrets |
|---------|------------------|
| Dev.to | `devto_token` |
| Hashnode | `hashnode_token`, `hashnode_publication_id` |
| Medium | `medium_token` (legacy only) |
| GitHub | `github_token` (gist scope) |

📖 **[Platform-specific guides →](/docs/INDEX.md#services)**

<br>

<a id="keychain-setup-by-os"></a>

## 🖥️ Keychain setup by OS

> *PipePub automatically uses your operating system's native keychain.*

### macOS

**Keychain tool:** `security` (built-in)

**Verification:**
```bash
security -v
```

**Storage location:** `~/Library/Keychains/login.keychain-db`

**View stored secrets:**
```bash
security dump-keychain 2>/dev/null | grep -A5 "pipepub-secrets"
```

### Linux

**Keychain tool:** `secret-tool` (requires `libsecret-tools`)

**Installation:**
```bash
# Ubuntu/Debian
sudo apt-get install libsecret-tools

# Fedora
sudo dnf install libsecret

# Arch
sudo pacman -S libsecret
```

**Verification:**
```bash
secret-tool --version
```

**View stored secrets:**
```bash
secret-tool search service pipepub-secrets
```

### Headless environments (CI/CD)

Keychain is **not available** in headless environments (servers, containers, CI runners). For these cases:

1. Use environment variables instead (see [CI/CD section](#cicd-environment))
2. Or set `DRY_RUN=true` for testing only

<br>

<a id="debugging"></a>

## 🐛 Debugging

> *Enable verbose logging to troubleshoot issues.*

### Local debug mode

Set in `.env`:
```text
LOG_LEVEL=debug
LOG_OUTPUT=both
```

Or run with environment variable:
```bash
LOG_LEVEL=debug ./tools/pipepub.sh publish
```

### Debug log location

When `LOG_LEVEL=debug` and `LOG_OUTPUT=file` or `both`:

```text
.tmp/pipepub_YYYYMMDD_HHMMSS.log
```

### What debug logs include

- Function entry/exit
- Variable values (secrets masked)
- API request/response payloads
- Secret existence checks (masked)
- Timing information

<br>

<a id="cicd-environment"></a>

## 🔄 CI/CD environment

> *Running PipePub in GitHub Actions or other CI systems.*

### Environment variables only

In CI/CD, keychain is not available. Set all configuration via environment variables:

```yaml
# GitHub Actions example
env:
  # Pipeline configuration
  DRY_RUN: true
  CI: true
  LOG_LEVEL: debug
  LOG_OUTPUT: both
  
  # Publisher defaults
  PUBLISHER_LANG: en-us
  PUBLISHER_STATUS: draft
  PUBLISHER_GIST: true
  PUBLISHER_AUTO: true
  
  # Secrets (from repository secrets)
  DEVTO_TOKEN: ${{ secrets.DEVTO_TOKEN }}
  HASHNODE_TOKEN: ${{ secrets.HASHNODE_TOKEN }}
  HASHNODE_PUBLICATION_ID: ${{ secrets.HASHNODE_PUBLICATION_ID }}
  MEDIUM_TOKEN: ${{ secrets.MEDIUM_TOKEN }}
  GH_PAT_GIST_TOKEN: ${{ secrets.GH_PAT_GIST_TOKEN }}
```

### CI-specific behavior

| Variable | CI value | Effect |
|----------|----------|--------|
| `CI` | `true` | Disables interactive prompts |
| `DRY_RUN` | `true` | No API calls (for PRs) |
| `LOG_LEVEL` | `debug` | Verbose logs for debugging |
| `LOG_OUTPUT` | `both` | Console + file logs |

📖 **[CI workflow reference →](/docs/advanced/infra.md)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Commands](https://img.shields.io/badge/DOC-commands-white)](/docs/advanced/commands.md "CLI commands")
[![Infra](https://img.shields.io/badge/DOC-infra-white)](/docs/advanced/infra.md "CI/CD infrastructure")
[![Tests](https://img.shields.io/badge/DOC-tests-white)](/docs/advanced/tests.md "Test suite")