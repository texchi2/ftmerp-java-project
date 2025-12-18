# LLM Orchestration Setup Guide for FTM ERP Development

Complete guide to setting up distributed LLM-assisted development environment with macOS (M2 Ultra) LLM server and rpitex (Raspberry Pi 5) development workstation.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [macOS M2 Ultra LLM Server Setup](#macos-m2-ultra-llm-server-setup)
3. [rpitex Raspberry Pi 5 Client Setup](#rpitex-raspberry-pi-5-client-setup)
4. [Network Configuration](#network-configuration)
5. [Testing the Setup](#testing-the-setup)
6. [Usage Guide](#usage-guide)
7. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    LAN Network (pfSense)                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────┐    ┌──────────────────────┐  │
│  │  macOS M2 Ultra         │    │  rpitex (RPi 5)     │  │
│  │  192.168.1.100          │    │  192.168.1.50       │  │
│  │                         │    │                      │  │
│  │  🤖 LLM Server          │◄───┤  👨‍💻 Development    │  │
│  │                         │    │                      │  │
│  │  ┌──────────────────┐   │    │  ┌────────────────┐ │  │
│  │  │ MLX-LM           │   │    │  │ Vim + Tmux     │ │  │
│  │  │ ├─Llama-4-Scout  │   │    │  │ + Vimux        │ │  │
│  │  │ └─CodeLlama-70b  │   │    │  └────────────────┘ │  │
│  │  └──────────────────┘   │    │                      │  │
│  │                         │    │  ┌────────────────┐ │  │
│  │  ┌──────────────────┐   │    │  │ OFBiz ERP      │ │  │
│  │  │ Ollama           │   │    │  │ Development    │ │  │
│  │  │ └─phind-codellama│   │    │  └────────────────┘ │  │
│  │  └──────────────────┘   │    │                      │  │
│  │                         │    │  ┌────────────────┐ │  │
│  │  ┌──────────────────┐   │    │  │ PostgreSQL     │ │  │
│  │  │ Flask API        │   │    │  │ Database       │ │  │
│  │  │ Port: 5000       │   │    │  └────────────────┘ │  │
│  │  └──────────────────┘   │    └──────────────────────┘  │
│  └─────────────────────────┘                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### LLM Model Allocation

| Model | Hardware | Use Case | API Endpoint |
|-------|----------|----------|--------------|
| **Claude Code (Sonnet 4.5)** | **Cloud (Anthropic)** | **Orchestration, GitHub Operations, Complex Refactoring** | **GitHub/Web Interface** |
| Llama-4-Scout-17B-16E | macOS M2 Ultra | Reasoning, Architecture | `/reason`, `/chat` |
| CodeLlama-70b-4bit | macOS M2 Ultra | Code Generation | `/generate`, `/refactor` |
| phind-codellama:34b-fp16 | macOS M2 Ultra (Ollama) | Code Completion, FIM | `/complete` |

### Claude Code Integration

**Claude Code** (this assistant) serves as the **orchestration layer** for the entire LLM-assisted development workflow:

#### Role in Development Process

1. **Repository Management**
   - Create and manage GitHub branches
   - Commit changes with comprehensive messages
   - Push code to remote repositories
   - Review and organize project structure

2. **Complex Code Operations**
   - Large-scale refactoring across multiple files
   - Architecture design and implementation
   - Code review and analysis
   - Documentation generation

3. **Workflow Orchestration**
   - Coordinates between local LLMs (macOS) and cloud AI (Claude)
   - Routes tasks to appropriate models based on complexity
   - Manages multi-step development workflows
   - Integrates with Vim/Tmux environment on rpitex

4. **GitHub Operations**
   - **Branch Management**: Creates feature branches with proper naming
   - **Commit Strategy**: Writes detailed commit messages following best practices
   - **Pull Requests**: Can assist in creating and reviewing PRs
   - **Issue Tracking**: Links commits to issues
   - **Code Search**: Searches across codebase using specialized agents

#### Claude Code Workflow

```
Developer Request
     ↓
Claude Code (Orchestration)
     ↓
   ┌─────────────────┬──────────────────┐
   │                 │                  │
Simple Task    Complex Task        GitHub Operation
   ↓                 ↓                  ↓
Route to Local  Handle Directly    Git Commands
(macOS LLM)     (Claude Sonnet)    (Branch/Commit/Push)
   ↓                 ↓                  ↓
phind-codellama  Analysis/Refactor  Update Repository
CodeLlama-70b    Documentation
Llama-4-Scout
```

#### When to Use Claude Code vs Local LLMs

**Use Claude Code for:**
- ✅ Repository operations (branch, commit, push)
- ✅ Multi-file refactoring
- ✅ Architecture decisions requiring broad context
- ✅ Complex OFBiz workflow analysis
- ✅ Documentation generation
- ✅ Code review and quality assessment
- ✅ BOM analysis and dataset creation

**Use Local LLMs (macOS) for:**
- ✅ Quick code completion (phind-codellama)
- ✅ Single-file code generation (CodeLlama-70b)
- ✅ Reasoning about specific problems (Llama-4-Scout)
- ✅ Real-time assistance while coding in Vim
- ✅ Fast iteration during development

#### Example: Collaborative Workflow

**Scenario**: Implement new BOM validation service

```
1. Developer describes requirement to Claude Code
   "Create a service to validate BOM completeness"

2. Claude Code:
   - Analyzes existing OFBiz BOM structure
   - Creates feature branch: claude/bom-validation-feature
   - Searches codebase for similar validation patterns
   - Designs service interface

3. Developer uses Vim on rpitex:
   - Opens service file in Vim
   - Uses <Space>lc (local LLM) for code completion
   - Uses <Space>lg to generate utility methods
   - Quick iterations with fast local models

4. Claude Code reviews:
   - Checks code quality
   - Suggests improvements
   - Adds comprehensive documentation
   - Commits changes with detailed message
   - Pushes to GitHub

5. Result: High-quality implementation with:
   - Fast local development (macOS LLMs)
   - Strategic guidance (Claude Code)
   - Proper version control (GitHub)
```

#### GitHub Branch Editing with Claude Code

Claude Code can directly edit branches on GitHub, making it ideal for:

**Creating Features**:
```
User: "Add a service to calculate garment production cost with BOM data"

Claude Code:
1. Creates branch: claude/garment-cost-calculation-XYZ
2. Analyzes existing cost calculation patterns
3. Implements service with proper OFBiz conventions
4. Adds unit tests
5. Updates documentation
6. Commits with comprehensive message:
   "Add garment production cost calculation service

   - Implements calculateGarmentCost service
   - Explodes BOM and sums material costs
   - Includes scrap factor calculations
   - Adds labor and overhead allocation
   - Unit tests with sample data

   Refs #123"
7. Pushes to GitHub
```

**Fixing Bugs**:
```
User: "Fix the BOM explosion issue where scrap factors aren't applied"

Claude Code:
1. Creates branch: claude/fix-bom-scrap-factor-XYZ
2. Searches codebase for BOM explosion logic
3. Identifies issue in getManufacturingComponents service
4. Fixes calculation
5. Adds regression test
6. Commits and pushes
```

**Refactoring**:
```
User: "Refactor MRP code to use modern OFBiz patterns"

Claude Code:
1. Creates branch: claude/refactor-mrp-modern-patterns-XYZ
2. Analyzes multiple files in manufacturing module
3. Refactors with modern patterns (EntityQuery, ServiceUtil)
4. Maintains backward compatibility
5. Updates related documentation
6. Commits with migration notes
```

### Data Flow

```
rpitex Vim Editor
     ↓
  (User presses <Space>lc for completion)
     ↓
  Vim function calls curl
     ↓
  HTTP POST → macOS:5000/complete
     ↓
  Flask API receives request
     ↓
  Routes to phind-codellama (Ollama)
     ↓
  LLM generates completion
     ↓
  Returns JSON response
     ↓
  Vim inserts completion at cursor
```

---

## macOS M2 Ultra LLM Server Setup

### Prerequisites

- macOS with Apple Silicon (M2 Ultra)
- 192GB RAM (excellent for running large models)
- Homebrew package manager
- Python 3.10+

### Step 1: Install Dependencies

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python 3
brew install python@3.11

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Or using Homebrew
brew install ollama
```

### Step 2: Install MLX-LM and Python Dependencies

```bash
# Create virtual environment
python3 -m venv ~/.ftm-llm-env
source ~/.ftm-llm-env/bin/activate

# Install MLX and MLX-LM
pip install mlx
pip install mlx-lm

# Install Flask and dependencies
pip install flask flask-cors requests
```

### Step 3: Download LLM Models

#### MLX-LM Models

```bash
# These will be downloaded on first use by mlx-lm
# Models are stored in ~/.cache/huggingface/

# Pre-download (optional, to verify)
python3 -c "from mlx_lm import load; load('mlx-community/Llama-4-Scout-17B-16E-Instruct-8bit')"
python3 -c "from mlx_lm import load; load('mlx-community/CodeLlama-70b-Instruct-hf-4bit-MLX')"
```

**Note:** First load will download ~8GB for Llama-4-Scout and ~35GB for CodeLlama-70b.

#### Ollama Models

```bash
# Start Ollama service
ollama serve &

# Pull phind-codellama model
ollama pull phind-codellama:34b-v2-fp16

# Verify
ollama list
```

Expected output:
```
NAME                          ID              SIZE    MODIFIED
phind-codellama:34b-v2-fp16   abc123def456    20GB    2 minutes ago
```

### Step 4: Install LLM Server Scripts

```bash
# Clone your repository
cd ~/
git clone https://github.com/texchi2/ftmerp-java-project.git

# Copy server script to a permanent location
mkdir -p ~/ftm-erp-llm
cp ~/ftmerp-java-project/docs/scripts/llm-server.py ~/ftm-erp-llm/
cp ~/ftmerp-java-project/docs/scripts/start-llm-server.sh ~/ftm-erp-llm/
chmod +x ~/ftm-erp-llm/*.sh
```

### Step 5: Configure LLM Server

Edit `~/ftm-erp-llm/llm-server.py` if needed to adjust model paths or ports.

Default configuration:
```python
FLASK_PORT = 5000
OLLAMA_HOST = "http://localhost:11434"
```

### Step 6: Set Up Automatic Startup (Optional)

Create a LaunchAgent for automatic startup on macOS:

```bash
# Create LaunchAgent directory
mkdir -p ~/Library/LaunchAgents

# Create plist file
cat > ~/Library/LaunchAgents/com.ftm.llm-server.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ftm.llm-server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/YOUR_USERNAME/ftm-erp-llm/start-llm-server.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/YOUR_USERNAME/ftm-erp-llm/llm-server.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/YOUR_USERNAME/ftm-erp-llm/llm-server-error.log</string>
</dict>
</plist>
EOF

# Replace YOUR_USERNAME with your actual username
sed -i '' "s/YOUR_USERNAME/$(whoami)/g" ~/Library/LaunchAgents/com.ftm.llm-server.plist

# Load the agent
launchctl load ~/Library/LaunchAgents/com.ftm.llm-server.plist
```

### Step 7: Start LLM Server Manually

```bash
cd ~/ftm-erp-llm
./start-llm-server.sh
```

Expected output:
```
=========================================
FTM ERP LLM Server Starting
=========================================
Host: 0.0.0.0
Port: 5000
Ollama Host: http://localhost:11434
=========================================
✓ Python 3 found: Python 3.11.6
✓ mlx-lm already installed
✓ Ollama is running on port 11434
✓ phind-codellama:34b-v2-fp16 is available
=========================================
Starting LLM Server
=========================================
Local access:  http://localhost:5000
LAN access:    http://192.168.1.100:5000

Configure rpitex to use: http://192.168.1.100:5000
=========================================

 * Serving Flask app 'llm-server'
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://192.168.1.100:5000
```

### Step 8: Test Local Server

```bash
# In a new terminal
# Health check
curl http://localhost:5000/health | jq

# List models
curl http://localhost:5000/models | jq

# Test completion
curl -X POST http://localhost:5000/complete \
  -H "Content-Type: application/json" \
  -d '{
    "prefix": "public class HelloWorld {",
    "language": "java",
    "model": "phind-codellama",
    "max_tokens": 100
  }' | jq
```

---

## rpitex Raspberry Pi 5 Client Setup

### Step 1: Install Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Vim and Tmux
sudo apt install -y vim tmux git curl jq

# Install Python 3 and pip
sudo apt install -y python3 python3-pip python3-venv

# Install PostgreSQL client tools
sudo apt install -y postgresql-client
```

### Step 2: Set Up Development Environment

```bash
# Create development directory if not exists
mkdir -p ~/development

# Clone repository
cd ~/development
git clone https://github.com/texchi2/ftmerp-java-project.git ofbiz-framework
git clone https://github.com/texchi2/ftmerp-java-plugins.git ofbiz-plugins

# Create symlink
cd ofbiz-framework
ln -sf ../ofbiz-plugins plugins
```

### Step 3: Install Vim Plugins

```bash
# Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Copy FTM vim configuration
cp ~/development/ofbiz-framework/docs/configs/vimrc-llm ~/.vimrc

# Set LLM server URL
export LLM_SERVER_URL="http://192.168.1.100:5000"
echo 'export LLM_SERVER_URL="http://192.168.1.100:5000"' >> ~/.bashrc

# Install vim plugins
vim +PlugInstall +qall
```

### Step 4: Set Up Tmux

```bash
# Copy configuration from FTM-SETUP-GUIDE.adoc
cat > ~/.tmux.conf <<'EOF'
# Set prefix to Ctrl-a
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Enable mouse support
set -g mouse on

# Start windows and panes at 1
set -g base-index 1
setw -g pane-base-index 1

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Split panes using | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Vim-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Status bar
set -g status-style bg=black,fg=white
set -g status-left-length 40
set -g status-left "#[fg=green]Session: #S #[fg=yellow]#I #[fg=cyan]#P"
set -g status-right "#[fg=cyan]%d %b %R"

# 256 colors
set -g default-terminal "screen-256color"

# Vi mode
setw -g mode-keys vi
EOF
```

### Step 5: Install LLM Client Script

```bash
# Copy client script
mkdir -p ~/bin
cp ~/development/ofbiz-framework/docs/scripts/llm-client.py ~/bin/
chmod +x ~/bin/llm-client.py

# Make sure ~/bin is in PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Step 6: Create FTM Development Session Script

```bash
cat > ~/bin/ftm-dev.sh <<'EOF'
#!/bin/bash
# FTM ERP Development Session

SESSION="ftm-erp"

# Check if session exists
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    # Create new session
    tmux new-session -d -s $SESSION -n editor -c ~/development/ofbiz-framework

    # Window 1: Editor (vim)
    tmux send-keys -t $SESSION:editor "cd ~/development/ofbiz-framework/plugins/ftm-garments" C-m
    tmux send-keys -t $SESSION:editor "vim ." C-m

    # Window 2: Build & Run
    tmux new-window -t $SESSION -n build -c ~/development/ofbiz-framework
    tmux split-window -h -t $SESSION:build -c ~/development/ofbiz-framework
    tmux send-keys -t $SESSION:build.0 "# Build commands here" C-m
    tmux send-keys -t $SESSION:build.1 "# Run server here" C-m

    # Window 3: Database
    tmux new-window -t $SESSION -n database -c ~/development/ofbiz-framework
    tmux send-keys -t $SESSION:database "# psql -U ftmuser -d ftmerp" C-m

    # Window 4: Git
    tmux new-window -t $SESSION -n git -c ~/development/ofbiz-framework
    tmux split-window -h -t $SESSION:git -c ~/development/ofbiz-plugins
    tmux send-keys -t $SESSION:git.0 "cd ~/development/ofbiz-framework" C-m
    tmux send-keys -t $SESSION:git.0 "# Framework git operations" C-m
    tmux send-keys -t $SESSION:git.1 "cd ~/development/ofbiz-plugins" C-m
    tmux send-keys -t $SESSION:git.1 "# Plugins git operations" C-m

    # Window 5: Logs
    tmux new-window -t $SESSION -n logs -c ~/development/ofbiz-framework/runtime/logs
    tmux send-keys -t $SESSION:logs "# tail -f ofbiz.log" C-m

    # Window 6: LLM Helper
    tmux new-window -t $SESSION -n llm -c ~/development/ofbiz-framework
    tmux send-keys -t $SESSION:llm "# LLM client ready - use llm-client.py" C-m

    # Select first window
    tmux select-window -t $SESSION:editor
fi

# Attach to session
tmux attach-session -t $SESSION
EOF

chmod +x ~/bin/ftm-dev.sh
```

### Step 7: Test Client Connection

```bash
# Test health check
curl http://192.168.1.100:5000/health

# Test using Python client
llm-client.py --server http://192.168.1.100:5000 health

# Test code completion
echo "public class Test {" | llm-client.py --server http://192.168.1.100:5000 complete --stdin --language java
```

---

## Network Configuration

### macOS Firewall Configuration

```bash
# Allow incoming connections on port 5000
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/python3
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/bin/python3

# Or disable firewall for LAN (less secure)
# System Preferences → Security & Privacy → Firewall → Turn Off Firewall
```

### pfSense Firewall Rules (if applicable)

If your LAN has strict firewall rules:

1. Log into pfSense admin panel
2. Go to: Firewall → Rules → LAN
3. Add rule:
   - Action: Pass
   - Protocol: TCP
   - Source: rpitex IP (192.168.1.50)
   - Destination: macOS IP (192.168.1.100)
   - Destination Port: 5000
   - Description: FTM LLM Server Access

### Network Testing

```bash
# From rpitex
# Test network connectivity
ping -c 4 192.168.1.100

# Test port accessibility
nc -zv 192.168.1.100 5000

# Test HTTP connection
curl -v http://192.168.1.100:5000/health
```

### Static IP Configuration (Recommended)

**On macOS:**
```
System Preferences → Network → Wi-Fi/Ethernet
→ Advanced → TCP/IP
→ Configure IPv4: Manually
→ IP Address: 192.168.1.100
→ Subnet Mask: 255.255.255.0
→ Router: 192.168.1.1
```

**On rpitex:**
```bash
# Edit network configuration
sudo nano /etc/dhcpcd.conf

# Add at the end:
interface eth0
static ip_address=192.168.1.50/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8

# Restart networking
sudo systemctl restart dhcpcd
```

---

## Testing the Setup

### End-to-End Integration Test

#### Test 1: Health Check

```bash
# On rpitex
curl http://192.168.1.100:5000/health | jq
```

Expected response:
```json
{
  "status": "healthy",
  "models": {
    "llama-scout": {
      "type": "mlx",
      "loaded": false,
      "use_case": "reasoning"
    },
    "codellama-70b": {
      "type": "mlx",
      "loaded": false,
      "use_case": "code_generation"
    },
    "phind-codellama": {
      "type": "ollama",
      "available": true,
      "use_case": "code_completion"
    }
  }
}
```

#### Test 2: Code Completion

```bash
# On rpitex
curl -X POST http://192.168.1.100:5000/complete \
  -H "Content-Type: application/json" \
  -d '{
    "prefix": "public class OrderService {\n    public String createOrder(",
    "suffix": ") {\n        return orderId;\n    }\n}",
    "language": "java",
    "model": "phind-codellama",
    "max_tokens": 150
  }' | jq '.completion'
```

#### Test 3: Code Explanation

```bash
# Create test file
cat > /tmp/test.java <<'EOF'
public class BOMCalculator {
    public double calculateMaterialCost(String productId, int quantity) {
        // TODO: implement
        return 0.0;
    }
}
EOF

# Get explanation
llm-client.py --server http://192.168.1.100:5000 explain --file /tmp/test.java
```

#### Test 4: Vim Integration

```bash
# Start vim
vim /tmp/test.java

# In vim:
# 1. Press <Space>h to see help
# 2. Type some Java code
# 3. Press <Space>lc for completion
# 4. Select code in visual mode
# 5. Press <Space>le for explanation
```

---

## Usage Guide

### Vim LLM Commands Reference

| Command | Mode | Key Binding | Description |
|---------|------|-------------|-------------|
| Complete | Normal/Insert | `<Space>lc` or `<C-Space>` | Code completion (FIM-aware) |
| Explain | Visual | `<Space>le` | Explain selected code |
| Refactor | Visual | `<Space>lr` | Refactor selected code |
| Refactor Custom | Visual | `<Space>lR` | Refactor with custom instructions |
| Generate | Normal | `<Space>lg` | Generate code from description |
| Ask/Reason | Normal | `<Space>la` | Ask LLM for help/reasoning |
| Help | Normal | `<Space>h` | Show help message |

### Workflow Examples

#### Example 1: Complete OFBiz Service Method

```java
// In vim, type:
public Map<String, Object> calculateGarmentCost(DispatchContext dctx,
                                                  Map<String, Object> context) {
    // Press <Space>lc here
```

LLM will complete with:
```java
    String productId = (String) context.get("productId");
    BigDecimal quantity = (BigDecimal) context.get("quantity");
    Delegator delegator = dctx.getDelegator();

    // Get BOM components
    List<GenericValue> bomComponents = EntityQuery.use(delegator)
        .from("ProductAssoc")
        .where("productId", productId,
               "productAssocTypeId", "MANUF_COMPONENT")
        .filterByDate()
        .queryList();

    // Calculate cost
    BigDecimal totalCost = BigDecimal.ZERO;
    // ... implementation continues
```

#### Example 2: Explain Complex OFBiz Code

```java
// Select this code in visual mode (V)
List<GenericValue> results = EntityQuery.use(delegator)
    .from("WorkEffort")
    .where("workEffortTypeId", "PROD_ORDER_HEADER")
    .filterByDate()
    .queryList();

// Press <Space>le
```

LLM explanation appears in new split window:
```
This code queries the OFBiz entity engine to retrieve production order records.

Breaking it down:
1. EntityQuery.use(delegator) - Starts a new entity query
2. from("WorkEffort") - Queries the WorkEffort entity
3. where() - Filters for production orders only
4. filterByDate() - Applies date filtering (fromDate/thruDate)
5. queryList() - Returns all matching records as a list

In the FTM garments context, this would retrieve all active production
runs for manufacturing shirts, pants, etc.
```

#### Example 3: Generate Service from Description

```
Press <Space>lg
Prompt: "Create a service to calculate total fabric needed for a production run"
```

LLM generates:
```groovy
import org.apache.ofbiz.entity.util.EntityQuery

def calculateFabricNeeded(DispatchContext dctx, Map context) {
    def delegator = dctx.getDelegator()
    def productionRunId = context.productionRunId

    // Get production run
    def productionRun = EntityQuery.use(delegator)
        .from("WorkEffort")
        .where("workEffortId", productionRunId)
        .queryOne()

    if (!productionRun) {
        return ServiceUtil.returnError("Production run not found")
    }

    def productId = productionRun.productId
    def quantity = productionRun.quantityToProduce

    // Get fabric components from BOM
    def fabricComponents = EntityQuery.use(delegator)
        .from("ProductAssoc")
        .where("productId", productId,
               "productAssocTypeId", "MANUF_COMPONENT")
        .filterByDate()
        .queryList()
        .findAll { it.productIdTo.contains("FABRIC") }

    // Calculate total fabric
    def totalFabric = 0.0
    fabricComponents.each { component ->
        def qtyPerUnit = component.quantity ?: 1.0
        def scrapFactor = component.scrapFactor ?: 1.0
        totalFabric += qtyPerUnit * scrapFactor * quantity
    }

    return ServiceUtil.returnSuccess([totalFabricNeeded: totalFabric])
}
```

#### Example 4: Ask for Reasoning

```
Press <Space>la
Question: "How should I handle production run cancellation if materials are already issued?"
```

LLM reasoning response in tmux pane:
```
Analysis:
When canceling a production run after material issuance, you need to
handle several OFBiz entities and maintain data integrity:

Recommended Approach:

1. Check Production Run Status
   - Only allow cancellation if not COMPLETED
   - Service: changeProductionRunStatus with statusId=PRUN_CANCELLED

2. Return Issued Materials to Inventory
   - Query WorkEffortInventoryAssign for issued materials
   - For each assignment:
     - Reverse InventoryItemDetail transaction
     - Update InventoryItem quantities
   - Service: returnInventoryFromWorkEffort (custom or built-in)

3. Update Related Entities
   - OrderItemShipGrpInvRes: Release reservations
   - MrpEvent: Mark as cancelled
   - WorkEffort: Set actualCompletionDate

4. Financial Considerations
   - If costs were already allocated, create reversal entries
   - Update GL accounts if using inventory accounting

Step-by-step Implementation:
...
```

### Command Line Usage

```bash
# Complete code from file
llm-client.py --server http://192.168.1.100:5000 complete \
  --file MyService.java \
  --language java

# Explain code from stdin
cat MyService.java | llm-client.py --server http://192.168.1.100:5000 explain --stdin

# Refactor with instructions
llm-client.py --server http://192.168.1.100:5000 refactor \
  --file MyService.java \
  --instructions "Add error handling and logging"

# Generate new code
llm-client.py --server http://192.168.1.100:5000 generate \
  "Create a service to validate BOM components" \
  --language groovy \
  --framework OFBiz

# Ask for reasoning
llm-client.py --server http://192.168.1.100:5000 reason \
  "How to optimize MRP performance for 10000 products?" \
  --context "Using PostgreSQL database"
```

---

## Troubleshooting

### Issue 1: Cannot Connect to LLM Server

**Symptoms:**
```
curl: (7) Failed to connect to 192.168.1.100 port 5000: Connection refused
```

**Checklist:**
1. ✓ Is LLM server running on macOS?
   ```bash
   # On macOS
   ps aux | grep llm-server.py
   ```

2. ✓ Is Ollama running?
   ```bash
   # On macOS
   ps aux | grep ollama
   curl http://localhost:11434/api/tags
   ```

3. ✓ Is firewall blocking?
   ```bash
   # On macOS
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
   ```

4. ✓ Network connectivity?
   ```bash
   # On rpitex
   ping 192.168.1.100
   nc -zv 192.168.1.100 5000
   ```

**Fix:**
```bash
# Restart LLM server on macOS
cd ~/ftm-erp-llm
./start-llm-server.sh
```

### Issue 2: Vim Commands Not Working

**Symptoms:**
```
E117: Unknown function: FTM_Complete
```

**Fix:**
```bash
# On rpitex
# Ensure vimrc is loaded
vim --version | grep vimrc

# Re-copy configuration
cp ~/development/ofbiz-framework/docs/configs/vimrc-llm ~/.vimrc

# Reload vim configuration
vim
:source ~/.vimrc
```

### Issue 3: Slow LLM Responses

**Symptoms:**
- Completion takes >30 seconds
- Timeout errors

**Optimization:**

1. **Reduce max_tokens:**
   Edit `~/.vimrc`:
   ```vim
   let data = {
       \ 'max_tokens': 100  " Reduce from 300
   \ }
   ```

2. **Use faster model:**
   ```vim
   let data = {
       \ 'model': 'phind-codellama'  " Fastest
       \ " instead of 'codellama-70b'
   \ }
   ```

3. **Increase timeout:**
   ```vim
   function! s:call_llm(endpoint, data)
       let cmd = 'timeout 60s curl ...'  " Increase from 30s
   endfunction
   ```

### Issue 4: Model Not Loading

**Symptoms:**
```json
{
  "error": "Failed to load llama-scout"
}
```

**Fix:**
```bash
# On macOS
# Check model files
ls -lh ~/.cache/huggingface/hub/

# Re-download model
python3 <<EOF
from mlx_lm import load
model, tokenizer = load("mlx-community/Llama-4-Scout-17B-16E-Instruct-8bit")
print("Model loaded successfully")
EOF
```

### Issue 5: Out of Memory on macOS

**Symptoms:**
- Server crashes when loading large model
- macOS shows memory pressure

**Solutions:**

1. **Load models one at a time:**
   ```python
   # In llm-server.py, comment out auto-loading
   # Only load on-demand
   ```

2. **Use smaller models:**
   - Llama-4-Scout-8bit ✓ (~8GB)
   - CodeLlama-70b-4bit ✓ (~35GB)
   - Total: ~43GB (fits in 192GB RAM)

3. **Monitor memory:**
   ```bash
   # On macOS
   top -o MEM
   ```

---

## Performance Optimization

### Model Preloading

To reduce first-request latency:

```bash
# On macOS
curl -X POST http://localhost:5000/preload \
  -H "Content-Type: application/json" \
  -d '{
    "models": ["llama-scout", "codellama-70b"]
  }'
```

Add to `start-llm-server.sh`:
```bash
# After server starts, preload models in background
sleep 10
curl -X POST http://localhost:5000/preload \
  -H "Content-Type: application/json" \
  -d '{"models": ["llama-scout", "codellama-70b"]}' &
```

### Caching Responses

For repeated completions, implement caching:

```python
# In llm-server.py
from functools import lru_cache

@lru_cache(maxsize=100)
def cached_completion(prompt, model):
    return generate_ollama(model, prompt)
```

---

## Summary

**Setup Checklist:**

macOS M2 Ultra:
- ✓ Install MLX-LM
- ✓ Install Ollama
- ✓ Download models
- ✓ Start LLM server
- ✓ Configure firewall
- ✓ Set static IP

rpitex Raspberry Pi 5:
- ✓ Install Vim + Tmux + Vimux
- ✓ Configure .vimrc with LLM functions
- ✓ Install llm-client.py
- ✓ Set LLM_SERVER_URL
- ✓ Create ftm-dev.sh
- ✓ Test connection

**Daily Workflow:**
1. Start LLM server on macOS (or use LaunchAgent)
2. SSH to rpitex
3. Run `ftm-dev.sh` to start tmux session
4. Code with LLM assistance in vim

**Quick Commands:**
```bash
# macOS: Start server
~/ftm-erp-llm/start-llm-server.sh

# rpitex: Start development
ftm-dev.sh

# Test connection
curl http://192.168.1.100:5000/health
```

---

**Document Version**: 1.0
**Last Updated**: 2025-12-18
**Author**: FTM ERP Development Team
