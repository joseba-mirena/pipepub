<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Contributing to PipePub

> *Thank you for considering contributing to PipePub!*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![CONTRIBUTING](https://pipepub.github.io/cdn/image/badge/doc/contributing.svg)](/.github/CONTRIBUTING.md "Contributing guide") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🤝 How to contribute](#how-to-contribute) |
| [⚙️ Enable GitHub Actions](#enable-github-actions) |
| [🐛 Reporting bugs](#reporting-bugs) |
| [✨ Suggesting features](#suggesting-features) |
| [📝 Pull requests](#pull-requests) |
| [🧪 Development setup](#development-setup) |
| [📋 Code style](#code-style) |

</details>

---

<br>

<a id="how-to-contribute"></a>

## 🤝 How to contribute

> *Every contribution matters — from bug reports to code changes.*

1. **Fork the repository** to your own GitHub account
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** following the code style guidelines
4. **Run tests** to ensure nothing breaks
5. **Commit your changes** with clear, descriptive messages
6. **Push to your fork** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request** against the `main` branch

<br>

<a id="enable-github-actions"></a>

### ⚙️ Enable GitHub Actions

After creating your fork, GitHub Actions may be **disabled by default** for security reasons.

**To enable workflows:**

1. Go to your repository **Settings** → **Actions** → **General**
2. Under "Actions permissions", select **"Allow all actions and reusable workflows"**
3. Click **Save**

> **Why?** GitHub disables Actions on forked repositories as a security measure. This is normal and happens for every fork.

✅ Once enabled, your pipeline will run automatically when you upload articles.

<br>

<a id="reporting-bugs"></a>

## 🐛 Reporting bugs

> *Help us identify and fix issues.*

**Before submitting a bug report:**

- Check if the issue already exists in [GitHub Issues](https://github.com/pipepub/pipepub/issues)
- Update to the latest version to see if the problem persists
- Review [Troubleshooting](/docs/basics/faq.md) for common solutions

**When submitting a bug report, include:**

- Clear, descriptive title
- Steps to reproduce the issue
- Expected vs actual behavior
- Environment (OS, PipePub version, shell type)
- Relevant logs (use `LOG_LEVEL=debug` for verbose output)
- Screenshots or terminal output if helpful

**Bug report template is available** when you [create a new issue](https://github.com/pipepub/pipepub/issues/new/choose).

<br>

<a id="suggesting-features"></a>

## ✨ Suggesting features

> *Have an idea to make PipePub better? We'd love to hear it!*

**When suggesting a feature, include:**

- Clear, descriptive title
- Problem statement (what this feature would solve)
- Proposed solution description
- Alternative approaches you've considered
- Any additional context or examples

**Feature request template is available** when you [create a new issue](https://github.com/pipepub/pipepub/issues/new/choose).

<br>

<a id="pull-requests"></a>

## 📝 Pull requests

> *Code contributions are welcome! Follow these guidelines.*

**Before submitting a PR:**

- Ensure your code follows the project's style guidelines
- Add or update tests as necessary
- Run the full test suite: `./tools/tests/run.sh`
- Update documentation for any user-facing changes

**PR requirements:**

- Target the `main` branch
- Keep changes focused (one feature or fix per PR)
- Write clear, descriptive commit messages
- Reference any related issues (e.g., `Closes #123`)

**PR template will be pre-filled** when you [create a pull request](https://github.com/pipepub/pipepub/compare).

<br>

<a id="development-setup"></a>

## 🧪 Development setup

> *Set up PipePub locally for development.*

```bash
# Clone your fork
git clone https://github.com/your-username/pipepub.git
cd pipepub

# Make scripts executable
chmod +x tools/pipepub.sh tools/commands/*.sh tools/tests/**/*.sh

# Run tests to verify setup
./tools/tests/run.sh

# Run the interactive menu
./tools/pipepub.sh
```

**For detailed development guide**, see:

- [Test Suite](/docs/advanced/tests.md) — How to run and write tests
- [Environment Setup](/docs/advanced/environment.md) — Dependencies and .env configuration
- [Reference](/docs/advanced/reference.md) — Architecture and library documentation

<br>

<a id="code-style"></a>

## 📋 Code style

> *Consistency makes maintenance easier.*

| Guideline | Standard |
|-----------|----------|
| **Shell Scripts** | Bash 4+ with `#!/usr/bin/env bash` shebang |
| **Indentation** | 2 spaces (no tabs) |
| **Line length** | 80-100 characters |
| **Variables** | UPPER_CASE for environment, lower_case for local |
| **Functions** | snake_case names, describe purpose in comment |
| **Error handling** | Check exit codes, provide meaningful messages |

**Example:**

```bash
# Good
publish_article() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file"
        return 1
    fi
    
    # process file
}
```

<br>

<a id="license"></a>

## 📄 License

By contributing to PipePub, you agree that your contributions will be licensed under the [MIT License](/LICENSE).

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Tests](https://pipepub.github.io/cdn/image/badge/doc/tests.svg)](/docs/advanced/tests.md "Test suite")
[![Environment](https://pipepub.github.io/cdn/image/badge/doc/environment.svg)](/docs/advanced/environment.md "Environment setup")