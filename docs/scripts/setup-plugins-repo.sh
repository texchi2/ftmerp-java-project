#!/bin/bash
# Setup script for ofbiz-plugins GitHub repository
# Run this on rpitex Raspberry Pi 5

set -e  # Exit on error

echo "==================================="
echo "FTM ERP Plugins Repository Setup"
echo "==================================="
echo ""

# Configuration
PLUGINS_DIR="$HOME/development/ofbiz-plugins"
FRAMEWORK_DIR="$HOME/development/ofbiz-framework"
GITHUB_USER="texchi2"
PLUGINS_REPO="ftmerp-java-plugins"

# Check if plugins directory exists
if [ ! -d "$PLUGINS_DIR" ]; then
    echo "ERROR: Plugins directory not found: $PLUGINS_DIR"
    echo "Please ensure your ofbiz-plugins directory exists."
    exit 1
fi

echo "✓ Found plugins directory: $PLUGINS_DIR"

# Navigate to plugins directory
cd "$PLUGINS_DIR"

# Check if ftm-garments exists
if [ ! -d "ftm-garments" ]; then
    echo "WARNING: ftm-garments plugin not found!"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✓ Found ftm-garments plugin"
fi

# Check if already a git repository
if [ -d ".git" ]; then
    echo "✓ Already a git repository"
    echo "Current status:"
    git status
    read -p "Continue with existing repository? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "Initializing git repository..."
    git init
    echo "✓ Git repository initialized"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Gradle
.gradle/
build/
*.class

# IntelliJ IDEA
.idea/
*.iml
*.iws
*.ipr
out/

# Eclipse
.project
.classpath
.settings/
bin/

# OFBiz runtime
runtime/
*.log

# OS
.DS_Store
Thumbs.db

# Temporary files
*.swp
*.swo
*~
EOF
    echo "✓ Created .gitignore"
fi

# Add all files
echo "Adding files to git..."
git add .

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "No changes to commit"
else
    # Commit
    echo "Committing files..."
    git commit -m "Initial commit: FTM ERP plugins including ftm-garments

This repository contains custom plugins for FTM Garments ERP system,
forked from Apache OFBiz and adapted for garment manufacturing operations.

Key components:
- ftm-garments: Custom plugin for FTM-specific functionality
- Integration with ofbiz-framework repository
- PostgreSQL database support
"
    echo "✓ Files committed"
fi

# Set main branch
echo "Setting main branch..."
git branch -M main
echo "✓ Branch set to main"

# Check if remote already exists
if git remote get-url origin > /dev/null 2>&1; then
    echo "✓ Remote 'origin' already configured"
    git remote -v
else
    # Add remote
    echo "Adding GitHub remote..."
    read -p "Have you created the GitHub repository '$GITHUB_USER/$PLUGINS_REPO'? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Please create the repository first:"
        echo "1. Go to https://github.com/new"
        echo "2. Repository name: $PLUGINS_REPO"
        echo "3. Description: FTM ERP Plugins for garment manufacturing"
        echo "4. Public or Private: Your choice"
        echo "5. DO NOT initialize with README, .gitignore, or license"
        echo ""
        echo "Then run this script again."
        exit 1
    fi

    git remote add origin "git@github.com:$GITHUB_USER/$PLUGINS_REPO.git"
    echo "✓ Remote added"
fi

# Push to GitHub
echo ""
echo "Pushing to GitHub..."
echo "You may be prompted for your GitHub credentials."
echo ""

if git push -u origin main; then
    echo "✓ Successfully pushed to GitHub!"
else
    echo ""
    echo "Push failed. This might be because:"
    echo "1. The repository doesn't exist on GitHub yet"
    echo "2. Authentication failed"
    echo "3. Network issues"
    echo ""
    echo "To retry manually:"
    echo "  cd $PLUGINS_DIR"
    echo "  git push -u origin main"
    exit 1
fi

# Update framework repository symlink tracking
echo ""
echo "Updating framework repository..."
cd "$FRAMEWORK_DIR"

if [ -L "plugins" ]; then
    echo "✓ Plugins symlink exists"

    # Check if symlink is tracked
    if git ls-files --error-unmatch plugins > /dev/null 2>&1; then
        echo "✓ Symlink already tracked in git"
    else
        echo "Adding symlink to git..."
        git add plugins
        git commit -m "Track plugins symlink for ofbiz-plugins integration"
        echo "✓ Symlink committed"
    fi
else
    echo "WARNING: Plugins symlink not found in framework directory"
    echo "Creating symlink..."
    ln -sf ../ofbiz-plugins plugins
    git add plugins
    git commit -m "Add plugins symlink to ofbiz-plugins repository"
    echo "✓ Symlink created and committed"
fi

echo ""
echo "==================================="
echo "✓ Setup Complete!"
echo "==================================="
echo ""
echo "Your repositories:"
echo "  Framework: https://github.com/$GITHUB_USER/ftmerp-java-project"
echo "  Plugins:   https://github.com/$GITHUB_USER/$PLUGINS_REPO"
echo ""
echo "Local directories:"
echo "  Framework: $FRAMEWORK_DIR"
echo "  Plugins:   $PLUGINS_DIR"
echo ""
echo "Next steps:"
echo "1. Clone both repositories on other development machines"
echo "2. Set up PostgreSQL database (see FTM-SETUP-GUIDE.adoc)"
echo "3. Configure vim/tmux environment"
echo "4. Start developing!"
echo ""
