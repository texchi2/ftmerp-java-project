# FTM ERP Documentation

Documentation for FTM Garments ERP system, customized from Apache OFBiz.

## 📖 Documentation Files

### Getting Started

- **[QUICK-START.md](QUICK-START.md)** - Quick reference guide for daily development
  - Initial setup steps
  - Development environment commands
  - Common workflows
  - Troubleshooting tips

- **[FTM-SETUP-GUIDE.adoc](FTM-SETUP-GUIDE.adoc)** - Comprehensive setup guide
  - Version control strategy (framework + plugins)
  - PostgreSQL database configuration
  - Vim/Tmux CLI IDE setup
  - Ollama AI integration
  - Complete development workflow

### Setup Scripts

Located in `scripts/` directory:

- **`clone-ftm-erp.sh`** - One-command setup for new development machines
  - Clones framework and plugins repositories
  - Creates symlinks
  - Configures git to ignore local database changes
  - Provides password configuration instructions
- **`setup-database.sh`** - Set up PostgreSQL databases (ftmerp, ftm_enrollment, ftm_ofbiz)
  - Creates three databases with appropriate users
  - Prompts for passwords (never stores real passwords in scripts)
  - Provides instructions for gradle.properties.local configuration
- **`setup-plugins-repo.sh`** - Initialize and push ofbiz-plugins to GitHub (for maintainers)

**Deprecated (Phase 9C):**
- `llm-client.py`, `llm-server.py`, `start-llm-server.sh` - Superseded by Claude Code with MCP

## 🎯 Quick Start

### For New Development Machine

```bash
# 1. Clone and set up repositories (one command)
git clone git@github.com:texchi2/ftmerp-java-project.git ofbiz-framework
bash ofbiz-framework/docs/scripts/clone-ftm-erp.sh

# 2. Set up PostgreSQL databases
cd ofbiz-framework/docs/scripts
./setup-database.sh

# 3. Configure passwords in gradle.properties.local
cd ~/development/ofbiz-framework
cat > gradle.properties.local << 'EOF'
# Database passwords (gitignored - safe to store real passwords)
dbPassword.ftmuser=YOUR_FTMUSER_PASSWORD
dbPassword.enrolladmin=YOUR_ENROLLADMIN_PASSWORD
dbPassword.ftmofbiz=YOUR_FTMOFBIZ_PASSWORD
dbPassword.mcp_readonly=YOUR_MCP_READONLY_PASSWORD
EOF

# 4. Build and load data
./gradlew build
./gradlew loadAll

# 5. Load BOM data
./gradlew ofbiz --args="--load-data file=plugins/ftm-garments/data/FtmBomData.xml"

# 6. Start OFBiz
./gradlew ofbiz
```

### For Branch Selection

```bash
# Clone with specific plugins branch
bash ofbiz-framework/docs/scripts/clone-ftm-erp.sh --branch main
```

## 📂 Repository Structure

```
FTM ERP System
├── ofbiz-framework/                    # Main framework repository
│   ├── applications/                   # OFBiz applications
│   ├── framework/                      # Core framework
│   ├── plugins -> ../ofbiz-plugins     # Symlink to plugins
│   └── docs/                           # This documentation
│       ├── FTM-SETUP-GUIDE.adoc       # Complete setup guide
│       ├── QUICK-START.md             # Quick reference
│       └── scripts/                    # Setup automation scripts
│
└── ofbiz-plugins/                      # Plugins repository
    ├── ftm-garments/                   # FTM custom plugin
    └── [other plugins]
```

## 🔗 GitHub Repositories

- **Framework**: https://github.com/texchi2/ftmerp-java-project
- **Plugins**: https://github.com/texchi2/ftmerp-java-plugins (created)

## 🛠️ Development Environment

### Required Software

- **Java**: OpenJDK 17 or later (21 recommended)
- **PostgreSQL**: 12 or later
- **Git**: For version control
- **Vim**: Text editor (with plugins)
- **Tmux**: Terminal multiplexer
- **Ollama** + **mlx-lm** + **Claude Code**: AI coding assistant (recommended)

### Hardware

- **Primary Development**: Raspberry Pi 5 (rpitex)
  - Local PostgreSQL database
  - remote LLM server
  - SSH access for remote development

## 📚 Additional Resources

### Apache OFBiz Resources

- [Official Documentation](https://ofbiz.apache.org/documentation.html)
- [Developer Guide](https://cwiki.apache.org/confluence/display/OFBIZ/Developer+Resources), and https://ofbizextra.org/ofbiz_adocs/docs/asciidoc/developer-manual.pdf
- [Data Model](https://cwiki.apache.org/confluence/display/OFBIZ/Data+Model)
- [Service Engine](https://cwiki.apache.org/confluence/display/OFBIZ/Service+Engine+Guide)

### Tools Documentation

- [PostgreSQL](https://www.postgresql.org/docs/)
- [Vim](https://www.vim.org/docs.php)
- [Tmux](https://github.com/tmux/tmux/wiki)
- [Ollama](https://github.com/ollama/ollama)
- [Gradle](https://docs.gradle.org/)

## 🤝 Contributing

### Workflow

1. Create feature branch from `main`
2. Make changes in appropriate repository (framework or plugins)
3. Test thoroughly
4. Commit with descriptive messages
5. Push to GitHub
6. Create pull request

### Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat: Add production cost calculation service

Implement service to calculate garment production costs including:
- Material costs
- Labor costs
- Overhead allocation

Related to #123
```

## 📞 Support

### Documentation

- Check `QUICK-START.md` for common tasks
- Check `FTM-SETUP-GUIDE.adoc` for detailed setup
- Check troubleshooting sections

### Logs

- **OFBiz logs**: `runtime/logs/ofbiz.log`
- **PostgreSQL logs**: `/var/log/postgresql/`
- **System logs**: `journalctl -xe`

### Database Credentials

Stored securely in: `~/.ftmerp_db_credentials`

## 🔒 Security Notes

1. **Never commit passwords** to git repositories
2. **Keep `.ftmerp_db_credentials` secure** (chmod 600)
3. **Use strong passwords** for database users
4. **Regular backups** of production database
5. **Review code** for SQL injection vulnerabilities

## 📝 License

Based on Apache OFBiz, licensed under Apache License 2.0.

FTM customizations and plugins are proprietary to FTM Garments Company.

## 🗺️ Roadmap

- [x] Set up version control for framework and plugins
- [x] Configure PostgreSQL database
- [x] Set up development environment (vim/tmux)
- [ ] Integrate Ollama AI assistance
- [ ] Implement garment production tracking
- [ ] Add inventory management features
- [ ] Create production cost calculation
- [ ] Develop custom reports for FTM operations
- [ ] Mobile app for production floor
- [ ] Integration with existing systems

---

**Last Updated**: 2025-12-12
**Version**: 1.0
**Maintained By**: FTM ERP Development Team
