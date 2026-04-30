<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### FAQ - Frequently Asked Questions

> *Common questions and troubleshooting solutions*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![faq](https://pipepub.github.io/cdn/image/badge/doc/faq.svg)](/docs/basics/faq.md "FAQ document") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [📋 General questions](#general-questions) |
| [🔑 Secrets & tokens](#secrets--tokens) |
| [📝 Publishing issues](#publishing-issues) |
| [🖼️ Cover images](#cover-images) |
| [🔍 Logs & debugging](#logs--debugging) |
| [🧪 Testing](#testing) |
| [🛠️ Development](#development) |
| [⚙️ Platform-specific](#platform-specific) |

</details>

---

<br>

<a id="general-questions"></a>

## 📋 General questions

<br>

### ❓ What is PipePub?

PipePub is an open-source GitHub Actions pipeline that automatically publishes markdown articles to DEV.to, Ghost, Hashnode, Medium, and other platforms — with support for tags, tables, and images.

<br>

### ❓ How much this cost?

**100% FREE**. PipeHub is open source and GitHub accounts are also free.

We kindly ask that you consider making a financial contribution to support this project.

<br>

### ❓ Do I need to install anything?

![PipePub GitHub use template](https://pipepub.github.io/cdn/image/screenshot/pipepub-github-use-template.png "PipePub GitHub use template")

**No.** If you only use the GitHub Actions workflow (the template), you don't need to install anything locally. Just add your secrets and push markdown files.

**For local development** (power users), you'll need Bash 4+, git, curl, jq, and openssl.

<br>

### ❓ Why are GitHub Actions disabled after I fork the repository?

If you just use PipeHub, **we recommend you to use the repositoy as template**.

If you pretend to contribute to PipeHub, we recommend you to fork the repositoy.

**GitHub disables Actions on forked repositories** by default for security. This prevents malicious code from running automatically in forks.

**To enable Actions:**

1. Go to your repository **Settings** → **Actions** → **General**
2. Under "Actions permissions", select **"Allow all actions and reusable workflows"**
3. Click **Save**

Once enabled, your pipeline will run automatically when you push articles to the `posts/` folder.

📖 **[GitHub documentation →](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-your-repository)**

<br>

### ❓ Which platforms are supported?

| Platform | Status |
|----------|--------|
| DEV.to | ✅ Live |
| Ghost | ✅ Live |
| Hashnode | ✅ Live |
| Medium | ✅ Live (Legacy token) |

**Coming soon:** WordPress support.

**On roadmap:** OAuth for Medium, LinkedIn and X twitter.

<br>

### ❓ Is Medium API still available?

**Currently, just legacy tokens.** Medium no longer issues new API tokens as of 2026. The `MEDIUM_TOKEN` secret **only works if you already have a legacy integration token**.

**However, OAuth support is on the roadmap!** Once implemented, new users will be able to authenticate via OAuth and publish to Medium without a legacy token.

📖 **[Full Medium guide →](/docs/services/medium.md)** (includes OAuth progress updates)

<br>

### ❓ When will Wordpress be supported?

**Wordpress integration is coming soon (short term).** 

We're actively working on Wordpress API support. Once live, you'll be able to publish to Wordpress using an API token.

We'll support both WordPress.com (via API) and self-hosted (via Application Passwords). Stay tuned for updates.

📖 Check the [services documentation](/docs/INDEX.md#services) for updates.

<br>

### ❓ Will LinkedIn and X twitter be supported?

**Yes, LinkedIn and X twitter integrations are planned (medium term).**

We'll support both LinkedIn and X twitter. Stay tuned for updates.

📖 Watch the [repository](https://github.com/pipepub/pipepub) for announcements.

<br>

<a id="secrets--tokens"></a>

## 🔑 Secrets & tokens

<br>

### ❓ Where do I add my API tokens?

![GitHub repository secret](https://pipepub.github.io/cdn/image/screenshot/github-repository-secret-thumb.jpg "GitHub repository secret")

Go to your repository: `Settings` → `Secrets and variables` → `Actions` → `Repository secrets` → `New repository secret`

<br>

### ❓ Which secrets do I need?

| Secret | Required for | Optional? |
|--------|--------------|-----------|
| `DEVTO_TOKEN` | DEV.to publishing | ✅ Yes |
| `GHOST_TOKEN` | Ghost publishing | ✅ Yes |
| `GHOST_DOMAIN` | Ghost publishing | ✅ Yes |
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

### ❓ How do I publish an article?

![GitHub upload or create file](https://pipepub.github.io/cdn/image/screenshot/github-upload-create-file.jpg "GitHub upload or create file")

1. Go to your [`posts/`](/posts/) folder.
2. Upload or write (save when finished) your article (`*.md` extension).

That is it!

📖 **[All publishing methods →](/docs/basics/publishing.md)**

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

By default, all services publish as **draft**. This lets you review before publishing publicly.

**Priority order (highest to lowest):**
1. Frontmatter `status` (per article)
2. Service default (`.github/config/services/*.conf`)

To change to public:

- **Per article**: Add `status: public` to frontmatter
- **Globally**: Modify `SERVICE_DEFAULT_STATUS` in `.github/config/services/*.conf`

Example frontmatter:

```yaml
---
status: public
---
```

📖 **[Frontmatter guide →](/docs/basics/markdown.md#frontmatter)**

<br>

### ❓ My tables aren't showing up properly.

PipePub automatically converts markdown tables to GitHub Gists. This requires:

1. `GH_PAT_GIST_TOKEN` secret configured with `gist` scope
2. Table written in standard markdown format

If Gist conversion fails, or it is set to false, the table will remain as plain markdown (which many platforms don't support).

<br>

### ❓ Everything works perfectly, but where are my tables?!

Each publishing platform handles tables differently. Here's what you need to know:

- **DEV.to**: If your article is published as a draft, you may need to open the draft and save it (or publish it publicly) for tables to render correctly. Public articles should display tables immediately.
- **Ghost**: Tables may not appear until you preview the draft.
- **Hashnode**: Tables may not appear until you publish the post publicly. Draft mode may not render embedded Gists.
- **Medium**: Tables are converted to GitHub Gists. Ensure `GH_PAT_GIST_TOKEN` is configured and the Gist is publicly accessible.

> **Tip:** Always preview your published article after going live to confirm tables render as expected.

<br>

### ❓ My tags aren't appearing correctly.

Each platform has different tag rules:

| Platform | Max tags | Spaces | Special chars |
|----------|----------|--------|---------------|
| DEV.to | 4 | Removed | Removed |
| Ghost | 5 | → `-` | Only `-` allowed (alphanumeric + hyphen) |
| Hashnode | 5 | → `_` | `_` and `-` allowed |
| Medium | 5 | → `-` | `-` allowed, `_` → `-` |

📖 **[Full tag rules →](/docs/basics/markdown.md#platform-specific-tag-rules)**

<br>

<a id="cover-images"></a>

## 🖼️ Cover images

<br>

### ❓ How do I add a cover image to my article?

Add `image` to your frontmatter:

```yaml
---
title: My Article
image: https://example.com/cover.jpg
---
```

PipePub handles the rest automatically for all supported platforms.

<br>

### ❓ My cover image doesn't appear on Hashnode

**Hashnode's API does not support a dedicated `coverImage` field.** However, PipePub automatically embeds your cover image as the first element in the article content. Hashnode then detects the first image and uses it as the cover.

**Checklist:**

1. Is the image URL publicly accessible via HTTPS?
2. Is the image URL correctly set in frontmatter as `image` (aliases: `cover_image`, `cover`, `hero`)?
3. Check that the image URL is not blocked or requiring authentication

📖 **[Hashnode cover image guide →](/docs/services/hashnode.md#cover-images)**

<br>

<a id="logs--debugging"></a>

## 🔍 Logs & debugging

<br>

### ❓ Where can I find logs?

| Log type | Location | When created |
|----------|----------|--------------|
| Workflow logs | GitHub Actions tab → click failed run | Every run |
| Pipeline debug | `.tmp/pipepub_*.log` | When `LOG_LEVEL=debug` |
| Test output | `.logs/test_*.log` | After running tests |
| Dry run report | `.reports/dry-run-*.json` | After dry run |

<br>

### ❓ How do I enable debug mode?

Add to your repository secrets or environment:

```text
LOG_LEVEL=debug
LOG_OUTPUT=both
```

Or run locally:

```bash
LOG_LEVEL=debug ./tools/pipepub.sh publish
```

📖 **[Debugging guide →](/docs/advanced/environment.md#debugging)**

<br>

<a id="testing"></a>

## 🧪 Testing

<br>

### ❓ How do I run tests locally?

```bash
# Run all tests
./tools/tests/run.sh

# Run quick tests (unit + integration)
./tools/tests/run.sh --quick

# Run dev tests with service overlay
./tools/tests/run.sh --dev

# Update snapshots
./tools/tests/run.sh --update-snapshots
```

📖 **[Test suite documentation →](/docs/advanced/tests.md)**

<br>

### ❓ How do I run only specific types of tests?

Use test tags with environment variables:

```bash
# Run only unit tests
TEST_TAG_INCLUDE=unit ./tools/tests/run.sh

# Exclude slow tests
TEST_TAG_EXCLUDE=slow ./tools/tests/run.sh
```

Built-in tags: `unit`, `integration`, `e2e`, `fast`, `smoke`

📖 **[Test tagging →](/docs/advanced/tests.md#test-tagging)**

<br>

### ❓ My API payload tests are failing after an update

When you change API payload structure, snapshots need updating:

```bash
# Update all snapshots
./tools/tests/run.sh --update-snapshots

# Update specific test
./tools/tests/unit/test_devto_api.sh --update-snapshots
```

📖 **[Snapshot management →](/docs/advanced/tests.md#snapshot-management)**

<br>

### ❓ How are tests run in GitHub Actions?

| Trigger | Command | Duration |
|---------|---------|----------|
| Pull Request | `./tools/tests/run.sh --quick` | ~2 min |
| Push to main | `./tools/tests/run.sh --debug` | ~5 min |

All test artifacts (logs, reports) are uploaded for debugging.

📖 **[CI integration →](/docs/advanced/infra.md#ci-test-workflow)**

<br>

### ❓ What information is included in test logs?

When running `./tools/tests/run.sh`, you'll see:

- System information (OS, Kernel, Bash version)
- Environment configuration (LOG_LEVEL, DRY_RUN, CI)
- Test execution details (TAP output)
- Debug log file path

<br>

<a id="development"></a>

## 🛠️ Development

<br>

### ❓ How do I develop a new platform integration?

PipePub supports development overlays without modifying production files.

> **Example:** See `docs/assets/example/dev/service/` for a complete working example (Ghost service).

1. Create `tools/config/registry-dev.conf`:

```text
myservice|myservice.sh|MYSERVICE_TOKEN
```

2. Create `tools/config/services-dev/myservice.conf` with configuration:

```bash
SERVICE_DISPLAY="My Service"
SERVICE_AUTH_TYPE="Bearer"
SERVICE_ENDPOINT="https://api.myservice.com/posts"
SERVICE_HANDLER_FUNC="publish_to_myservice"
SERVICE_MAX_TAGS=5
```

3. Create `tools/handlers-dev/myservice.sh` with the publish function.

4. Create `tools/tests/dev/test_myservice_dev.sh` with tests.

5. Run tests with `--dev` flag to validate:

```bash
./tools/tests/run.sh --dev
```

📖 **[Example files →](/docs/assets/example/dev/service/)**

📖 **[Service loading guide →](/docs/advanced/tools.md#service-loading)**

<br>

### ❓ How do I test my development service?

Create a test file in `tools/tests/dev/`:

```bash
# tools/tests/dev/test_myservice_dev.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

run_tests() {
    # Your test logic here
    assert_equals "expected" "actual" "test passes"
}

run_tests
```

Then run:

```bash
./tools/tests/run.sh --dev --filter=test_myservice_dev.sh
```

📖 **[Dev test mode →](/docs/advanced/tests.md#dev-test-mode)**

<br>

<a id="platform-specific"></a>

## ⚙️ Platform-specific

<br>

### ❓ DEV.to: How do I get my API token?

1. Go to [DEV.to Settings → Extensions](https://dev.to/settings/extensions)
2. Click "Generate API key"
3. Copy the key and add as `DEVTO_TOKEN` secret

📖 **[Full DEV.to guide →](/docs/services/devto.md)**

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

### ❓ Wordpress: When will it be supported?

**Wordpress integration is coming soon (short term).** 

We're actively working on Wordpress API support. Once live, you'll be able to publish to Wordpress using an API token.

We'll support both WordPress.com (via API) and self-hosted (via Application Passwords). Stay tuned for updates.

📖 Check the [services documentation](/docs/INDEX.md#services) for updates.

<br>

### ❓ LinkedIn and X Twitter: Will they be supported?

**Yes, LinkedIn and X Twitter integration are planned (medium term).**

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
| Wordpress integration | 🔜 Short term |
| Medium OAuth | 📝 Medium term |
| LinkeIn OAuth | 📝 Medium term |
| X Twitter OAuth | 📝 Medium term |
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

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Quick Start](https://pipepub.github.io/cdn/image/badge/doc/quickstart.svg)](/docs/basics/quickstart.md "Quick Start guide")
[![Publishing](https://pipepub.github.io/cdn/image/badge/doc/publishing.svg)](/docs/basics/publishing.md "Publishing methods")
[![Markdown](https://pipepub.github.io/cdn/image/badge/doc/markdown.svg)](/docs/basics/markdown.md "Markdown guide")
[![Settings](https://pipepub.github.io/cdn/image/badge/doc/settings.svg)](/docs/basics/settings.md "Settings guide")
[![Security](https://pipepub.github.io/cdn/image/badge/doc/security.svg)](/docs/SECURITY.md "Security policy")
[![Support](https://pipepub.github.io/cdn/image/badge/doc/support.svg)](/docs/SUPPORT.md "Support guide")