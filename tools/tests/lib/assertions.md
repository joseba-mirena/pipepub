## Complete Assertions Library Reference

> *PipePub Assertions library*

| Category | Function | Description | Parameters |
|----------|----------|-------------|------------|
| **Equality** | `assert_equals` | Assert two values are equal | `actual`, `expected`, `message` |
| | `assert_not_equals` | Assert two values are not equal | `actual`, `expected`, `message` |
| **String** | `assert_contains` | Assert string contains substring | `haystack`, `needle`, `message` |
| | `assert_not_contains` | Assert string does NOT contain substring | `haystack`, `needle`, `message` |
| | `assert_starts_with` | Assert string starts with prefix | `string`, `prefix`, `message` |
| | `assert_ends_with` | Assert string ends with suffix | `string`, `suffix`, `message` |
| | `assert_matches` | Assert string matches regex pattern | `string`, `pattern`, `message` |
| **Numeric** | `assert_greater_than` | Assert numeric value is greater than | `actual`, `expected`, `message` |
| | `assert_less_than` | Assert numeric value is less than | `actual`, `expected`, `message` |
| **File System** | `assert_file_exists` | Assert file exists | `file`, `message` |
| | `assert_file_not_exists` | Assert file does not exist | `file`, `message` |
| | `assert_dir_exists` | Assert directory exists | `dir`, `message` |
| | `assert_file_readable` | Assert file is readable | `file`, `message` |
| | `assert_file_writable` | Assert file is writable | `file`, `message` |
| | `assert_file_executable` | Assert file is executable | `file`, `message` |
| **Command/Exit** | `assert_success` | Assert command succeeds (exit 0) | `cmd`, `message` |
| | `assert_failure` | Assert command fails (non-zero exit) | `cmd`, `message` |
| | `assert_exit_code` | Assert command exits with specific code | `expected`, `cmd`, `message` |
| **Output** | `assert_output` | Assert command output equals expected | `expected`, `cmd`, `message` |
| | `assert_output_contains` | Assert command output contains substring | `needle`, `cmd`, `message` |
| **Variable** | `assert_set` | Assert variable is set (non-empty) | `var_name`, `message` |
| | `assert_unset` | Assert variable is unset (empty) | `var_name`, `message` |
| **Utility** | `skip_test` | Skip current test with reason | `reason` |
| | `assert_reset` | Reset TAP counter | (none) |

### Output Format

All assertions output TAP format:
- Success: `ok <counter> - <message>`
- Failure: `not ok <counter> - <message>`
- Diagnostics go to stderr with `# ` prefix