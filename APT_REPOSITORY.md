# APT Repository Integration

This document explains how the APT repository is integrated into the main Feluda repository and how releases work.

## Overview

The APT repository has been merged into the main Feluda repository under the `apt-repo/` directory. This allows for automatic APT package builds and releases when a new GitHub release is created.

## Directory Structure

```
feluda/
├── apt-repo/                 # APT repository files
│   ├── conf/                # reprepro configuration
│   ├── incoming/            # New packages to be added
│   ├── dists/               # Distribution metadata
│   ├── pool/                # Package pool
│   ├── db/                  # reprepro database
│   └── README.md            # Installation instructions
├── .github/workflows/       # GitHub Actions
│   ├── release-apt.yml      # Automatic release workflow
│   ├── build-deb.yml        # Manual build workflow
│   └── deploy-pages.yml     # GitHub Pages deployment
└── ...                      # Main Feluda source code
```

## GitHub Actions Workflows

### 1. Automatic Release Workflow (`release-apt.yml`)

**Trigger**: When a new GitHub release is published
**Purpose**: Automatically builds and publishes APT packages

**Steps**:
1. Checkout the repository
2. Setup Rust toolchain
3. Build Feluda binary
4. Install reprepro (APT repository management tool)
5. Setup GPG signing (if configured)
6. Extract version from release tag
7. Create DEB package
8. Update APT repository
9. Export and save public key
10. Commit and push changes
11. Upload DEB package as release asset

### 2. Manual Build Workflow (`build-deb.yml`)

**Trigger**: Manual workflow dispatch or repository dispatch
**Purpose**: Manual APT package builds for testing or specific versions

### 3. GitHub Pages Deployment (`deploy-pages.yml`)

**Trigger**: On push to main branch or after APT package builds
**Purpose**: Deploy APT repository to GitHub Pages for public access

## Setup Instructions

### 1. Repository Setup

The APT repository is already set up in the `apt-repo/` directory. The basic structure includes:

- reprepro configuration for Ubuntu Bionic
- GPG key management
- Package pool structure
- Distribution metadata

### 2. GPG Key Generation (Required)

**IMPORTANT**: You must generate a GPG key locally and add it to GitHub secrets for package signing.

#### Step 1: Generate GPG Key Locally

```bash
# Generate a new GPG key
gpg --full-generate-key

# Choose the following options:
# - Key type: RSA and RSA (default)
# - Key size: 4096
# - Expiration: 0 (does not expire)
# - Name: Feluda APT Repository
# - Email: feluda-apt@yourdomain.com (use your domain)
```

#### Step 2: Export the Private Key

```bash
# List your keys to find the key ID
gpg --list-secret-keys

# Export the private key (replace KEY_ID with your actual key ID)
gpg --armor --export-secret-key KEY_ID > feluda-apt-private-key.gpg

# The output will look like:
# -----BEGIN PGP PRIVATE KEY BLOCK-----
# ... (long base64 encoded key)
# -----END PGP PRIVATE KEY BLOCK-----
```

#### Step 3: Export the Public Key

```bash
# Export the public key
gpg --armor --export KEY_ID > feluda-apt-public-key.gpg

# Save this file - it will be used by the workflow
cp feluda-apt-public-key.gpg apt-repo/public-key.gpg
```

#### Step 4: Get Key Fingerprint

```bash
# Get the key fingerprint
gpg --fingerprint KEY_ID

# Save this fingerprint for reference
```

### 3. GitHub Secrets Configuration

Add these secrets to your GitHub repository:

#### Required Secrets:

1. **`GPG_PRIVATE_KEY`**:
   - Copy the entire content of `feluda-apt-private-key.gpg`
   - Include the `-----BEGIN PGP PRIVATE KEY BLOCK-----` and `-----END PGP PRIVATE KEY BLOCK-----` lines

2. **`GPG_PASSPHRASE`**:
   - If you set a passphrase when creating the GPG key, add it here
   - If you didn't set a passphrase, leave this empty

3. **`REPO_ACCESS_TOKEN`**:
   - Go to Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate a new token with `repo` scope
   - Add the token as `REPO_ACCESS_TOKEN`

### 4. GitHub Pages

Enable GitHub Pages for the repository:
1. Go to Settings → Pages
2. Source: Deploy from a branch
3. Branch: main
4. Folder: / (root)
5. Save

## Release Process

### Automatic Release (Recommended)

1. Create a new release on GitHub:
   - Go to Releases → Create a new release
   - Tag version: `v1.9.9` (or your version)
   - Release title: `Feluda v1.9.9`
   - Description: Release notes
   - Publish release

2. The `release-apt.yml` workflow will automatically:
   - Build the Feluda binary
   - Create a DEB package
   - Update the APT repository
   - Export and save the public key
   - Deploy to GitHub Pages
   - Add the DEB package as a release asset

### Manual Release

1. Go to Actions → "Build and Publish DEB Package"
2. Click "Run workflow"
3. Enter the version number
4. Click "Run workflow"

## Installation for Users

Users can install Feluda via APT using these commands:

```bash
# Add the repository
curl -fsSL https://anistark.github.io/feluda/apt-repo/public-key.gpg | sudo apt-key add -
echo "deb [arch=amd64] https://anistark.github.io/feluda/apt-repo/ bionic main" | sudo tee /etc/apt/sources.list.d/feluda.list

# Install Feluda
sudo apt update
sudo apt install feluda
```

## Troubleshooting

### GPG Key Issues

If users encounter GPG verification issues, they can use the unsigned repository:

```bash
echo "deb [trusted=yes] https://anistark.github.io/feluda/apt-repo/ bionic main" | sudo tee /etc/apt/sources.list.d/feluda.list
```

### Workflow Failures

1. Check GitHub Actions logs for specific error messages
2. Ensure all required secrets are configured
3. Verify GitHub Pages is enabled
4. Check that the repository has proper permissions

### Package Issues

1. Verify the DEB package structure in the workflow
2. Check reprepro configuration
3. Ensure GPG keys are properly configured
4. Test package installation locally

## Maintenance

### Updating reprepro Configuration

The reprepro configuration is in `apt-repo/conf/distributions`. To add new distributions or components:

1. Edit the configuration file
2. Update the workflow to use the new distribution
3. Test the build process

### GPG Key Rotation

To rotate GPG keys:

1. Generate new GPG key pair locally (see GPG Key Generation section)
2. Update the `GPG_PRIVATE_KEY` secret in GitHub
3. Update the `GPG_PASSPHRASE` secret if needed
4. Test the signing process

### Repository Cleanup

Periodically clean up old packages:

1. Remove old packages from `apt-repo/pool/`
2. Update the reprepro database
3. Commit and push changes

## Security Considerations

1. **GPG Signing**: Always use GPG signing for production packages
2. **Secret Management**: Keep GPG private keys secure and never commit them to the repository
3. **Access Control**: Limit repository write access
4. **Package Verification**: Verify packages before distribution
5. **Key Backup**: Keep a secure backup of your GPG private key

## Support

For issues with the APT repository:
1. Check the GitHub Actions logs
2. Review the setup documentation
3. Open an issue in the main repository

For issues with Feluda itself, visit the main repository: https://github.com/anistark/feluda
