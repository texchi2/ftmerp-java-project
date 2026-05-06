# `framework/` — OFBiz core engines

Inherits all rules from `/CLAUDE.md`. **Additional caution required.**

## Default posture: do not modify

`framework/` contains the OFBiz engines themselves (entity, service, security, webapp, widget, minilang, base, start, etc.). These are the foundation that every component in `applications/` and every plugin in `ftmerp-java-plugins` depends on.

**Modifying `framework/` is the highest-risk change in this repo.** Default behavior:

1. Assume the bug lives in `applications/` or a plugin first. Search there.
2. If the issue truly is in `framework/`, **stop and ask Dr Tex** before editing.
3. Prefer working around a framework limitation in calling code over patching the framework.

## If you must modify `framework/`

All of the following are required, no exceptions:

- A failing test under `framework/testtools/` (or the relevant component) that reproduces the bug.
- The fix.
- The test now passes.
- A full build: `./gradlew build`.
- A full restart (every framework change requires restart — see root CLAUDE.md §7).
- Smoke test the affected engine — for entity changes, query a known entity; for service changes, run a known service; for webapp changes, hit the login page.
- Commit body explicitly notes which engine changed and what downstream components could be affected.

## Subdirectory map

| Path | Engine | Touch only if |
|---|---|---|
| `framework/base/` | bootstrap, utilities | foundation bug, very rare |
| `framework/start/` | startup | startup-script bug |
| `framework/entity/` | entity engine, delegator | data-layer bug — extreme caution |
| `framework/entityext/` | EECA, distributed cache | EECA bug |
| `framework/service/` | service dispatcher, ECA | service-engine bug |
| `framework/security/` | auth, permissions | security bug — Dr Tex must approve |
| `framework/webapp/` | request handler, view handler, controller | URL-routing or session bug |
| `framework/widget/` | screen / form / menu renderer | rendering bug |
| `framework/minilang/` | MiniLang interpreter | MiniLang feature/bug |
| `framework/catalina/` | embedded Tomcat config | container-level issue |
| `framework/datafile/` | flat-file parser | data-file import |
| `framework/testtools/` | test runner | tests themselves — ok to edit freely |

`framework/testtools/` is the one place in `framework/` where edits are routine (adding tests). Everything else: ask first.

## Forbidden without explicit Dr Tex approval

- Changing engine signatures or public APIs (downstream plugins depend on them).
- Removing deprecated methods (plugins may still use them).
- Switching dependency versions in `framework/*/build.gradle`.
- Modifying `framework/security/` — auth changes need a security review.
- Modifying `framework/entity/config/entityengine.xml` (DB credentials, usually `assume-unchanged`).
