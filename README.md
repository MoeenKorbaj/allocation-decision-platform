# Allocation Decision Platform

A decision-support platform for allocating limited public resources (grants, housing units, ...)
from the decision-maker's perspective.

**The problem:** a limited resource, far more applicants than supply, a policy to apply,
and legal accountability for every decision.

**The approach:** AI understands and explains; a mathematical optimizer (OR-Tools CP-SAT) computes
the allocation deterministically; a human approves. Policies are versioned data, not code.

> **Status:** Week 0 - production platform foundation (no AI yet).

> **Disclaimer:** all data is synthetic and all program regulations are fictional.
> Nothing here represents any real government program or organization.

## Repository layout

| Path | Content |
|---|---|
| `src/` | Domain, optimization engine, MCP servers, agents, portal |
| `tests/` | Unit, integration and engine determinism tests |
| `infra/` | Bicep (Azure Verified Modules), environments |
| `eval/` | AI evaluation datasets, evaluators, thresholds |
| `data/` | Synthetic data generator, knowledge for Foundry IQ |
| `prompts/` | Versioned agent instructions |
| `docs/` | ADRs, architecture, compliance, runbooks |

## License

MIT