# PostgreSQL Database Setup for FTM ERP

This document describes the PostgreSQL database configuration for the FTM ERP OFBiz system.

## Database Configuration

The FTM ERP system uses PostgreSQL with three separate databases for different purposes:

### Database Overview

| Database | Purpose | Owner | Usage |
|----------|---------|-------|-------|
| `ftmerp` | Main operational data | `ftmuser` | All standard OFBiz entities and transactions |
| `ofbizolap` | Analytics/OLAP data | `ftmuser` | Business intelligence and reporting data |
| `ofbiztenant` | Multi-tenant data | `ftmuser` | Tenant-specific data for multi-tenancy support |

### Database User

- **Username:** `ftmuser`
- **Password:** `FTMIT@2026`
- **Privileges:** CREATEDB, full access to all three databases

## Initial Setup

### 1. Create PostgreSQL User

```bash
sudo -u postgres psql -c "CREATE USER ftmuser WITH PASSWORD 'FTMIT@2026' CREATEDB;"
```

### 2. Create Databases

```bash
# Main database
sudo -u postgres psql -c "CREATE DATABASE ftmerp OWNER ftmuser;"

# OLAP database for analytics
sudo -u postgres psql -c "CREATE DATABASE ofbizolap OWNER ftmuser;"

# Tenant database for multi-tenancy
sudo -u postgres psql -c "CREATE DATABASE ofbiztenant OWNER ftmuser;"
```

### 3. Grant Privileges

```bash
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ftmerp TO ftmuser;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ofbizolap TO ftmuser;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ofbiztenant TO ftmuser;"
```

### 4. Verify Setup

```bash
# Check databases exist
sudo -u postgres psql -c "\l" | grep -E "ftmerp|ofbizolap|ofbiztenant"

# Check user exists
sudo -u postgres psql -c "\du ftmuser"

# Test connection
PGPASSWORD='FTMIT@2026' psql -U ftmuser -d ftmerp -h 127.0.0.1 -c "SELECT version();"
```

## OFBiz Configuration

The database configuration is defined in:
```
ofbiz-framework/framework/entity/config/entityengine.xml
```

### Main Datasource (localpostgres)

```xml
<datasource name="localpostgres"
    helper-class="org.apache.ofbiz.entity.datasource.GenericHelperDAO"
    field-type-name="postgres"
    check-on-start="true"
    add-missing-on-start="true">
    <read-data reader-name="seed"/>
    <read-data reader-name="seed-initial"/>
    <read-data reader-name="demo"/>
    <read-data reader-name="ext"/>
    <inline-jdbc
        jdbc-driver="org.postgresql.Driver"
        jdbc-uri="jdbc:postgresql://127.0.0.1/ftmerp"
        jdbc-username="ftmuser"
        jdbc-password="FTMIT@2026"
        isolation-level="ReadCommitted"
        pool-minsize="2"
        pool-maxsize="250"
        time-between-eviction-runs-millis="600000"/>
</datasource>
```

### OLAP Datasource (localpostgresolap)

```xml
<datasource name="localpostgresolap"
    helper-class="org.apache.ofbiz.entity.datasource.GenericHelperDAO"
    field-type-name="postgres"
    check-on-start="true"
    add-missing-on-start="true">
    <inline-jdbc
        jdbc-driver="org.postgresql.Driver"
        jdbc-uri="jdbc:postgresql://127.0.0.1/ofbizolap"
        jdbc-username="ftmuser"
        jdbc-password="FTMIT@2026"
        isolation-level="ReadCommitted"
        pool-minsize="2"
        pool-maxsize="250"
        time-between-eviction-runs-millis="600000"/>
</datasource>
```

### Tenant Datasource (localpostgrestenant)

```xml
<datasource name="localpostgrestenant"
    helper-class="org.apache.ofbiz.entity.datasource.GenericHelperDAO"
    field-type-name="postgres"
    check-on-start="true"
    add-missing-on-start="true">
    <inline-jdbc
        jdbc-driver="org.postgresql.Driver"
        jdbc-uri="jdbc:postgresql://127.0.0.1/ofbiztenant"
        jdbc-username="ftmuser"
        jdbc-password="FTMIT@2026"
        isolation-level="ReadCommitted"
        pool-minsize="2"
        pool-maxsize="250"
        time-between-eviction-runs-millis="600000"/>
</datasource>
```

