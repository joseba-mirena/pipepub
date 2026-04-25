[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Quick Start

> *Get PipePub up and running in 5 minutes — no terminal required*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![quickstart](https://img.shields.io/badge/DOC-quickstart-white)](/docs/basics/quickstart.md "Quick Start document") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🚀 Create your copy](#create-your-copy) |
| [🔑 Add your secrets](#add-your-secrets) |
| [🌐 Upload your article](#upload-your-article) |
| [📋 Publishing modes](#publishing-modes) |
| [📝 Write your article](#write-your-article) |

</details>

---

<br>

<a id="create-your-copy"></a>

## 🚀 Create your copy

> *Start by creating your own repository from the template.*

1. Go to the [PipePub repository](https://github.com/pipepub/pipepub)
2. Click the **"Use this template"** button (top right)
3. Select **"Create a new repository"**
4. Choose your repository name and settings
5. Click **"Create repository from template"**

<br>

<a id="add-your-secrets"></a>

## 🔑 Add your secrets

> *Configure API tokens for the platforms you want to publish to.*

**Navigate to:** `Settings` → `Secrets and variables` → `Actions` → `Repository secrets`

Click **"New repository secret"** and add any of the following (only add the platforms you use):

| Secret | Platform | Required for |
|--------|----------|--------------|
| `DEVTO_TOKEN` | Dev.to | Publishing to Dev.to |
| `HASHNODE_TOKEN` | Hashnode | Publishing to Hashnode |
| `HASHNODE_PUBLICATION_ID` | Hashnode | Publishing to Hashnode |
| `MEDIUM_TOKEN` | Medium | Publishing to Medium (legacy only) |
| `GH_PAT_GIST_TOKEN` | GitHub | Table-to-Gist conversion (optional) |

📖 **[Detailed platform setup guides →](/docs/INDEX.md#services)**

<br>

<a id="upload-your-article"></a>

## 🌐 Upload your article

> *Publish your article — no terminal, no git commands.*

**Step 1:** Go to your repository on GitHub

**Step 2:** Navigate to the `posts/` folder

**Step 3:** Click **"Add file"** → **"Upload files"**

**Step 4:** Drag and drop your `.md` file(s)

**Step 5:** Scroll down and click **"Commit changes"**

**That's it!** Your article will be published to your configured platforms within 1-2 minutes.

> ✏️ **Don't have an article yet?** [Write it on GitHub!](#write-your-article)

---

> 💻 **Prefer the command line?** See [CLI Publishing Methods](/docs/advanced/commands.md#git-push)

<br>

<a id="publishing-modes"></a>

## 📋 Publishing modes

| Mode | How to trigger | Best for |
|------|----------------|----------|
| **Automatic** | Upload to `posts/` folder | Regular publishing workflow |
| **Manual** | Actions tab → "Publish post(s)" → "Run workflow" | Testing, re-publishing, selective publishing |

📖 **[All publishing methods explained →](/docs/basics/publishing.md)**

<br>

<a id="write-your-article"></a>

## 📝 Write your article

> *Create a markdown file directly on GitHub.*

**Step 1:** Go to your repository → `posts/` folder

**Step 2:** Click **"Add file"** → **"Create new file"**

**Step 3:** Name your file (e.g., `my-article.md`)

**Step 4:** Add frontmatter and content:

```markdown
---
tags: technology, github, automation
---

# Your Awesome Title

Your content goes here...
```

**Step 5:** Click **"Commit changes"**

📖 **[Full article format guide →](/docs/basics/markdown.md)**

<br>

<a id="next-steps"></a>

## 🎯 Next steps

| You want to... | Read this |
|----------------|-----------|
| Learn article formatting | [Markdown Guide](/docs/basics/markdown.md) |
| Configure pipeline settings | [Settings Guide](/docs/basics/settings.md) |
| Troubleshoot issues | [FAQ](/docs/basics/faq.md) |
| Use CLI / local tools | [Environment Setup](/docs/advanced/environment.md) |

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Markdown](https://img.shields.io/badge/DOC-markdown-white)](/docs/basics/markdown.md "Markdown guide")
[![Settings](https://img.shields.io/badge/DOC-settings-white)](/docs/basics/settings.md "Settings guide")
[![FAQ](https://img.shields.io/badge/DOC-faq-white)](/docs/basics/faq.md "FAQ")
[![Publishing](https://img.shields.io/badge/DOC-publishing-white)](/docs/basics/publishing.md "All publishing methods")