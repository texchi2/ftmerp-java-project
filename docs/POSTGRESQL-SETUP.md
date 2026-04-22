
# PostgreSQL Database Setup for FTM ERP

This document describes the PostgreSQL database configuration for the FTM ERP OFBiz system.

**⚠️ Security Note:** This document contains NO actual passwords.
Passwords are stored ONLY in `~/.pgpass` on each developer machine (chmod 600).
Ask Dr. Tex for actual credentials via secure channel (Signal/WhatsApp).

## Database Configuration

The FTM ERP system uses PostgreSQL with three separate databases:

### Database Overview

| Database | Purpose | Owner | Usage |
|----------|---------|-------|-------|
| `ftmerp` | Main operational data | `ftmuser` | All standard OFBiz entities and transactions |
| `ofbizolap` | Analytics/OLAP data | `ftmuser` | Business intelligence and reporting data |
| `ofbiztenant` | Multi-tenant data | `ftmuser` | Tenant-specific data for multi-tenancy support |

### Database User

- **Username:** `ftmuser`
- **Privileges:** CREATEDB, full access to all three databases
- **Password:** stored in `~/.pgpass` only — never in any committed file

## Initial Setup

### 1. Create PostgreSQL User

```bash
sudo -u postgres psql -c "CREATE USER ftmuser WITH PASSWORD 'YOUR_FTMUSER_PASSWORD' CREATEDB;"


2. Create Databases

sudo -u postgres psql -c "CREATE DATABASE ftmerp OWNER ftmuser;"
sudo -u postgres psql -c "CREATE DATABASE ofbizolap OWNER ftmuser;"
sudo -u postgres psql -c "CREATE DATABASE ofbiztenant OWNER ftmuser;"


3. Grant Privileges

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ftmerp TO ftmuser;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ofbizolap TO ftmuser;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ofbiztenant TO ftmuser;"


4. Add pg_hba.conf Entries

sudo bash -c 'cat >> /etc/postgresql/16/main/pg_hba.conf << EOF

# FTM OFBiz databases
host  ftmerp      ftmuser  192.168.30.0/24  md5
host  ftmerp      ftmuser  127.0.0.1/32     md5
host  ofbizolap   ftmuser  192.168.30.0/24  md5
host  ofbizolap   ftmuser  127.0.0.1/32     md5
host  ofbiztenant ftmuser  192.168.30.0/24  md5
host  ofbiztenant ftmuser  127.0.0.1/32     md5
EOF'
sudo systemctl reload postgresql


5. Verify Setup

# Check databases exist
sudo -u postgres psql -c "\l" | grep -E "ftmerp|ofbizolap|ofbiztenant"

# Check user exists
sudo -u postgres psql -c "\du ftmuser"

# Test connection (password from ~/.pgpass)
psql -U ftmuser -d ftmerp -h 127.0.0.1 -c "SELECT version();"


OFBiz Configuration
The database configuration is defined in:

ofbiz-framework/framework/entity/config/entityengine.xml


⚠️ entityengine.xml contains jdbc-password — this file is NOT committed to git
as-is. The password field uses an environment variable or is set per deployment.
Main Datasource (localpostgres)

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
        jdbc-uri="jdbc:postgresql://192.168.30.3/ftmerp"
        jdbc-username="ftmuser"
        jdbc-password="YOUR_FTMUSER_PASSWORD"
        isolation-level="ReadCommitted"
        pool-minsize="2"
        pool-maxsize="250"
        time-between-eviction-runs-millis="600000"/>
</datasource>


OLAP Datasource (localpostgresolap)

<datasource name="localpostgresolap"
    helper-class="org.apache.ofbiz.entity.datasource.GenericHelperDAO"
    field-type-name="postgres"
    check-on-start="true"
    add-missing-on-start="true">
    <inline-jdbc
        jdbc-driver="org.postgresql.Driver"
        jdbc-uri="jdbc:postgresql://192.168.30.3/ofbizolap"
        jdbc-username="ftmuser"
        jdbc-password="YOUR_FTMUSER_PASSWORD"
        isolation-level="ReadCommitted"
        pool-minsize="2"
        pool-maxsize="250"
        time-between-eviction-runs-millis="600000"/>
</datasource>


Tenant Datasource (localpostgrestenant)

<datasource name="localpostgrestenant"
    helper-class="org.apache.ofbiz.entity.datasource.GenericHelperDAO"
    field-type-name="postgres"
    check-on-start="true"
    add-missing-on-start="true">
    <inline-jdbc
        jdbc-driver="org.postgresql.Driver"
        jdbc-uri="jdbc:postgresql://192.168.30.3/ofbiztenant"
        jdbc-username="ftmuser"
        jdbc-password="YOUR_FTMUSER_PASSWORD"
        isolation-level="ReadCommitted"
        pool-minsize="2"
        pool-maxsize="250"
        time-between-eviction-runs-millis="600000"/>
</datasource>


Default Delegator Configuration

<delegator name="default" entity-model-reader="main" entity-group-reader="main"
           entity-eca-reader="main" distributed-cache-clear-enabled="false">
    <group-map group-name="org.apache.ofbiz"        datasource-name="localpostgres"/>
    <group-map group-name="org.apache.ofbiz.olap"   datasource-name="localpostgresolap"/>
    <group-map group-name="org.apache.ofbiz.tenant" datasource-name="localpostgrestenant"/>
</delegator>


Troubleshooting
Connection Refused

# Check PostgreSQL is running and listening on correct interfaces
sudo systemctl status postgresql
sudo ss -tlnp | grep 5432
# Expected: both 127.0.0.1:5432 AND 192.168.30.3:5432

# If only 127.0.0.1 appears — fix listen_addresses (recurring issue after reboot):
sudo sed -i "s/^listen_addresses = .*/listen_addresses = '127.0.0.1,192.168.30.3'/" \
  /etc/postgresql/16/main/postgresql.conf
sudo systemctl restart postgresql


Authentication Failed

# Verify connection using ~/.pgpass (no password in command)
psql -U ftmuser -d ftmerp -h 127.0.0.1 -c "SELECT 1;"

# Reset password if needed (get correct password from Dr. Tex)
sudo -u postgres psql -c "ALTER USER ftmuser WITH PASSWORD 'YOUR_FTMUSER_PASSWORD';"


Database Does Not Exist

sudo -u postgres psql -c "\l"
sudo -u postgres psql -c "CREATE DATABASE <dbname> OWNER ftmuser;"


~/.pgpass Format Reference
Passwords are stored ONLY here — never in any committed file.

# hostname:port:database:username:password
192.168.30.3:5432:ftmerp:ftmuser:YOUR_FTMUSER_PASSWORD
192.168.30.3:5432:ofbizolap:ftmuser:YOUR_FTMUSER_PASSWORD
192.168.30.3:5432:ofbiztenant:ftmuser:YOUR_FTMUSER_PASSWORD
192.168.30.3:5432:ofbiz:mcp_readonly:YOUR_MCP_READONLY_PASSWORD
192.168.30.3:5432:ftm_enrollment:enrolladmin:YOUR_ENROLLADMIN_PASSWORD


chmod 600 ~/.pgpass


Security Notes
	1.	Never commit passwords — use ~/.pgpass for all credentials
	2.	Change default passwords before production deployment on erp2
	3.	Generate strong passwords for production: openssl rand -base64 24
	4.	Limit network access — pg_hba.conf restricts to 192.168.30.0/24 only
	5.	Enable SSL/TLS for Phase 9E production deployment on erp2
Production Password Rotation

# Generate strong password
openssl rand -base64 24

# Update PostgreSQL user
sudo -u postgres psql -c "ALTER USER ftmuser WITH PASSWORD '<strong-password>';"

# Update entityengine.xml on erp2 (production only — never commit)
# Update ~/.pgpass on all authorized machines


Maintenance
Backup Databases

# Uses ~/.pgpass for authentication — no password in command
pg_dump -U ftmuser -h 192.168.30.3 ftmerp > ftmerp_backup_$(date +%Y%m%d).sql
pg_dump -U ftmuser -h 192.168.30.3 ofbizolap > ofbizolap_backup_$(date +%Y%m%d).sql
pg_dump -U ftmuser -h 192.168.30.3 ofbiztenant > ofbiztenant_backup_$(date +%Y%m%d).sql


Restore Databases

psql -U ftmuser -h 192.168.30.3 -d ftmerp < ftmerp_backup.sql
psql -U ftmuser -h 192.168.30.3 -d ofbizolap < ofbizolap_backup.sql
psql -U ftmuser -h 192.168.30.3 -d ofbiztenant < ofbiztenant_backup.sql


Database Maintenance

# Connect (password from ~/.pgpass)
psql -U ftmuser -d ftmerp -h 192.168.30.3

# Vacuum and analyze
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


References
	•	PostgreSQL Documentation
	•	OFBiz Entity Engine Guide
	•	Apache OFBiz Database Configuration
Related Documentation
	•	OFBiz Learning Guide
	•	FTM Garments Workflow Dataset
	•	ERP Manufacturing Glossary
	•	Developer Environment Setup


---
Changes made:
	•	Replaced all "real passwords" occurrences with YOUR_FTMUSER_PASSWORD
	•	Removed PGPASSWORD='...' from all commands
	•	Added security warning banner at the top

==
