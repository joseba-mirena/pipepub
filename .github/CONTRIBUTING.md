[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Contributing to PipePub

> *Thank you for considering contributing to PipePub!*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![CONTRIBUTING](https://img.shields.io/badge/DOC-contributing-white)](/.github/CONTRIBUTING.md "Contributing guide") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🤝 How to contribute](#how-to-contribute) |
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
- Run the full test suite: `./tools/tests/run_all_tests.sh`
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
./tools/tests/run_all_tests.sh

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

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Tests](https://img.shields.io/badge/DOC-tests-white)](/docs/advanced/tests.md "Test suite")
[![Environment](https://img.shields.io/badge/DOC-environment-white)](/docs/advanced/environment.md "Environment setup")