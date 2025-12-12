#!/bin/bash
# Clone FTM ERP repositories (framework + plugins)
# Use this script to set up FTM ERP on a new development machine

set -e  # Exit on error

echo "==================================="
echo "FTM ERP Repository Clone Script"
echo "==================================="
echo ""

# Configuration
GITHUB_USER="texchi2"
FRAMEWORK_REPO="ftmerp-java-project"
PLUGINS_REPO="ftmerp-java-plugins"
DEV_DIR="$HOME/development"

# Check if development directory exists
if [ ! -d "$DEV_DIR" ]; then
    echo "Creating development directory: $DEV_DIR"
    mkdir -p "$DEV_DIR"
    echo "✓ Directory created"
else
    echo "✓ Development directory exists: $DEV_DIR"
fi

cd "$DEV_DIR"

# Clone framework repository
FRAMEWORK_DIR="$DEV_DIR/ofbiz-framework"
if [ -d "$FRAMEWORK_DIR" ]; then
    echo "Framework directory already exists: $FRAMEWORK_DIR"
    read -p "Pull latest changes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$FRAMEWORK_DIR"
        git pull
        echo "✓ Framework updated"
    fi
else
    echo "Cloning framework repository..."
    git clone "https://github.com/$GITHUB_USER/$FRAMEWORK_REPO.git" ofbiz-framework
    echo "✓ Framework cloned"
fi

# Clone plugins repository
PLUGINS_DIR="$DEV_DIR/ofbiz-plugins"
if [ -d "$PLUGINS_DIR" ]; then
    echo "Plugins directory already exists: $PLUGINS_DIR"
    read -p "Pull latest changes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$PLUGINS_DIR"
        git pull
        echo "✓ Plugins updated"
    fi
else
    echo "Cloning plugins repository..."
    git clone "https://github.com/$GITHUB_USER/$PLUGINS_REPO.git" ofbiz-plugins
    echo "✓ Plugins cloned"
fi

# Create/verify symlink
cd "$FRAMEWORK_DIR"
if [ -L "plugins" ]; then
    echo "✓ Plugins symlink already exists"
    LINK_TARGET=$(readlink plugins)
    if [ "$LINK_TARGET" != "../ofbiz-plugins" ]; then
        echo "WARNING: Symlink points to $LINK_TARGET instead of ../ofbiz-plugins"
        read -p "Fix symlink? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm plugins
            ln -sf ../ofbiz-plugins plugins
            echo "✓ Symlink fixed"
        fi
    fi
elif [ -d "plugins" ]; then
    echo "WARNING: 'plugins' is a directory, not a symlink!"
    echo "This should be a symlink to ../ofbiz-plugins"
    read -p "Remove directory and create symlink? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf plugins
        ln -sf ../ofbiz-plugins plugins
        echo "✓ Symlink created"
    fi
else
    echo "Creating plugins symlink..."
    ln -sf ../ofbiz-plugins plugins
    echo "✓ Symlink created"
fi

# Verify Java is installed
if ! command -v java &> /dev/null; then
    echo ""
    echo "WARNING: Java is not installed!"
    echo "OFBiz requires Java 11 or later."
    echo "Install with: sudo apt install openjdk-17-jdk"
else
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    echo "✓ Java version: $JAVA_VERSION"
    if [ "$JAVA_VERSION" -lt 11 ]; then
        echo "WARNING: Java 11 or later is recommended"
    fi
fi

# Verify Gradle wrapper
if [ -f "$FRAMEWORK_DIR/gradlew" ]; then
    echo "✓ Gradle wrapper found"
else
    echo "WARNING: Gradle wrapper not found!"
fi

echo ""
echo "==================================="
echo "✓ Clone Complete!"
echo "==================================="
echo ""
echo "Repository locations:"
echo "  Framework: $FRAMEWORK_DIR"
echo "  Plugins:   $PLUGINS_DIR"
echo ""
echo "Next steps:"
echo "1. Set up PostgreSQL database:"
echo "     cd $FRAMEWORK_DIR/docs/scripts"
echo "     ./setup-database.sh"
echo ""
echo "2. Configure database in entityengine.xml"
echo "   See: $FRAMEWORK_DIR/docs/FTM-SETUP-GUIDE.adoc"
echo ""
echo "3. Build OFBiz:"
echo "     cd $FRAMEWORK_DIR"
echo "     ./gradlew build"
echo ""
echo "4. Load initial data:"
echo "     ./gradlew loadAll"
echo ""
echo "5. Start OFBiz:"
echo "     ./gradlew ofbiz"
echo ""
echo "6. Access at: https://localhost:8443/accounting"
echo "   Default credentials: admin/ofbiz"
echo ""
