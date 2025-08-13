#!/bin/bash

# Feluda APT Repository Setup Script
# This script helps set up the APT repository for the main Feluda repository

set -e

echo "🔧 Setting up Feluda APT Repository..."

# Check if reprepro is installed
if ! command -v reprepro &> /dev/null; then
    echo "❌ reprepro is not installed. Please install it first:"
    echo "   sudo apt install reprepro"
    exit 1
fi

# Check if GPG is available
if ! command -v gpg &> /dev/null; then
    echo "❌ GPG is not installed. Please install it first:"
    echo "   sudo apt install gnupg"
    exit 1
fi

echo "✅ Dependencies check passed"

# Check if we're in the right directory
if [ ! -f "Cargo.toml" ] || [ ! -d "apt-repo" ]; then
    echo "❌ Please run this script from the root of the Feluda repository"
    exit 1
fi

# Initialize the repository
echo "📦 Initializing APT repository..."
cd apt-repo
reprepro -V export
cd ..

echo "✅ Repository initialized successfully"

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Generate a GPG key locally (see APT_REPOSITORY.md for instructions)"
echo "2. Push this repository to GitHub"
echo "3. Add the following secrets to your GitHub repository:"
echo "   - GPG_PRIVATE_KEY: Your exported private key"
echo "   - GPG_PASSPHRASE: Your GPG key passphrase (if set)"
echo "   - REPO_ACCESS_TOKEN: A GitHub token with repository write access"
echo "4. Enable GitHub Pages for the repository"
echo "5. Test the workflow by creating a release"
echo ""
echo "🔗 Repository URL will be:"
echo "   https://anistark.github.io/feluda/apt-repo/"
echo ""
echo "📖 For detailed instructions, see APT_REPOSITORY.md"
