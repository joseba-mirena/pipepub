<a id="top"></a>

[![Publish like a PRO](https://pipepub.github.io/cdn/image/logo/pipepub-full-right.png)](https://github.com/pipepub "PipeHub - Publish like a PRO")

### Security Policy

> *Reporting vulnerabilities and security best practices*

<hr>

<details>
<summary>ℹ️ <b>Information</b></summary>

| Info | Details |
|------|---------|
| **Name** | [![PipePub](https://pipepub.github.io/cdn/image/badge/logo/pipepub.svg)](https://github.com/pipepub "PipePub - Publish like a PRO") |
| **Package** | ![Repository](https://pipepub.github.io/cdn/image/badge/repo/pipepub.svg "GitHub Repository") |
| **Version** | [![Version](https://pipepub.github.io/cdn/image/badge/version/current.svg)](/CHANGELOG.md#v1.0.0 "PipePub v.1.0.0") |
| **DOC** | [![security](https://pipepub.github.io/cdn/image/badge/doc/security.svg)](/docs/SECURITY.md "Security policy") |
| **License** | [![License](https://pipepub.github.io/cdn/image/badge/license/current.svg)](/LICENSE "Free MIT license") |

</details>

<details>
<summary>📑 <b>Quick links</b></summary>

| Section |
|---------|
| [🔐 Reporting a vulnerability](#reporting-a-vulnerability) |
| [🔒 Security best practices](#security-best-practices) |
| [📦 Supported versions](#supported-versions) |
| [🔧 Dependency management](#dependency-management) |

</details>

---

<br>

<a id="secure-secrets-handling"></a>

## 🔐 How PipePub handles secrets securely

> *Your API tokens and credentials are never exposed in plain text.*

### GitHub Actions (Cloud)

When using PipePub as a GitHub Actions workflow, all secrets are stored as **encrypted repository secrets**:

- Secrets are stored at rest using **AES-256 encryption**
- Never appear in logs (automatically masked by GitHub)
- Only accessible to workflows running on the repository
- Not exposed to forks by default

### Local development (Power users)

When running PipePub locally, secrets are stored in your **operating system's native keychain**:

| OS | Keychain tool | Storage location |
|----|---------------|------------------|
| **macOS** | `security` (Keychain Access) | Encrypted login keychain |
| **Linux** | `secret-tool` (libsecret) | GNOME Keyring / KWallet |

```bash
# Secrets are never stored in .env or plain text files
# Manage them via the interactive menu:
./tools/pipepub.sh secrets add devto

# Or via direct commands:
./tools/pipepub.sh secrets list
./tools/pipepub.sh secrets export
```

**Key benefits:**
- ✅ Secrets encrypted at rest by the OS
- ✅ No risk of committing secrets to git
- ✅ Separate storage per user account
- ✅ Master key auto-generated on first run

📖 **[Environment setup guide →](/docs/advanced/environment.md#secrets-management)**

<br>

<a id="reporting-a-vulnerability"></a>

## 🔐 Reporting a vulnerability

> *Your help in keeping PipePub secure is greatly appreciated.*

**If you discover a security vulnerability, please DO NOT file a public issue.**

### Reporting process

1. **Email the maintainer** directly at `security@pipepub.com` (or use the private reporting method on GitHub)
2. Include detailed information about the vulnerability
3. Allow time for the issue to be assessed and patched
4. A public disclosure will be made after a fix is released

### What to include

| Information | Description |
|-------------|-------------|
| **Description** | Clear explanation of the vulnerability |
| **Steps to reproduce** | How to trigger the issue |
| **Impact** | What an attacker could potentially do |
| **Environment** | PipePub version, OS, dependencies |
| **Proposed fix** | If you have suggestions |

### Response timeline

| Timeframe | Action |
|-----------|--------|
| **24-48 hours** | Acknowledgment of receipt |
| **5-7 days** | Initial assessment and severity rating |
| **30 days** | Patch released (or explanation of delay) |
| **After patch** | Public disclosure with credit to reporter |

📖 **[Support guide →](/docs/SUPPORT.md)**

<br>

<a id="security-best-practices"></a>

## 🔒 Security best practices

> *Recommendations for keeping your PipePub installation secure.*

### API tokens and secrets

| Practice | Recommendation |
|----------|----------------|
| **Token scope** | Use minimal required scopes (e.g., `gist` only for GitHub) |
| **Expiration** | Set short expiration (30-90 days) and rotate regularly |
| **Storage** | Use GitHub repository secrets or OS keychain, never commit tokens |
| **Audit** | Regularly review which services have access |

### GitHub Actions

| Practice | Recommendation |
|----------|----------------|
| **Permissions** | Review workflow permissions (default is read-only) |
| **Secrets** | Never log secrets; PipePub automatically masks them |
| **Fork handling** | Workflows from forks have limited access to secrets |

### Environment variables

```text
# Never commit .env files
.env
.env.local
.env.*.local

# Use .env.example as template
cp .env.example .env
# Then edit .env with your actual values
```

### Keychain security (local usage)

| OS | Security feature |
|----|------------------|
| **macOS** | Secrets stored in encrypted login keychain |
| **Linux** | Secrets stored in GNOME Keyring or KWallet |

```bash
# Verify keychain is working
./tools/pipepub.sh check
```

<br>

<a id="supported-versions"></a>

## 📦 Supported versions

> *Security updates are provided for the following versions.*

| Version | Support status | Security updates |
|---------|----------------|------------------|
| **v1.x** | ✅ Active | Critical and high severity |
| **v0.x** | ❌ End of life | No updates |

### Version policy

- **Major version (v1.x)**: Actively maintained with security patches
- **Minor versions (v1.0, v1.1, etc.)**: New features and fixes
- **Unsupported versions**: Upgrade to latest version

📖 **[Changelog →](/CHANGELOG.md)**

<br>

<a id="dependency-management"></a>

## 🔧 Dependency management

> *Third-party dependencies and their security implications.*

### Critical dependencies

| Dependency | Purpose | Security notes |
|------------|---------|----------------|
| `curl` | API requests | Keep updated; uses HTTPS by default |
| `jq` | JSON parsing | Low risk, validate input |
| `openssl` | Keychain encryption | Critical; keep updated |
| `git` | Repository operations | Standard security practices |

### Update recommendations

```bash
# macOS
brew update && brew upgrade

# Ubuntu/Debian
sudo apt-get update && sudo apt-get upgrade

# Manual version check
jq --version
curl --version
openssl version
```

### Security announcements

- Watch the [GitHub repository](https://github.com/pipepub/pipepub) for security advisories
- Security advisories are published under the [Security tab](https://github.com/pipepub/pipepub/security)

<br>

[↑ Back to top](#top)

<!-- Related documentation persona routing -->

**Related documentation**:

[![README](https://pipepub.github.io/cdn/image/badge/doc/readme.svg)](/README.md "Main documentation")
[![Support](https://pipepub.github.io/cdn/image/badge/doc/support.svg)](/docs/SUPPORT.md "Support guide")
[![FAQ](https://pipepub.github.io/cdn/image/badge/doc/faq.svg)](/docs/basics/faq.md "FAQ")
[![Environment](https://pipepub.github.io/cdn/image/badge/doc/environment.svg)](/docs/advanced/environment.md "Environment setup")