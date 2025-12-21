# HTTPS/SSL/TLS Setup for OFBiz

This guide explains how to configure HTTPS with self-signed certificates for Apache OFBiz using the internal Catalina (Tomcat) web servlet.

## Overview

OFBiz uses Apache Tomcat's Catalina container for serving web applications. Modern versions (OFBiz 24.09+) use Tomcat 8+ style connector definitions.

## Quick Setup

### 1. Generate Self-Signed Certificate

```bash
cd ~/development/ofbiz-framework

# Create keystore directory if it doesn't exist
mkdir -p framework/catalina/config

# Generate self-signed certificate (valid for 365 days)
keytool -genkey -alias ofbizssl \
  -keyalg RSA -keysize 2048 \
  -validity 365 \
  -keystore framework/catalina/config/ofbiz-keystore \
  -storepass changeit \
  -keypass changeit \
  -dname "CN=rpitex.local, OU=FTM Garments, O=FTM Swaziland, L=Mbabane, ST=Hhohho, C=SZ"

# Verify the keystore was created
ls -lh framework/catalina/config/ofbiz-keystore
keytool -list -keystore framework/catalina/config/ofbiz-keystore -storepass changeit
```

**Certificate Details**:
- **Alias**: ofbizssl
- **Algorithm**: RSA 2048-bit
- **Validity**: 365 days
- **Password**: changeit (⚠️ **change for production!**)

### 2. Configure HTTPS Connector (Modern Tomcat 8+ Style)

Edit `framework/catalina/ofbiz-component.xml` and update the HTTPS connector configuration:

**OLD Style (Deprecated)**:
```xml
<property name="https-connector" value="connector">
    <property name="port" value="8443"/>
    <property name="protocol" value="org.apache.coyote.http11.Http11NioProtocol"/>
    <!-- nested properties... -->
</property>
```

**NEW Style (Tomcat 8+)**:
```xml
<!-- HTTPS Connector (Modern Tomcat 8+ Style) -->
<property name="https-connector" value="connector">
    <property name="port" value="8443"/>
    <property name="protocol" value="org.apache.coyote.http11.Http11NioProtocol"/>
    <property name="maxThreads" value="150"/>
    <property name="SSLEnabled" value="true"/>
    <property name="scheme" value="https"/>
    <property name="secure" value="true"/>
    <property name="clientAuth" value="false"/>
    <property name="sslProtocol" value="TLS"/>
    <property name="keystoreFile" value="framework/catalina/config/ofbiz-keystore"/>
    <property name="keystorePass" value="changeit"/>
    <property name="keystoreType" value="JKS"/>
    <property name="keyAlias" value="ofbizssl"/>
    <property name="sslEnabledProtocols" value="TLSv1.2,TLSv1.3"/>
    <property name="ciphers" value="TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256"/>
</property>
```

### 3. Complete ofbiz-component.xml Example

Here's a complete example for `framework/catalina/ofbiz-component.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ofbiz-component name="catalina"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="https://ofbiz.apache.org/dtds/ofbiz-component.xsd">

    <resource-loader name="main" type="component"/>

    <!-- Catalina Container Configuration -->
    <container name="catalina-container" loaders="main" class="org.apache.ofbiz.catalina.container.CatalinaContainer">

        <!-- General Server Settings -->
        <property name="apps-context-reloadable" value="false"/>
        <property name="apps-cross-context" value="false"/>
        <property name="apps-distributable" value="false"/>

        <!-- Default Server (Engine) -->
        <property name="default-server" value="engine">
            <property name="default-host" value="0.0.0.0"/>
            <property name="jvm-route" value="jvm1"/>
            <property name="access-log-pattern">
                <property-value>%h %l %u %t "%r" %s %b "%{Referer}i" "%{User-Agent}i"</property-value>
            </property>
            <property name="access-log-rotate" value="true"/>
            <property name="access-log-prefix" value="access_log"/>
            <property name="access-log-dir" value="runtime/logs"/>
            <property name="access-log-maxDays" value="30"/>
            <property name="enable-request-dump" value="false"/>
        </property>

        <!-- HTTP Connector (port 8080) -->
        <property name="http-connector" value="connector">
            <property name="port" value="8080"/>
            <property name="protocol" value="HTTP/1.1"/>
            <property name="connectionTimeout" value="20000"/>
            <property name="maxThreads" value="150"/>
            <property name="minSpareThreads" value="25"/>
            <property name="maxSpareThreads" value="75"/>
            <property name="enableLookups" value="false"/>
            <property name="redirectPort" value="8443"/>
            <property name="acceptCount" value="100"/>
            <property name="URIEncoding" value="UTF-8"/>
            <property name="compression" value="on"/>
            <property name="compressibleMimeType" value="text/html,text/xml,text/plain,text/css,text/javascript,application/javascript"/>
        </property>

        <!-- HTTPS Connector (port 8443) - Modern Tomcat 8+ Style -->
        <property name="https-connector" value="connector">
            <property name="port" value="8443"/>
            <property name="protocol" value="org.apache.coyote.http11.Http11NioProtocol"/>
            <property name="maxThreads" value="150"/>
            <property name="minSpareThreads" value="25"/>
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

            <!-- Modern TLS Protocols (disable old/insecure protocols) -->
            <property name="sslEnabledProtocols" value="TLSv1.2,TLSv1.3"/>

            <!-- Strong Cipher Suites (PCI DSS compliant) -->
            <property name="ciphers" value="TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256"/>

            <!-- Compression for HTTPS -->
            <property name="compression" value="on"/>
            <property name="compressibleMimeType" value="text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/json"/>
        </property>

        <!-- AJP Connector (for load balancers like Apache/Nginx) -->
        <property name="ajp-connector" value="connector">
            <property name="port" value="8009"/>
            <property name="protocol" value="AJP/1.3"/>
            <property name="redirectPort" value="8443"/>
            <property name="URIEncoding" value="UTF-8"/>
            <property name="secretRequired" value="false"/>
        </property>

    </container>

    <!-- Root Web Application -->
    <webapp name="ROOT"
            title="Root"
            server="default-server"
            location="webapp/ROOT"
            mount-point="/"
            app-bar-display="false"/>

