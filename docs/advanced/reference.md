<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Technical Reference

> *Architecture, libraries, naming conventions, and fast lookups*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![reference](https://pipepub.github.io/cdn/image/badge/doc/reference.svg)](/docs/advanced/reference.md "Technical reference") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🏗️ Architecture overview](#architecture-overview) |
| [📚 Core libraries](#core-libraries) |
| [🔑 Secret naming conventions](#secret-naming-conventions) |
| [📁 File paths reference](#file-paths-reference) |
| [⚙️ Configuration variables](#configuration-variables) |
| [🎨 Exit codes](#exit-codes) |

</details>

---

<br>

<a id="architecture-overview"></a>

## 🏗️ Architecture overview

> *PipePub follows a clean separation of concerns between UI, logic, and storage.*

```text
┌─────────────────────────────────────────────────────────────┐
│ TOOLS (Commands)                                            │
│ (pipepub.sh, publish.sh, secrets.sh, check.sh, test.sh)    │
│ - Handle user interaction                                   │
│ - Call library functions                                    │
│ - Render UI using panel/chat methods                       │
└─────────────────────────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│ LIBRARIES                                                   │
│ (common.sh, panel.sh, options.sh, keychain.sh, etc.)       │
│ - NO UI output (pure logic)                                 │
│ - Provide functions and data only                           │
│ - Return status codes and echo values                       │
└─────────────────────────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│ STORAGE                                                     │
│ (.env file, OS keychain, .tmp/, .logs/, .reports/)         │
│ - Configuration storage                                     │
│ - Secure secret storage                                     │
│ - Runtime logs and reports                                  │
└─────────────────────────────────────────────────────────────┘
```

📖 **[Detailed architecture →](/docs/advanced/cli-interactive.md#menu-layout)**

<br>

<a id="core-libraries"></a>

## 📚 Core libraries

> *Reusable components that power PipePub.*

| Library | Location | Purpose |
|---------|----------|---------|
| `common.sh` | `tools/lib/common.sh` | Environment loading, service management, secret loading |
| `panel.sh` | `tools/lib/panel.sh` | Menu rendering (background panels + clean chat methods) |
| `options.sh` | `tools/lib/options.sh` | Footer handling (Exit/Back and Help) |
| `keychain.sh` | `tools/lib/keychain.sh` | OS keychain abstraction (macOS/Linux) |
| `services.sh` | `tools/config/services.sh` | Service definitions (DEV.to, Hashnode, Medium, etc.) |

### Library responsibilities

| Library | Key functions | No UI output |
|---------|---------------|---------------|
| `common.sh` | `load_env()`, `get_services()`, `get_service_status()` | ✅ Yes |
| `panel.sh` | `panel_build()`, `chat_success()`, `panel_confirm()` | ❌ UI layer |
| `options.sh` | `set_options_context()`, `handle_footer_choice()` | ✅ Logic only |
| `keychain.sh` | `set_secret()`, `get_secret()`, `delete_secret()` | ✅ Yes |
| `services.sh` | `get_service_fields()`, `get_service_display_name()` | ✅ Yes |

<br>

<a id="secret-naming-conventions"></a>

## 🔑 Secret naming conventions

> *All secrets are stored in the OS keychain with consistent naming.*

### Format

```text
{service}_{field}
```

### Service secrets

| Service | Secret keys | Required |
|---------|-------------|----------|
| DEV.to | `devto_token` | Yes |
| Hashnode | `hashnode_token`, `hashnode_publication_id` | Yes |
| Medium | `medium_token` | Yes (legacy) |
| GitHub | `github_token` | No (for Gists) |

### OAuth services (future)

| Service | Secret keys | Required |
|---------|-------------|----------|
| X (Twitter) | `twitter_client_id`, `twitter_client_secret`, `twitter_access_token`, `twitter_refresh_token` | Yes |
| LinkedIn | `linkedin_client_id`, `linkedin_client_secret`, `linkedin_access_token`, `linkedin_refresh_token` | Yes |

### Core secrets

| Secret key | Purpose | Auto-created |
|------------|---------|---------------|
| `_master` | Master encryption key for secret storage | ✅ Yes |

📖 **[Secrets management guide →](/docs/advanced/environment.md#secrets-management)**

<br>

<a id="file-paths-reference"></a>

## 📁 File paths reference

> *Important file and directory locations.*

| Path | Purpose | Git ignored |
|------|---------|-------------|
| `.env` | Local environment configuration | ✅ Yes |
| `.env.example` | Template for `.env` | ❌ No |
| `posts/` | User articles (markdown files) | ❌ No (user content) |
| `images/` | User images for articles | ❌ No (user content) |
| `docs/` | Documentation | ❌ No |
| `.github/` | GitHub Actions workflows and scripts | ❌ No |
| `tools/` | Local CLI tools | ❌ No |
| `tools/tests/` | Test suite | ❌ No |
| `.tmp/` | Temporary runtime files | ✅ Yes |
| `.logs/` | Pipeline execution logs | ✅ Yes |
| `.reports/` | Test reports (JSON) | ✅ Yes |

### Runtime generated paths

| Path | Pattern | Description |
|------|---------|-------------|
| `.tmp/pipepub_*.log` | `pipepub_YYYYMMDD_HHMMSS.log` | Debug logs |
| `.logs/test_run_all_tests_*.log` | `test_run_all_tests_YYYYMMDD_HHMMSS.log` | Test output |
| `.reports/dry-run-*.json` | `dry-run-YYYYMMDD_HHMMSS.json` | Dry run reports |

<br>

<a id="configuration-variables"></a>

## ⚙️ Configuration variables

> *Environment variables and their defaults.*

### Application configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_NAME` | `PipePub` | Application display name |
| `APP_VERSION` | `v1.0.0` | Version shown in UI |
| `APP_ICON` | `⮻` | Icon in menu header |

### Logging configuration

| Variable | Default | Values | Description |
|----------|---------|--------|-------------|
| `LOG_LEVEL` | `info` | `debug`, `info`, `warning`, `error` | Verbosity level |
| `LOG_OUTPUT` | `console` | `console`, `file`, `both` | Log destination |
| `LOG_QUIET` | `false` | `true`, `false` | Suppress all output |
| `LOG_NO_ICONS` | `false` | `true`, `false` | Plain text logs |

### Publisher defaults

| Variable | Default | Values | Description |
|----------|---------|--------|-------------|
| `PUBLISHER_LANG` | `en-us` | locale string | Language/locale |
| `PUBLISHER_STATUS` | `draft` | `draft`, `public` | Default publish status |
| `PUBLISHER_AUTO` | `true` | `true`, `false` | Auto-publish on push |
| `PUBLISHER_GIST` | `false` | `true`, `false` | Table-to-Gist conversion |

### Runtime flags

| Variable | Default | Values | Description |
|----------|---------|--------|-------------|
| `DRY_RUN` | `false` | `true`, `false` | Test mode (no API calls) |
| `CI` | (unset) | `true`, `false` | CI mode (no prompts) |
| `DEBUG` | `false` | `true`, `false` | Enable verbose output |

📖 **[Full environment guide →](/docs/advanced/environment.md)**

<br>

<a id="exit-codes"></a>

## 🎨 Exit codes

> *Standard exit codes used by PipePub scripts.*

| Code | Meaning | Description |
|------|---------|-------------|
| `0` | Success | Operation completed successfully |
| `1` | General error | Generic failure |
| `2` | Missing dependency | Required tool not found |
| `3` | Configuration error | `.env` missing or invalid |
| `4` | Secret error | Keychain unavailable or secret missing |
| `5` | API error | Platform API returned error |
| `6` | Validation error | Frontmatter or content invalid |

### Example usage

```bash
./tools/pipepub.sh publish
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed with exit code $?"
fi
```

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Environment](https://pipepub.github.io/cdn/image/badge/doc/environment.svg)](/docs/advanced/environment.md "Environment setup")
[![Commands](https://pipepub.github.io/cdn/image/badge/doc/commands.svg)](/docs/advanced/commands.md "CLI commands")
[![Tests](https://pipepub.github.io/cdn/image/badge/doc/tests.svg)](/docs/advanced/tests.md "Test suite")