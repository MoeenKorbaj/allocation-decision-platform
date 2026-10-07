# ADR-10: Bicep + Azure Verified Modules + azd

- **Status:** Accepted
- **Date:** 2026-10-07

## Context
A public-sector platform must be auditable down to its infrastructure: every resource has to be
reproducible, reviewed and removable. For cost control on a personal subscription, environments
must be created before a demo and destroyed after it, in minutes and without manual steps.

## Decision
- All infrastructure is Bicep in `infra/`, built from **Azure Verified Modules (AVM)**.
- **azd** orchestrates infrastructure and application together through `azure.yaml`:
  `azd up` creates an environment, `azd down` removes it; `dev` and `prod` are azd environments.
- No resource is created by hand. SKUs are set explicitly in Bicep; no module default decides a price.
- Azure Policy (allowed region `uaenorth`, required tags, local auth disabled) is assigned
  at the project resource-group scope only, so other workloads in the subscription are unaffected.
- Azure Blueprints is not used: it is being retired (January 2027). Bicep in Git with pull-request
  review and Azure Policy is the replacement pattern Microsoft recommends.

## Alternatives considered
| Option | Why rejected |
|---|---|
| Terraform | Strong and multi-cloud, but adds state management and a second toolchain; this platform is Azure-only |
| Raw Bicep without AVM | Every module rewritten by hand, and security defaults re-derived each time |
| Portal or ad-hoc CLI | Not reproducible, not reviewable, not removable as a unit |
| Policy at subscription scope | Would affect unrelated workloads in the same subscription |

## Consequences
- **We gain:** one command to create or destroy an environment; infrastructure reviewed through the same PRs and checks as code; cost bounded by environment lifetime.
- **We pay:** AVM module versions must be tracked; azd conventions shape the repository layout.
- **Revisit when:** the platform moves to a landing zone with policies at management-group scope (post-launch).
