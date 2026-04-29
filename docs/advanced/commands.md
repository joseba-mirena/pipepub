<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### CLI Commands Reference

> *Direct command-line interface for automation and power users*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![commands](https://pipepub.github.io/cdn/image/badge/doc/commands.svg)](/docs/advanced/commands.md "Commands reference") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🛠️ Main command](#main-command) |
| [📤 Publish commands](#publish-commands) |
| [🔄 Git push publishing](#git-push-publishing) |
| [🔑 Secrets management](#secrets-management) |
| [🔍 System commands](#system-commands) |
| [🧪 Test commands](#test-commands) |
| [📚 Help commands](#help-commands) |

</details>

---

<br>

<a id="main-command"></a>

## 🛠️ Main command

> *The primary entry point for all PipePub operations.*

![PipePub CLI interactive menu](https://pipepub.github.io/cdn/image/screenshot/pipepub-cli-interactive-menu.png "PipePub CLI interactive menu")

```bash
./tools/pipepub.sh
```

| Command | Description |
|---------|-------------|
| `./tools/pipepub.sh` | Launch interactive menu |
| `./tools/pipepub.sh --version` | Show version information |
| `./tools/pipepub.sh --help` | Show quick help |
| `./tools/pipepub.sh --man` | Show full manual |
| `./tools/pipepub.sh --doc` | Open documentation file |

<br>

<a id="publish-commands"></a>

## 📤 Publish commands

> *Publish articles using the PipePub CLI.*

### Interactive menu

![PipePub CLI interactive publish](https://pipepub.github.io/cdn/image/screenshot/pipepub-cli-interactive-publish.png "PipePub CLI interactive publish")

```bash
./tools/pipepub.sh publish
```

Launches the file selection interface.

### Direct publishing with environment variables

```bash
# Publish specific file
MANUAL_FILENAMES="article.md" ./tools/pipepub.sh publish

# Dry run (no actual API calls)
DRY_RUN=true ./tools/pipepub.sh publish

# Debug mode
LOG_LEVEL=debug ./tools/pipepub.sh publish
```

📖 **[Publishing modes →](/docs/basics/settings.md#publishing-behavior)**

<br>

<a id="git-push-publishing"></a>

## 🔄 Git push publishing (CLI)

> *For developers who prefer the standard git workflow.*

### Prerequisites

- Git installed locally
- Repository cloned to your machine
- Write access to the repository

### Step 1: Clone the repository (if not already done)

```bash
git clone https://github.com/pipepub/pipepub.git
cd pipepub
```

### Step 2: Add your article

Place your markdown file in the `posts/` folder:

```bash
cp my-article.md posts/
```

### Step 3: Commit and push

```bash
git add posts/my-article.md
git commit -m "Add my-article.md"
git push origin main
```

### Step 4: Automatic publishing

If `auto: true` (default per service), your article will be published automatically in less than a minute.

### Push multiple articles

```bash
git add posts/article1.md posts/article2.md posts/article3.md
git commit -m "Add multiple articles"
git push origin main
```

📖 **[All publishing methods →](/docs/basics/publishing.md)**

<br>

<a id="secrets-management"></a>

## 🔑 Secrets management

> *Manage API tokens securely in your OS keychain.*

### Interactive secrets menu

![PipePub CLI interactive secrets](https://pipepub.github.io/cdn/image/screenshot/pipepub-cli-interactive-secrets.png "PipePub CLI interactive secrets")

```bash
./tools/pipepub.sh secrets
```

Launches the interactive secrets management interface.

### Direct secret commands

| Command | Description |
|---------|-------------|
| `./tools/pipepub.sh secrets add devto` | Add DEV.to token |
| `./tools/pipepub.sh secrets add hashnode` | Add Hashnode token + publication ID |
| `./tools/pipepub.sh secrets add medium` | Add Medium legacy token |
| `./tools/pipepub.sh secrets add github` | Add GitHub token (gist scope) |
| `./tools/pipepub.sh secrets list` | List configured services |
| `./tools/pipepub.sh secrets export` | Export secrets as environment variables |
| `./tools/pipepub.sh secrets delete devto` | Remove DEV.to token |

📖 **[Detailed secrets guide →](/docs/advanced/environment.md#secrets-management)**

<br>

<a id="system-commands"></a>

## 🔍 System commands

> *Check dependencies and system configuration.*

### Check system

![PipePub CLI interactive check system](https://pipepub.github.io/cdn/image/screenshot/pipepub-cli-interactive-system.png "PipePub CLI interactive check system")

```bash
./tools/pipepub.sh check
```

Verifies:

- Required dependencies (`git`, `curl`, `jq`, `openssl`)
- OS keychain availability
- `.env` file configuration
- Secret storage accessibility

<br>

<a id="test-commands"></a>

## 🧪 Test commands

> *Run test suites to validate functionality.*

### Interactive test menu

![PipePub CLI interactive tests](https://pipepub.github.io/cdn/image/screenshot/pipepub-cli-interactive-tests.png "PipePub CLI interactive tests")

```bash
./tools/pipepub.sh test
```

Launches the test selection interface.

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

### Direct test commands

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

<a id="help-commands"></a>

## 📚 Help commands

> *Get assistance when you need it.*

| Command | Description |
|---------|-------------|
| `./tools/pipepub.sh help` | Quick help overview |
| `./tools/pipepub.sh --help` | Same as above |
| `./tools/pipepub.sh --man` | Full manual page |
| `./tools/pipepub.sh --doc` | Open documentation in browser |

<br>

<a id="environment-variables"></a>

## 🌍 Environment variables

> *Control behavior without modifying code.*

| Variable | Values | Default | Description |
|----------|--------|---------|-------------|
| `DRY_RUN` | `true`, `false` | `false` | Test mode (no API calls) |
| `LOG_LEVEL` | `debug`, `info`, `warning`, `error` | `info` | Verbosity level |
| `LOG_OUTPUT` | `console`, `file`, `both` | `console` | Where to send logs |
| `LOG_QUIET` | `true`, `false` | `false` | Suppress all output |
| `PUBLISHER_GIST` | `true`, `false` | `true` | Enable table-to-Gist conversion |
| `PUBLISHER_LANG` | `en-us`, `es-es`, etc. | `en-us` | Language/locale |

📖 **[Full environment guide →](/docs/advanced/environment.md)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Interactive Menu](https://img.shields.io/badge/DOC-cli--interactive-white)](/docs/advanced/cli-interactive.md "Interactive menu guide")
[![Tools](https://pipepub.github.io/cdn/image/badge/doc/tools.svg)](/docs/advanced/tools.md "Local tools guide")
[![Environment](https://pipepub.github.io/cdn/image/badge/doc/environment.svg)](/docs/advanced/environment.md "Environment setup")
[![Tests](https://pipepub.github.io/cdn/image/badge/doc/tests.svg)](/docs/advanced/tests.md "Test suite")