### Default Delegator Configuration

```xml
<delegator name="default" entity-model-reader="main" entity-group-reader="main"
           entity-eca-reader="main" distributed-cache-clear-enabled="false">
    <group-map group-name="org.apache.ofbiz" datasource-name="localpostgres"/>
    <group-map group-name="org.apache.ofbiz.olap" datasource-name="localpostgresolap"/>
    <group-map group-name="org.apache.ofbiz.tenant" datasource-name="localpostgrestenant"/>
</delegator>
```

## Troubleshooting

### Connection Refused

If you see "Connection refused" errors:

```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start PostgreSQL if needed
sudo systemctl start postgresql

# Enable PostgreSQL to start on boot
sudo systemctl enable postgresql
```

### Authentication Failed

If you see "password authentication failed":

1. Verify the password is correct:
```bash
PGPASSWORD='FTMIT@2026' psql -U ftmuser -d ftmerp -h 127.0.0.1 -c "SELECT 1;"
```

2. Reset the password if needed:
```bash
sudo -u postgres psql -c "ALTER USER ftmuser WITH PASSWORD 'FTMIT@2026';"
```

3. Check all datasources in `entityengine.xml` use the same credentials

### Database Does Not Exist

If you see "database does not exist":

```bash
# List all databases
sudo -u postgres psql -c "\l"

# Create missing database
sudo -u postgres psql -c "CREATE DATABASE <dbname> OWNER ftmuser;"
```

## Security Notes

**⚠️ Important for Production:**

1. **Change the default password** - `FTMIT@2026` should only be used for development
2. **Use strong passwords** - Minimum 16 characters with mixed case, numbers, and symbols
3. **Configure PostgreSQL authentication** - Edit `/etc/postgresql/*/main/pg_hba.conf` for proper access control
4. **Enable SSL/TLS** - Configure PostgreSQL to use encrypted connections
5. **Regular backups** - Set up automated database backups
6. **Network security** - Limit PostgreSQL access to trusted networks only

### Production Password Change

```bash
# Generate a strong password
openssl rand -base64 24

# Update PostgreSQL user
sudo -u postgres psql -c "ALTER USER ftmuser WITH PASSWORD '<strong-password>';"

# Update entityengine.xml with new password
# Edit: framework/entity/config/entityengine.xml
# Update all three datasources: localpostgres, localpostgresolap, localpostgrestenant
```

## Maintenance

### Backup Databases

```bash
# Backup all three databases
pg_dump -U ftmuser -h 127.0.0.1 ftmerp > ftmerp_backup.sql
pg_dump -U ftmuser -h 127.0.0.1 ofbizolap > ofbizolap_backup.sql
pg_dump -U ftmuser -h 127.0.0.1 ofbiztenant > ofbiztenant_backup.sql
```

### Restore Databases

```bash
# Restore from backup
psql -U ftmuser -h 127.0.0.1 -d ftmerp < ftmerp_backup.sql
psql -U ftmuser -h 127.0.0.1 -d ofbizolap < ofbizolap_backup.sql
psql -U ftmuser -h 127.0.0.1 -d ofbiztenant < ofbiztenant_backup.sql
```

### Database Maintenance

```bash
# Connect to database
PGPASSWORD='FTMIT@2026' psql -U ftmuser -d ftmerp -h 127.0.0.1

# Vacuum and analyze (optimize performance)
VACUUM ANALYZE;

# Check database size
SELECT pg_size_pretty(pg_database_size('ftmerp'));

# List largest tables
SELECT schemaname, tablename,
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;
```

## References

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [OFBiz Entity Engine Guide](https://cwiki.apache.org/confluence/display/OFBIZ/Entity+Engine+Guide)
- [Apache OFBiz Database Configuration](https://cwiki.apache.org/confluence/display/OFBIZ/Database+Configuration)

## Related Documentation

- [OFBiz Learning Guide](./OFBIZ-LEARNING-GUIDE.md)
- [FTM Garments Workflow Dataset](./FTM-GARMENTS-WORKFLOW-DATASET.md)
- [ERP Manufacturing Glossary](./ERP-MANUFACTURING-GLOSSARY.md)
