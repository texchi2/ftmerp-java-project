# FTM ERP - Apache OFBiz for Garment Manufacturing

Enterprise Resource Planning system for FTM Garments, customized from Apache OFBiz 24.09.04.

## Quick Start (New Developer Machine)

```bash
# Clone and set up repositories
git clone git@github.com:texchi2/ftmerp-java-project.git ofbiz-framework
bash ofbiz-framework/docs/scripts/clone-ftm-erp.sh

# Follow on-screen instructions for:
# 1. Database setup (setup-database.sh)
# 2. Password configuration (gradle.properties.local)
# 3. Build and run
```

## Documentation

Comprehensive documentation is in the `docs/` directory:

- **[docs/QUICK-START.md](docs/QUICK-START.md)** - Quick reference for daily development
- **[docs/MAKE-TO-ORDER-WORKFLOW.md](docs/MAKE-TO-ORDER-WORKFLOW.md)** - Make-to-order sales and production
- **[docs/BOM-DEEP-DIVE.md](docs/BOM-DEEP-DIVE.md)** - Bill of Materials structure and usage
- **[docs/POSTGRESQL-SETUP.md](docs/POSTGRESQL-SETUP.md)** - Database configuration details
- **[docs/README.md](docs/README.md)** - Full documentation index

## System Requirements

- **Java**: OpenJDK 17 or later
- **PostgreSQL**: 17.6 or later
- **Git**: For version control
- **Gradle**: Included via wrapper

## Repository Structure

```
FTM ERP System
├── ofbiz-framework/                    # This repository (framework)
│   ├── applications/                   # OFBiz applications
│   ├── framework/                      # Core framework
│   ├── plugins -> ../ofbiz-plugins     # Symlink to plugins repo
│   ├── data/                           # BOM and seed data
│   └── docs/                           # Documentation and scripts
│
└── ofbiz-plugins/                      # Plugins repository (separate)
    └── ftm-garments/                   # FTM custom plugin
```

## Key Features

- **Bill of Materials (BOM)**: Complete 18-component BOM for men's casual pants
- **Make-to-Order (MTO)**: Production runs triggered by sales orders
- **MRP Integration**: Material requirements planning from BOM explosion
- **PostgreSQL**: Three-database architecture (main, enrollment, analytics)
- **Custom Plugin**: ftm-garments plugin for FTM-specific functionality

## Access Points

After starting OFBiz:

- **WebTools**: http://localhost:8080/webtools (admin/ofbiz)
- **Catalog**: http://localhost:8080/catalog
- **Manufacturing**: http://localhost:8080/manufacturing
- **Order Manager**: http://localhost:8080/ordermgr

## Current Status

✅ OFBiz 24.09.04 running on PostgreSQL  
✅ HTTP-only mode (HTTPS disabled for development)  
✅ BOM data loaded (FTM-PNT-32-NVY with 18 components)  
✅ ftm-garments plugin integrated  
✅ Make-to-order workflow documented

## Security Notes

- **Never commit passwords** to git
- Real passwords stored in `gradle.properties.local` (gitignored)
- Database credentials also in `~/.pgpass` (chmod 600)
- Use placeholder passwords (YOUR_*) in all scripts

## Support

- Check documentation in `docs/` directory
- Review `docs/QUICK-START.md` for common tasks
- See `runtime/logs/ofbiz.log` for application logs

## License

Based on Apache OFBiz, licensed under Apache License 2.0.

FTM customizations are proprietary to FTM Garments Company.

---

**Version**: 1.0  
**Last Updated**: 2026-04-24  
**OFBiz Version**: 24.09.04
