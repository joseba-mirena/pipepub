[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Medium Integration Guide

> *Publish your articles to Medium automatically (legacy token required)*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![medium](https://img.shields.io/badge/DOC-medium-white)](/docs/services/medium.md "Medium guide") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [⚠️ Important note](#important-note) |
| [🔑 Getting your legacy token](#getting-your-legacy-token) |
| [⚙️ Configuration](#configuration) |
| [🏷️ Tag rules](#tag-rules) |
| [📝 Publishing behavior](#publishing-behavior) |
| [🔧 Troubleshooting](#troubleshooting) |

</details>

---

<br>

<a id="important-note"></a>

## ⚠️ Important note

> **Medium no longer issues new API tokens as of 2026.**

The `MEDIUM_TOKEN` secret only works if you already have a **legacy integration token**.

**However, OAuth support is on the roadmap!** Once implemented, new users will be able to authenticate via OAuth and publish to Medium without a legacy token.

📖 **[Check roadmap for updates →](/docs/advanced/reference.md#roadmap)**

<br>

<a id="getting-your-legacy-token"></a>

## 🔑 Getting your legacy token

> *Only available if you already have a Medium integration token.*

1. Log in to your [Medium account](https://medium.com/)
2. Go to **Settings** → **Integration tokens** (`https://medium.com/me/settings`)
3. If you have an existing token, copy it immediately
4. Add it as a repository secret named `MEDIUM_TOKEN`

📖 **[How to add secrets →](/docs/basics/settings.md#github-secrets)**

**If you don't have a token**, you cannot publish to Medium via PipePub at this time. Watch for OAuth support coming soon.

<br>

<a id="configuration"></a>

## ⚙️ Configuration

> *Set up Medium publishing in your repository.*

### Repository Secret

| Secret | Value |
|--------|-------|
| `MEDIUM_TOKEN` | Your legacy Medium integration token |

### Optional Frontmatter

To publish only to Medium (and not other platforms):

```yaml
---
publisher: medium
---
```

<br>

<a id="tag-rules"></a>

## 🏷️ Tag rules

> *Medium has specific tag requirements.*

| Rule | Limit / Requirement |
|------|---------------------|
| **Maximum tags** | 5 tags per article |
| **Allowed characters** | Alphanumeric + `_` + `-` |
| **Space handling** | Converted to hyphens (`-`) |
| **Underscore `_`** | Converted to hyphens (`-`) |
| **Hyphen `-`** | Kept as is |
| **Length limit** | 1-25 characters per tag |
| **Case sensitivity** | Lowercase (converted automatically) |

### Tag conversion examples

| Original Tag | Converted Tag |
|--------------|---------------|
| `cloud computing` | `cloud-computing` |
| `github-actions` | `github-actions` |
| `test_tag` | `test-tag` |
| `CI/CD` | `cicd` |
| `DevOps` | `devops` |

### Best practices for Medium tags

1. **Use hyphens for multi-word tags** — spaces become hyphens
2. **Avoid underscores** — they become hyphens
3. **Keep tags short** — under 25 characters
4. **Use lowercase** — tags are automatically lowercased
5. **Limit to 5 tags** — extra tags are ignored

📖 **[General tag guidelines →](/docs/basics/markdown.md#platform-specific-tag-rules)**

<br>

<a id="publishing-behavior"></a>

## 📝 Publishing behavior

> *How Medium handles your articles.*

| Setting | Default | Behavior |
|---------|---------|----------|
| **Status** | `draft` | Articles publish as drafts for review |
| **Formats** | Markdown | Markdown converted to Medium HTML |
| **Tables** | Gist embed | Requires `GH_PAT_GIST_TOKEN` |
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

### ❌ Failed to get Medium User ID

**Error:** `❌ Failed to get Medium User ID`

**Solutions:**
1. Is `MEDIUM_TOKEN` secret correctly added?
2. Is the token still valid (not expired)?
3. Did you copy the full token correctly?

### ❌ Article not appearing on Medium

**Checklist:**

1. Is `MEDIUM_TOKEN` secret correctly added?
2. Does your article have a title (`# H1` heading)?
3. Check the Actions tab for workflow errors
4. Verify the article was sent (check workflow logs)

### ❌ Table not rendering

Medium does not support markdown tables. PipePub converts tables to GitHub Gists for proper rendering. Ensure `GH_PAT_GIST_TOKEN` is configured.

### ❌ I don't have a legacy token

Medium closed new API token issuance in 2026. If you don't have a legacy token, you cannot publish to Medium via API at this time.

**OAuth support is on the roadmap!** Once implemented, new users will be able to authenticate via OAuth.

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Dev.to](https://img.shields.io/badge/DOC-devto-white)](/docs/services/devto.md "Dev.to guide")
[![Hashnode](https://img.shields.io/badge/DOC-hashnode-white)](/docs/services/hashnode.md "Hashnode guide")
[![GitHub](https://img.shields.io/badge/DOC-github-white)](/docs/services/github.md "GitHub Gist guide")
[![Markdown](https://img.shields.io/badge/DOC-markdown-white)](/docs/basics/markdown.md "Markdown guide")