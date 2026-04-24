# FTM ERP Quick Start Guide

Quick reference for getting started with FTM Garments ERP development.

## 🚀 Initial Setup (New Development Machine)

### 1. Clone and Set Up Repositories

```bash
# Clone framework repository
git clone git@github.com:texchi2/ftmerp-java-project.git ofbiz-framework

# Run one-command setup script
bash ofbiz-framework/docs/scripts/clone-ftm-erp.sh
```

This will:
- Clone framework repository (ftmerp-java-project)
- Clone plugins repository (ftmerp-java-plugins) on branch `feature/ftm-garments`
- Create symlink: `plugins -> ../ofbiz-plugins`
- Configure git to ignore local database configuration changes
- Verify Java installation
- Display next steps

**Branch Selection:**
```bash
# Use specific plugins branch
bash ofbiz-framework/docs/scripts/clone-ftm-erp.sh --branch main
```

### 2. Set up PostgreSQL Databases

```bash
cd ~/development/ofbiz-framework/docs/scripts
./setup-database.sh
```

This will:
- Install PostgreSQL (if needed)
- Create three databases: `ftmerp`, `ftm_enrollment`, `ftm_ofbiz`
- Create four users: `ftmuser`, `enrolladmin`, `ofbizadmin`, `mcp_readonly`
- Prompt for passwords (NEVER stores real passwords in scripts)
- Provide instructions for password configuration

### 3. Configure Database Passwords

Create `gradle.properties.local` (gitignored, safe for real passwords):

```bash
cd ~/development/ofbiz-framework
cat > gradle.properties.local << 'EOF'
# Database passwords (gitignored - safe to store real passwords)
dbPassword.ftmuser=YOUR_FTMUSER_PASSWORD
dbPassword.enrolladmin=YOUR_ENROLLADMIN_PASSWORD
dbPassword.ftmofbiz=YOUR_FTMOFBIZ_PASSWORD
dbPassword.mcp_readonly=YOUR_MCP_READONLY_PASSWORD
EOF
```

Create `~/.pgpass` for command-line PostgreSQL access:

```bash
cat > ~/.pgpass << 'EOF'
localhost:5432:ftmerp:ftmuser:YOUR_FTMUSER_PASSWORD
localhost:5432:ftm_enrollment:enrolladmin:YOUR_ENROLLADMIN_PASSWORD
localhost:5432:ftm_ofbiz:ofbizadmin:YOUR_FTMOFBIZ_PASSWORD
localhost:5432:*:mcp_readonly:YOUR_MCP_READONLY_PASSWORD
EOF

chmod 600 ~/.pgpass
```

**IMPORTANT**: Replace `YOUR_*` placeholders with the actual passwords you entered during `setup-database.sh`

### 4. Verify Database Configuration

OFBiz reads database configuration from `framework/entity/config/entityengine.xml`.
Passwords are loaded from `gradle.properties.local` via Gradle properties.

The configuration should look like:

```xml
<datasource name="localpostgres">
    <inline-jdbc
        jdbc-uri="jdbc:postgresql://127.0.0.1/ftmerp"
        jdbc-username="ftmuser"
        jdbc-password="${dbPassword.ftmuser}"/>
</datasource>
```

Note: `git update-index --assume-unchanged` prevents local password changes from being committed.

### 4. Build and Run

```bash
cd ~/development/ofbiz-framework

# Build
./gradlew build

# Load initial data
./gradlew loadAll

# Start OFBiz
./gradlew ofbiz

# Stop OFBiz (in another terminal)
./gradlew "ofbiz --shutdown"
# Or force stop if shutdown doesn't work
./gradlew "ofbiz --stop"
# Or kill process directly
pkill -f ofbiz
```

Access at:
- **HTTP (Development)**: http://192.168.2.110:8080/webtools
- **HTTPS (Production)**: https://192.168.2.110:8443/accounting

Default credentials: `admin` / `ofbiz`

**Note**: For development, HTTP-only mode is recommended (simpler, no certificate warnings). See "Disable HTTPS for Development" below.

## 🛠️ Development Environment

### Start Development Session

```bash
# Install tmux and vim (if not already)
sudo apt install tmux vim

# Start FTM development environment
~/bin/ftm-dev.sh
```

This creates a tmux session with:
- Window 1: Vim editor for code
- Window 2: Build & run commands
- Window 3: PostgreSQL client
- Window 4: Git management
- Window 5: Log monitoring

### Tmux Commands

