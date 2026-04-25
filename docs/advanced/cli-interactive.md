[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Interactive Menu Guide

> *Navigate PipePub's terminal user interface (TUI) like a pro*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![cli-interactive](https://img.shields.io/badge/DOC-cli--interactive-white)](/docs/advanced/cli-interactive.md "Interactive menu guide") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🚀 Launching the menu](#launching-the-menu) |
| [🎨 Menu layout](#menu-layout) |
| [🎮 Navigation basics](#navigation-basics) |
| [📊 Service status indicators](#service-status-indicators) |
| [⌨️ Keyboard shortcuts](#keyboard-shortcuts) |
| [🛠️ Available actions](#available-actions) |

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

The menu displays:

- Service status for each platform (configured/missing)
- Core infrastructure status
- Publishing readiness summary
- Numbered action menu

<br>

<a id="menu-layout"></a>

## 🎨 Menu layout

> *Clean, modern interface with clear visual hierarchy and colored backgrounds.*

### Example main menu

![PipePub CLI interactive menu](/docs/assets/img/pipepub-cli-interactive.png "PipePub CLI interactive menu")

### Visual elements example

| Element | Meaning |
|---------|---------|
| `⮩` | Section header (Services / Infrastructure) |
| `⮮` | Section header (Actions) |
| `✔` | Configured / available (green background) |
| `✘` | Not configured / missing (red or dark background) |
| `➊` `➋` | Action numbers |
| `🄌` | Exit action |
| `🅗` | Help action |

**Note:** In the actual terminal, status icons have colored backgrounds:
- `✔` appears on a **green/dark gray** background
- `✘` appears on a **red/dark gray** background
- The box borders and layout are rendered with consistent spacing

<br>

<a id="navigation-basics"></a>

## 🎮 Navigation basics

> *Simple number-based navigation keeps everything accessible.*

### How it works

| Action | How to use |
|--------|------------|
| **Select menu item** | Press the corresponding number key (1-9) |
| **Exit menu** | Press `0` |
| **Show help** | Press `h` |
| **Confirm prompts** | Press `Enter` |
| **Cancel** | Press `Ctrl+C` (exits immediately) |

### Footer options (always visible)

| Option | Label | Action |
|--------|-------|--------|
| `0` | Exit | Exits the application |
| `h` | Help | Shows documentation |

<br>

<a id="service-status-indicators"></a>

## 📊 Service status indicators

> *At-a-glance view of which platforms are ready to publish.*

### Publishing Services

| Icon | Status | Meaning |
|------|--------|---------|
| `✔` | Configured | All required secrets present |
| `✘` | Missing | No secrets configured |
| `⚠️` | Partial | Some but not all secrets present (if applicable) |

### Core Infrastructure

| Icon | Status | Meaning |
|------|--------|---------|
| `✔` | Available | GitHub token configured (for Gists) |
| `✘` | Unavailable | No GitHub token (tables won't convert) |

### Publishing readiness

After the separator line, the menu shows a summary:

```text
       ➊ Publishing is ready
```

Or if not ready:

```text
       ➊ Not ready — add secrets first
```

<br>

<a id="keyboard-shortcuts"></a>

## ⌨️ Keyboard shortcuts

> *Speed up your workflow with these shortcuts.*

### File selection prompts

When selecting multiple files to publish:

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

<a id="available-actions"></a>

## 🛠️ Available actions

> *What you can do from the interactive menu.*

| Action | Number | Description | Direct command |
|--------|--------|-------------|----------------|
| **Publish articles** | `➊` | Select and publish markdown files | `./tools/pipepub.sh publish` |
| **Manage secrets** | `➋` | Add, list, remove API tokens | `./tools/pipepub.sh secrets` |
| **Check system** | `➌` | Verify dependencies and configuration | `./tools/pipepub.sh check` |
| **Run tests** | `➍` | Execute test suites | `./tools/pipepub.sh test` |

📖 **[Detailed command reference →](/docs/advanced/commands.md)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Commands](https://img.shields.io/badge/DOC-commands-white)](/docs/advanced/commands.md "CLI commands reference")
[![Tools](https://img.shields.io/badge/DOC-tools-white)](/docs/advanced/tools.md "Local tools guide")
[![Environment](https://img.shields.io/badge/DOC-environment-white)](/docs/advanced/environment.md "Environment setup")