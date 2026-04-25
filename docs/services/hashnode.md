[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Hashnode Integration Guide

> *Publish your articles to Hashnode automatically*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![hashnode](https://img.shields.io/badge/DOC-hashnode-white)](/docs/services/hashnode.md "Hashnode guide") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🔑 Getting your API credentials](#getting-your-api-credentials) |
| [⚙️ Configuration](#configuration) |
| [🏷️ Tag rules](#tag-rules) |
| [📝 Publishing behavior](#publishing-behavior) |
| [🔧 Troubleshooting](#troubleshooting) |

</details>

---

<br>

<a id="getting-your-api-credentials"></a>

## 🔑 Getting your API credentials

> *Generate your Hashnode API token and find your publication ID.*

### Step 1: Get your Hashnode Personal Access Token

![Hashnode Personal Access Token](/docs/assets/img/hashnode-personal-access-token.png "Hashnode Personal Access Token")

1. Log in to your [Hashnode account](https://hashnode.com/)
2. Go to **Settings** → **Developer** (`https://hashnode.com/settings/developer`)
3. Under "Personal Access Tokens", click **"Generate new token"**
4. Give it a name (e.g., "PipePub")
5. Select the required scopes (at minimum: `publishPost`)
6. Copy the token immediately (you won't see it again)
7. Add it as a repository secret named `HASHNODE_TOKEN`

### Step 2: Find your Publication ID

Your publication ID is in your Hashnode dashboard URL:

```text
https://hashnode.com/your-publication-id
```

**Example:** If your blog URL is `https://hashnode.com/acmecorp`, your publication ID is `acmecorp`.

Add it as a repository secret named `HASHNODE_PUBLICATION_ID`.

📖 **[How to add secrets →](/docs/basics/settings.md#github-secrets)**

<br>

<a id="configuration"></a>

## ⚙️ Configuration

> *Set up Hashnode publishing in your repository.*

### Repository Secrets

| Secret | Value |
|--------|-------|
| `HASHNODE_TOKEN` | Your Hashnode Personal Access Token |
| `HASHNODE_PUBLICATION_ID` | Your Hashnode publication ID |

### Optional Frontmatter

To publish only to Hashnode (and not other platforms):

```yaml
---
publisher: hashnode
---
```

<br>

<a id="tag-rules"></a>

## 🏷️ Tag rules

> *Hashnode has flexible tag requirements.*

| Rule | Limit / Requirement |
|------|---------------------|
| **Maximum tags** | 5 tags per article |
| **Allowed characters** | Alphanumeric + `_` + `-` |
| **Space handling** | Converted to underscores (`_`) |
| **Underscore `_`** | Kept in tag name; converted to `-` in URL slug |
| **Hyphen `-`** | Kept in both tag name and slug |
| **Length limit** | No explicit limit |
| **Case sensitivity** | Preserved as entered |

### Tag conversion examples

| Original Tag | Tag Name (display) | URL Slug |
|--------------|-------------------|----------|
| `cloud computing` | `cloud_computing` | `cloud-computing` |
| `github-actions` | `github-actions` | `github-actions` |
| `test_tag` | `test_tag` | `test-tag` |
| `CI/CD` | `CI/CD` | `cicd` |

### Best practices for Hashnode tags

1. **Use hyphens for multi-word tags** — they're preserved in slugs
2. **Avoid spaces** — they become underscores in display (may look odd)
3. **Up to 5 tags** — extra tags are ignored
4. **Case-sensitive** — `DevOps` and `devops` are different tags

📖 **[General tag guidelines →](/docs/basics/markdown.md#platform-specific-tag-rules)**

<br>

<a id="publishing-behavior"></a>

## 📝 Publishing behavior

> *How Hashnode handles your articles.*

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

### ❌ Article not appearing on Hashnode

**Checklist:**

1. Is `HASHNODE_TOKEN` secret correctly added?
2. Is `HASHNODE_PUBLICATION_ID` secret correctly added?
3. Does your article have a title (`# H1` heading)?
4. Does your token have `publishPost` scope?
5. Check the Actions tab for workflow errors

### ❌ "Publication not found" error

Your publication ID is incorrect. Check your Hashnode dashboard URL:

```text
https://hashnode.com/your-publication-id
```

The ID is everything after `https://hashnode.com/`.

### ❌ Tags not showing correctly

Hashnode preserves underscores and hyphens but converts spaces to underscores.

**Example:** `"cloud computing"` → `"cloud_computing"` (display) / `"cloud-computing"` (slug)

### ❌ Table not rendering

Ensure `GH_PAT_GIST_TOKEN` is configured for Gist conversion, or set `gist: false` in frontmatter to keep plain markdown.

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Dev.to](https://img.shields.io/badge/DOC-devto-white)](/docs/services/devto.md "Dev.to guide")
[![Medium](https://img.shields.io/badge/DOC-medium-white)](/docs/services/medium.md "Medium guide")
[![GitHub](https://img.shields.io/badge/DOC-github-white)](/docs/services/github.md "GitHub Gist guide")
[![Markdown](https://img.shields.io/badge/DOC-markdown-white)](/docs/basics/markdown.md "Markdown guide")