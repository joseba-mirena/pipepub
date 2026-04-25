[![Publish like a PRO](/docs/assets/img/pipepub-logo-top-right.jpg)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Test Suite Guide

> *Run, write, and understand PipePub's test suite*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://img.shields.io/badge/Pipe-Pub-red?labelColor=white)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://img.shields.io/badge/pipepub/pipepub-white?labelColor=white "GitHub Repository") |
| **Version** | [![Version](https://img.shields.io/badge/v-1.0.0-green)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![tests](https://img.shields.io/badge/DOC-tests-white)](/docs/advanced/tests.md "Test suite guide") |
| **License** | [![License](https://img.shields.io/badge/license-MIT-yellow)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🚀 Running tests](#running-tests) |
| [📊 Test categories](#test-categories) |
| [📁 Test directory structure](#test-directory-structure) |
| [📝 Test output](#test-output) |
| [🧪 Writing tests](#writing-tests) |
| [🔄 CI integration](#ci-integration) |

</details>

---

<br>

<a id="running-tests"></a>

## 🚀 Running tests

> *Multiple ways to execute the test suite.*

### From interactive menu

```bash
./tools/pipepub.sh test
```

### From command line

| Command | Description |
|---------|-------------|
| `./tools/tests/run_all_tests.sh` | Full test suite (unit + integration + e2e) |
| `./tools/tests/run_all_tests.sh --filter=test_frontmatter.sh` | Run specific test file |
| `./tools/tests/run_all_tests.sh --debug` | Enable debug logging |
| `./tools/tests/run_all_tests.sh --update-snapshots` | Update snapshot files |
| `./tools/tests/run_all_tests.sh --tag=unit` | Run tests with specific tag |
| `./tools/tests/run_all_tests.sh --exclude=slow` | Exclude tests with specific tag |

### Running individual test files

```bash
./tools/tests/unit/test_frontmatter.sh
./tools/tests/unit/test_tags.sh
./tools/tests/unit/test_content.sh
./tools/tests/unit/test_devto_api.sh
./tools/tests/unit/test_hashnode_api.sh
./tools/tests/unit/test_medium_api.sh
./tools/tests/integration/test_multipost.sh
./tools/tests/e2e/run_dry_run.sh
```

<br>

<a id="test-categories"></a>

## 📊 Test categories

> *Different test types for different purposes.*

### Unit tests (`unit/`)

| Test file | What it tests |
|-----------|---------------|
| `test_frontmatter.sh` | YAML frontmatter parsing, field extraction |
| `test_frontmatter_config.sh` | Frontmatter configuration options |
| `test_tags.sh` | Tag sanitization, platform-specific rules |
| `test_content.sh` | Content extraction, H1 title detection |
| `test_devto_api.sh` | Dev.to API payload construction |
| `test_hashnode_api.sh` | Hashnode GraphQL payload construction |
| `test_medium_api.sh` | Medium API payload construction |
| `test_smoke.sh` | Basic smoke tests |

### Integration tests (`integration/`)

| Test file | What it tests |
|-----------|---------------|
| `test_multipost.sh` | Multi-file publishing workflow |
| `test_pipeline_behavior.sh` | End-to-end pipeline behavior |
| `test_gist_integration.sh` | GitHub Gist creation and embedding |

### End-to-end tests (`e2e/`)

| Test file | What it tests |
|-----------|---------------|
| `run_dry_run.sh` | Complete pipeline with mocks (no real API calls) |

<br>

<a id="test-directory-structure"></a>

## 📁 Test directory structure

> *Complete test suite layout.*

```text
tools/tests/
├── run_all_tests.sh           # Main test runner
│
├── unit/                      # Unit tests
│   ├── test_frontmatter.sh
│   ├── test_frontmatter_config.sh
│   ├── test_tags.sh
│   ├── test_content.sh
│   ├── test_devto_api.sh
│   ├── test_hashnode_api.sh
│   ├── test_medium_api.sh
│   └── test_smoke.sh
│
├── integration/               # Integration tests
│   ├── test_gist_integration.sh
│   ├── test_multipost.sh
│   └── test_pipeline_behavior.sh
│
├── e2e/                       # End-to-end tests
│   └── run_dry_run.sh
│
├── fixtures/                  # Test data
│   ├── input/                 # Input markdown files
│   │   └── posts/             # Sample articles (full, minimal, with-tags, etc.)
│   └── snapshots/             # Expected output
│       └── json/              # API payload snapshots
│           ├── devto-payload.json
│           ├── hashnode-payload.json
│           └── medium-payload.json
│
└── lib/                       # Test helpers
    ├── setup.sh               # Common test environment setup
    ├── test_runner.sh         # Main test runner with TAP output
    ├── assertions.sh          # Assertion functions
    ├── tap.sh                 # TAP output formatting
    ├── tags.sh                # Tag filtering
    ├── fixtures.sh            # Fixture management
    ├── deps.sh                # Dependency checking
    └── timeout.sh             # Timeout handling
```

<br>

<a id="test-output"></a>

## 📝 Test output

> *Comprehensive logging for debugging.*

### Example test output

```text
# Test output captured to: .logs/test_run_all_tests_20260425_050213.log
# ================================================================
# System Information
# ================================================================
#   OS: Ubuntu 24.04.4 LTS
#   Kernel: 6.17.0-20-generic
#   Machine: x86_64
#   Processor: x86_64
#   Hostname: developer-lap
#   Bash: 5.2.21(1)-release
#   Date: 2026-04-25 05:02:13 CEST
#   Timeout: /usr/bin/timeout
#   jq: /usr/bin/jq
# ================================================================
# Environment Configuration
# ================================================================
#   LOG_LEVEL: debug
#   LOG_OUTPUT: both
#   DRY_RUN: false
#   TEST_MODE: not set
#   CI: not set
# ================================================================

Debug log: .tmp/pipepub_20260425_050213.log
PipePub Test Suite
# Test base directory: /home/developer/pipepub/tools/tests

# Suite: Unit Tests
# Found 8 test file(s):
#   - test_content.sh
#   - test_devto_api.sh
#   - test_frontmatter.sh
#   - test_frontmatter_config.sh
#   - test_medium_api.sh
#   - test_smoke.sh
#   - test_tags.sh

Test File: test_frontmatter
# Test 1: Parse full frontmatter
✓ PASS: tags
✓ PASS: title
✓ PASS: status

# Test 2: Parse minimal frontmatter
✓ PASS: title
✓ PASS: tags should be empty

# ✅ test_frontmatter PASSED (5/5 tests)

# Final Summary
# Suites: 3 passed, 0 failed
# Tests:  45 passed, 0 failed, 0 skipped
# Total:  45 tests run
# ✅ All tests passed!
```

### Log locations

| Log type | Path |
|----------|------|
| Test output | `.logs/test_<test_name>_<timestamp>.log` |
| Debug log | `.tmp/pipepub_<timestamp>.log` |
| Dry run reports | `.reports/dry-run-<timestamp>.json` |

<br>

<a id="writing-tests"></a>

## 🧪 Writing tests

> *Guidelines for adding new tests.*

### Test file template

```bash
#!/bin/bash
# tools/tests/unit/test_myfeature.sh
# @tags: unit fast

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "my_library"

# Tag the test file for filtering
tag "test_myfeature.sh" "unit myfeature"

run_tests() {
    echo "# Test 1: Basic functionality"
    
    # Run the function being tested
    my_function "input"
    
    # Assert results
    assert_equals "$RESULT" "expected" "result should match"
    assert_not_empty "$OUTPUT" "output should not be empty"
    
    echo ""
    echo "# Test 2: Edge case"
    
    my_function ""
    assert_equals "$RESULT" "default" "empty input should use default"
}

run_tests
tap_exit_code
```

### Test helpers

| Function | Description |
|----------|-------------|
| `tag "file" "tags"` | Add tags for filtering (`--tag`, `--exclude`) |
| `load_pipeline_lib "name"` | Load pipeline library from `.github/scripts/lib/` |
| `use_fixture "path"` | Copy fixture file to current directory |
| `create_test_post "fixture" "title" "target"` | Create test post from fixture |
| `assert_equals "expected" "actual" "message"` | Compare values |
| `assert_contains "string" "substring" "message"` | Check substring |
| `assert_not_empty "value" "message"` | Verify value is not empty |
| `tap_exit_code` | Output TAP summary and exit with proper code |

### Fixtures

Fixtures are sample markdown files in `fixtures/input/posts/`:

| Fixture | Description |
|---------|-------------|
| `full.md` | Complete frontmatter (all fields) |
| `minimal.md` | Minimal frontmatter (title only) |
| `with-tags.md` | Multiple tags |
| `with-table.md` | Contains markdown table |
| `status-draft.md` | Draft status |
| `status-public.md` | Public status |
| `auto-true.md` | Auto-publish enabled |
| `auto-false.md` | Auto-publish disabled |
| `gist-true.md` | Gist conversion enabled |
| `gist-false.md` | Gist conversion disabled |
| `multi-publisher.md` | Multiple publishers |
| `single-publisher.md` | Single publisher |

<br>

<a id="ci-integration"></a>

## 🔄 CI integration

> *Running tests in GitHub Actions.*

### GitHub Actions workflow

```yaml
name: CI Tests

on:
  pull_request:
    branches: [main, master]
  push:
    branches: [main, master]

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
        run: ./tools/tests/run_all_tests.sh
      - name: Upload test artifacts
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
        run: ./tools/tests/run_all_tests.sh --debug
      - name: Upload test artifacts
        if: always()
        uses: actions/upload-artifact@v6
        with:
          name: test-artifacts-merge
          path: |
            .logs/
            .reports/
          retention-days: 7
```

### CI environment variables

| Variable | Value | Effect |
|----------|-------|--------|
| `CI` | `true` | Disables interactive prompts |
| `DRY_RUN` | `true` | No real API calls |
| `LOG_LEVEL` | `debug` | Verbose logging |
| `LOG_OUTPUT` | `both` | Console + file logs |

📖 **[Infrastructure guide →](/docs/advanced/infra.md)**

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://img.shields.io/badge/DOC-README-white)](/docs/README.md "Main documentation")
[![Commands](https://img.shields.io/badge/DOC-commands-white)](/docs/advanced/commands.md "CLI commands")
[![Tools](https://img.shields.io/badge/DOC-tools-white)](/docs/advanced/tools.md "Local tools guide")
[![Environment](https://img.shields.io/badge/DOC-environment-white)](/docs/advanced/environment.md "Environment setup")
[![Infra](https://img.shields.io/badge/DOC-infra-white)](/docs/advanced/infra.md "CI/CD infrastructure")