# BCC Stables — Feather development

New RedM stables resource built from scratch for the current Feather Framework.
The resource folder and export identity are `bcc-stables`.

## Branches and status

- `main` contains the current VORP version until the Feather Framework release.
- `feather` contains the new Feather build, with no backward compatibility.

This branch is a development scaffold, not a playable release. Legacy scripts,
SQL, bundled UI and publishing workflows have been removed. The manifest loads
no scripts and performs no database or gameplay operations. No integration tests
or live RedM acceptance have been completed.

## Authoritative plan

The master plan lives in the sibling `feather-framework-docs` repository at
`feather-stables/FEATHER_STABLES_MASTER_PLAN.md`.

Shared workspace location:
`C:/coding/feather-scripts/feather-framework-docs/feather-stables/FEATHER_STABLES_MASTER_PLAN.md`.

Start with Phase 0: verify exact local Feather API contracts and prove entity
ownership, native behavior and interrupted settlement recovery before gameplay.
Keep implementation status and acceptance evidence in the master plan.

## Integration direction

Use Core session, RPC, event, policy, locale and notification APIs, plus Feather
Economy, Inventory, MySQL, Routing, Toolkit and Menu v2 for their domain services.
Stables owns horse identity, lifecycle and gameplay rules. Do not add VORP/RSG
bridges, old BCC API aliases or legacy database imports.

Runtime dependencies and startup order follow the Phase 0 contract audit.
After deploying new scripts or manifest changes, run server-console `refresh`
before starting/restarting the resource.

## License

See [LICENSE.md](LICENSE.md). Preserve existing attribution and license notices.
