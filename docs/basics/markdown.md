<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Markdown Format Guide

> *How to format your articles for optimal publishing across all platforms*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![markdown](https://pipepub.github.io/cdn/image/badge/doc/markdown.svg)](/docs/basics/markdown.md "Markdown guide") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [📋 Frontmatter](#frontmatter) |
| [🏷️ Tags](#tags) |
| [📝 Content](#content) |
| [📊 Tables](#tables) |
| [🖼️ Images](#images) |
| [🔧 Platform-specific tag rules](#platform-specific-tag-rules) |

</details>

---

<br>

<a id="frontmatter"></a>

## 📋 Frontmatter

> *YAML frontmatter at the top of your markdown file controls article metadata.*

Place frontmatter at the very beginning of your `.md` file, surrounded by `---`:

```markdown
---
tags: technology, github, automation
publisher: devto, hashnode
gist: true
title: Article title
subtitle: Article subtitle
image: https://pipepub.github.io/cdn/image/hero/publish-like-a-pro.jpg
status: draft
auto: true
---

# Your Article Title

Your article content
```

### Frontmatter Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `tags` | comma-separated string | (empty) | Article tags (platform limits apply) |
| `publisher` | comma-separated string | all configured platforms | Which platforms to publish to |
| `gist` | boolean | `true` | Convert tables to GitHub Gists |
| `title` | string | (empty) | Article title (uses # header if not provided) |
| `subtitle` | string | (empty) | Article subtitle |
| `image` | string | (empty) | Article cover image url |
| `status` | `draft` or `public` | `draft` | Publish as draft or public |
| `auto` | boolean | `true` | Auto-publish on push (`false` = manual only) |

<br>

<a id="tags"></a>

## 🏷️ Tags

> *Tags help readers discover your content.*

**Example frontmatter with tags:**

```markdown
---
tags: bash, automation, github-actions, devops
---
```

**Important notes:**
- Different platforms have different tag limits and rules (see [platform-specific rules](#platform-specific-tag-rules))
- Tags are case-sensitive on some platforms
- Spaces and special characters are handled differently per platform

<br>

<a id="content"></a>

## 📝 Content

> *Standard markdown with full support for headings, lists, code blocks, and more.*

### Headings

```markdown
# H1 - Article title (used by platforms)
## H2 - Main sections
### H3 - Subsections
```

**Note:** The first `# H1` heading in your document is used as the article title on publishing platforms.

### Lists

```markdown
- Unordered list item
- Another item

1. Ordered list item
2. Another item
```

### Code blocks

```markdown
```bash
echo "Hello, World!"
```

### Links

```markdown
[PipePub GitHub Repository](https://github.com/pipepub/pipepub)
```

### Blockquotes

```markdown
> This is a quoted block of text.
> Useful for callouts or highlighting important information.
```

<br>

<a id="tables"></a>

## 📊 Tables

> *PipePub automatically converts markdown tables to GitHub Gists for proper rendering.*

**Standard markdown table:**

```markdown
| Feature | Status | Notes |
|---------|--------|-------|
| Markdown | ✅ Supported | Full markdown support |
| Tables | ✅ Converted | Auto-converted to Gists |
| Images | ✅ Supported | Use raw GitHub URLs |
```

**How table conversion works:**

1. PipePub detects tables in your markdown
2. Creates a GitHub Gist for each table
3. Replaces the table with an embedded Gist
4. Your table is now SEO-friendly and properly formatted on all platforms

**Requirements for table conversion:**
- `GH_PAT_GIST_TOKEN` secret configured with `gist` scope
- Or set `gist: false` in frontmatter to keep tables as plain markdown

<br>

<a id="images"></a>

## 🖼️ Images

> *Use absolute GitHub raw URLs for images that work everywhere.*

### Image syntax

```markdown
![Description](https://raw.githubusercontent.com/<username>/<repository>/main/images/photo.png)
```

### Using the `images/` folder

1. Add your images to the `images/` folder in your repository
2. Commit and push them to GitHub
3. Use the raw URL in your markdown

**Example workflow:**

```bash
# Add image to images folder
cp my-photo.png images/

# Commit and push
git add images/my-photo.png
git commit -m "Add article image"
git push origin main
```

**Raw URL format:**

```
https://raw.githubusercontent.com/<your-username>/<your-repo>/main/images/my-photo.png
```

<br>

<a id="platform-specific-tag-rules"></a>

## 🔧 Platform-specific tag rules

> *Each platform handles tags differently. Here's what you need to know.*

### Comparison table

| Platform | Max Tags | Allowed Characters | Space Handling | Underscore `_` | Hyphen `-` | Length Limit | Case |
|----------|----------|-------------------|----------------|----------------|------------|--------------|------|
| **DEV.to** | 4 | Alphanumeric only (a-z, 0-9) | Removed | Removed | Removed | 2-30 chars | Lowercase |
| **Hashnode** | 5 | Alphanumeric + `_` + `-` | Converted to `_` | Kept (name), `_` → `-` (slug) | Kept | No explicit limit | Preserved |
| **Medium** | 5 | Alphanumeric + `_` + `-` | Converted to `-` | Converted to `-` | Kept | 1-25 chars | Lowercase (converted) |

### Tag conversion examples

| Original Tag | DEV.to | Hashnode | Medium |
|--------------|--------|----------|--------|
| `cloud computing` | `cloudcomputing` | `cloud_computing` | `cloud-computing` |
| `github-actions` | `githubactions` | `github-actions` | `github-actions` |
| `CI/CD` | `cicd` | `cicd` | `cicd` |
| `test_tag` | `testtag` | `test_tag` | `test-tag` |
| `áéíóú` | `aeiou` | `aeiou` | `aeiou` |
| `c#` | `c` | `c` | `c` |

### Platform-specific notes

#### DEV.to
- **Most restrictive** - Only alphanumeric characters allowed
- Removes all special characters including spaces, underscores, and hyphens
- Converts multi-word tags to single words: `"cloud computing"` → `"cloudcomputing"`
- Maximum 4 tags per article

#### Hashnode
- **Most flexible** - Preserves underscores and hyphens
- Converts spaces to underscores for tag names
- Creates URL-friendly slugs by converting underscores to hyphens
- Supports up to 5 tags

#### Medium
- **Moderate** - Allows hyphens but converts underscores
- Replaces spaces with hyphens: `"cloud computing"` → `"cloud-computing"`
- Replaces underscores with hyphens: `"test_tag"` → `"test-tag"`
- Maximum 5 tags with 25 character limit per tag

### Best practices for cross-platform tags

To ensure your tags work well across all platforms:

1. **Use alphanumeric characters** whenever possible
2. **Avoid spaces** - use hyphens or underscores instead: `cloud-computing`
3. **Keep tags short** - under 25 characters
4. **Limit to 4 tags** - works everywhere (DEV.to max)
5. **Use lowercase** for consistency

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Quick Start](https://pipepub.github.io/cdn/image/badge/doc/quickstart.svg)](/docs/basics/quickstart.md "Quick Start guide")
[![Settings](https://pipepub.github.io/cdn/image/badge/doc/settings.svg)](/docs/basics/settings.md "Settings guide")
[![FAQ](https://pipepub.github.io/cdn/image/badge/doc/faq.svg)](/docs/basics/faq.md "FAQ")