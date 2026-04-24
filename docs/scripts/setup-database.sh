#!/bin/bash
# PostgreSQL database setup for FTM ERP
# Creates three databases: ftmerp (main), ftm_enrollment (SCEP), ftm_ofbiz (analytics)
#
# IMPORTANT: This script uses placeholder passwords.
# Real passwords are managed in gradle.properties.local (gitignored)

set -e  # Exit on error

echo "==================================="
echo "FTM ERP Database Setup"
echo "==================================="
echo ""

# Configuration - Three-database architecture
DB_MAIN="ftmerp"
DB_ENROLLMENT="ftm_enrollment"
DB_OFBIZ="ftm_ofbiz"

USER_MAIN="ftmuser"
USER_ENROLLMENT="enrolladmin"
USER_OFBIZ="ofbizadmin"
USER_READONLY="mcp_readonly"

# Password placeholders - DO NOT put real passwords here
# Real passwords go in: ~/development/ofbiz-framework/gradle.properties.local
PASSWORD_MAIN="YOUR_FTMUSER_PASSWORD"
PASSWORD_ENROLLMENT="YOUR_ENROLLADMIN_PASSWORD"
PASSWORD_OFBIZ="YOUR_FTMOFBIZ_PASSWORD"
PASSWORD_READONLY="YOUR_MCP_READONLY_PASSWORD"

echo "This script will create three PostgreSQL databases:"
echo "  1. $DB_MAIN (owner: $USER_MAIN) - Main ERP database"
echo "  2. $DB_ENROLLMENT (owner: $USER_ENROLLMENT) - SCEP enrollment system"
echo "  3. $DB_OFBIZ (owner: $USER_OFBIZ) - Analytics/OLAP database"
echo ""
echo "Plus read-only user: $USER_READONLY (for MCP server)"
echo ""

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

echo ""
echo "======================================================"
echo "IMPORTANT: Password Configuration"
echo "======================================================"
echo ""
echo "This script will prompt you to enter passwords for database users."
echo "After database setup, you MUST add these passwords to:"
echo ""
echo "  ~/development/ofbiz-framework/gradle.properties.local"
echo ""
echo "Example gradle.properties.local content:"
echo ""
echo "  # Database passwords (gitignored - safe to store real passwords)"
echo "  dbPassword.ftmuser=<password_you_enter_for_ftmuser>"
echo "  dbPassword.enrolladmin=<password_you_enter_for_enrolladmin>"
echo "  dbPassword.ftmofbiz=<password_you_enter_for_ofbizadmin>"
echo "  dbPassword.mcp_readonly=<password_you_enter_for_mcp_readonly>"
echo ""
echo "Also add to ~/.pgpass for command-line access:"
echo ""
echo "  localhost:5432:ftmerp:ftmuser:<password_you_enter_for_ftmuser>"
echo "  localhost:5432:ftm_enrollment:enrolladmin:<password_for_enrolladmin>"
echo "  localhost:5432:ftm_ofbiz:ofbizadmin:<password_for_ofbizadmin>"
echo "  localhost:5432:*:mcp_readonly:<password_for_mcp_readonly>"
echo ""
read -p "Press Enter to continue..."
echo ""

