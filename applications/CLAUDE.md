# `applications/` — business components

Inherits all rules from `/CLAUDE.md`. Additions specific to the OFBiz business domain follow.

## Layout

Each subdirectory is an OFBiz component (accounting, content, datamodel, humanres, manufacturing, marketing, order, party, product, workeffort, plus `commonext`, `securityext`). Components are wired in `applications/component-load.xml`.

## When to use what

| Task | Tool |
|---|---|
| New persistent entity | `entitymodel.xml` (ASK Dr Tex first — schema change) |
| New lightweight, script-based service | **Groovy DSL** (`*.groovy` under `groovyScripts/`) |
| Service requiring strong typing, transactions, or perf | **Java** (heavier — discuss with Dr Tex) |
| Touching an EXISTING MiniLang service | leave it in MiniLang; do not write new MiniLang |
| UI screen | `widget-screen.xml` |
| UI form | `widget-form.xml` |
| Menu | `widget-menu.xml` |

Default to **Groovy DSL**. Java for typed/transactional/perf-critical work. **MiniLang is deprecated** by the Apache OFBiz community — do not author new MiniLang services. Existing MiniLang may be maintained in place; port to Groovy only on explicit request.

## Entity engine — do / don't

**Do**:

- Use `delegator.findByAnd(...)` / `EntityQuery.use(delegator)...` from Groovy/Java.
- Set `no-auto-stamp="true"` on entities mapped to external (non-OFBiz) DBs.
- Add `<view-entity>` for read-only joins instead of N+1 queries.
- (Legacy MiniLang uses `<entity-and>`, `<entity-condition>`, `<entity-find>` — maintain in place if encountered, do not author new.)

**Don't**:

- Bypass the entity engine with `java.sql.*` or `Class.forName("...Driver")`. The only sanctioned raw SQL is `groovy.sql.Sql` inside a Groovy service against an external DB.
- Modify `entitymodel.xml` (or `entitymodel_*.xml`) without explicit approval — schema drift is catastrophic in production.
- Touch `*Demo*Data.xml` or `*SeedData.xml` casually. Flag any change in the commit body.

## Permission services

Every user-facing service must enforce permissions:

- Set `auth="true"` on the service definition, **and**
- Inside the service: `<check-permission permission="..." action="...">` (MiniLang) or `dispatcher.runSync("checkPermission", ...)` (Groovy/Java).

Never trust `userLogin` from the request alone.

## Service return contract

- Groovy: `return success([key: value])` for success; `return error("message")` for failure. Do not throw — return.
- Java: `return ServiceUtil.returnSuccess(...)` / `ServiceUtil.returnError(...)`.
- Legacy MiniLang (maintenance only): `<field-to-result>` for each output, with `<check-errors/>` at the end.

## Screen / form XML

- Root element requires `xmlns=` and `xsi:schemaLocation=` (rule §5.4 in root CLAUDE.md).
- Reference labels via `${uiLabelMap.LabelName}`, never hard-code English.
- Run `agent-browser` after any screen/form change (see root CLAUDE.md §9). No unit-test requirement (per TDD policy in root §4).

## controller.xml

`<request-map>` entries come first, then `<view-map>` entries. Mixing the two breaks the URL router silently.

## Restart triggers (component-local)

- `ofbiz-component.xml` — restart required.
- `web.xml` (under `webapp/<name>/WEB-INF/`) — restart required.
- `entitymodel.xml`, `entitymodel_*.xml` — restart required.
- Service definitions (`*.xml` under `servicedef/`) — usually hot-reloaded, but verify in `ofbiz.log`.
- Screen / form / menu / FTL — hot-reloaded.