</ofbiz-component>
```

### 4. Test HTTPS Configuration

```bash
cd ~/development/ofbiz-framework

# Stop OFBiz if running
./gradlew "ofbiz --shutdown"

# Clean build
./gradlew clean

# Start OFBiz
./gradlew ofbiz
```

### 5. Access OFBiz via HTTPS

Open your browser and navigate to:
- **HTTPS**: https://192.168.2.110:8443/webtools
- **HTTP**: http://192.168.2.110:8080/webtools (will redirect to HTTPS)

**Accept the Self-Signed Certificate Warning**:
- Chrome: Click "Advanced" → "Proceed to 192.168.2.110 (unsafe)"
- Firefox: Click "Advanced" → "Accept the Risk and Continue"

## Production Setup

### 1. Use a Proper Certificate Authority (CA)

For production, obtain a certificate from a trusted CA:

**Option A: Let's Encrypt (Free)**
```bash
# Install certbot
sudo apt install certbot

# Generate certificate
sudo certbot certonly --standalone -d your-domain.com

# Convert to JKS format
openssl pkcs12 -export \
  -in /etc/letsencrypt/live/your-domain.com/fullchain.pem \
  -inkey /etc/letsencrypt/live/your-domain.com/privkey.pem \
  -out ofbiz-cert.p12 \
  -name ofbizssl

keytool -importkeystore \
  -srckeystore ofbiz-cert.p12 -srcstoretype PKCS12 \
  -destkeystore framework/catalina/config/ofbiz-keystore \
  -deststoretype JKS \
  -alias ofbizssl
```

**Option B: Commercial CA**
- Purchase certificate from DigiCert, GlobalSign, etc.
- Follow CA's instructions to generate CSR and obtain certificate
- Import into JKS keystore

### 2. Strengthen Security

**Update ofbiz-component.xml for production**:

```xml
<!-- Production HTTPS Connector -->
<property name="https-connector" value="connector">
    <!-- ... basic settings ... -->

    <!-- Force TLSv1.3 only (if supported by all clients) -->
    <property name="sslEnabledProtocols" value="TLSv1.3"/>

    <!-- PCI DSS 4.0 compliant ciphers -->
    <property name="ciphers" value="TLS_AES_256_GCM_SHA384,TLS_CHACHA20_POLY1305_SHA256,TLS_AES_128_GCM_SHA256"/>

    <!-- Enable HTTP Strict Transport Security (HSTS) -->
    <property name="maxHttpHeaderSize" value="8192"/>

    <!-- Disable client renegotiation -->
    <property name="allowUnsafeLegacyRenegotiation" value="false"/>
</property>
```

**Add security headers** in `framework/common/webcommon/WEB-INF/web.xml`:

```xml
<filter>
    <filter-name>httpHeaderSecurityFilter</filter-name>
    <filter-class>org.apache.catalina.filters.HttpHeaderSecurityFilter</filter-class>
    <init-param>
        <param-name>hstsEnabled</param-name>
        <param-value>true</param-value>
    </init-param>
    <init-param>
        <param-name>hstsMaxAgeSeconds</param-name>
        <param-value>31536000</param-value>
    </init-param>