```bash
# Detach from session
Ctrl-a d

# Re-attach to session
tmux attach -t ftm-erp

# List sessions
tmux ls

# Navigate between windows
Ctrl-a 0-5  # Window number

# Split panes
Ctrl-a |    # Vertical split
Ctrl-a -    # Horizontal split

# Navigate panes
Ctrl-h/j/k/l  # Vim-style navigation
```

### Vim Commands (with Ollama AI)

```vim
<Space>oc    " AI code completion
<Space>oe    " Explain selected code (visual mode)
<Space>or    " Refactor selected code (visual mode)

<Space>f     " Find files
<Space>g     " Search in files (ripgrep)
<Space>n     " Toggle file tree

gd           " Go to definition
gr           " Find references
K            " Show documentation
<Space>rn    " Rename symbol
```

## 🤖 Ollama AI Integration

### Start Ollama Server

```bash
# Install Ollama (if not installed)
curl -fsSL https://ollama.com/install.sh | sh

# Pull models
ollama pull codellama:13b
ollama pull deepseek-coder:6.7b
ollama pull mistral:7b

# Start server
ollama serve
```

### Command Line AI Help

```bash
# Ask questions
~/bin/ollama-help.sh "How do I configure PostgreSQL in OFBiz?"

# Get code examples
~/bin/ollama-help.sh "Write an OFBiz service to calculate production cost"

# Debug help
~/bin/ollama-help.sh "Explain this error: java.lang.NullPointerException at..."
```

## 📦 Clone on New Machine

```bash
# On any new development machine
cd ~/development/ofbiz-framework/docs/scripts
./clone-ftm-erp.sh
```

This will:
- Clone both framework and plugins repositories
- Set up proper symlink structure
- Verify Java installation
- Show next steps

## 🔄 Daily Workflow

### Morning Startup

```bash
# Start Ollama (if not running)
ollama serve &

# Start development environment
~/bin/ftm-dev.sh

# Pull latest changes
cd ~/development/ofbiz-framework && git pull
cd ~/development/ofbiz-plugins && git pull
```

### Development Cycle

```bash
# 1. Make changes in vim (Window 1)

# 2. Build (Window 2)
./gradlew build

# 3. Run tests
./gradlew test

# 4. Test manually
./gradlew ofbiz

# 5. Commit changes
# Framework changes (Window 4, left pane)
cd ~/development/ofbiz-framework
git add .
git commit -m "Description of changes"
git push

# Plugin changes (Window 4, right pane)
cd ~/development/ofbiz-plugins
git add .
git commit -m "Description of changes"
git push
```

## 📊 Database Operations

### Connect to Database

```bash
# From command line
psql -U ftmuser -d ftmerp -h localhost

# In tmux session (Window 3)
# Already connected!
```

### Common Queries

```sql
-- List all tables
\dt

-- Describe table
\d table_name

-- List FTM custom tables
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_name LIKE 'ftm_%';

-- Check connection
SELECT current_database(), current_user, version();
```

### Backup Database

```bash
# Backup
pg_dump -U ftmuser -d ftmerp > ftmerp_backup_$(date +%Y%m%d).sql

# Restore
psql -U ftmuser -d ftmerp < ftmerp_backup_20250101.sql
```

## 🐛 Troubleshooting

### OFBiz Won't Start

```bash
# Check logs
tail -f runtime/logs/ofbiz.log

# Clean and rebuild
./gradlew cleanAll
./gradlew build
```

### Catalina Container Error: "Cannot load CatalinaContainer; no engines defined"

This error occurs when `framework/catalina/ofbiz-component.xml` is malformed or corrupted.

**Solution**: Restore the clean configuration file from the official Apache OFBiz repository:

```bash
cd ~/development/ofbiz-framework

# Backup the broken file
cp framework/catalina/ofbiz-component.xml framework/catalina/ofbiz-component.xml.backup

# Check your OFBiz version
cat gradle.properties | grep ofbiz.version

# Download clean version for your release (replace with your version)
curl -o framework/catalina/ofbiz-component.xml \
  https://raw.githubusercontent.com/apache/ofbiz-framework/release24.09.04/framework/catalina/ofbiz-component.xml

# Or restore from git if it's in your repository
git checkout framework/catalina/ofbiz-component.xml

# Verify the file is valid XML
xmllint --noout framework/catalina/ofbiz-component.xml

# Rebuild
./gradlew clean loadAll
```

**Common Issues**:
- Manual edits broke XML structure
- Container properties in wrong location (should be in component file for OFBiz 24.09+)
- Missing engine or connector definitions

### Database Connection Issues

```bash
# Test PostgreSQL connection
psql -U ftmuser -d ftmerp -h localhost

# Check PostgreSQL status
sudo systemctl status postgresql

# Restart PostgreSQL if needed
sudo systemctl restart postgresql

# Check credentials
cat ~/.ftmerp_db_credentials
```