# Function to create database and user
create_database() {
    local db_name=$1
    local db_user=$2
    local db_password=$3
    local db_description=$4

    echo ""
    echo "Setting up: $db_description"
    echo "Database: $db_name, User: $db_user"
    echo ""

    # Prompt for password
    echo "Enter password for database user '$db_user':"
    read -s USER_PASSWORD
    echo ""
    echo "Confirm password:"
    read -s USER_PASSWORD_CONFIRM
    echo ""

    if [ "$USER_PASSWORD" != "$USER_PASSWORD_CONFIRM" ]; then
        echo "ERROR: Passwords do not match!"
        return 1
    fi

    if [ -z "$USER_PASSWORD" ]; then
        echo "ERROR: Password cannot be empty!"
        return 1
    fi

    # Check if database already exists
    if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$db_name"; then
        echo "WARNING: Database '$db_name' already exists!"
        read -p "Drop and recreate? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo -u postgres psql -c "DROP DATABASE IF EXISTS $db_name;"
            sudo -u postgres psql -c "DROP USER IF EXISTS $db_user;"
            echo "✓ Existing database dropped"
        else
            echo "Skipping $db_name"
            return 0
        fi
    fi

    # Create database user
    echo "Creating database user '$db_user'..."
    sudo -u postgres psql << EOF
CREATE USER $db_user WITH ENCRYPTED PASSWORD '$USER_PASSWORD';
ALTER USER $db_user WITH CREATEDB;
EOF
    echo "✓ User created"

    # Create database
    echo "Creating database '$db_name'..."
    sudo -u postgres psql << EOF
CREATE DATABASE $db_name OWNER $db_user;
GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;
EOF
    echo "✓ Database created"

    # Test connection
    echo "Testing database connection..."
    if PGPASSWORD="$USER_PASSWORD" psql -U "$db_user" -d "$db_name" -h localhost -c "SELECT version();" > /dev/null 2>&1; then
        echo "✓ Connection successful"
    else
        echo "ERROR: Connection failed!"
        return 1
    fi

    # Save password hint to credentials file
    echo ""
    echo "Add this to ~/development/ofbiz-framework/gradle.properties.local:"
    echo "  dbPassword.$db_user=<the_password_you_just_entered>"
    echo ""
    echo "Add this to ~/.pgpass:"
    echo "  localhost:5432:$db_name:$db_user:<the_password_you_just_entered>"
    echo ""
}

# Create main ERP database
create_database "$DB_MAIN" "$USER_MAIN" "$PASSWORD_MAIN" "Main ERP Database"

# Create enrollment database
create_database "$DB_ENROLLMENT" "$USER_ENROLLMENT" "$PASSWORD_ENROLLMENT" "SCEP Enrollment Database"

# Create analytics database
create_database "$DB_OFBIZ" "$USER_OFBIZ" "$PASSWORD_OFBIZ" "Analytics/OLAP Database"

# Create read-only user for MCP server
echo ""
echo "Setting up read-only user for MCP server..."
echo "User: $USER_READONLY (read access to all three databases)"
echo ""

echo "Enter password for read-only user '$USER_READONLY':"
read -s READONLY_PASSWORD
echo ""
echo "Confirm password:"
read -s READONLY_PASSWORD_CONFIRM
echo ""

if [ "$READONLY_PASSWORD" != "$READONLY_PASSWORD_CONFIRM" ]; then
    echo "ERROR: Passwords do not match!"
    exit 1
fi

if [ -z "$READONLY_PASSWORD" ]; then
    echo "ERROR: Password cannot be empty!"
    exit 1
fi

# Check if user already exists
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$USER_READONLY'" | grep -q 1; then
    echo "WARNING: User '$USER_READONLY' already exists!"
    read -p "Drop and recreate? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo -u postgres psql -c "DROP USER IF EXISTS $USER_READONLY;"
        echo "✓ Existing user dropped"
    else
        echo "Skipping read-only user creation"
    fi
fi

# Create read-only user
echo "Creating read-only user '$USER_READONLY'..."
sudo -u postgres psql << EOF
CREATE USER $USER_READONLY WITH ENCRYPTED PASSWORD '$READONLY_PASSWORD';
GRANT CONNECT ON DATABASE $DB_MAIN TO $USER_READONLY;
GRANT CONNECT ON DATABASE $DB_ENROLLMENT TO $USER_READONLY;
GRANT CONNECT ON DATABASE $DB_OFBIZ TO $USER_READONLY;
EOF
echo "✓ Read-only user created"

# Grant read permissions on all tables (will be applied when tables are created)
for db in "$DB_MAIN" "$DB_ENROLLMENT" "$DB_OFBIZ"; do
    sudo -u postgres psql -d "$db" << EOF
