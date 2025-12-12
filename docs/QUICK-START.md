# FTM ERP Quick Start Guide

Quick reference for getting started with FTM Garments ERP development.

## 🚀 Initial Setup (On rpitex Raspberry Pi 5)

### 1. Set up Version Control for Plugins

```bash
cd ~/development/ofbiz-framework/docs/scripts
./setup-plugins-repo.sh
```

This will:
- Initialize git in `~/development/ofbiz-plugins`
- Create initial commit
- Push to GitHub at `texchi2/ftmerp-java-plugins`
- Update framework repository symlink tracking

### 2. Set up PostgreSQL Database

```bash
cd ~/development/ofbiz-framework/docs/scripts
./setup-database.sh
```

This will:
- Install PostgreSQL (if needed)
- Create `ftmerp` database
- Create `ftmuser` database user
- Save credentials to `~/.ftmerp_db_credentials`

### 3. Configure OFBiz Database Connection

Edit `framework/entity/config/entityengine.xml`:

```xml
<datasource name="localpostgres"
        helper-class="org.apache.ofbiz.entity.datasource.GenericHelperDAO"
        field-type-name="postgres"
        check-on-start="true"
        add-missing-on-start="true">
    <inline-jdbc
            jdbc-driver="org.postgresql.Driver"
            jdbc-uri="jdbc:postgresql://127.0.0.1/ftmerp"
            jdbc-username="ftmuser"
            jdbc-password="YOUR_PASSWORD"
            isolation-level="ReadCommitted"
            pool-minsize="2"
            pool-maxsize="250"/>
</datasource>
```

Add to `build.gradle`:

```gradle
dependencies {
    implementation 'org.postgresql:postgresql:42.7.1'
}
```

### 4. Build and Run

```bash
cd ~/development/ofbiz-framework

# Build
./gradlew build

# Load initial data
./gradlew loadAll

# Start OFBiz
./gradlew ofbiz
```

Access at: https://localhost:8443/accounting
Default credentials: `admin` / `ofbiz`

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

### Database Connection Issues

```bash
# Test PostgreSQL connection
psql -U ftmuser -d ftmerp -h localhost

# Check PostgreSQL status
sudo systemctl status postgresql

# Check credentials
cat ~/.ftmerp_db_credentials
```

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
