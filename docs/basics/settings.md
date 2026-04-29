<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Settings & Configuration

> *Configure your PipePub pipeline — no local setup required*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![settings](https://pipepub.github.io/cdn/image/badge/doc/settings.svg)](/docs/basics/settings.md "Settings guide") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🔑 GitHub Secrets](#github-secrets) |
| [⚙️ Enabling GitHub Actions](#enable-actions) |
| [⚙️ Pipeline Variables](#pipeline-variables) |
| [📝 Frontmatter Settings](#frontmatter-settings) |
| [🔧 Publishing Behavior](#publishing-behavior) |
| [🔬 Advanced Configuration](#advanced-configuration) |

</details>

---

<br>

<a id="github-secrets"></a>

## 🔑 GitHub Secrets

> *API tokens and credentials stored securely in your repository.*

**Where to add them:** `Settings` → `Secrets and variables` → `Actions` → `Repository secrets`

![GitHub repository secret](https://pipepub.github.io/cdn/image/screenshot/github-repository-secret-thumb.jpg "GitHub repository secret")

| Secret | Platform | Required for |
|--------|----------|--------------|
| `DEVTO_TOKEN` | DEV.to | Publishing to DEV.to |
| `HASHNODE_TOKEN` | Hashnode | Publishing to Hashnode |
| `HASHNODE_PUBLICATION_ID` | Hashnode | Publishing to Hashnode |
| `MEDIUM_TOKEN` | Medium | Publishing to Medium (legacy only) |
| `GH_PAT_GIST_TOKEN` | GitHub | Table-to-Gist conversion (optional) |

📖 **[Detailed platform setup guides →](/docs/INDEX.md#services)**

<br>

<a id="enable-actions"></a>

## ⚙️ Enabling GitHub Actions

When you create a repository from the PipePub template, GitHub Actions may be disabled by default.

**To enable:**

| Step | Action |
|------|--------|
| 1 | Go to **Settings** → **Actions** → **General** |
| 2 | Under "Actions permissions", select **"Allow all actions and reusable workflows"** |
| 3 | Click **Save** |

> **Note:** This is a one-time setup per repository. Once enabled, all workflows will run automatically.

<br>

<a id="pipeline-variables"></a>

## ⚙️ Pipeline Variables

> *Control pipeline behavior using repository variables.*

**Where to add them:** `Settings` → `Secrets and variables` → `Actions` → `Variables`

| Variable | Values | Default | Description |
|----------|--------|---------|-------------|
| `PUBLISHER_LANG` | `en-us`, `es-es`, etc. | `en-us` | Language/locale for content |
| `PUBLISHER_GIST` | `true`, `false` | `true` | Convert tables to GitHub Gists |
| `DEBUG` | `true`, `false` | `false` | Enable verbose logging |

**Note:** `PUBLISHER_STATUS` and `PUBLISHER_AUTO` are no longer used as global variables. Default status and auto-publish behavior are now configured per service in `.github/config/services/*.conf`. Individual articles can still override these via frontmatter.

### Service defaults

| Service | Default status | Default auto |
|---------|----------------|--------------|
| DEV.to | `draft` | `true` |
| Hashnode | `draft` | `true` |
| Medium | `draft` | `true` |

These can be modified in `.github/config/services/*.conf`.

<br>

<a id="frontmatter-settings"></a>

## 📝 Frontmatter Settings

> *Override pipeline defaults per article using YAML frontmatter.*

Add these at the top of any `.md` file in `posts/`:

```yaml
---
title: My Awesome Article
subtitle: A comprehensive guide
tags: technology, github, automation
publisher: devto, hashnode
status: public
auto: false
gist: true
image: https://example.com/cover.jpg
---
```

### Frontmatter reference

| Field | Aliases | Type | Overrides | Description |
|-------|---------|------|-----------|-------------|
| `title` | - | string | N/A | Article title (overrides first H1 heading) |
| `subtitle` | - | string | N/A | Article subtitle (platform support varies) |
| `tags` | - | comma-separated | N/A | Article tags (platform limits apply) |
| `publisher` | - | comma-separated | All platforms | Publish only to specified platforms |
| `status` | - | `draft` or `public` | Service default | Draft or public for this article |
| `auto` | - | `true` or `false` | Service default | Auto-publish on push for this article |
| `gist` | - | `true` or `false` | `PUBLISHER_GIST` | Convert tables to Gists for this article |
| `image` | `cover_image`, `cover`, `hero` | URL | N/A | Cover image URL (platform support varies) |

### Field details

| Field | Details |
|-------|---------|
| `title` | If not provided, PipePub uses the first `# H1` heading from content |
| `subtitle` | Supported by Hashnode and Medium. DEV.to ignores subtitle. |
| `image` | Supported natively by DEV.to and Medium. Hashnode requires image to be first element in content (automatic). |
| `status` | Default values are `draft` for all services (configurable per service). |
| `auto` | Default values are `true` for all services (configurable per service). |

📖 **[Full markdown guide →](/docs/basics/markdown.md)**

<br>

<a id="publishing-behavior"></a>

## 🔧 Publishing Behavior

> *How settings affect the publishing workflow.*

### Automatic vs Manual Publishing

| `auto` (frontmatter) / service default | Behavior |
|----------------------------------------|----------|
| `true` (default per service) | Article publishes automatically when pushed to `posts/` |
| `false` | Article only publishes via manual workflow dispatch |

### Draft vs Public

| `status` (frontmatter) / service default | Behavior |
|-------------------------------------------|----------|
| `draft` (default per service) | Article appears as draft on platforms — review before publishing |
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
| `devto` | Publishes only to DEV.to |
| `hashnode` | Publishes only to Hashnode |
| `medium` | Publishes only to Medium |
| `devto, hashnode` | Publishes to multiple specific platforms |

📖 **[All publishing methods →](/docs/basics/publishing.md)**

<br>

<a id="advanced-configuration"></a>

## 🔬 Advanced Configuration

> *For local development and advanced use cases.*

The settings above cover **GitHub Actions pipeline usage only**.

If you want to:

- Run PipePub **locally** on your machine
- Use the **interactive menu** (`./tools/pipepub.sh`)
- Configure **logging** (`LOG_LEVEL`, `LOG_OUTPUT`)
- Set up **keychain** for secret storage
- Develop new services with **dev overrides**

📖 **[See the Environment Setup guide →](/docs/advanced/environment.md)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Quick Start](https://pipepub.github.io/cdn/image/badge/doc/quickstart.svg)](/docs/basics/quickstart.md "Quick Start guide")
[![Markdown](https://pipepub.github.io/cdn/image/badge/doc/markdown.svg)](/docs/basics/markdown.md "Markdown guide")
[![FAQ](https://pipepub.github.io/cdn/image/badge/doc/faq.svg)](/docs/basics/faq.md "FAQ")
[![Environment](https://pipepub.github.io/cdn/image/badge/doc/environment.svg)](/docs/advanced/environment.md "Local environment setup")