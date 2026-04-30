<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Ghost Integration Guide

> *Publish your articles to Ghost automatically*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![Ghost](https://pipepub.github.io/cdn/image/badge/doc/ghost.svg)](/docs/services/ghost.md "Ghost guide") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🔑 Getting your API credentials](#getting-your-api-credentials) |
| [⚙️ Configuration](#configuration) |
| [📝 Publishing behavior](#publishing-behavior) |
| [🏷️ Tag rules](#tag-rules) |
| [🔧 Troubleshooting](#troubleshooting) |

</details>

---

<br>

### Ghost 6.x requirements

> Ghost 5.x reached End of Life in January 2026. PipePub requires **Ghost 6.0 or higher** for full compatibility.  If you use Ghost v5.x, please, consider to upgrade it.

<a id="getting-your-api-credentials"></a>

## 🔑 Getting your API credentials

![Ghost integration](https://pipepub.github.io/cdn/image/screenshot/ghost-integration-keys.png "Ghost integration")

> *Generate your Ghost integration and find your Admin API key and API URL.*

1. Log in to your Ghost Admin panel 
2. Go to **Settings** → Advanced **Integrations**
3. Under "Advanced", click **"Add custom Integration"**
4. Give it a name (e.g., "PipePub") and click **Add** button
5. Add Admin API key as a repository secret named `GHOST_TOKEN`
6. Add API URL (do not add: `https://`; add just the domain: `www.mydomainname.dev`) as a repository secret named `GHOST_DOMAIN`

![GitHub repository secret](https://pipepub.github.io/cdn/image/screenshot/github-repository-secret-thumb.jpg "GitHub repository secret")

📖 **[How to add secrets →](/docs/basics/settings.md#github-secrets)**

<br>

<a id="configuration"></a>

## ⚙️ Configuration

> *Set up Ghost publishing in your repository.*

### Repository Secrets

| Secret | Value |
|--------|-------|
| `GHOST_TOKEN` | Your Ghost Admin API key |
| `GHOST_DOMAIN` | Your Ghost API URL |

### Optional Frontmatter

To publish only to Ghost (and not other platforms):

```yaml
---
publisher: ghost
---
```

To override default status or auto-publish for a specific article:

```yaml
---
status: public
auto: false
---
```

**Frontmatter example**

```yaml
---
tags: tag1, tag2, tag3, tag4
publisher: ghost, devto, hashnode, medium
gist: true
title: Ghost Test Article
subtitle: Publish like a PRO 
image: https://pipepub.github.io/cdn/image/hero/publish-like-a-pro.jpg
status: draft
auto: true
---
```

<br>

<a id="publishing-behavior"></a>

## 📝 Publishing behavior

> *How Ghost handles your articles.*

| Setting | Default | Behavior |
|---------|---------|----------|
| **Status** | `draft` | Articles publish as drafts for review |
| **Formats** | Markdown | Full markdown support (optional tables via Gists) |
| **Tags** | Converted | See tag rules above |

### Changing to public

To publish immediately as public, set in frontmatter:

```yaml
---
status: public
---
```

<br>

<a id="tag-rules"></a>

## 🏷️ Tag rules

> *Ghost has specific tag requirements for the API.*

| Rule | Limit / Requirement |
|------|---------------------|
| **Maximum tags** | 5 tags per article |
| **Allowed characters** | Alphanumeric + hyphen (`-`) only |
| **Space handling** | Converted to hyphens (`-`) |
| **Underscore `_`** | Removed (not allowed) |
| **Hyphen `-`** | Kept as is |
| **Length limit** | 1-25 characters per tag |
| **Case sensitivity** | Lowercase (converted automatically) |

### Tag conversion examples

| Original Tag | Converted Tag |
|--------------|---------------|
| `cloud computing` | `cloud-computing` |
| `github-actions` | `github-actions` |
| `test_tag` | `testtag` |
| `CI/CD` | `cicd` |
| `DevOps` | `devops` |

### Best practices for Ghost tags

1. **Use hyphens for multi-word tags** — spaces become hyphens
2. **Avoid underscores** — they are removed entirely
3. **Keep tags short** — under 25 characters
4. **Use lowercase** — tags are automatically lowercased
5. **Limit to 5 tags** — extra tags are ignored

📖 **[General tag guidelines →](/docs/basics/markdown.md#platform-specific-tag-rules)**

<br>

<a id="troubleshooting"></a>

## 🔧 Troubleshooting

### ❌ Article not appearing on Ghost

**Checklist:**

1. Is `GHOST_TOKEN` secret correctly added?
2. Is `GHOST_DOMAIN` secret correctly added?
3. Does your article have a title (or `# H1` heading)?
4. Verify the article was sent (check workflow logs)

### ❌ "Domain not found" error

Your API URL is incorrect. Check your Ghost integration API URL.

### ❌ Tags not showing correctly

Ghost only accepts alphanumeric characters and hyphens. Spaces become hyphens, underscores are removed.

**Example:** `"cloud_computing"` → `"cloudcomputing"`

### ❌ Table not rendering

Ensure `GH_PAT_GIST_TOKEN` is configured for Gist conversion, or set `gist: false` in frontmatter to keep plain markdown.

### ❌ Cover image not appearing

**Checklist:**

1. Is the image URL publicly accessible via HTTPS?
2. Is the image URL correctly set in frontmatter as `image` (aliases: `cover_image`, `cover`, `hero`)?
3. Check that the image URL is not blocked or requiring authentication

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![DEV.to](https://pipepub.github.io/cdn/image/badge/doc/devto.svg)](/docs/services/devto.md "DEV.to guide")
[![Hashnode](https://pipepub.github.io/cdn/image/badge/doc/hashnode.svg)](/docs/services/hashnode.md "Hashnode guide")
[![Medium](https://pipepub.github.io/cdn/image/badge/doc/medium.svg)](/docs/services/medium.md "Medium guide")
[![GitHub](https://pipepub.github.io/cdn/image/badge/doc/github.svg)](/docs/services/github.md "GitHub Gist guide")
[![Markdown](https://pipepub.github.io/cdn/image/badge/doc/markdown.svg)](/docs/basics/markdown.md "Markdown guide")