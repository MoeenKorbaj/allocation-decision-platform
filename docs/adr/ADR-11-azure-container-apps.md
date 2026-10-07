# ADR-11: Azure Container Apps for the MCP servers and the portal

- **Status:** Accepted
- **Date:** 2026-10-07

## Context
The platform runs three long-lived HTTP services: the Case Registry MCP server, the Allocation
Engine MCP server and the Blazor portal. Load is low and bursty (an allocation cycle, a demo),
so idle cost should be near zero. Releases must be reversible quickly, and one engineer cannot
operate a Kubernetes cluster.

## Decision
- The three services run on **Azure Container Apps** in one environment per azd environment.
- `minReplicas: 0` in dev, so idle services scale to zero.
- Revisions provide rollback: a bad release is reverted by shifting traffic to the previous revision.
- Images are stored in **Azure Container Registry (Basic)** and pulled with a managed identity, no registry passwords.
- Agents run as hosted agents on Foundry Agent Service, not on Container Apps.

## Alternatives considered
| Option | Why rejected |
|---|---|
| AKS | Full Kubernetes operations for three services; cost and effort out of proportion |
| App Service | No scale to zero; weaker fit for multiple small container services |
| Azure Functions | Poor fit for long-lived MCP servers and the stateful Blazor Server portal |
| GitHub Container Registry instead of ACR | Free for public images, but leaves the reference enterprise pattern (managed-identity pull, private registry) to save about $5 a month |

## Consequences
- **We gain:** near-zero idle cost, revision-based rollback, no cluster to operate.
- **We pay:** ACR Basic is a fixed cost (about $5/month) while it exists, mitigated by `azd down` between work periods; cold starts after scale to zero.
- **Revisit when:** the platform needs Kubernetes-specific capabilities or a landing zone mandates AKS.
