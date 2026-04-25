#!/bin/bash
# .github/lang/en-us.sh - English (United States)

LANG_CODE="en-us"
LANG_NAME="English (United States)"

# Welcome messages
MSG_WELCOME="Welcome to PipePub"
MSG_GOODBYE="Goodbye!"

# Publishing messages
MSG_PUBLISH_START="Starting pipeline..."
MSG_PUBLISH_SUCCESS="Publishing completed successfully!"
MSG_PUBLISH_FAILURE="Publishing failed!"
MSG_PUBLISH_CONFIRM="Continue with publishing? (y/N)"
MSG_PUBLISH_ABORTED="Aborted."

# Service messages (service name will be injected from config)
MSG_SERVICE_PUBLISHING="Publishing to {service}"
MSG_SERVICE_SUCCESS="Successfully published to {service}"
MSG_SERVICE_FAILURE="Failed to publish to {service}"
MSG_SERVICE_MISSING_TOKEN="Missing token for {service}"
MSG_SERVICE_MISSING_CONFIG="Missing configuration for {service}"
MSG_SERVICE_PARTIAL_CONFIG="Partial configuration for {service} (OAuth needed)"

# Secret messages
MSG_SECRET_NO_MASTER="No master key found."
MSG_SECRET_MASTER_CREATED="Master key created."
MSG_SECRET_SAVED="{field} saved"
MSG_SECRET_NOT_SAVED="{field} not saved (review secret format)"
MSG_SECRET_SKIPPED="Skipped (empty)"
MSG_SECRET_REMOVED="{service} secrets removed"
MSG_SECRET_NO_SERVICES="No services configured yet."
MSG_SECRET_ADD_INSTRUCTION="Run: ./tools/pipepub.sh secrets add <service>"

# Confirmation messages
MSG_CONFIRM_REMOVE="Remove all secrets for '{service}'? (y/N)"
MSG_CONFIRM_CONTINUE="Continue? (y/N)"

# Input prompts
MSG_PROMPT_CHOICE="Choice"
MSG_PROMPT_SELECT_SERVICE="Select service"
MSG_PROMPT_PRESS_ENTER="Press Enter to continue..."
MSG_PROMPT_ENTER_SECRET="Enter {field}"

# Status messages
MSG_STATUS_CONFIGURED="configured"
MSG_STATUS_PARTIAL="partial"
MSG_STATUS_MISSING="not configured"