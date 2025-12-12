#!/bin/bash
# PostgreSQL database setup for FTM ERP
# Run this on rpitex Raspberry Pi 5

set -e  # Exit on error

echo "==================================="
echo "FTM ERP Database Setup"
echo "==================================="
echo ""

# Configuration
DB_NAME="ftmerp"
DB_USER="ftmuser"
DB_PASSWORD=""  # Will be prompted

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "PostgreSQL is not installed."
    read -p "Install PostgreSQL now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt update
        sudo apt install -y postgresql postgresql-contrib
        echo "✓ PostgreSQL installed"
    else
        echo "Please install PostgreSQL first:"
        echo "  sudo apt install postgresql postgresql-contrib"
        exit 1
    fi
fi

# Check if PostgreSQL is running
if ! sudo systemctl is-active --quiet postgresql; then
    echo "Starting PostgreSQL..."
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    echo "✓ PostgreSQL started"
else
    echo "✓ PostgreSQL is running"
fi

# Prompt for password
echo ""
echo "Enter a password for database user '$DB_USER':"
read -s DB_PASSWORD
echo ""
echo "Confirm password:"
read -s DB_PASSWORD_CONFIRM
echo ""

if [ "$DB_PASSWORD" != "$DB_PASSWORD_CONFIRM" ]; then
    echo "ERROR: Passwords do not match!"
    exit 1
fi

if [ -z "$DB_PASSWORD" ]; then
    echo "ERROR: Password cannot be empty!"
    exit 1
fi

# Check if database already exists
if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo "WARNING: Database '$DB_NAME' already exists!"
    read -p "Drop and recreate? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;"
        sudo -u postgres psql -c "DROP USER IF EXISTS $DB_USER;"
        echo "✓ Existing database dropped"
    else
        echo "Keeping existing database. Exiting."
        exit 0
    fi
fi

# Create database user
echo "Creating database user '$DB_USER'..."
sudo -u postgres psql << EOF
CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASSWORD';
ALTER USER $DB_USER WITH CREATEDB;
EOF
echo "✓ User created"

# Create database
echo "Creating database '$DB_NAME'..."
sudo -u postgres psql << EOF
CREATE DATABASE $DB_NAME OWNER $DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOF
echo "✓ Database created"

# Test connection
echo "Testing database connection..."
if PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -h localhost -c "SELECT version();" > /dev/null 2>&1; then
    echo "✓ Connection successful"
else
    echo "ERROR: Connection failed!"
    exit 1
fi

# Update pg_hba.conf for local connections (if needed)
PG_HBA_CONF=$(sudo -u postgres psql -t -P format=unaligned -c 'SHOW hba_file;')
echo ""
echo "PostgreSQL configuration file: $PG_HBA_CONF"
echo "Ensure local connections are allowed with password authentication."
echo ""

# Create configuration file for OFBiz
FRAMEWORK_DIR="$HOME/development/ofbiz-framework"
CONFIG_FILE="$FRAMEWORK_DIR/framework/entity/config/entityengine.xml"

if [ -f "$CONFIG_FILE" ]; then
    echo "Creating backup of entityengine.xml..."
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✓ Backup created"

    echo ""
    echo "IMPORTANT: You need to manually update the database configuration in:"
    echo "  $CONFIG_FILE"
    echo ""
    echo "Use these settings:"
    echo "  Database: $DB_NAME"
    echo "  Username: $DB_USER"
    echo "  Password: $DB_PASSWORD"
    echo "  JDBC URL: jdbc:postgresql://127.0.0.1/$DB_NAME"
    echo ""
    echo "See FTM-SETUP-GUIDE.adoc for the complete configuration."
else
    echo "WARNING: entityengine.xml not found at expected location"
    echo "Please configure manually when you have the OFBiz framework set up."
fi

# Create credentials file for reference (secured)
CREDS_FILE="$HOME/.ftmerp_db_credentials"
cat > "$CREDS_FILE" << EOF
# FTM ERP Database Credentials
# Created: $(date)
# WARNING: Keep this file secure!

DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=localhost
DB_PORT=5432
JDBC_URL=jdbc:postgresql://127.0.0.1/$DB_NAME

# PostgreSQL connection command:
# psql -U $DB_USER -d $DB_NAME -h localhost

# JDBC Driver (add to build.gradle):
# implementation 'org.postgresql:postgresql:42.7.1'
EOF
chmod 600 "$CREDS_FILE"
echo "✓ Credentials saved to $CREDS_FILE (secure)"

echo ""
echo "==================================="
echo "✓ Database Setup Complete!"
echo "==================================="
echo ""
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Host: localhost"
echo ""
echo "Credentials saved to: $CREDS_FILE"
echo ""
echo "Next steps:"
echo "1. Update entityengine.xml with database configuration"
echo "2. Add PostgreSQL JDBC driver to build.gradle"
echo "3. Run './gradlew loadAll' to load initial data"
echo "4. Start OFBiz with './gradlew ofbiz'"
echo ""
echo "To connect to the database:"
echo "  psql -U $DB_USER -d $DB_NAME -h localhost"
echo ""
