[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### FAQ - Frequently Asked Questions

> *Common questions and troubleshooting solutions*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![faq](https://img.shields.io/badge/DOC-faq-white)](/docs/basics/faq.md "FAQ document") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [📋 General questions](#general-questions) |
| [🔑 Secrets & tokens](#secrets--tokens) |
| [📝 Publishing issues](#publishing-issues) |
| [🔍 Logs & debugging](#logs--debugging) |
| [⚙️ Platform-specific](#platform-specific) |

</details>

---

<br>

<a id="general-questions"></a>

## 📋 General questions

<br>

### ❓ What is PipePub?

PipePub is an open-source GitHub Actions pipeline that automatically publishes markdown articles to Dev.to, Hashnode, Medium, and other platforms — with support for tags, tables, and images.

<br>

### ❓ Do I need to install anything?

**No.** If you only use the GitHub Actions workflow (the template), you don't need to install anything locally. Just add your secrets and push markdown files.

**For local development** (power users), you'll need Bash 4+, git, curl, jq, and openssl.

<br>

### ❓ Which platforms are supported?

| Platform | Status |
|----------|--------|
| Dev.to | ✅ Live |
| Hashnode | ✅ Live |
| Medium | ⚠️ Legacy tokens only (OAuth 🔜 Coming soon) |
| GitHub (Gists) | ✅ Live |
| Ghost | 🔜 Coming soon (short term) |
| WordPress | 📝 Planned (medium term) |

**Coming soon:** OAuth for Medium, native Ghost integration, WordPress support.

<br>

### ❓ Is Medium API still available?

**Currently, no.** Medium no longer issues new API tokens as of 2026. The `MEDIUM_TOKEN` secret **only works if you already have a legacy integration token**.

**However, OAuth support is on the roadmap!** Once implemented, new users will be able to authenticate via OAuth and publish to Medium without a legacy token.

📖 **[Full Medium guide →](/docs/services/medium.md)** (includes OAuth progress updates)

<br>

### ❓ When will Ghost be supported?

**Ghost integration is coming soon (short term).** 

We're actively working on Ghost API support. Once live, you'll be able to publish to Ghost using an API token.

📖 Check the [services documentation](/docs/INDEX.md#services) for updates.

<br>

### ❓ Will WordPress be supported?

**Yes, WordPress integration is planned (medium term).**

We'll support both WordPress.com (via API) and self-hosted (via Application Passwords). Stay tuned for updates.

📖 Watch the [repository](https://github.com/pipepub/pipepub) for announcements.

<br>

<a id="secrets--tokens"></a>

## 🔑 Secrets & tokens

<br>

### ❓ Where do I add my API tokens?

![GitHub repository secret](/docs/assets/img/github-repository-secret-thumb.jpg "GitHub repository secret")

Go to your repository: `Settings` → `Secrets and variables` → `Actions` → `Repository secrets` → `New repository secret`

<br>

### ❓ Which secrets do I need?

| Secret | Required for | Optional? |
|--------|--------------|-----------|
| `DEVTO_TOKEN` | Dev.to publishing | ✅ Yes |
| `HASHNODE_TOKEN` | Hashnode publishing | ✅ Yes |
| `HASHNODE_PUBLICATION_ID` | Hashnode publishing | ✅ Yes |
| `MEDIUM_TOKEN` | Medium publishing | ✅ Yes (legacy only) |
| `GH_PAT_GIST_TOKEN` | Table-to-Gist conversion | ✅ Yes |

📖 **[Detailed platform guides →](/docs/INDEX.md#services)**

<br>

### ❓ My token isn't working. What should I check?

1. Verify the token has the correct scopes (for GitHub: `gist` scope)
2. Check that the secret name is exactly correct (case-sensitive)
3. Regenerate the token and update the secret
4. For Hashnode, ensure you also added `HASHNODE_PUBLICATION_ID`

<br>

<a id="publishing-issues"></a>

## 📝 Publishing issues

<br>

### ❓ My article didn't publish. What went wrong?

**Checklist:**

1. Is the file in the `posts/` folder?
2. Does the file have a `.md` extension?
3. Are your secrets correctly configured for the platform?
4. Check the Actions tab for workflow errors
5. Review the workflow logs for specific error messages

📖 **[All publishing methods →](/docs/basics/publishing.md)**

<br>

### ❓ Why is my article a draft instead of public?

By default, `PUBLISHER_STATUS=draft`. This lets you review before publishing publicly.

To change to public, use [Frontmatter](/docs/basics/markdown.md#frontmatter "Frontmatter guide") or update the environment variable in `.github/workflows/pipepub.yml`:

```yaml
PUBLISHER_STATUS: 'public'
```

<br>

### ❓ My tables aren't showing up properly.

PipePub automatically converts markdown tables to GitHub Gists. This requires:

1. `GH_PAT_GIST_TOKEN` secret configured with `gist` scope
2. Table written in standard markdown format

If Gist conversion fails, the table will remain as plain markdown (which many platforms don't support).

<br>

### ❓ Everything works perfectly, but where are my tables?!

Each publishing platform handles tables differently. Here's what you need to know:

- **Dev.to**: If your article is published as a draft, you may need to open the draft and save it (or publish it publicly) for tables to render correctly. Public articles should display tables immediately.
- **Hashnode**: Tables may not appear until you publish the post publicly. Draft mode may not render embedded Gists.
- **Medium**: Tables are converted to GitHub Gists. Ensure `GH_PAT_GIST_TOKEN` is configured and the Gist is publicly accessible.

> **Tip:** Always preview your published article after going live to confirm tables render as expected.

<br>

### ❓ My tags aren't appearing correctly.

Each platform has different tag rules:

| Platform | Max tags | Spaces | Special chars |
|----------|----------|--------|---------------|
| Dev.to | 4 | Removed | Removed |
| Hashnode | 5 | → `_` | `_` and `-` allowed |
| Medium | 5 | → `-` | `-` allowed, `_` → `-` |

📖 **[Full tag rules →](/docs/basics/markdown.md#platform-specific-tag-rules)**

<br>

<a id="logs--debugging"></a>

## 🔍 Logs & debugging

<br>

### ❓ Where can I find logs?

You can download logs and reports from actions artifacts.

| Log type | Location |
|----------|----------|
| Workflow logs | GitHub Actions tab → click failed run |
| Test logs | `.logs/test_run_all_tests_<timestamp>.log` |
| Debug logs | `.tmp/pipepub_<timestamp>.log` |

<br>

### ❓ How do I enable debug mode?

Add to your repository secrets or environment:

```
LOG_LEVEL=debug
LOG_OUTPUT=both
```

Or run locally:

```bash
LOG_LEVEL=debug ./tools/pipepub.sh publish
```

<br>

### ❓ What information is included in test logs?

When running `./tools/tests/run_all_tests.sh`, you'll see:

- System information (OS, Kernel, Bash version)
- Environment configuration (LOG_LEVEL, DRY_RUN, CI)
- Test execution details
- Debug log file path

<br>

<a id="platform-specific"></a>

## ⚙️ Platform-specific

<br>

### ❓ Dev.to: How do I get my API token?

1. Go to [Dev.to Settings → Extensions](https://dev.to/settings/extensions)
2. Click "Generate API key"
3. Copy the key and add as `DEVTO_TOKEN` secret

📖 **[Full Dev.to guide →](/docs/services/devto.md)**

<br>

### ❓ Hashnode: Where do I find my publication ID?

Your publication ID is in your Hashnode dashboard URL after `https://hashnode.com/`.

Example: `https://hashnode.com/your-publication-id`

📖 **[Full Hashnode guide →](/docs/services/hashnode.md)**

<br>

### ❓ Medium: I don't have a legacy token. Can I still publish?

**Currently, no.** Medium closed new API token issuance in 2026. The `MEDIUM_TOKEN` secret only works if you already have a legacy integration token.

**However, OAuth support is on the roadmap!** Once implemented, new users will be able to authenticate via OAuth and publish to Medium without a legacy token.

📖 **[Full Medium guide →](/docs/services/medium.md)** (includes OAuth progress updates)

<br>

### ❓ Ghost: When will it be supported?

**Ghost integration is coming soon (short term).** 

We're actively working on Ghost API support. Once live, you'll be able to publish to Ghost using an API token.

📖 Check the [services documentation](/docs/INDEX.md#services) for updates.

<br>

### ❓ WordPress: Will it be supported?

**Yes, WordPress integration is planned (medium term).**

We'll support both WordPress.com (via API) and self-hosted (via Application Passwords). Stay tuned for updates.

📖 Watch the [repository](https://github.com/pipepub/pipepub) for announcements.

<br>

### ❓ GitHub: Why do I need a token for tables?

PipePub converts markdown tables to GitHub Gists for proper rendering. This requires a Personal Access Token with `gist` scope.

📖 **[Full GitHub guide →](/docs/services/github.md)**

<br>

<a id="roadmap"></a>

### ❓ What's coming next?

| Feature | Status |
|---------|--------|
| Medium OAuth | 🔜 Soon |
| Ghost integration | 🔜 Short term |
| WordPress integration | 📝 Medium term |
| Additional platforms | 📝 Under consideration |

📖 **[Full development roadmap →](/docs/advanced/reference.md#roadmap)**

<br>

<a id="still-need-help"></a>

## 🆘 Still need help?

- 📖 **[Read the full documentation](/docs/README.md)**
- 🐛 **[Open an issue](https://github.com/pipepub/pipepub/issues/new/choose)**
- 💬 **[Start a discussion](https://github.com/pipepub/pipepub/discussions)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Quick Start](https://img.shields.io/badge/DOC-quickstart-white)](/docs/basics/quickstart.md "Quick Start guide")
[![Publishing](https://img.shields.io/badge/DOC-publishing-white)](/docs/basics/publishing.md "Publishing methods")
[![Markdown](https://img.shields.io/badge/DOC-markdown-white)](/docs/basics/markdown.md "Markdown guide")
[![Settings](https://img.shields.io/badge/DOC-settings-white)](/docs/basics/settings.md "Settings guide")
[![Security](https://img.shields.io/badge/DOC-security-white)](/docs/SECURITY.md "Security policy")
[![Support](https://img.shields.io/badge/DOC-support-white)](/docs/SUPPORT.md "Support guide")