# FTM ERP — `ftmerp-java-project`

FTM Group's internal fork of Apache OFBiz Framework (forked from `apache/ofbiz-framework` trunk, Sep 2025). **Not for upstream contribution.** All work stays in `texchi2/ftmerp-java-project`.

Sister repo: `ftmerp-java-plugins` (custom plugins, including `ftm-wifi-enrollment`).

---

## OpenWolf bootstrap

@.wolf/OPENWOLF.md

If `.wolf/OPENWOLF.md` does not resolve, **stop and tell Dr Tex** — OpenWolf must be initialized on this machine for this repo before continuing. Do not invent context.

Each session: read `.wolf/OPENWOLF.md`, check `.wolf/cerebrum.md` before generating code, check `.wolf/anatomy.md` before reading large files.

---

## 1. Think before coding

Before any edit or code generation, do this mental check:

- What do I actually know from the request?
- What am I assuming?
- What could be interpreted in multiple ways?
- What is unclear?

If something is unclear, **surface it — do not fill the gap silently.** Ask Dr Tex (or the calling agent) before proceeding. OFBiz is full of cross-component coupling; a wrong assumption costs a half-day of debugging.

Flow we want: `request → clarification → correct implementation`.
Flow we reject: `request → guess → wrong code → fix loop`.

---

## 2. Simplicity first

Do the minimum that solves the problem. Nothing more.

- No features beyond what was requested.
- No abstractions for one-time use.
- No "configurability just in case."
- No defensive coding for failures that cannot happen.
- No rewrites of working logic to make it "cleaner."

Self-check before committing: *would a senior OFBiz engineer call this overcomplicated?* If yes, simplify.

Three similar lines beats a premature abstraction.

---

## 3. Surgical edits

Every change must trace directly to the request.

- Only modify what the task requires.
- Do not refactor unrelated code.
- Do not reformat or restyle code you didn't have to touch.
- Do not delete dead code unless explicitly asked.
- Do not "improve" XSD-namespaced XML beyond the change.

OFBiz screens, forms, and services are referenced by name from many places (controller.xml, ofbiz-component.xml, MiniLang, Groovy, FTL). One "tidying" rename can break the wired graph silently.

---

## 4. Goal-driven execution (TDD policy)

Convert vague requests into verifiable goals:

- Bug fix → write a failing test that reproduces it, then fix.
- New behavior → define inputs/outputs, write the test, implement, re-run.
- Refactor → tests pass before and after, byte-identical behavior.

### TDD MANDATORY for

- **Service engine** code (`*.xml` service definitions + Java/Groovy implementations; legacy MiniLang too if you must touch it)
- **Entity engine** changes (entitymodel, view-entity, EECA)
- Business logic in Groovy or Java services

Use `./gradlew "ofbiz --test component=<name>"` or write JUnit under `framework/testtools/`.

### TDD NOT REQUIRED for

- Screen widget XML (`widget-screen.xml`, `widget-form.xml`, `widget-menu.xml`)
- FTL templates
- CSS / JS in `themes/`
- Tooltips, labels, UI copy

For these, browser-test via **agent-browser** (see §10).

---

## 5. OFBiz architecture rules (hard rules — violations require Dr Tex's approval)

1. **`/doc-first`**: fetch the relevant OFBiz XSD before writing any OFBiz XML (services, entities, screens, forms, menus, controller, component). Do not guess attributes.
2. **External DB entities**: always set `no-auto-stamp="true"` on entities mapped to non-OFBiz tables.
3. **Groovy services**: use `groovy.sql.Sql` for raw SQL (never bypass it), and always `return success([...])` (or `error(...)`).
4. **Screen XML**: `xmlns=` and `xsi:schemaLocation=` are required on the root element.
5. **`controller.xml` ordering**: all `<request-map>` entries come *before* `<view-map>` entries.
6. **Restart-required changes** (cannot hot-reload): `web.xml`, `entitymodel.xml`, `ofbiz-component.xml`. Tell Dr Tex when a change requires restart.
7. **Never bypass the entity engine** with raw JDBC except inside a Groovy service via `groovy.sql.Sql` for read-only reporting against external DBs.
8. **Never skip permission services** on user-facing service definitions. Use `<check-permission>` or service `auth="true"`.
9. **New component** requires entries in `applications/component-load.xml` or `framework/component-load.xml` plus a valid `ofbiz-component.xml`.
10. **MiniLang is deprecated** by the Apache OFBiz community — limited debugging, refactoring, and maintainability. **Do not write new MiniLang services.** New services use **Groovy DSL** (lightweight, script-based) or **Java** (heavier, typed). Existing MiniLang may be maintained in place; port to Groovy only when explicitly asked (Surgical Edits, §3).

