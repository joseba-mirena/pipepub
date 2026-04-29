# Development Service Example - Ghost

This example demonstrates how to add a new publishing platform to PipePub.

## Files in this example

| File | Purpose |
|------|---------|
| `tools/config/registry-dev.conf` | Registers the service with required secrets |
| `tools/config/services-dev/ghost.conf` | Service configuration (endpoint, tags, defaults) |
| `tools/handlers-dev/ghost.sh` | Handler script with `publish_to_ghost()` function |
| `tools/tests/dev/test_ghost_dev.sh` | Development tests for the service |

## How to use

1. Copy these patterns to create your own service
2. Replace `ghost` with your service name
3. Implement the handler function
4. Run `./tools/tests/run.sh --dev` to test

## Files location in your repository

These files should be placed in your local repository (they are git-ignored):

- `tools/config/registry-dev.conf`
- `tools/config/services-dev/`
- `tools/handlers-dev/`
- `tools/tests/dev/`

📖 **[Full development guide →](/docs/advanced/tools.md#service-loading)**