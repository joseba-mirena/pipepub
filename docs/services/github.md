<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### GitHub Integration Guide

> *Configure GitHub for table-to-Gist conversion*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![github](https://pipepub.github.io/cdn/image/badge/doc/github.svg)](/docs/services/github.md "GitHub guide") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🔑 What is this for?](#what-is-this-for) |
| [🔧 Getting your GitHub token](#getting-your-github-token) |
| [⚙️ Configuration](#configuration) |
| [📊 How table conversion works](#how-table-conversion-works) |
| [🔧 Troubleshooting](#troubleshooting) |

</details>

---

<br>

<a id="what-is-this-for"></a>

## 🔑 What is this for?

> *GitHub integration enables automatic table-to-Gist conversion.*

PipePub uses GitHub Gists to display tables on platforms that don't support native markdown tables (like Medium).

**Without Gist conversion:** Tables appear as raw markdown or break entirely.

**With Gist conversion:** Tables are replaced with embedded GitHub Gists that render beautifully on any platform.

📖 **[See table conversion in action →](/docs/basics/markdown.md#tables)**

<br>

<a id="getting-your-github-token"></a>

## 🔧 Getting your GitHub token

![GitHub personal access token Gist](https://pipepub.github.io/cdn/image/screenshot/github-personal-access-token-gist-thumb.jpg "GitHub personal access token Gist")

> *Generate a Personal Access Token with `gist` scope.*

### Step 1: Create a classic token

1. Go to [GitHub Settings → Tokens](https://github.com/settings/tokens)
2. Click **"Generate new token (classic)"**
3. Give it a descriptive name (e.g., "PipePub Gist Token")
4. Set expiration (recommended: 90 days)
5. Select the **`gist`** scope (only this scope is needed)
6. Click **"Generate token"**

```text
https://github.com/settings/tokens/new?scopes=gist&description=PipePub%20Gist%20Token
```

### Step 2: Copy and add as secret

![GitHub repository secret](https://pipepub.github.io/cdn/image/screenshot/github-repository-secret-thumb.jpg "GitHub repository secret")

1. **Copy the token immediately** — you won't see it again!
2. Go to your repository: `Settings` → `Secrets and variables` → `Actions`
3. Click **"New repository secret"**
4. **Name:** `GH_PAT_GIST_TOKEN`
5. **Secret:** Paste your GitHub token
6. Click **"Add secret"**

📖 **[How to add secrets →](/docs/basics/settings.md#github-secrets)**

<br>

<a id="configuration"></a>

## ⚙️ Configuration

> *Set up GitHub Gist conversion in your repository.*

### Repository Secret

| Secret | Required | Scope |
|--------|----------|-------|
| `GH_PAT_GIST_TOKEN` | Optional (for tables) | `gist` |

### Pipeline Variable

| Variable | Value | Default | Description |
|----------|-------|---------|-------------|
| `PUBLISHER_GIST` | `true` / `false` | `true` | Enable/disable table conversion |

### Per-article override

In your article frontmatter:

```yaml
---
gist: false   # Disable Gist conversion for this article only
---
```

<br>

<a id="how-table-conversion-works"></a>

## 📊 How table conversion works

> *PipePub automatically converts tables to Gists behind the scenes.*

### The process

1. PipePub scans your markdown file for tables
2. For each table found, it creates a GitHub Gist
3. The Gist URL is embedded in place of the table
4. Platforms render the Gist beautifully

### Example

**Original markdown:**

```markdown
| Feature | Status |
|---------|--------|
| Tables  | ✅ Works |
```

**After conversion (simplified):**

```html
<script src="https://gist.github.com/user/abc123.js"></script>
```

**Result on Medium/DEV.to/Hashnode:** A beautifully rendered, interactive table.

### Requirements

| Requirement | Details |
|-------------|---------|
| `GH_PAT_GIST_TOKEN` | Must be configured with `gist` scope |
| `PUBLISHER_GIST` | Must be `true` (default) |
| Internet access | Gist embed requires external script loading |

### Privacy note

Gists are **public** by default. Anyone with the Gist URL can view the table data. Do not use for sensitive information.

<br>

<a id="troubleshooting"></a>

## 🔧 Troubleshooting

### ❌ Table not converting to Gist

**Checklist:**

1. Is `GH_PAT_GIST_TOKEN` secret correctly added?
2. Does the token have `gist` scope?
3. Is `PUBLISHER_GIST=true` (default)?
4. Check the Actions tab for Gist creation errors

### ❌ Gist creation fails with 401/403 error

**Error:** `❌ Failed to create Gist`

**Solutions:**
- Verify token is valid (not expired)
- Check token has `gist` scope
- Regenerate token if needed

### ❌ Table not rendering on platform

If Gist conversion is disabled (`PUBLISHER_GIST=false`), tables remain as plain markdown and may not render.

**Solutions:**
- Set `PUBLISHER_GIST=true`
- Or add `gist: true` to article frontmatter

### ❌ I don't want to use Gists

You can disable table conversion entirely:

- Set `PUBLISHER_GIST=false` in repository variables
- Or add `gist: false` to individual article frontmatter

Tables will remain as plain markdown (may not render on some platforms).

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![DEV.to](https://pipepub.github.io/cdn/image/badge/doc/devto.svg)](/docs/services/devto.md "DEV.to guide")
[![Hashnode](https://pipepub.github.io/cdn/image/badge/doc/hashnode.svg)](/docs/services/hashnode.md "Hashnode guide")
[![Medium](https://pipepub.github.io/cdn/image/badge/doc/medium.svg)](/docs/services/medium.md "Medium guide")
[![Markdown](https://pipepub.github.io/cdn/image/badge/doc/markdown.svg)](/docs/basics/markdown.md "Markdown guide")