GRANT USAGE ON SCHEMA public TO $USER_READONLY;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO $USER_READONLY;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO $USER_READONLY;
EOF
done
echo "✓ Read permissions granted"

echo ""
echo "Add this to ~/development/ofbiz-framework/gradle.properties.local:"
echo "  dbPassword.$USER_READONLY=<the_password_you_just_entered>"
echo ""
echo "Add this to ~/.pgpass:"
echo "  localhost:5432:*:$USER_READONLY:<the_password_you_just_entered>"
echo ""

# Update pg_hba.conf for local connections (if needed)
PG_HBA_CONF=$(sudo -u postgres psql -t -P format=unaligned -c 'SHOW hba_file;')
echo ""
echo "PostgreSQL configuration file: $PG_HBA_CONF"
echo "Ensure local connections are allowed with password authentication."
echo ""

echo ""
echo "==================================="
echo "✓ Database Setup Complete!"
echo "==================================="
echo ""
echo "Databases created:"
echo "  1. $DB_MAIN (owner: $USER_MAIN) - Main ERP"
echo "  2. $DB_ENROLLMENT (owner: $USER_ENROLLMENT) - SCEP Enrollment"
echo "  3. $DB_OFBIZ (owner: $USER_OFBIZ) - Analytics/OLAP"
echo ""
echo "Users created:"
echo "  - $USER_MAIN (full access to $DB_MAIN)"
echo "  - $USER_ENROLLMENT (full access to $DB_ENROLLMENT)"
echo "  - $USER_OFBIZ (full access to $DB_OFBIZ)"
echo "  - $USER_READONLY (read-only access to all databases)"
echo ""
echo "======================================================"
echo "NEXT STEPS - CRITICAL!"
echo "======================================================"
echo ""
echo "1. Create ~/development/ofbiz-framework/gradle.properties.local:"
echo ""
echo "   cat > ~/development/ofbiz-framework/gradle.properties.local << 'EOF'"
echo "   # Database passwords (gitignored - safe to store real passwords)"
echo "   dbPassword.ftmuser=<password_you_entered_for_ftmuser>"
echo "   dbPassword.enrolladmin=<password_you_entered_for_enrolladmin>"
echo "   dbPassword.ftmofbiz=<password_you_entered_for_ofbizadmin>"
echo "   dbPassword.mcp_readonly=<password_you_entered_for_mcp_readonly>"
echo "   EOF"
echo ""
echo "2. Create ~/.pgpass for command-line PostgreSQL access:"
echo ""
echo "   cat > ~/.pgpass << 'EOF'"
echo "   localhost:5432:ftmerp:ftmuser:<password_for_ftmuser>"
echo "   localhost:5432:ftm_enrollment:enrolladmin:<password_for_enrolladmin>"
echo "   localhost:5432:ftm_ofbiz:ofbizadmin:<password_for_ofbizadmin>"
echo "   localhost:5432:*:mcp_readonly:<password_for_mcp_readonly>"
echo "   EOF"
echo ""
echo "   chmod 600 ~/.pgpass"
echo ""
echo "3. Update entityengine.xml (framework/entity/config/entityengine.xml)"
echo "   - Database passwords are loaded from gradle.properties.local"
echo "   - See docs/POSTGRESQL-SETUP.md for configuration details"
echo ""
echo "4. Build and load data:"
echo "   cd ~/development/ofbiz-framework"
echo "   ./gradlew build"
echo "   ./gradlew loadAll"
echo ""
echo "To connect to databases:"
echo "  psql -U $USER_MAIN -d $DB_MAIN -h localhost"
echo "  psql -U $USER_ENROLLMENT -d $DB_ENROLLMENT -h localhost"
echo "  psql -U $USER_OFBIZ -d $DB_OFBIZ -h localhost"
echo "  psql -U $USER_READONLY -d $DB_MAIN -h localhost  # Read-only"
echo ""