### Database "ofbizolap" or "ofbiztenant" Does Not Exist

OFBiz requires three PostgreSQL databases:

```bash
# Create missing databases
sudo -u postgres psql -c "CREATE DATABASE ofbizolap OWNER ftmuser;"
sudo -u postgres psql -c "CREATE DATABASE ofbiztenant OWNER ftmuser;"

# Grant privileges
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ofbizolap TO ftmuser;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ofbiztenant TO ftmuser;"

# Verify all three databases exist
sudo -u postgres psql -c "\l" | grep -E "ftmerp|ofbizolap|ofbiztenant"
```

See [PostgreSQL Setup Guide](./POSTGRESQL-SETUP.md) for complete database configuration.

### Symlink Issues

```bash
# Verify symlink
ls -la ~/development/ofbiz-framework/plugins

# Should show: plugins -> ../ofbiz-plugins

# Recreate if broken
cd ~/development/ofbiz-framework
rm plugins
ln -sf ../ofbiz-plugins plugins
```

### Ollama Not Responding

```bash
# Check if running
ps aux | grep ollama

# Restart
killall ollama
ollama serve &

# Test API
curl http://localhost:11434/api/tags
```

### Git Push Triggers Unwanted Rebuild

If `git push` automatically triggers a rebuild, there may be git hooks installed:

```bash
cd ~/development/ofbiz-framework

# Check for git hooks
ls -la .git/hooks/

# View hooks that might trigger builds
cat .git/hooks/pre-push 2>/dev/null
cat .git/hooks/post-commit 2>/dev/null

# Disable by renaming (can re-enable later)
mv .git/hooks/pre-push .git/hooks/pre-push.disabled
mv .git/hooks/post-commit .git/hooks/post-commit.disabled

# Or remove gradle commands from the hook files if you want to keep other functionality
```

**Note**: Some CI/CD systems install hooks automatically. Check your build automation configuration.

### Disable HTTPS for Development

For development environments, use HTTP-only mode to avoid SSL certificate issues:

```bash
cd ~/development/ofbiz-framework

# 1. Comment out HTTPS connector in ofbiz-component.xml
nano framework/catalina/ofbiz-component.xml
# Find and comment out the entire <property name="https-connector"> block

# 2. Disable HTTPS redirection
nano framework/webapp/config/url.properties
# Add these lines:
# no.http=N
# port.https.enabled=N
# force.https.host=

# 3. Restart OFBiz
sudo systemctl restart ofbiz.service

# 4. Access via HTTP (no HTTPS)
# http://192.168.2.110:8080/webtools
# Login: admin / ofbiz
```

**Benefits**:
- ✅ No SSL certificate warnings
- ✅ Faster startup
- ✅ Simpler configuration
- ✅ Easier HTTP traffic debugging

See [HTTPS Setup Guide](./HTTPS-SSL-SETUP.md) for detailed HTTPS configuration when needed for production.

## 📚 Resources

- **Full Setup Guide**: `docs/FTM-SETUP-GUIDE.adoc`
- **OFBiz Documentation**: https://ofbiz.apache.org/documentation.html
- **PostgreSQL Docs**: https://www.postgresql.org/docs/
- **Vim Tips**: https://vim.fandom.com/wiki/Vim_Tips_Wiki
- **Tmux Tutorial**: https://github.com/tmux/tmux/wiki
- **Ollama Docs**: https://github.com/ollama/ollama/blob/main/docs/api.md

## 🔗 Repository Links

- **Framework**: https://github.com/texchi2/ftmerp-java-project
- **Plugins**: https://github.com/texchi2/ftmerp-java-plugins
- **Issues**: https://github.com/texchi2/ftmerp-java-project/issues

## 💡 Tips

1. **Use tmux sessions** - They persist across SSH disconnections
2. **Commit often** - Small, focused commits are easier to review
3. **Use AI assistance** - Ollama can help explain OFBiz code and generate boilerplate
4. **Test in PostgreSQL** - Keep a database window open for quick queries
5. **Monitor logs** - Keep log window visible to catch errors early
6. **Backup database** - Regular backups prevent data loss
7. **Document changes** - Add comments and update docs as you code

## 🎯 Next Steps

1. ✅ Complete version control setup
2. ✅ Set up PostgreSQL database
3. ✅ Configure vim/tmux environment
4. ✅ Test Ollama integration
5. 🚧 Start developing FTM garments customization
6. 🚧 Implement garment production tracking
7. 🚧 Add inventory management features
8. 🚧 Create custom reports for FTM operations
