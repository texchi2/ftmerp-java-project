

# FTM Developer Environment Setup

## Required Environment Variables

Add to `~/.zshrc` (macOS) or `~/.bashrc` (Linux).
**NEVER commit these files to git.**

### macOS tmm7 (MacBook Air)

```bash
# PostgreSQL MCP — password-free URI (.pgpass handles auth)
export OFBIZ_MCP_DB_URI="postgresql://mcp_readonly@192.168.30.3:5432/ofbiz"
export OFBIZ_MCP_DB_URI_DEV="postgresql://ofbiz@192.168.30.3:5432/ofbiz"

# postgres-mcp binary — uv venv inside project directory
export POSTGRES_MCP_BIN="/Users/texchi/development/ftmerp-java-plugins/.venv/bin/postgres-mcp"

# Repository paths
export OFBIZ_PLUGINS_PATH="/Users/texchi/development/ftmerp-java-plugins"
export OFBIZ_FRAMEWORK_PATH="/Users/texchi/development/ftmerp-java-project"

# EXA search
export EXA_API_KEY="your_key_here"
export EXA_MCP_SERVER_PATH="/usr/local/lib/node_modules/exa-mcp-server/.smithery/stdio/index.cjs"


Linux — rpitex / ftmitu (system-wide venv)

export OFBIZ_MCP_DB_URI="postgresql://mcp_readonly@192.168.30.3:5432/ofbiz"
export OFBIZ_MCP_DB_URI_DEV="postgresql://ofbiz@192.168.30.3:5432/ofbiz"
export POSTGRES_MCP_BIN="/opt/postgres-mcp-venv/bin/postgres-mcp"
export OFBIZ_PLUGINS_PATH="/home/texchi/development/ofbiz-plugins"
export OFBIZ_FRAMEWORK_PATH="/home/texchi/development/ofbiz-framework"
export EXA_API_KEY="your_key_here"
export EXA_MCP_SERVER_PATH="/usr/local/lib/node_modules/exa-mcp-server/.smithery/stdio/index.cjs"


Linux — ofbiz-dev container (uv venv inside project)

export OFBIZ_MCP_DB_URI="postgresql://ofbiz@192.168.30.3:5432/ofbiz"
export OFBIZ_MCP_DB_URI_DEV="postgresql://ofbiz@192.168.30.3:5432/ofbiz"
export POSTGRES_MCP_BIN="/opt/ofbiz-plugins/.venv/bin/postgres-mcp"
export OFBIZ_PLUGINS_PATH="/opt/ofbiz-plugins"
export OFBIZ_FRAMEWORK_PATH="/opt/ofbiz-framework"


Kona’s machines (ftmitu + Pi5)

export OFBIZ_MCP_DB_URI="postgresql://mcp_readonly@192.168.30.3:5432/ofbiz"
export OFBIZ_MCP_DB_URI_DEV="postgresql://ofbiz@192.168.30.3:5432/ofbiz"
export POSTGRES_MCP_BIN="/opt/postgres-mcp-venv/bin/postgres-mcp"
export OFBIZ_PLUGINS_PATH="/home/kona/development/ofbiz-plugins"
export OFBIZ_FRAMEWORK_PATH="/home/kona/development/ofbiz-framework"


~/.pgpass Setup (passwords stored HERE ONLY)

# hostname:port:database:username:password
192.168.30.3:5432:ofbiz:mcp_readonly:Ftm@MCP2026!
192.168.30.3:5432:ofbiz:ofbiz:ofbiz
192.168.30.3:5432:ftm_enrollment:enrolladmin:Ftm@Enr0ll2026!


chmod 600 ~/.pgpass


postgres-mcp Installation (per machine)
ARM64: rpitex, ofbiz-dev, Kona Pi5

# Build deps (compile fallback)
apt-get install -y build-essential python3-dev libpq-dev

# System-wide venv
uv venv /opt/postgres-mcp-venv
uv pip install --python /opt/postgres-mcp-venv/bin/python "pglast>=7.11"
uv pip install --python /opt/postgres-mcp-venv/bin/python postgres-mcp
/opt/postgres-mcp-venv/bin/postgres-mcp --version


ofbiz-dev (uv venv inside project dir)

cd /opt/ofbiz-plugins
uv venv .venv
uv pip install --python .venv/bin/python "pglast>=7.11"
uv pip install --python .venv/bin/python postgres-mcp
.venv/bin/postgres-mcp --version


macOS tmm7 (uv venv inside project dir)

cd /Users/texchi/development/ftmerp-java-plugins
uv venv .venv
uv pip install --python .venv/bin/python postgres-mcp
.venv/bin/postgres-mcp --version


x86_64 Linux: ftmitu, erp2

uv venv /opt/postgres-mcp-venv
uv pip install --python /opt/postgres-mcp-venv/bin/python postgres-mcp
/opt/postgres-mcp-venv/bin/postgres-mcp --version


PostgreSQL Host Fix (RECURRING — apply after every reboot)
PostgreSQL on pfsense-msi-ftm (192.168.30.3) resets to 127.0.0.1 only after reboot.

# On pfsense-msi-ftm Ubuntu host — run after any reboot
sudo sed -i "s/^listen_addresses = .*/listen_addresses = '127.0.0.1,192.168.30.3'/" \
  /etc/postgresql/16/main/postgresql.conf
sudo systemctl restart postgresql
sudo ss -tlnp | grep 5432
# Verify both 127.0.0.1:5432 AND 192.168.30.3:5432 appear


Permanent fix — add to /etc/postgresql/16/main/postgresql.conf directly and protect:

# Make the line explicit and permanent
sudo sed -i "s/^#*listen_addresses.*/listen_addresses = '127.0.0.1,192.168.30.3'/" \
  /etc/postgresql/16/main/postgresql.conf

# Verify it survives restart
sudo systemctl restart postgresql && sudo ss -tlnp | grep 5432


Claude Code Settings

# Copy template and fill in your machine's paths
cp claude-settings.json.template ~/.claude/settings.json

# Source your env vars first
source ~/.zshrc  # or ~/.bashrc

# Verify MCP works
source ~/.zshrc && postgres-mcp "$OFBIZ_MCP_DB_URI" --access-mode=restricted


Verification Checklist

# 1. PostgreSQL reachable
psql "$OFBIZ_MCP_DB_URI" -c "SELECT count(*) FROM work_effort;"

# 2. postgres-mcp starts
"$POSTGRES_MCP_BIN" --access-mode=restricted  # Ctrl+C after INFO line appears

# 3. filesystem MCP works
npx -y @modelcontextprotocol/server-filesystem "$OFBIZ_PLUGINS_PATH"

# 4. Claude Code connects all MCPs
cc
/mcp   # shows all MCP servers and their status



---
