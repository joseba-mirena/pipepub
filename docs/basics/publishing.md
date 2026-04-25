[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Publishing Methods

> *All the ways to publish your articles — no terminal required*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![publishing](https://img.shields.io/badge/DOC-publishing-white)](/docs/basics/publishing.md "Publishing methods") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🌐 Method 1: Upload your article](#method-1-upload-your-article) |
| [✏️ Method 2: Create your article on GitHub](#method-2-create-your-article-on-github) |
| [⏰ When is your article published?](#when-is-your-article-published) |
| [⚙️ Total control: auto + status](#total-control-auto--status) |

</details>

---

<br>

<a id="method-1-upload-your-article"></a>

## 🌐 Method 1: Upload your article

> *Best if you already wrote your article in a markdown editor.*

**Step 1:** Go to your repository on GitHub

**Step 2:** Navigate to the `posts/` folder

**Step 3:** Click **"Add file"** → **"Upload files"**

```text
posts/
├── .gitkeep
└── (drag your files here)
```

**Step 4:** Drag and drop your `.md` file(s)

**Step 5:** Scroll down and click **"Commit changes"**

**That's it!** If `auto: true` (default), your article publishes automatically in less than a minute.

📖 **[Article format guide →](/docs/basics/markdown.md)**

<br>

<a id="method-2-create-your-article-on-github"></a>

## ✏️ Method 2: Create your article on GitHub

> *Best if you want to write directly in your browser — no external editor needed.*

**Step 1:** Go to your repository → `posts/` folder

**Step 2:** Click **"Add file"** → **"Create new file"**

**Step 3:** Name your file (e.g., `my-article.md`)

**Step 4:** Add frontmatter (optional) and your content:

```markdown
---
tags: technology, github, automation
---

# My Article Title

Your content goes here...
```

**Step 5:** Click **"Commit changes"**

**That's it!** If `auto: true` (default), your article publishes automatically in less than a minute.

> 💡 **Tip:** GitHub provides a live markdown preview — click the **"Preview"** tab while writing.

📖 **[Full markdown guide →](/docs/basics/markdown.md)**

<br>

<a id="when-is-your-article-published"></a>

## ⏰ When is your article published?

> *Control if publishing happens automatically or manually.*

| Setting | Behavior |
|---------|----------|
| `auto: true` (default) | Article publishes automatically when you upload or create it |
| `auto: false` | Article sits in `posts/` — you must publish it manually via Actions tab |

### How to manually publish (when `auto: false`)

**Step 1:** Go to the **Actions** tab in your repository

**Step 2:** Click on the **"Publish post(s)"** workflow on the left

**Step 3:** Click the **"Run workflow"** button on the right

**Step 4:** Enter the filenames you want to publish:

```text
article1.md article2.md article3.md
```

**Step 5:** Click **"Run workflow"**

The selected articles will be published in less than a minute.

> 💡 **Note:** You only need to enter the filename, not the full path (e.g., `my-article.md`, not `posts/my-article.md`)

<br>

<a id="total-control-auto--status"></a>

## ⚙️ Total control: `auto` + `status`

> *Combine these two frontmatter settings for complete control over your publishing workflow.*

| Setting | Values | What it controls |
|---------|--------|------------------|
| **`auto`** | `true` (default) or `false` | **When** to publish: automatically on push, or manually via Actions tab |
| **`status`** | `draft` (default) or `public` | **How** to publish: as a draft for review, or live immediately |

### All possible combinations

| `auto` | `status` | Result |
|--------|----------|--------|
| `true` (default) | `draft` (default) | ✅ Auto-publishes as DRAFT — review on platform before going live |
| `true` (default) | `public` | ✅ Auto-publishes as PUBLIC — goes live immediately |
| `false` | `draft` (default) | ⏸️ Sits in `posts/` (no publish) — use manual trigger when ready |
| `false` | `public` | ⏸️ Sits in `posts/` (no publish) — use manual trigger to publish as public |

### Example frontmatter

```yaml
---
auto: false
status: draft
---
```

This gives you **total control**:
- Article won't publish automatically
- When you manually trigger, it will appear as a draft
- Review on the platform, then publish when ready

📖 **[Full frontmatter reference →](/docs/basics/markdown.md#frontmatter)**

<br>

---

> 💻 **For power users:** Prefer the command line? See [CLI Publishing Methods](/docs/advanced/commands.md#git-push-publishing)

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Quick Start](https://img.shields.io/badge/DOC-quickstart-white)](/docs/basics/quickstart.md "Quick Start guide")
[![Markdown](https://img.shields.io/badge/DOC-markdown-white)](/docs/basics/markdown.md "Markdown guide")
[![Settings](https://img.shields.io/badge/DOC-settings-white)](/docs/basics/settings.md "Settings guide")