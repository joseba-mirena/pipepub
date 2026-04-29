<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### DEV.to Integration Guide

> *Publish your articles to DEV.to automatically*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![devto](https://pipepub.github.io/cdn/image/badge/doc/devto.svg)](/docs/services/devto.md "DEV.to guide") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🔑 Getting your API key](#getting-your-api-key) |
| [⚙️ Configuration](#configuration) |
| [🏷️ Tag rules](#tag-rules) |
| [📝 Publishing behavior](#publishing-behavior) |
| [🔧 Troubleshooting](#troubleshooting) |

</details>

---

<br>

<a id="getting-your-api-key"></a>

## 🔑 Getting your API key

![DEV.to API key](https://pipepub.github.io/cdn/image/screenshot/devto-community-api-key-thumb.jpg "DEV.to API key")

> *Generate your DEV.to API key for authentication.*

1. Log in to your [DEV.to account](https://dev.to/)
2. Go to **Settings** → **Extensions** (`https://dev.to/settings/extensions`)
3. Under "API Keys", click **"Generate API key"**
4. Copy the generated key immediately (you won't see it again)
5. Add it as a repository secret named `DEVTO_TOKEN`

📖 **[How to add secrets →](/docs/basics/settings.md#github-secrets)**

<br>

<a id="configuration"></a>

## ⚙️ Configuration

> *Set up DEV.to publishing in your repository.*

### Repository Secret

| Secret | Value |
|--------|-------|
| `DEVTO_TOKEN` | Your DEV.to API key |

### Optional Frontmatter

To publish only to DEV.to (and not other platforms):

```yaml
---
publisher: devto
---
```

<br>

<a id="tag-rules"></a>

## 🏷️ Tag rules

> *DEV.to has specific tag requirements.*

| Rule | Limit / Requirement |
|------|---------------------|
| **Maximum tags** | 4 tags per article |
| **Allowed characters** | Alphanumeric only (a-z, 0-9) |
| **Space handling** | Removed entirely |
| **Special characters** | Removed (`_`, `-`, `#`, etc.) |
| **Length limit** | 2-30 characters per tag |
| **Case sensitivity** | Lowercase (converted automatically) |

### Tag conversion examples

| Original Tag | Converted Tag |
|--------------|---------------|
| `cloud computing` | `cloudcomputing` |
| `github-actions` | `githubactions` |
| `test_tag` | `testtag` |
| `CI/CD` | `cicd` |
| `c# programming` | `cprogramming` |

### Best practices for DEV.to tags

1. **Use simple, single words** — spaces and special characters are removed
2. **Keep tags short** — under 30 characters
3. **Use lowercase** — tags are case-insensitive but converted to lowercase
4. **Limit to 4 tags** — extra tags are ignored

📖 **[General tag guidelines →](/docs/basics/markdown.md#platform-specific-tag-rules)**

<br>

<a id="publishing-behavior"></a>

## 📝 Publishing behavior

> *How DEV.to handles your articles.*

| Setting | Default | Behavior |
|---------|---------|----------|
| **Status** | `draft` | Articles publish as drafts for review |
| **Formats** | Markdown | Full markdown support (tables via Gists) |
| **Images** | Supported | Use raw GitHub URLs |
| **Tags** | Converted | See tag rules above |

### Changing to public

To publish immediately as public, set in frontmatter:

```yaml
---
status: public
---
```

Or change the default in your workflow variables (`PUBLISHER_STATUS=public`).

<br>

<a id="troubleshooting"></a>

## 🔧 Troubleshooting

### ❌ Article not appearing on DEV.to

**Checklist:**

1. Is `DEVTO_TOKEN` secret correctly added?
2. Does your article have a title (`# H1` heading)?
3. Check the Actions tab for workflow errors
4. Verify the article was sent (check workflow logs)

### ❌ Tags not showing correctly

DEV.to only accepts alphanumeric characters. Special characters and spaces are removed automatically.

**Example:** `"cloud computing"` → `"cloudcomputing"`

### ❌ Table not rendering

Ensure `GH_PAT_GIST_TOKEN` is configured for Gist conversion, or set `gist: false` in frontmatter to keep plain markdown.

### ❌ Rate limit exceeded

DEV.to API allows 5,000 requests per hour. Space out your commits if publishing many articles at once.

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Hashnode](https://pipepub.github.io/cdn/image/badge/doc/hashnode.svg)](/docs/services/hashnode.md "Hashnode guide")
[![Medium](https://pipepub.github.io/cdn/image/badge/doc/medium.svg)](/docs/services/medium.md "Medium guide")
[![GitHub](https://pipepub.github.io/cdn/image/badge/doc/github.svg)](/docs/services/github.md "GitHub Gist guide")
[![Markdown](https://pipepub.github.io/cdn/image/badge/doc/markdown.svg)](/docs/basics/markdown.md "Markdown guide")