---

## 6. ERP safety boundaries

OFBiz is an ERP. Treat the following as **read-only by default** — modify only with explicit instruction:

- `runtime/` (logs, working data, derived state)
- `config/` (deployment config, credentials)
- `framework/entity/config/entityengine.xml` (DB credentials — usually `assume-unchanged`)
- `gradle.properties.local` (real passwords)
- Any tenant data, seed data, or `*Demo*Data.xml`

**`entitymodel.xml`**: never auto-edit. Schema drift is catastrophic in an ERP. If a task seems to require an entity change, stop and ask.

If a commit touches seed/demo data, flag it explicitly in the commit body.

---

## 7. Build, test, restart commands

```bash
# Build
./gradlew build

# Run a component's tests
./gradlew "ofbiz --test component=<name>"

# Load all seed/demo data (DESTROYS dev DB — confirm first)
./gradlew loadAll

# Pull plugins
./pullAllPluginsSource.sh
```

### Clean restart of OFBiz

```bash
# Stop daemons
./gradlew --no-daemon terminateOfbiz

# Kill any survivors
pkill -f "ofbiz.base.start.Start" 2>/dev/null
pkill -f "GradleWrapperMain" 2>/dev/null
sleep 3
kill -9 $(ps aux | grep java | grep -v grep | awk '{print $2}') 2>/dev/null
sleep 3

# Verify nothing left
ps aux | grep java | grep -v grep   # must be empty

# Start
cd /opt/ofbiz-framework && ./gradlew ofbiz &

# Verify startup
grep "Started Apache Tomcat" runtime/logs/ofbiz.log | tail -2
```

### Paths

- Framework: `/opt/ofbiz-framework/`
- Plugin: `/opt/ofbiz-plugins/<plugin-name>/`
- Logs: `/opt/ofbiz-framework/runtime/logs/ofbiz.log`
- UI: `http://192.168.30.102:8080` (admin / ofbiz)

---

## 8. Commit policy

### Jira ID auto-prepend

Every commit subject must start with `OFBIZ-XXXXX:`.

Resolution order, no need to ask Dr Tex:

1. If the current branch matches `*/OFBIZ-NNNNN-*`, extract that ID.
2. Otherwise, ask **once per session** for the Jira ID and reuse it for every commit that session.
3. If neither is available, ask Dr Tex.

### Commit body

- Focus on *why*, not *what* (one or two sentences).
- Flag any seed-data or `entitymodel.xml` change explicitly.
- Flag if a restart is required.
- Keep the `https://claude.ai/code/...` trailer — FTM-internal, no upstream concern.

### Branch policy

- Develop on the branch the harness assigns (e.g. `claude/create-ofbiz-claude-md-fjK8M`).
- `git push -u origin <branch>`.
- Never force-push to main / trunk.
- Never `--no-verify`.

---

## 9. Browser testing

**Use `agent-browser`, never Playwright** for OFBiz UI testing.

Before any browser task:

```bash
agent-browser skills get agent-browser
```

Login: `admin` / `ofbiz` at `http://192.168.30.102:8080`. After login, navigate to the target screen and check for `ERROR MESSAGE` text in the rendered HTML — that is OFBiz's standard error rendering.

---

## 10. Multi-instance collaboration & model switching (Phase 9C)

### Instance roles

```
tmm7 (MacStudio)   → primary-dev  → claude-sonnet-4-6 / llama3.3:70b
ofbiz-dev (Incus)  → build-test   → gemma4-ofbiz:latest (via SSH tunnel)
rpitex (Pi5)       → staging      → gemma4-ofbiz:latest (via SSH tunnel)
```

