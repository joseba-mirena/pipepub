<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Hashnode Integration Guide

> *Publish your articles to Hashnode automatically*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![hashnode](https://pipepub.github.io/cdn/image/badge/doc/hashnode.svg)](/docs/services/hashnode.md "Hashnode guide") |
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
| [🖼️ Cover images](#cover-images) |
| [🔧 Troubleshooting](#troubleshooting) |

</details>

---

<br>

<a id="getting-your-api-credentials"></a>

## 🔑 Getting your API credentials

> *Generate your Hashnode API token and find your publication ID.*

### Step 1: Get your Hashnode Personal Access Token

![Hashnode Personal Access Token](https://pipepub.github.io/cdn/image/screenshot/hashnode-personal-access-token.png "Hashnode Personal Access Token")

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

![GitHub repository secret](https://pipepub.github.io/cdn/image/screenshot/github-repository-secret-thumb.jpg "GitHub repository secret")

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
publisher: hashnode, devto, ghost, medium
gist: true
title: Hashnode Test Article
subtitle: Publish like a PRO 
image: https://pipepub.github.io/cdn/image/hero/publish-like-a-pro.jpg
status: draft
auto: true
---
```

<br>

<a id="publishing-behavior"></a>

## 📝 Publishing behavior

> *How Hashnode handles your articles.*

| Setting | Default | Behavior |
|---------|---------|----------|
| **Status** | `draft` | Articles publish as drafts for review |
| **Formats** | Markdown | Full markdown support (tables via Gists) |
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

<a id="cover-images"></a>

## 🖼️ Cover images

> *Hashnode's GraphQL API does not support a dedicated `coverImage` field in `CreateDraftInput`.*

### How PipePub handles cover images

When you add a cover image in frontmatter:

```yaml
---
image: https://example.com/cover.jpg
---
```

PipePub automatically embeds it as the first element in the article content:

```markdown
![Cover Image](https://example.com/cover.jpg)

[rest of your article content...]
```

Hashnode then detects the first image in the content and uses it as the post cover image.

### Important notes

| Note | Description |
|------|-------------|
| **External URLs work** | You can use any publicly accessible HTTPS image URL |
| **No upload required** | Unlike some platforms, Hashnode accepts external image URLs |
| **First image wins** | The first image in your content becomes the cover |
| **Format** | Standard markdown image syntax: `![alt text](url)` |

### Limitations

- Hashnode API has no native `coverImage` field for mutations
- The workaround described above is fully automatic - no action needed from you
- Cover image will not appear as a separate metadata field in the API response, but will display correctly on the published article

<br>

<a id="troubleshooting"></a>

## 🔧 Troubleshooting

### ❌ Article not appearing on Hashnode

**Checklist:**

1. Is `HASHNODE_TOKEN` secret correctly added?
2. Is `HASHNODE_PUBLICATION_ID` secret correctly added?
3. Does your article have a title (`# H1` heading)?
4. Does your token have `publishPost` scope?
5. Verify the article was sent (check workflow logs)

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

### ❌ Cover image not appearing

**Checklist:**

1. Is the image URL publicly accessible via HTTPS?
2. Is the image URL correctly set in frontmatter as `image` (aliases: `cover_image`, `cover`, `hero`)?
3. Is the image the first element in your content? (PipePub does this automatically)
4. Check that the image URL is not blocked or requiring authentication

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![DEV.to](https://pipepub.github.io/cdn/image/badge/doc/devto.svg)](/docs/services/devto.md "DEV.to guide")
[![Ghost](https://pipepub.github.io/cdn/image/badge/doc/ghost.svg)](/docs/services/ghost.md "Ghost guide")
[![Medium](https://pipepub.github.io/cdn/image/badge/doc/medium.svg)](/docs/services/medium.md "Medium guide")
[![GitHub](https://pipepub.github.io/cdn/image/badge/doc/github.svg)](/docs/services/github.md "GitHub Gist guide")
[![Markdown](https://pipepub.github.io/cdn/image/badge/doc/markdown.svg)](/docs/basics/markdown.md "Markdown guide")