[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Settings & Configuration

> *Configure your PipePub pipeline — no local setup required*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![settings](https://img.shields.io/badge/DOC-settings-white)](/docs/basics/settings.md "Settings guide") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🔑 GitHub Secrets](#github-secrets) |
| [⚙️ Pipeline Variables](#pipeline-variables) |
| [📝 Frontmatter Settings](#frontmatter-settings) |
| [🔄 Publishing Behavior](#publishing-behavior) |
| [🔧 Advanced Configuration](#advanced-configuration) |

</details>

---

<br>

<a id="github-secrets"></a>

## 🔑 GitHub Secrets

> *API tokens and credentials stored securely in your repository.*

**Where to add them:** `Settings` → `Secrets and variables` → `Actions` → `Repository secrets`

![GitHub repository secret](/docs/assets/img/github-repository-secret-thumb.jpg "GitHub repository secret")

| Secret | Platform | Required for |
|--------|----------|--------------|
| `DEVTO_TOKEN` | Dev.to | Publishing to Dev.to |
| `HASHNODE_TOKEN` | Hashnode | Publishing to Hashnode |
| `HASHNODE_PUBLICATION_ID` | Hashnode | Publishing to Hashnode |
| `MEDIUM_TOKEN` | Medium | Publishing to Medium (legacy only) |
| `GH_PAT_GIST_TOKEN` | GitHub | Table-to-Gist conversion (optional) |

📖 **[Detailed platform setup guides →](/docs/INDEX.md#services)**

<br>

<a id="pipeline-variables"></a>

## ⚙️ Pipeline Variables

> *Control pipeline behavior using repository variables.*

**Where to add them:** `Settings` → `Secrets and variables` → `Actions` → `Variables`

| Variable | Values | Default | Description |
|----------|--------|---------|-------------|
| `PUBLISHER_LANG` | `en-us`, `es-es`, etc. | `en-us` | Language/locale for content |
| `PUBLISHER_STATUS` | `draft`, `public` | `draft` | Default publish status |
| `PUBLISHER_GIST` | `true`, `false` | `true` | Convert tables to GitHub Gists |
| `PUBLISHER_AUTO` | `true`, `false` | `true` | Auto-publish on push |
| `DEBUG` | `true`, `false` | `false` | Enable verbose logging |

<br>

<a id="frontmatter-settings"></a>

## 📝 Frontmatter Settings

> *Override pipeline defaults per article using YAML frontmatter.*

Add these at the top of any `.md` file in `posts/`:

```yaml
---
tags: technology, github, automation
publisher: devto, hashnode
gist: true
status: draft
auto: true
---
```

| Field | Type | Overrides | Description |
|-------|------|-----------|-------------|
| `tags` | comma-separated string | N/A | Article tags (platform limits apply) |
| `publisher` | comma-separated string | All platforms | Publish only to specified platforms |
| `gist` | boolean | `PUBLISHER_GIST` | Convert tables to Gists for this article |
| `status` | `draft` or `public` | `PUBLISHER_STATUS` | Draft or public for this article |
| `auto` | boolean | `PUBLISHER_AUTO` | Auto-publish on push for this article |

📖 **[Full markdown guide →](/docs/basics/markdown.md)**

<br>

<a id="publishing-behavior"></a>

## 🔄 Publishing Behavior

> *How settings affect the publishing workflow.*

### Automatic vs Manual Publishing

| `PUBLISHER_AUTO` / `auto` | Behavior |
|---------------------------|----------|
| `true` (default) | Article publishes automatically when pushed to `posts/` |
| `false` | Article only publishes via manual workflow dispatch |

### Draft vs Public

| `PUBLISHER_STATUS` / `status` | Behavior |
|------------------------------|----------|
| `draft` (default) | Article appears as draft on platforms — review before publishing |
| `public` | Article publishes immediately (use with caution) |

### Table Conversion (Gist)

| `PUBLISHER_GIST` / `gist` | Behavior |
|---------------------------|----------|
| `true` (default) | Tables converted to GitHub Gists for proper rendering |
| `false` | Tables remain as plain markdown (may not render on some platforms) |

**Note:** Table conversion requires `GH_PAT_GIST_TOKEN` secret.

### Platform Selection (publisher)

| Setting | Behavior |
|---------|----------|
| Not set | Publishes to all configured platforms (all secrets added) |
| `devto` | Publishes only to Dev.to |
| `hashnode` | Publishes only to Hashnode |
| `medium` | Publishes only to Medium |
| `devto, hashnode` | Publishes to multiple specific platforms |

📖 **[All publishing methods →](/docs/basics/publishing.md)**

<br>

<a id="advanced-configuration"></a>

## 🔧 Advanced Configuration

> *For local development and advanced use cases.*

The settings above cover **GitHub Actions pipeline usage only**.

If you want to:

- Run PipePub **locally** on your machine
- Use the **interactive menu** (`./tools/pipepub.sh`)
- Configure **logging** (`LOG_LEVEL`, `LOG_OUTPUT`)
- Set up **keychain** for secret storage

📖 **[See the Environment Setup guide →](/docs/advanced/environment.md)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Quick Start](https://img.shields.io/badge/DOC-quickstart-white)](/docs/basics/quickstart.md "Quick Start guide")
[![Markdown](https://img.shields.io/badge/DOC-markdown-white)](/docs/basics/markdown.md "Markdown guide")
[![FAQ](https://img.shields.io/badge/DOC-faq-white)](/docs/basics/faq.md "FAQ")
[![Environment](https://img.shields.io/badge/DOC-environment-white)](/docs/advanced/environment.md "Local environment setup")