---
tags: delete me, auto, test, dev op, draft, pipeline
publisher: devto, hashnode, medium
gist: true
title: PipePub Test Article
subtitle: Publish like a PRO 
image: https://pipepub.github.io/cdn/image/hero/publish-like-a-pro.jpg
status: draft
auto: true
---
[![PipeHub](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipePub - Publish like a PRO")

## It Works!

[PipePub](https://github.com/pipepub "PipePub - Publish like a PRO") is an open-source GitHub Actions pipeline that turns your **markdown files into published articles** on all major content distribution platforms, with tags, tables, and image support.

## Features

| Feature | Description |
|---------|-------------|
| **Automatization** | Auto or manual publish modes |
| **Frontmatter** | YAML metadata support |
| **Tag sanitization** | Normalization platform-specific rules |
| **Gist tables** | Convert tables to embedded gists |
| **Multi-platform** | DEV.to + Hashnode + Medium support |
| **Flexible** | Use a GitHub repo and/or your local enviroment |
| **Open source** | Use freely, use as template, modify, and share. |

<hr>

### 📌 Frontmatter Reference

| Field | Values | Default | Description |
|-------|--------|---------|-------------|
| `tags` | string | n/a | Article tags (comma-separated) |
| `publisher` | `devto`, `hashnode`, `medium` | all platforms | Which platforms to publish to |
| `gist` | `true`, `false` | `true` | Convert tables to GitHub Gists |
| `title` | string | n/a | Article title (uses # header if not provided) |
| `subtitle` | string | n/a | Article subtitle |
| `image` | string | n/a | Article cover image url |
| `status` | `draft`, `public` | `draft` | Publish as draft or public |
| `auto` | `true`, `false` | `true` | Automatically publish (false = manual trigger only) |

<hr>

### Article example

```markdown
---
tags: tag1, tag2, tag3, tag4, tag5
publisher: devto, hashnode, medium
gist: true
title: Article title
subtitle: Article subtitle
image: https://pipepub.github.io/cdn/image/hero/publish-like-a-pro.jpg
status: draft
auto: true
---

## My awesome article

Rest of your article content.
```

<hr>

## How it Works?

1. **Use our template** — click "Use this template" on [github.com/pipepub/pipepub](https://github.com/pipepub/pipepub)
2. **Add your API tokens** as GitHub secrets
3. **Write your article** — upload a `.md` file or create one directly on GitHub

**Published** — your article appears on your platforms within seconds. No terminal. No git commands. Just your browser.

<hr>

📖 **[Full Documentation](https://github.com/pipepub/pipepub/blob/main/README.md)**

<hr>

[![PipeHub - Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-left.png)](https://github.com/pipepub "PipePub - Publish like a PRO")

> For writers who want to focus on content, not formatting.


*Made with ❤️ by [Joseba Mirena](https://www.josebamirena.com)*