</filter>
```

### 3. Change Default Password

```bash
# Generate strong password
STRONG_PASS=$(openssl rand -base64 24)
echo "New keystore password: $STRONG_PASS"

# Create new keystore with strong password
keytool -genkey -alias ofbizssl \
  -keyalg RSA -keysize 4096 \
  -validity 825 \
  -keystore framework/catalina/config/ofbiz-keystore \
  -storepass "$STRONG_PASS" \
  -keypass "$STRONG_PASS" \
  -dname "CN=your-domain.com, OU=IT, O=Your Company, L=City, ST=State, C=US"

# Update ofbiz-component.xml with new password
# <property name="keystorePass" value="YOUR_STRONG_PASSWORD"/>
```

**⚠️ Security Warning**: Never commit passwords to version control!

## Troubleshooting

### Certificate Errors

**Problem**: Browser shows "NET::ERR_CERT_AUTHORITY_INVALID"

**Solution**: This is normal for self-signed certificates. For development, accept the warning. For production, use a proper CA certificate.

### Port Already in Use

```bash
# Check what's using port 8443
sudo netstat -tlnp | grep 8443
# OR
sudo ss -tlnp | grep 8443

# Kill the process if needed
sudo kill -9 <PID>
```

### Keystore Not Found

```bash
# Verify keystore location
ls -la framework/catalina/config/ofbiz-keystore

# Check keystoreFile path in ofbiz-component.xml matches actual location
grep keystoreFile framework/catalina/ofbiz-component.xml
```

### Wrong Password

```bash
# Reset keystore password
keytool -storepasswd \
  -keystore framework/catalina/config/ofbiz-keystore \
  -storepass changeit \
  -new <new-password>

# Update ofbiz-component.xml with new password
```

### TLS Version Errors

If clients can't connect due to TLS version:

```xml
<!-- Allow TLSv1.2 for older clients -->
<property name="sslEnabledProtocols" value="TLSv1.2,TLSv1.3"/>
```

## Verification

### Check Certificate Details

```bash
# View certificate in keystore
keytool -list -v \
  -keystore framework/catalina/config/ofbiz-keystore \
  -storepass changeit \
  -alias ofbizssl
```

### Test SSL/TLS Configuration

```bash
# Test with OpenSSL
openssl s_client -connect localhost:8443 -showcerts

# Test specific TLS version
openssl s_client -connect localhost:8443 -tls1_2
openssl s_client -connect localhost:8443 -tls1_3

# Check cipher suites
nmap --script ssl-enum-ciphers -p 8443 localhost
```

### Online SSL Testing

For production sites, use online tools:
- **SSL Labs**: https://www.ssllabs.com/ssltest/
- **SecurityHeaders.com**: https://securityheaders.com/
- **Mozilla Observatory**: https://observatory.mozilla.org/

## Network Access Configuration

### Allow HTTPS from Other Machines

```bash
# Check firewall
sudo ufw status

# Allow HTTPS
sudo ufw allow 8443/tcp

# Allow HTTP
sudo ufw allow 8080/tcp
```

### Access from Network

From other machines on your network (192.168.2.x):
- https://192.168.2.110:8443/webtools
- http://192.168.2.110:8080/webtools (redirects to HTTPS)

## Best Practices

### Development Environment

1. ✅ Use self-signed certificates
2. ✅ Keep default password (changeit) for convenience
3. ✅ Test with browser certificate warnings accepted
4. ✅ Use TLSv1.2 and TLSv1.3
5. ✅ Document certificate expiration dates

### Production Environment

1. ✅ Use certificates from trusted CA
2. ✅ Use strong, randomly generated passwords
3. ✅ Store passwords in secure vault (not in code)
4. ✅ Use TLSv1.3 only (if possible)
5. ✅ Enable HSTS and security headers
6. ✅ Renew certificates before expiration
7. ✅ Monitor certificate validity
8. ✅ Use 4096-bit RSA or ECDSA certificates
9. ✅ Regular security audits with SSL Labs
10. ✅ Keep Tomcat and OFBiz updated

## References

- [Apache Tomcat SSL Configuration](https://tomcat.apache.org/tomcat-9.0-doc/ssl-howto.html)
- [OFBiz Security Guide](https://cwiki.apache.org/confluence/display/OFBIZ/Security)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [OWASP TLS Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Protection_Cheat_Sheet.html)

## Related Documentation

- [QUICK-START.md](./QUICK-START.md) - OFBiz setup and daily workflow
- [POSTGRESQL-SETUP.md](./POSTGRESQL-SETUP.md) - Database configuration
- [OFBIZ-LEARNING-GUIDE.md](./OFBIZ-LEARNING-GUIDE.md) - OFBiz concepts
