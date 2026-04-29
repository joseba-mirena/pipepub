<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Interactive Menu Guide

> *Navigate PipePub's terminal user interface (TUI) like a pro*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![cli-interactive](https://img.shields.io/badge/DOC-cli--interactive-white)](/docs/advanced/cli-interactive.md "Interactive menu guide") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🚀 Launching the menu](#launching-the-menu) |
| [🎨 Main menu layout](#main-menu-layout) |
| [📊 Main menu status indicators](#main-menu-status-indicators) |
| [ℹ️ Main menu info line](#main-menu-info-line) |
| [🦶 Footer options](#footer-options) |
| [⌨️ Keyboard shortcuts](#keyboard-shortcuts) |
| [📤 Publish sub-menu](#publish-sub-menu) |
| [🔑 Secrets sub-menu](#secrets-sub-menu) |
| [🔍 Check sub-menu](#check-sub-menu) |
| [🧪 Test sub-menu](#test-sub-menu) |

</details>

---

<br>

<a id="launching-the-menu"></a>

## 🚀 Launching the menu

> *Start the interactive TUI from your terminal.*

```bash
cd pipepub
./tools/pipepub.sh
```

The main menu displays:

- Publishing Services section (all configured platforms)
- Core Infrastructure section (GitHub Gist token status)
- Publishing readiness summary
- Numbered action menu (1-4)
- Footer with Exit and Help options

<br>

<a id="main-menu-layout"></a>

## 🎨 Main menu layout

> *Clean, modern interface with clear visual hierarchy.*

![PipePub CLI interactive menu](https://pipepub.github.io/cdn/image/screenshot/pipepub-cli-interactive-menu.png "PipePub CLI interactive menu")

### Sections

| Section | Content |
|---------|---------|
| **Publishing Services** | List of all platforms (DEV.to, Hashnode, Medium) with status |
| **Core Infrastructure** | GitHub token status (required for Gist table conversion) |
| **Info line** | Publishing readiness or action hint |
| **Actions** | Numbered menu items (1-4) |
| **Footer** | Exit (0) and Help (h) options |

### Visual elements

| Element | Meaning |
|---------|---------|
| `⮩` | Section header |
| `⮮` | Actions section header |
| `✔` | Configured / available (green background) |
| `✘` | Not configured / missing (red background) |
| `⚠️` | Partial configuration (yellow background) |
| `➊` `➋` `➌` `➍` | Action numbers |
| `🄌` | Exit action |
| `🅗` | Help action |

<br>

<a id="main-menu-status-indicators"></a>

## 📊 Main menu status indicators

### Publishing Services section

| Icon | Status | Meaning |
|------|--------|---------|
| `✔` | `success` | All required secrets present |
| `⚠️` | `warning` | Some but not all secrets present |
| `✘` | `error` | No secrets configured |

### Core Infrastructure section

| Icon | Status | Meaning |
|------|--------|---------|
| `✔` | `success` | `GH_PAT_GIST_TOKEN` found |
| `✘` | `error` | No GitHub token (tables won't convert) |

<br>

<a id="main-menu-info-line"></a>

## ℹ️ Main menu info line

> *Dynamic message below the core infrastructure section.*

| Condition | Message |
|-----------|---------|
| At least one service has secrets | `Publishing is ready:➊` |
| No services have secrets | `Add a secret to enable publishing:➋` |

<br>

<a id="footer-options"></a>

## 🦶 Footer options

> *Footer context changes depending on where you are in the menu.*

### Main menu footer

| Option | Label | Action |
|--------|-------|--------|
| `0` | Exit | Exits the application |
| `h` | Help | Shows documentation |
| `q` | n/a | Exit the interactive menu |

### Sub-menu footer

When inside any sub-menu, the footer changes:

| Option | Label | Action |
|--------|-------|--------|
| `0` | Back | Returns to main menu |
| `h` | Help | Shows context-specific help |
| `q` | n/a | Exit the interactive menu |

<br>

<a id="keyboard-shortcuts"></a>

## ⌨️ Keyboard shortcuts

### File selection (in publish sub-menu)

| Input | Example | Meaning |
|-------|---------|---------|
| Individual numbers | `1 3 5` | Select files 1, 3, and 5 |
| Range | `1-3` | Select files 1, 2, and 3 |
| Mixed | `1 3-5 7` | Select files 1, 3, 4, 5, and 7 |
| All files | `a` | Select every available file |

### Confirm/Cancel prompts

| Key | Action |
|-----|--------|
| `y` | Yes, proceed |
| `n` | No, cancel |
| `Enter` | Default option (usually Yes) |

<br>

<a id="publish-sub-menu"></a>

## 📤 Publish sub-menu

> *Accessed by pressing `➊` from the main menu.*

![PipePub CLI interactive publish](https://pipepub.github.io/cdn/image/screenshot/pipepub-cli-interactive-publish.png "PipePub CLI interactive publish")

### Layout

The publish sub-menu displays:

- **Publishing Services section** - Same as main menu
- **Available files section** - List of markdown files in `posts/` folder with size and modification time
- **Info line** - Number of files ready to process
- **Actions** - Numbered menu items (1-6)
- **Footer** - Back (0) and Help (h)

### Actions

| Number | Action | Description |
|--------|--------|-------------|
| `➊` | Select articles | Interactive file selection (supports ranges) |
| `➋` | Process all | Publish all files in `posts/` folder |
| `➌` | Delete files | Interactive file deletion |
| `➍` | Delete all files | Delete all files in `posts/` folder (with confirmation) |
| `➎` | Copy example file | Copies `docs/assets/example/post-example.md` to `posts/` |
| `➏` | Manage secrets | Opens secrets sub-menu |

### File information format

Each file is displayed with:
```text
filename.md  size    YYYY-MM-DD HH-MM-SS
```

Example:
```text
my-article.md  4KB    2026-04-28 14-30-22
```

<br>

<a id="secrets-sub-menu"></a>

## 🔑 Secrets sub-menu

> *Accessed by pressing `➋` from the main menu.*

![PipePub CLI interactive secrets](https://pipepub.github.io/cdn/image/screenshot/pipepub-cli-interactive-secrets.png "PipePub CLI interactive secrets")

### Layout

The secrets sub-menu displays:

- **Publishing Services section** - All platforms with current status
- **Core Infrastructure section** - GitHub token status
- **Info line** - "Manage API tokens and credentials securely"
- **Actions** - Numbered menu items (1-4)
- **Footer** - Back (0) and Help (h)

### Actions

| Number | Action | Description |
|--------|--------|-------------|
| `➊` | Add/update secrets | Select service and enter token(s) |
| `➋` | Remove secrets | Select configured service to remove secrets |
| `➌` | List all configured services | Shows which services have secrets (masked values) |
| `➍` | Export secrets | Outputs secrets as `KEY=VALUE` for GitHub Actions |

### Adding secrets

When adding secrets for a service:

1. Select service from list
2. Enter each required field (tokens are masked)
3. Secrets are stored in OS keychain

### Removing secrets

When removing secrets:

1. Select configured service from list
2. Confirm deletion
3. All secrets for that service are removed from keychain

### Export format

```text
DEVTO_TOKEN=your_token_here
HASHNODE_TOKEN=your_token_here
HASHNODE_PUBLICATION_ID=your_publication_id
GH_PAT_GIST_TOKEN=your_github_token
```

<br>

<a id="check-sub-menu"></a>

## 🔍 Check sub-menu

> *Accessed by pressing `➌` from the main menu.*

![PipePub CLI interactive check system](https://pipepub.github.io/cdn/image/screenshot/pipepub-cli-interactive-system.png "PipePub CLI interactive check system")

### Behavior

The check command runs immediately without a sub-menu. It verifies:

| Category | Items checked |
|----------|---------------|
| Operating System | macOS or Linux detection |
| Dependencies | `git`, `curl`, `jq`, `openssl` |
| Keychain | OS keychain availability (`security` or `secret-tool`) |
| Keychain Access | Read/write permissions |
| Python | Optional (for OAuth flows) |

After displaying results, press any key to return to main menu.

<br>

<a id="test-sub-menu"></a>

## 🧪 Test sub-menu

> *Accessed by pressing `➍` from the main menu.*

![PipePub CLI interactive tests](https://pipepub.github.io/cdn/image/screenshot/pipepub-cli-interactive-tests.png "PipePub CLI interactive tests")

### Layout

The test sub-menu displays:

- **Test Suites section** - Test runner and file counts
- **Info lines** - Test location and dev mode hints
- **Actions** - Numbered menu items (1-8)
- **Footer** - Back (0) and Help (h)

### Actions

| Number | Action | Description |
|--------|--------|-------------|
| `➊` | Run all tests | Full test suite (unit + integration + e2e) |
| `➋` | Run unit tests only | Fast, isolated tests |
| `➌` | Run integration tests only | Tests with pipeline integration |
| `➍` | Run E2E tests only | End-to-end dry run tests |
| `➎` | Run with debug output | Verbose logging enabled |
| `➏` | Update snapshots | Update JSON snapshot files |
| `➐` | Run dev tests | With dev service overlay (requires `tools/config/` files) |
| `➑` | Clean test files | Remove test artifacts from `posts/`, `.logs/`, `.tmp/`, `.reports/` |

### Test flags reference

| Flag (command line) | Corresponding menu action |
|---------------------|---------------------------|
| (none) | Run all tests |
| `--unit` | Run unit tests only |
| `--integration` | Run integration tests only |
| `--e2e` | Run E2E tests only |
| `--debug` | Run with debug output |
| `--update-snapshots` | Update snapshots |
| `--dev` | Run dev tests |

📖 **[Full test suite documentation →](/docs/advanced/tests.md)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Commands](https://pipepub.github.io/cdn/image/badge/doc/commands.svg)](/docs/advanced/commands.md "CLI commands reference")
[![Tools](https://pipepub.github.io/cdn/image/badge/doc/tools.svg)](/docs/advanced/tools.md "Local tools guide")
[![Environment](https://pipepub.github.io/cdn/image/badge/doc/environment.svg)](/docs/advanced/environment.md "Environment setup")
[![Tests](https://pipepub.github.io/cdn/image/badge/doc/tests.svg)](/docs/advanced/tests.md "Test suite")