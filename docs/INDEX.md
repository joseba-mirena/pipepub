<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Documentation Index

> *Complete list of all PipePub documentation — categorized for easy navigation*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![Documentation Index](https://pipepub.github.io/cdn/image/badge/doc/index.svg)](/docs/INDEX.md "Documentation Index document") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [📚 Basics](#basics) |
| [🔌 Services](#services) |
| [⚙️ Advanced](#advanced) |
| [🛠️ Developer Reference](#developer-reference) |
| [👥 Community & Support](#community-support) |
| [📁 Repository Structure](#repository-structure) |

</details>

---

<br>

<a id="basics"></a>

## 📚 Basics

> *Essential documents for getting started.*

| Document | Description |
|----------|-------------|
| [![Main Documentation](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main Documentation document") | Documentation home page |
| [![Quick Start](https://pipepub.github.io/cdn/image/badge/doc/quickstart.svg)](/docs/basics/quickstart.md "Quick Start document") | Get up and running in 5 minutes |
| [![Publishing Methods](https://pipepub.github.io/cdn/image/badge/doc/publishing.svg)](/docs/basics/publishing.md "Publishing Methods document") | All the ways to publish your articles |
| [![Markdown Format](https://pipepub.github.io/cdn/image/badge/doc/markdown.svg)](/docs/basics/markdown.md "Markdown Format document") | Frontmatter, tags, images, tables |
| [![Settings & Configuration](https://pipepub.github.io/cdn/image/badge/doc/settings.svg)](/docs/basics/settings.md "Settings & Configuration document") | Pipeline configuration (GitHub UI) |
| [![FAQ](https://pipepub.github.io/cdn/image/badge/doc/faq.svg)](/docs/basics/faq.md "FAQ document") | Frequently asked questions |

<br>

<a id="services"></a>

## 🔌 Services

> *Platform-specific configuration and tag rules.*

| Document | Description |
|----------|-------------|
| [![DEV.to](https://pipepub.github.io/cdn/image/badge/doc/devto.svg)](/docs/services/devto.md "DEV.to document") | API token, tag rules, limits |
| [![Hashnode](https://pipepub.github.io/cdn/image/badge/doc/hashnode.svg)](/docs/services/hashnode.md "Hashnode document") | Token, publication ID, tag rules |
| [![Medium](https://pipepub.github.io/cdn/image/badge/doc/medium.svg)](/docs/services/medium.md "Medium document") | Legacy tokens, tag rules, OAuth roadmap |
| [![GitHub](https://pipepub.github.io/cdn/image/badge/doc/github.svg)](/docs/services/github.md "GitHub document") | Gist token for table conversion |

<br>

<a id="advanced"></a>

## ⚙️ Advanced

> *For power users running PipePub locally.*

| Document | Description |
|----------|-------------|
| [![Environment Setup](https://pipepub.github.io/cdn/image/badge/doc/environment.svg)](/docs/advanced/environment.md "Environment Setup document") | Dependencies, .env, keychain setup |
| [![Interactive Menu](https://pipepub.github.io/cdn/image/badge/doc/interactive.svg)](/docs/advanced/cli-interactive.md "Interactive Menu document") | TUI navigation, panel system |
| [![CLI Commands](https://pipepub.github.io/cdn/image/badge/doc/commands.svg)](/docs/advanced/commands.md "CLI Commands document") | publish, secrets, check, test |
| [![Local Tools](https://pipepub.github.io/cdn/image/badge/doc/tools.svg)](/docs/advanced/tools.md "Local Tools document") | pipepub.sh, publish.sh, secrets.sh |
| [![Infrastructure & CI/CD](https://pipepub.github.io/cdn/image/badge/doc/infra.svg)](/docs/advanced/infra.md "Infrastructure & CI/CD document") | CI/CD setup, installation per OS |
| [![Test Suite](https://pipepub.github.io/cdn/image/badge/doc/tests.svg)](/docs/advanced/tests.md "Test Suite document") | Running tests, CI/CD integration |
| [![Technical Reference](https://pipepub.github.io/cdn/image/badge/doc/reference.svg)](/docs/advanced/reference.md "Technical Reference document") | Architecture, libraries, naming conventions |

<br>

<a id="developer-reference"></a>

## 🛠️ Developer Reference

> *For contributors and advanced developers.*

| Document | Description |
|----------|-------------|
| [![Documentation Index](https://pipepub.github.io/cdn/image/badge/doc/index.svg)](/docs/INDEX.md "Documentation Index document") | This page — full documentation index |
| [![Manual](https://pipepub.github.io/cdn/image/badge/doc/man.svg)](/docs/MAN "Manual document") | Terminal manual page |
| [![Changelog](https://pipepub.github.io/cdn/image/badge/doc/changelog.svg)](/CHANGELOG.md "Changelog document") | Version history and release notes |
| [![License](https://pipepub.github.io/cdn/image/badge/doc/license.svg)](/LICENSE "License document") | MIT License |

<br>

<a id="community-support"></a>

## 👥 Community & Support

> *Getting help and contributing back.*

| Document | Description |
|----------|-------------|
| [![Security Policy](https://pipepub.github.io/cdn/image/badge/doc/security.svg)](/docs/SECURITY.md "Security Policy document") | Reporting vulnerabilities |
| [![Support](https://pipepub.github.io/cdn/image/badge/doc/support.svg)](/docs/SUPPORT.md "Support document") | Getting help |
| [![Contributing Guide](https://pipepub.github.io/cdn/image/badge/doc/contributing.svg)](/.github/CONTRIBUTING.md "Contributing Guide document") | How to contribute |

<br>

<a id="repository-structure"></a>

## 📁 Repository Structure

> **User articles**: [posts/](/posts/)

```markdown
/
├── .github/
│   ├── config/
│   │   ├── services/
│   │   │   ├── devto.conf
│   │   │   ├── hashnode.conf
│   │   │   └── medium.conf
│   │   └── registry.conf
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.yml
│   │   ├── config.yml
│   │   └── feature_request.yml
│   ├── lang/                  # to be implemented
│   │   ├── en-us.sh
│   │   └── es-es.sh
│   ├── scripts/
│   │   ├── core/
│   │   │   └── registry.sh
│   │   ├── handlers/
│   │   │   ├── devto.sh
│   │   │   ├── gist_tables.sh
│   │   │   ├── hashnode.sh
│   │   │   └── medium.sh
│   │   ├── lib/
│   │   │   ├── api.sh
│   │   │   ├── common.sh
│   │   │   ├── content.sh
│   │   │   ├── frontmatter.sh
│   │   │   ├── html.sh
│   │   │   ├── logging.sh
│   │   │   ├── tags.sh
│   │   │   └── validation.sh
│   │   └── main.sh
│   ├── workflows/
│   │   ├── ci.yml
│   │   └── pipepub.yml
│   ├── CONTRIBUTING.md
│   ├── FUNDING.yml
│   └── PULL_REQUEST_TEMPLATE.md
├── .logs/                    # tests (auto-generated)
├── .reports/                 # tests (auto-generated)
├── .tmp/                     # debug (auto-generated)
├── docs/
│   ├── advanced/
│   │   ├── cli-interactive.md
│   │   ├── commands.md
│   │   ├── environment.md
│   │   ├── infra.md
│   │   ├── reference.md
│   │   ├── tests.md
│   │   └── tools.md
│   ├── assets/
│   │   └── example/
│   │       └── post-example.md
│   ├── basics/
│   │   ├── faq.md
│   │   ├── markdown.md
│   │   ├── publishing.md
│   │   ├── quickstart.md
│   │   └── settings.md
│   ├── services/
│   │   ├── devto.md
│   │   ├── github.md
│   │   ├── hashnode.md
│   │   └── medium.md
│   ├── INDEX.md
│   ├── MAN
│   ├── README.md
│   ├── SECURITY.md
│   └── SUPPORT.md
├── images/
│   └── .gitkeep
├── posts/
│   └── .gitkeep
├── tools/
│   ├── commands/
│   │   ├── check.sh
│   │   ├── help.sh
│   │   ├── publish.sh
│   │   ├── secrets.sh
│   │   └── test.sh
│   ├── config/
│   │   ├── services.sh
│   │   └── services.yaml
│   ├── lib/
│   │   ├── common.sh
│   │   ├── keychain.sh
│   │   ├── options.sh
│   │   ├── panel.sh
│   │   └── setup.sh
│   ├── tests/
│   │   ├── e2e/
│   │   │   └── run_dry_run.sh
│   │   ├── fixtures/
│   │   │   ├── input/
│   │   │   │   └── posts/
│   │   │   │       ├── config
│   │   │   │       ├── all-fields.md
│   │   │   │       ├── auto-false.md
│   │   │   │       ├── auto-true.md
│   │   │   │       ├── basic.md
│   │   │   │       ├── full.md
│   │   │   │       ├── gist-false.md
│   │   │   │       ├── gist-true.md
│   │   │   │       ├── minimal.md
│   │   │   │       ├── multi-publisher.md
│   │   │   │       ├── single-publisher.md
│   │   │   │       ├── status-draft.md
│   │   │   │       ├── status-public.md
│   │   │   │       ├── with-cover.md
│   │   │   │       ├── with-multiple-tables.md
│   │   │   │       ├── with-table.md
│   │   │   │       └── with-tags.md
│   │   │   └── snapshots/
│   │   │       └── json/
│   │   │           ├── devto-payload.json
│   │   │           ├── hashnode-payload.json
│   │   │           └── medium-payload.json
│   │   ├── integration/
│   │   │   ├── test_gist_integration.sh
│   │   │   ├── test_multipost.sh
│   │   │   └── test_pipeline_behavior.sh
│   │   ├── lib/
│   │   │   ├── assertions.sh
│   │   │   ├── deps.sh
│   │   │   ├── fixtures.sh
│   │   │   ├── setup.sh
│   │   │   ├── tags.sh
│   │   │   ├── tap.sh
│   │   │   ├── test_runner.sh
│   │   │   └── timeout.sh
│   │   ├── unit/
│   │   │   ├── test_content.sh
│   │   │   ├── test_devto_api.sh
│   │   │   ├── test_frontmatter_config.sh
│   │   │   ├── test_frontmatter.sh
│   │   │   ├── test_hashnode_api.sh
│   │   │   ├── test_medium_api.sh
│   │   │   ├── test_smoke.sh
│   │   │   └── test_tags.sh
│   │   └── run_all_tests.sh
│   └── pipepub.sh
├── .env                      # pipepub (auto-generated)
├── .env.example
├── .gitignore
├── CHANGELOG.md
├── LICENSE
└── README.md
```

<br>

---

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![Main Documentation](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main Documentation document")
[![Quick Start](https://pipepub.github.io/cdn/image/badge/doc/quickstart.svg)](/docs/basics/quickstart.md "Quick Start document")
[![Publishing Methods](https://pipepub.github.io/cdn/image/badge/doc/publishing.svg)](/docs/basics/publishing.md "Publishing Methods document")
[![Markdown Format](https://pipepub.github.io/cdn/image/badge/doc/markdown.svg)](/docs/basics/markdown.md "Markdown Format document")
[![FAQ](https://pipepub.github.io/cdn/image/badge/doc/faq.svg)](/docs/basics/faq.md "FAQ document")
[![Security Policy](https://pipepub.github.io/cdn/image/badge/doc/security.svg)](/docs/SECURITY.md "Security Policy document")
[![Contributing Guide](https://pipepub.github.io/cdn/image/badge/doc/contributing.svg)](/.github/CONTRIBUTING.md "Contributing Guide document")
[![Support](https://pipepub.github.io/cdn/image/badge/doc/support.svg)](/docs/SUPPORT.md "Support document")