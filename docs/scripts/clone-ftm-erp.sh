#!/bin/bash
# Clone FTM ERP repositories (framework + plugins)
# Use this script to set up FTM ERP on a new development machine
#
# Usage:
#   ./clone-ftm-erp.sh                    # Use default branch (feature/ftm-garments)
#   ./clone-ftm-erp.sh --branch main      # Use specific branch

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
PLUGINS_BRANCH="feature/ftm-garments"  # Default branch

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --branch)
            PLUGINS_BRANCH="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --branch <name>    Checkout specific plugins branch (default: feature/ftm-garments)"
            echo "  -h, --help         Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "Configuration:"
echo "  Development directory: $DEV_DIR"
echo "  Plugins branch: $PLUGINS_BRANCH"
echo ""

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

    # Checkout specified branch
    cd "$PLUGINS_DIR"
    if git show-ref --verify --quiet "refs/heads/$PLUGINS_BRANCH"; then
        echo "Checking out existing branch: $PLUGINS_BRANCH"
        git checkout "$PLUGINS_BRANCH"
    elif git show-ref --verify --quiet "refs/remotes/origin/$PLUGINS_BRANCH"; then
        echo "Checking out remote branch: $PLUGINS_BRANCH"
        git checkout -b "$PLUGINS_BRANCH" "origin/$PLUGINS_BRANCH"
    else
        echo "WARNING: Branch '$PLUGINS_BRANCH' not found, staying on default branch"
    fi
    echo "✓ Branch: $(git branch --show-current)"
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

# Configure git to ignore local database configuration changes
echo ""
echo "Configuring git to ignore local database changes..."
ENTITYENGINE_XML="framework/entity/config/entityengine.xml"
if [ -f "$ENTITYENGINE_XML" ]; then
    # Check if already ignored
    if git ls-files --error-unmatch "$ENTITYENGINE_XML" > /dev/null 2>&1; then
        # File is tracked, mark as assume-unchanged
        git update-index --assume-unchanged "$ENTITYENGINE_XML"
        echo "✓ Git will ignore local changes to entityengine.xml"
        echo "  (Database credentials can be customized without affecting git)"
    else
        echo "✓ entityengine.xml is not tracked"
    fi
else
    echo "! entityengine.xml not found (will be created during build)"
fi

# Verify Java is installed
echo ""
if ! command -v java &> /dev/null; then
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

# Check for password configuration file
echo ""
GRADLE_PROPS="$FRAMEWORK_DIR/gradle.properties.local"
if [ -f "$GRADLE_PROPS" ]; then
    echo "✓ Found gradle.properties.local (passwords configured)"
else
    echo "⚠ Password configuration file not found"
    echo ""
    echo "IMPORTANT: Database passwords must be configured!"
    echo ""
    echo "Create $GRADLE_PROPS with:"
    echo ""
    echo "  # Database passwords (gitignored - safe to store real passwords)"
    echo "  dbPassword.ftmuser=YOUR_FTMUSER_PASSWORD"
    echo "  dbPassword.enrolladmin=YOUR_ENROLLADMIN_PASSWORD"
    echo "  dbPassword.ftmofbiz=YOUR_FTMOFBIZ_PASSWORD"
    echo ""
    echo "Replace YOUR_* placeholders with actual passwords from your secure storage."
    echo ""
fi

echo ""
echo "==================================="
echo "✓ Clone Complete!"
echo "==================================="
echo ""
echo "Repository locations:"
echo "  Framework: $FRAMEWORK_DIR"
echo "  Plugins:   $PLUGINS_DIR (branch: $PLUGINS_BRANCH)"
echo ""
echo "Next steps:"
echo ""
echo "1. Configure database passwords in gradle.properties.local:"
echo "     cd $FRAMEWORK_DIR"
echo "     cat > gradle.properties.local << 'EOF'"
echo "     dbPassword.ftmuser=YOUR_FTMUSER_PASSWORD"
echo "     dbPassword.enrolladmin=YOUR_ENROLLADMIN_PASSWORD"
echo "     dbPassword.ftmofbiz=YOUR_FTMOFBIZ_PASSWORD"
echo "     EOF"
echo ""
echo "2. Set up PostgreSQL databases (if not already configured):"
echo "     cd $FRAMEWORK_DIR/docs/scripts"
echo "     ./setup-database.sh"
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
echo "6. Access at: http://192.168.2.110:8080/webtools"
echo "   Default credentials: admin/ofbiz"
echo ""
echo "For detailed setup instructions, see:"
echo "  - docs/POSTGRESQL-SETUP.md"
echo "  - docs/QUICK-START.md"
echo "  - docs/MAKE-TO-ORDER-WORKFLOW.md"
echo ""
