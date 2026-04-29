<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Infrastructure & CI/CD Guide

> *Set up PipePub in continuous integration and deployment pipelines*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![infra](https://pipepub.github.io/cdn/image/badge/doc/infra.svg)](/docs/advanced/infra.md "Infrastructure guide") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [📋 GitHub Actions workflow](#github-actions-workflow) |
| [🔧 Workflow triggers](#workflow-triggers) |
| [🔑 Secrets configuration](#secrets-configuration) |
| [📊 CI test workflow](#ci-test-workflow) |
| [📤 Artifact uploads](#artifact-uploads) |
| [🔄 Other CI systems](#other-ci-systems) |

</details>

---

<br>

<a id="github-actions-workflow"></a>

## 📋 GitHub Actions workflow

> *PipePub includes a pre-configured GitHub Actions workflow for automatic publishing.*

### Workflow file location

```text
.github/workflows/pipepub.yml
```

### Publish workflow (`pipepub.yml`)

```yaml
name: Publish post(s)

on:
  push:
    paths:
      - 'posts/**/*.md'
    branches:
      - main
      - master
  workflow_dispatch:
    inputs:
      filenames:
        description: 'Filenames to publish (space-separated)'
        required: false
        type: string

jobs:
  publish:
    runs-on: ubuntu-latest
    name: Publish to Platforms
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 2

      - name: Check files to post
        run: |
          # Lists files in posts/ folder

      - name: Run PipePub pipeline
        env:
          GH_PAT_GIST_TOKEN: ${{ secrets.GH_PAT_GIST_TOKEN }}
          DEVTO_TOKEN: ${{ secrets.DEVTO_TOKEN }}
          HASHNODE_TOKEN: ${{ secrets.HASHNODE_TOKEN }}
          HASHNODE_PUBLICATION_ID: ${{ secrets.HASHNODE_PUBLICATION_ID }}
          MEDIUM_TOKEN: ${{ secrets.MEDIUM_TOKEN }}
          PUBLISHER_LANG: ${{ vars.PUBLISHER_LANG || 'en-us' }}
          PUBLISHER_GIST: ${{ vars.PUBLISHER_GIST || 'true' }}
          DEBUG: ${{ vars.DEBUG || 'false' }}
          MANUAL_FILENAMES: ${{ github.event.inputs.filenames }}
        run: .github/scripts/main.sh

      - name: Upload processing logs
        if: always()
        uses: actions/upload-artifact@v6
        with:
          name: publish-logs
          path: .tmp/
          retention-days: 7

      - name: Notify result
        if: always()
        run: |
          if [ "${{ job.status }}" == "success" ]; then
            echo "✅ Publishing like a PRO!"
            echo "📎 Full log: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
          else
            echo "❌ Pipeline failed!"
            echo "🔍 Check log: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
          fi
```

<br>

<a id="workflow-triggers"></a>

## 🔧 Workflow triggers

> *Two ways to trigger the publishing workflow.*

### Automatic trigger (push)

| Condition | Behavior |
|-----------|----------|
| **Files changed** | Any `.md` file in `posts/` folder |
| **Branches** | `main` or `master` |
| **Result** | Workflow runs automatically |

### Manual trigger (workflow_dispatch)

1. Go to **Actions** tab
2. Select **"Publish post(s)"**
3. Click **"Run workflow"**
4. Enter filenames (space-separated, without `posts/` prefix)
5. Click **"Run workflow"**

```text
article1.md article2.md article3.md
```

<br>

<a id="secrets-configuration"></a>

## 🔑 Secrets configuration

> *Add API tokens as repository secrets.*

### Location

`Settings` → `Secrets and variables` → `Actions` → `Repository secrets`

### Required secrets (by platform)

| Secret | Platform | Required for |
|--------|----------|--------------|
| `DEVTO_TOKEN` | DEV.to | Publishing to DEV.to |
| `HASHNODE_TOKEN` | Hashnode | Publishing to Hashnode |
| `HASHNODE_PUBLICATION_ID` | Hashnode | Publishing to Hashnode |
| `MEDIUM_TOKEN` | Medium | Publishing to Medium (legacy) |
| `GH_PAT_GIST_TOKEN` | GitHub | Table-to-Gist conversion |

### Optional variables

`Settings` → `Secrets and variables` → `Actions` → `Variables`

| Variable | Values | Default | Description |
|----------|--------|---------|-------------|
| `PUBLISHER_LANG` | `en-us`, `es-es`, etc. | `en-us` | Language/locale |
| `PUBLISHER_GIST` | `true`, `false` | `true` | Table-to-Gist conversion |
| `DEBUG` | `true`, `false` | `false` | Enable verbose logging |

### Service defaults configuration

Default publish status and auto-publish behavior are configured per service in:

```text
.github/config/services/devto.conf      # SERVICE_DEFAULT_STATUS="draft"
.github/config/services/hashnode.conf   # SERVICE_DEFAULT_AUTO="true"
.github/config/services/medium.conf     # SERVICE_DEFAULT_STATUS="draft"
```

These files are committed to your repository and can be changed via pull request. Frontmatter in individual articles overrides these defaults.

📖 **[Secrets guide →](/docs/basics/settings.md#github-secrets)**

<br>

<a id="ci-test-workflow"></a>

## 📊 CI test workflow

> *Automated testing on pull requests and merges.*

### Test workflow file

```text
.github/workflows/ci.yml
```

### Workflow structure

```yaml
name: CI Tests

on:
  pull_request:
    branches: [main, master]
    paths-ignore:
      - '**.md'
      - 'docs/assets/**'
      - 'images/**'
  push:
    branches: [main, master]
    paths-ignore:
      - '**.md'
      - 'docs/assets/**'
      - 'images/**'

env:
  DRY_RUN: true
  CI: true
  LOG_LEVEL: debug
  LOG_OUTPUT: both

jobs:
  quick-tests:
    name: Quick Tests (PR)
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v6
      - name: Run quick test suite
        run: ./tools/tests/run.sh --quick
      - name: Upload test logs
        if: always()
        uses: actions/upload-artifact@v6
        with:
          name: test-artifacts-pr
          path: |
            .logs/
            .reports/
          retention-days: 3

  full-tests:
    name: Full Tests (Merge)
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master')
    steps:
      - uses: actions/checkout@v6
      - name: Run full test suite
        run: ./tools/tests/run.sh --debug
      - name: Upload test logs
        if: always()
        uses: actions/upload-artifact@v6
        with:
          name: test-artifacts-merge
          path: |
            .logs/
            .reports/
          retention-days: 7
```

### Test behavior by trigger

| Trigger | Job | DRY_RUN | CI flag | API calls |
|---------|-----|---------|---------|-----------|
| **Pull Request** | `quick-tests` | `true` | `true` | ❌ No (mocked) |
| **Push to main/master** | `full-tests` | `true` | `true` | ❌ No (mocked) |
| **Manual publish** | `publish` | `false` | `false` | ✅ Yes (real) |

📖 **[Test suite documentation →](/docs/advanced/tests.md)**

<br>

<a id="artifact-uploads"></a>

## 📤 Artifact uploads

> *Capture logs and reports for debugging.*

### Publish workflow artifacts

| Artifact name | Path | Retention | Contents |
|---------------|------|-----------|----------|
| `publish-logs` | `.tmp/` | 7 days | Pipeline execution logs |

### CI workflow artifacts

| Artifact name | Path | Retention | Trigger |
|---------------|------|-----------|---------|
| `test-artifacts-pr` | `.logs/`, `.reports/` | 3 days | Pull Request |
| `test-artifacts-merge` | `.logs/`, `.reports/` | 7 days | Push to main |

### Accessing artifacts

1. Go to **Actions** tab
2. Select the workflow run
3. Scroll to **Artifacts** section
4. Click to download

<br>

<a id="other-ci-systems"></a>

## 🔄 Other CI systems

> *PipePub can run in any CI/CD environment that supports Bash.*

### GitLab CI example

```yaml
# .gitlab-ci.yml
publish:
  stage: publish
  image: ubuntu:latest
  before_script:
    - apt-get update && apt-get install -y git curl jq
  script:
    - export DRY_RUN=false
    - export DEVTO_TOKEN=$DEVTO_TOKEN
    - .github/scripts/main.sh
  only:
    - main
```

### Jenkins pipeline example

```groovy
pipeline {
    agent any
    environment {
        DRY_RUN = 'false'
        DEVTO_TOKEN = credentials('devto-token')
    }
    stages {
        stage('Publish') {
            steps {
                sh ```
                    .github/scripts/main.sh
                ```
            }
        }
    }
}
```

### Environment variables required for CI

| Variable | Required for |
|----------|--------------|
| `DEVTO_TOKEN` | DEV.to publishing |
| `HASHNODE_TOKEN` | Hashnode publishing |
| `HASHNODE_PUBLICATION_ID` | Hashnode publishing |
| `MEDIUM_TOKEN` | Medium publishing (legacy) |
| `GH_PAT_GIST_TOKEN` | Table-to-Gist conversion |
| `DRY_RUN` | Test mode (set to `true` for CI tests) |
| `CI` | Set to `true` to disable interactive prompts |

📖 **[Environment variables reference →](/docs/advanced/environment.md)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Environment](https://pipepub.github.io/cdn/image/badge/doc/environment.svg)](/docs/advanced/environment.md "Environment setup")
[![Tests](https://pipepub.github.io/cdn/image/badge/doc/tests.svg)](/docs/advanced/tests.md "Test suite")
[![Commands](https://pipepub.github.io/cdn/image/badge/doc/commands.svg)](/docs/advanced/commands.md "CLI commands")