---
tags: delete me, auto, test, dev op, draft, pipeline
publisher: devto, hashnode, medium
gist: true
title: PipePub Test Article
subtitle: Publish like a PRO 
image: https://raw.githubusercontent.com/pipepub/pipepub/main/docs/assets/img/publish-like-a-pro-hero.jpg
status: draft
auto: true
---

[![PipeHub](https://raw.githubusercontent.com/pipepub/pipepub/main/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub)

## It Works!

[PipePub](https://github.com/pipepub "PipePub - Publish like a PRO") is an open-source GitHub Actions pipeline that turns your **markdown files into published articles** on all major content distribution platforms, with tags, tables, and image support.

## Features

| Feature | Description |
|---------|-------------|
| **Automatization** | Auto or manual publish modes |
| **Frontmatter** | YAML metadata support |
| **Tag sanitization** | Normalization platform-specific rules |
| **Gist tables** | Convert tables to embedded gists |
| **Multi-platform** | Dev.to + Hashnode + Medium support |
| **Flexible** | Use a GitHub repo and/or your local enviroment |
| **Open source** | Use freely, use as template, modify, and share. |

<hr>

### 📌 Frontmatter Reference

| Field | Values | Default | Description |
|-------|--------|---------|-------------|
| `tags` | string | n/a | Article tags (max 4 for Dev.to, 5 for Medium) |
| `publisher` | `devto`, `hashnode`, `medium` | all platforms | Which platforms to publish to |
| `gist` | `true`, `false` | `true` | Convert tables to GitHub Gists |
| `image` | string | n/a | Article cover image url |
| `status` | `draft`, `public` | `draft` | Publish as draft or public |
| `auto` | `true`, `false` | `true` | Automatically publish on push (false = manual trigger only) |

<hr>

### Optional Frontmatter example

```yaml
---
tags: tag1, tag2, tag3, tag4, tag5
publisher: devto, hashnode, medium
gist: true
image: https://<image-url>
status: draft
auto: true
---

# Article title

Rest of your article content.
```

<hr>

### Code Example

```bash
#!/bin/bash
cp docs/test-post.md posts/test-post.md
git add posts/test-post.md
git push origin main
```

<hr>

*For writers who want to focus on content, not formatting.*

---

[![PipeHub - Publish like a PRO](https://raw.githubusercontent.com/pipepub/pipepub/main/docs/assets/img/icon.png)](https://github.com/pipepub)

*Made with ❤️ by [Joseba Mirena](https://www.josebamirena.com)*
