#!/bin/bash
# Setup HTTPS/SSL for OFBiz with self-signed certificate
# Run this from the ofbiz-framework root directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OFBIZ_ROOT="${OFBIZ_ROOT:-$HOME/development/ofbiz-framework}"

echo "=== OFBiz HTTPS/SSL Setup ==="
echo ""
echo "This script will:"
echo "  1. Generate a self-signed SSL certificate"
echo "  2. Configure Catalina for HTTPS"
echo "  3. Backup existing configuration"
echo ""

# Check we're in the right place
if [ ! -f "$OFBIZ_ROOT/build.gradle" ]; then
    echo "Error: Cannot find OFBiz installation at $OFBIZ_ROOT"
    echo "Please run this script from the ofbiz-framework directory or set OFBIZ_ROOT"
    exit 1
fi

cd "$OFBIZ_ROOT"

# Configuration
KEYSTORE_DIR="framework/catalina/config"
KEYSTORE_FILE="$KEYSTORE_DIR/ofbiz-keystore"
KEYSTORE_PASS="${KEYSTORE_PASS:-changeit}"
KEY_ALIAS="ofbizssl"
CERT_VALIDITY="365"

# Get hostname/IP for certificate
HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "Certificate will be created for:"
echo "  Hostname: $HOSTNAME"
echo "  IP Address: $IP_ADDRESS"
echo ""

# Prompt for certificate details
read -p "Organization Name [FTM Garments]: " ORG_NAME
ORG_NAME=${ORG_NAME:-"FTM Garments"}

read -p "Organizational Unit [IT Department]: " ORG_UNIT
ORG_UNIT=${ORG_UNIT:-"IT Department"}

read -p "City [Mbabane]: " CITY
CITY=${CITY:-"Mbabane"}

read -p "State/Province [Hhohho]: " STATE
STATE=${STATE:-"Hhohho"}

read -p "Country Code [SZ]: " COUNTRY
COUNTRY=${COUNTRY:-"SZ"}

echo ""
echo "Creating certificate for:"
echo "  CN=$HOSTNAME"
echo "  OU=$ORG_UNIT"
echo "  O=$ORG_NAME"
echo "  L=$CITY"
echo "  ST=$STATE"
echo "  C=$COUNTRY"
echo ""

read -p "Continue? [Y/n]: " CONFIRM
CONFIRM=${CONFIRM:-Y}
if [[ ! $CONFIRM =~ ^[Yy] ]]; then
    echo "Cancelled."
    exit 0
fi

# Create keystore directory
echo "Creating keystore directory..."
mkdir -p "$KEYSTORE_DIR"

# Backup existing keystore
if [ -f "$KEYSTORE_FILE" ]; then
    BACKUP_FILE="${KEYSTORE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing keystore to: $BACKUP_FILE"
    cp "$KEYSTORE_FILE" "$BACKUP_FILE"
fi

# Generate self-signed certificate
echo "Generating self-signed certificate..."
keytool -genkey -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity "$CERT_VALIDITY" \
    -keystore "$KEYSTORE_FILE" \
    -storepass "$KEYSTORE_PASS" \
    -keypass "$KEYSTORE_PASS" \
    -dname "CN=$HOSTNAME, OU=$ORG_UNIT, O=$ORG_NAME, L=$CITY, ST=$STATE, C=$COUNTRY" \
    -ext "SAN=DNS:$HOSTNAME,DNS:localhost,IP:$IP_ADDRESS,IP:127.0.0.1"

echo "✓ Certificate created successfully"
echo ""

# Verify certificate
echo "Certificate details:"
keytool -list -v -keystore "$KEYSTORE_FILE" -storepass "$KEYSTORE_PASS" -alias "$KEY_ALIAS" | grep -A 5 "Owner:"
echo ""

# Backup ofbiz-component.xml
CATALINA_CONFIG="framework/catalina/ofbiz-component.xml"
if [ -f "$CATALINA_CONFIG" ]; then
    BACKUP_CONFIG="${CATALINA_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backing up $CATALINA_CONFIG to: $BACKUP_CONFIG"
    cp "$CATALINA_CONFIG" "$BACKUP_CONFIG"
fi

echo ""
echo "=== HTTPS Setup Complete! ==="
echo ""
echo "Keystore location: $KEYSTORE_FILE"
echo "Keystore password: $KEYSTORE_PASS"
echo "Certificate alias: $KEY_ALIAS"
echo "Valid for: $CERT_VALIDITY days"
echo ""
echo "Next steps:"
echo "  1. Update framework/catalina/ofbiz-component.xml with HTTPS connector configuration"
echo "  2. Restart OFBiz: ./gradlew 'ofbiz --shutdown' && ./gradlew ofbiz"
echo "  3. Access via HTTPS: https://$IP_ADDRESS:8443/webtools"
echo ""
echo "See docs/HTTPS-SSL-SETUP.md for detailed configuration instructions."
echo ""

# Offer to show example configuration
read -p "Show example HTTPS connector configuration? [Y/n]: " SHOW_CONFIG
SHOW_CONFIG=${SHOW_CONFIG:-Y}
if [[ $SHOW_CONFIG =~ ^[Yy] ]]; then
    echo ""
    echo "Add this to framework/catalina/ofbiz-component.xml:"
    echo ""
    cat <<'EOF'
<!-- HTTPS Connector (Modern Tomcat 8+ Style) -->
<property name="https-connector" value="connector">
    <property name="port" value="8443"/>
    <property name="protocol" value="org.apache.coyote.http11.Http11NioProtocol"/>
    <property name="maxThreads" value="150"/>
    <property name="connectionTimeout" value="20000"/>
    <property name="acceptCount" value="100"/>
    <property name="URIEncoding" value="UTF-8"/>

    <!-- SSL/TLS Configuration -->
    <property name="SSLEnabled" value="true"/>
    <property name="scheme" value="https"/>
    <property name="secure" value="true"/>
    <property name="clientAuth" value="false"/>
    <property name="sslProtocol" value="TLS"/>

    <!-- Keystore Configuration -->
    <property name="keystoreFile" value="framework/catalina/config/ofbiz-keystore"/>
    <property name="keystorePass" value="changeit"/>
    <property name="keystoreType" value="JKS"/>
    <property name="keyAlias" value="ofbizssl"/>

    <!-- Modern TLS Protocols -->
    <property name="sslEnabledProtocols" value="TLSv1.2,TLSv1.3"/>

    <!-- Strong Cipher Suites -->
    <property name="ciphers" value="TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256"/>

    <!-- Compression -->
    <property name="compression" value="on"/>
    <property name="compressibleMimeType" value="text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/json"/>
</property>
EOF
    echo ""
fi

echo "Done!"
