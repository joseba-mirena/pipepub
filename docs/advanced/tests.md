<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Test Suite Guide

> *Run, write, and understand PipePub's test suite*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#history "PipePub v.1.0.0") |
| **DOC** | [![tests](https://pipepub.github.io/cdn/image/badge/doc/tests.svg)](/docs/advanced/tests.md "Test suite guide") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🚀 Running tests](#running-tests) |
| [🏷️ Test flags](#test-flags) |
| [🧪 Test isolation](#test-isolation) |
| [📸 Snapshot management](#snapshot-management) |
| [🏷️ Test tagging](#test-tagging) |
| [📊 Test categories](#test-categories) |
| [📁 Test directory structure](#test-directory-structure) |
| [📝 Test output](#test-output) |
| [✅ Assertions library](#assertions-library) |
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
| `./tools/tests/run.sh` | Full test suite (unit + integration + e2e) |
| `./tools/tests/run.sh --quick` | Run unit + integration tests only (fast) |
| `./tools/tests/run.sh --unit` | Run only unit tests |
| `./tools/tests/run.sh --integration` | Run only integration tests |
| `./tools/tests/run.sh --e2e` | Run only e2e tests |
| `./tools/tests/run.sh --filter=NAME` | Run only test file matching NAME |
| `./tools/tests/run.sh --update-snapshots` | Update snapshot files |
| `./tools/tests/run.sh --debug` | Enable debug logging |
| `./tools/tests/run.sh --dev` | Run dev tests with service overlay |

<br>

<a id="test-flags"></a>

## 🏷️ Test flags

> *Detailed flag descriptions.*

| Flag | Description |
|------|-------------|
| `--quick` | Run unit + integration tests, skip e2e (fastest) |
| `--unit` | Run only unit tests |
| `--integration` | Run only integration tests |
| `--e2e` | Run only end-to-end tests |
| `--filter=NAME` | Run only test file matching NAME (e.g., `--filter=test_tags.sh`) |
| `--update-snapshots` | Update all snapshot files instead of comparing |
| `--debug` | Enable debug logging, capture detailed output |
| `--dev` | Run dev tests with service overlay (requires `tools/config/` dev files) |

### Usage examples

```bash
# Run all tests
./tools/tests/run.sh

# Run quick tests (unit + integration)
./tools/tests/run.sh --quick

# Run with dev service overlay
./tools/tests/run.sh --dev

# Update snapshots
./tools/tests/run.sh --update-snapshots

# Run specific test file
./tools/tests/run.sh --filter=test_tags.sh
```

<br>

<a id="test-isolation"></a>

## 🧪 Test isolation

> *Each test runs in a completely isolated environment.*

### Isolation guarantees

- Temporary directory created at `/tmp/publisher-test-<name>-XXXXXX`
- `.github/` folder copied to temp directory
- Dev files overlaid when `--dev` flag is used
- Posts directory created fresh for each test
- Environment variables reset between tests
- Automatic cleanup on test exit (success or failure)

### Dev mode isolation

When `--dev` flag is used:

1. Loads services from `tools/config/registry-dev.conf`
2. Loads configs from `tools/config/services-dev/`
3. Loads handlers from `tools/handlers-dev/`
4. Runs tests in `tools/tests/dev/`

This allows developing new services without affecting production.

> **Example:** See `docs/assets/example/dev/service/` for a complete working example including registry, config, handler, and tests for a Ghost service.

<br>

<a id="snapshot-management"></a>

## 📸 Snapshot management

> *Compare API payloads against expected JSON snapshots.*

### Snapshot location

```text
tools/tests/fixtures/snapshots/json/
├── devto-payload.json
├── hashnode-payload.json
└── medium-payload.json
```

### Using snapshots in tests

```bash
# In test file
assert_json_snapshot "$actual_payload" "devto-payload.json"
```

### Updating snapshots

```bash
# Update all snapshots
./tools/tests/run.sh --update-snapshots

# Or run individual test with update
./tools/tests/unit/test_devto_api.sh --update-snapshots
```

### Snapshot behavior

| Mode | Behavior |
|------|----------|
| Normal | Compares actual output against snapshot, fails on mismatch |
| `--update-snapshots` | Creates/updates snapshot file, test passes |

<br>

<a id="test-tagging"></a>

## 🏷️ Test tagging

> *Filter tests by tags for selective execution.*

### Adding tags to test files

```bash
# At the top of test file
tag "test_file.sh" "unit fast"
```

### Tag filtering via environment

```bash
# Run only tests with "unit" tag
TEST_TAG_INCLUDE=unit ./tools/tests/run.sh

# Exclude tests with "slow" tag
TEST_TAG_EXCLUDE=slow ./tools/tests/run.sh
```

### Built-in tags

| Tag | Description |
|-----|-------------|
| `unit` | Unit tests |
| `integration` | Integration tests |
| `e2e` | End-to-end tests |
| `fast` | Fast-running tests |
| `smoke` | Smoke tests |

<br>

<a id="test-categories"></a>

## 📊 Test categories

> *Different test types for different purposes.*

### Unit tests (`unit/`)

| Test file | What it tests |
|-----------|---------------|
| `test_frontmatter.sh` | YAML frontmatter parsing, field extraction |
| `test_frontmatter_config.sh` | Frontmatter configuration options |
| `test_tags.sh` | Tag sanitization, service-specific rules |
| `test_content.sh` | Content extraction, H1 title detection |
| `test_devto_api.sh` | DEV.to API payload construction |
| `test_ghost_api.sh` | Ghost API payload construction |
| `test_hashnode_api.sh` | Hashnode GraphQL payload construction |
| `test_medium_api.sh` | Medium API payload construction |
| `test_smoke.sh` | Basic smoke tests |

### Integration tests (`integration/`)

| Test file | What it tests |
|-----------|---------------|
| `test_multipost.sh` | Multi-file publishing workflow |
| `test_pipeline_behavior.sh` | Pipeline behavior (publisher selection, gist toggle) |
| `test_gist_integration.sh` | GitHub Gist creation and embedding |

### End-to-end tests (`e2e/`)

| Test file | What it tests |
|-----------|---------------|
| `run_dry_run.sh` | Complete pipeline with mocks (no real API calls) |

### Dev tests (`dev/` - git ignored)

| Test file | What it tests |
|-----------|---------------|
| `test_ghost_dev.sh` | Example: Ghost service development |

<br>

<a id="test-directory-structure"></a>

## 📁 Test directory structure

> *Complete test suite layout.*

```text
tools/tests/
├── run.sh                    # Main test runner
│
├── unit/                     # Unit tests
│   ├── test_frontmatter.sh
│   ├── test_frontmatter_config.sh
│   ├── test_tags.sh
│   ├── test_content.sh
│   ├── test_devto_api.sh
│   ├── test_ghost_api.sh
│   ├── test_hashnode_api.sh
│   ├── test_medium_api.sh
│   └── test_smoke.sh
│
├── integration/              # Integration tests
│   ├── test_gist_integration.sh
│   ├── test_multipost.sh
│   └── test_pipeline_behavior.sh
│
├── e2e/                      # End-to-end tests
│   └── run_dry_run.sh
│
├── dev/                      # Dev tests (git ignored)
│   └── test_ghost_dev.sh
│
├── fixtures/                 # Test data
│   ├── input/
│   │   └── posts/            # Sample markdown articles
│   └── snapshots/
│       └── json/             # API payload snapshots
│           ├── devto-payload.json
│           ├── ghost-payload.json
│           ├── hashnode-payload.json
│           └── medium-payload.json
│
└── lib/                      # Test helpers
    ├── setup.sh              # Test environment setup + isolation
    ├── test_runner.sh        # TAP test runner
    ├── assertions.sh         # Complete assertion library
    ├── fixtures.sh           # Fixture and snapshot management
    ├── tags.sh               # Test tagging and filtering
    ├── deps.sh               # Test dependency management
    ├── timeout.sh            # Timeout protection
    ├── hooks.sh              # Test lifecycle hooks
    ├── isolation.sh          # Test isolation helpers
    └── logger.sh             # Test logging utilities
```

<br>

<a id="test-output"></a>

## 📝 Test output

> *Comprehensive logging for debugging.*

### Example test output

```text
# Test output captured to: .logs/test_run_20260425_050213.log
# ================================================================
# System Information
# ================================================================
#   OS: Ubuntu 24.04.4 LTS
#   Kernel: 6.17.0-20-generic
#   Machine: x86_64
#   Bash: 5.2.21(1)-release
#   Date: 2026-04-25 05:02:13 CEST
# ================================================================
# Environment Configuration
# ================================================================
#   LOG_LEVEL: debug
#   LOG_OUTPUT: both
#   DRY_RUN: false
#   CI: false
#   TEST_DEV_MODE: false
# ================================================================

Debug log: .tmp/pipepub_20260425_050213.log
PipePub Test Suite

# Suite: Unit Tests
# Found 8 test file(s):
#   - test_content.sh
#   - test_devto_api.sh
#   - test_ghost_api.sh
#   - test_frontmatter.sh
#   - test_frontmatter_config.sh
#   - test_hashnode_api.sh
#   - test_medium_api.sh
#   - test_smoke.sh
#   - test_tags.sh

Test File: test_frontmatter
# Test 1: Parse full frontmatter
ok 1 - tags
ok 2 - title
ok 3 - status

# Test 2: Parse minimal frontmatter
ok 4 - title
ok 5 - tags should be empty

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

<a id="assertions-library"></a>

## ✅ Assertions library

> *Complete TAP-compatible assertions for tests.*

Location: `tools/tests/lib/assertions.sh`

### Equality assertions

| Function | Parameters | Description |
|----------|------------|-------------|
| `assert_equals` | `actual`, `expected`, `message` | Assert two values are equal |
| `assert_not_equals` | `actual`, `expected`, `message` | Assert two values are not equal |

### String assertions

| Function | Parameters | Description |
|----------|------------|-------------|
| `assert_contains` | `haystack`, `needle`, `message` | Assert string contains substring |
| `assert_not_contains` | `haystack`, `needle`, `message` | Assert string does NOT contain substring |
| `assert_starts_with` | `string`, `prefix`, `message` | Assert string starts with prefix |
| `assert_ends_with` | `string`, `suffix`, `message` | Assert string ends with suffix |
| `assert_matches` | `string`, `pattern`, `message` | Assert string matches regex pattern |

### Numeric assertions

| Function | Parameters | Description |
|----------|------------|-------------|
| `assert_greater_than` | `actual`, `expected`, `message` | Assert actual > expected |
| `assert_less_than` | `actual`, `expected`, `message` | Assert actual < expected |

### File system assertions

| Function | Parameters | Description |
|----------|------------|-------------|
| `assert_file_exists` | `file`, `message` | Assert file exists |
| `assert_file_not_exists` | `file`, `message` | Assert file does not exist |
| `assert_dir_exists` | `dir`, `message` | Assert directory exists |
| `assert_file_readable` | `file`, `message` | Assert file is readable |
| `assert_file_writable` | `file`, `message` | Assert file is writable |
| `assert_file_executable` | `file`, `message` | Assert file is executable |

### Command/exit assertions

| Function | Parameters | Description |
|----------|------------|-------------|
| `assert_success` | `cmd`, `message` | Assert command succeeds (exit 0) |
| `assert_failure` | `cmd`, `message` | Assert command fails (non-zero exit) |
| `assert_exit_code` | `expected`, `cmd`, `message` | Assert command exits with specific code |

### Output assertions

| Function | Parameters | Description |
|----------|------------|-------------|
| `assert_output` | `expected`, `cmd`, `message` | Assert command output equals expected |
| `assert_output_contains` | `needle`, `cmd`, `message` | Assert output contains substring |

### Variable assertions

| Function | Parameters | Description |
|----------|------------|-------------|
| `assert_set` | `var_name`, `message` | Assert variable is set (non-empty) |
| `assert_unset` | `var_name`, `message` | Assert variable is unset (empty) |

### Utility functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `skip_test` | `reason` | Skip current test with reason |
| `assert_reset` | (none) | Reset TAP counter |

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
    assert_contains "$OUTPUT" "expected string" "output should contain expected string"

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
| `tag "file" "tags"` | Add tags for filtering (`TEST_TAG_INCLUDE`, `TEST_TAG_EXCLUDE`) |
| `load_pipeline_lib "name"` | Load pipeline library from `.github/scripts/lib/` |
| `use_fixture "path"` | Copy fixture file to current directory |
| `create_test_post "fixture" "title" "target"` | Create test post from fixture |
| `assert_json_snapshot "json" "name"` | Compare JSON against snapshot |
| `assert_equals "expected" "actual" "message"` | Compare values |
| `assert_contains "string" "substring" "message"` | Check substring |
| `skip_test "reason"` | Skip current test |

### Fixtures

Fixtures are sample markdown files in `fixtures/input/posts/`:

| Fixture | Description |
|---------|-------------|
| `full.md` | Complete frontmatter (all fields) |
| `minimal.md` | Minimal frontmatter (title only) |
| `with-tags.md` | Multiple tags |
| `with-table.md` | Contains markdown table |
| `with-multiple-tables.md` | Multiple markdown tables |
| `status-draft.md` | Draft status |
| `status-public.md` | Public status |
| `auto-true.md` | Auto-publish enabled |
| `auto-false.md` | Auto-publish disabled |
| `gist-true.md` | Gist conversion enabled |
| `gist-false.md` | Gist conversion disabled |
| `multi-publisher.md` | Multiple publishers |
| `single-publisher.md` | Single publisher |
| `all-fields.md` | All frontmatter fields |
| `basic.md` | Basic content without frontmatter |

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
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - 'images/**'
  push:
    branches: [main, master]
    paths-ignore:
      - '**.md'
      - 'docs/**'
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
        run: ./tools/tests/run.sh --debug
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

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/docs/README.md "Main documentation")
[![Commands](https://pipepub.github.io/cdn/image/badge/doc/commands.svg)](/docs/advanced/commands.md "CLI commands")
[![Tools](https://pipepub.github.io/cdn/image/badge/doc/tools.svg)](/docs/advanced/tools.md "Local tools guide")
[![Environment](https://pipepub.github.io/cdn/image/badge/doc/environment.svg)](/docs/advanced/environment.md "Environment setup")
[![Infra](https://pipepub.github.io/cdn/image/badge/doc/infra.svg)](/docs/advanced/infra.md "CI/CD infrastructure")