### Local model endpoint

`llama3.3-agent:latest` via `http://192.168.30.3:11434`

### Shell aliases

`~/.zshrc` on tmm7, `~/.bashrc` on ofbiz-dev / rpitex:

```bash
# Cloud Claude
alias cc='claude'
alias cc-sonnet='claude --model claude-sonnet-4-6'
alias cc-opus='claude --model claude-opus-4-7'

# Local Ollama (MacStudio)
alias cc-llama='ollama launch claude --model llama3.3:70b'
alias cc-ofbiz='ollama launch claude --model gemma4-ofbiz:latest'
alias cc-fast='ollama launch claude --model gemma3:12b'

# On ofbiz-dev / rpitex (SSH tunnel to MacStudio Ollama)
alias tunnel-ollama='ssh -L 11434:localhost:11434 texchi@192.168.192.79 -N -f'
alias cc-ofbiz='ANTHROPIC_BASE_URL=http://127.0.0.1:11434 \
  ANTHROPIC_AUTH_TOKEN=ollama ANTHROPIC_API_KEY=ollama \
  claude --model gemma4-ofbiz:latest'
```

### Session start checklist

```bash
# 1. Sync git
ftm-sync

# 2. Check handoff notes
cat .claude-code-state.json | python3 -c "import json,sys; \
  s=json.load(sys.stdin)['session_handoff']; \
  print('Last:', s['last_completed']); \
  print('Current:', s['current_task']); \
  [print('TODO:', x) for x in s['unresolved']]"

# 3. Pick model (see decision guide below)
```

### Model decision guide

```
Task                              → Model
──────────────────────────────────────────────
Architecture / phase planning     → cc-sonnet or cc-opus
Debugging complex OFBiz errors    → cc-sonnet
Writing Groovy services           → cc-ofbiz (gemma4, knows OFBiz)
Writing screen / form XML         → cc-ofbiz
Bulk find-and-replace             → cc-llama (free, fast)
Git history / security tasks      → cc-sonnet (careful reasoning)
Quick bash commands               → cc-fast
```

### Shared state files

```
Tracked in git (auto-shared across instances):
  CLAUDE.md                       ← this file, project conventions
  applications/CLAUDE.md          ← business-component rules
  framework/CLAUDE.md             ← core-engine caution
  .wolf/cerebrum.md               ← OFBiz knowledge + failure patterns
                                    (the ONLY .wolf/ file in git)

Gitignored (per-machine, never tracked):
  .wolf/OPENWOLF.md               ← OpenWolf bootstrap (managed by local OpenWolf install)
  .wolf/anatomy.md                ← repo file map (managed by local OpenWolf install)
  .wolf/* (everything else)       ← per-machine OpenWolf working files
  .claude-code-state.json         ← session handoff (recreate per machine)
  gradle.properties.local         ← real passwords (recreate per machine)
  framework/entity/config/entityengine.xml  ← real passwords (assume-unchanged)
  start-ftm.sh                    ← recreate after re-clone
```

`.gitignore` lists each non-shared `.wolf/` file by name (negation patterns are not used). When a new per-machine file appears under `.wolf/`, add an explicit line for it. If you want a new file to be shared via git, simply do not list it.

### Context continuity across model switches

Compaction preserves architectural decisions, unresolved bugs, and implementation state. `CLAUDE.md` + `.wolf/cerebrum.md` are always loaded, so project context survives. Update `.claude-code-state.json` before switching machines.

---

## 11. Nested guidance

Two nested `CLAUDE.md` files extend these rules:

- `applications/CLAUDE.md` — when to use service / MiniLang / Groovy / Java; entity engine do's & don'ts; permission services; seed-data caution.
- `framework/CLAUDE.md` — core-engine caution: almost never modify; if you must, what tests must pass.

---

**Tradeoff:** these guidelines bias toward caution over speed. For trivial tasks (typo fixes, label tweaks), use judgment — but when in doubt, ask Dr Tex.
