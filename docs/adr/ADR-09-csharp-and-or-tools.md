# ADR-09: C# end to end; OR-Tools via Google.OrTools for .NET

- **Status:** Accepted
- **Date:** 2026-10-07

## Context
An allocation decision must be reproducible: an appellant must get the same result a year later
from the same inputs. That requires a real optimization solver, not the LLM (ADR-01).
The project is built by one engineer at about 10 hours a week, so every additional language,
toolchain and deployment pipeline costs time that should go into the concepts:
agents, optimization, governance.

## Decision
- The whole platform is C# on .NET 10 (LTS): domain, optimization engine, both MCP servers,
  agents (Microsoft Agent Framework for .NET) and the portal (Blazor).
- The optimizer is Google OR-Tools CP-SAT through the official `Google.OrTools` NuGet package.
- The SDK is pinned in `global.json`; package versions are managed centrally in `Directory.Packages.props`.

## Alternatives considered
| Option | Why rejected |
|---|---|
| Python for the engine and agents (richer OR and AI ecosystem) | Two languages, two toolchains, two container types; splits the domain model across a language boundary |
| Python only for the engine, behind MCP | Workable, but the cross-language contract adds work with no benefit at this scale |
| A commercial solver (Gurobi, CPLEX) | Licensing cost; CP-SAT is free and sufficient for ~1,000 beneficiaries within 60 s |
| Vue for the portal | Breaks the single-language decision; the portal is not where the project's value lies |

## Consequences
- **We gain:** one language and one build; shared domain types between engine, servers and agents; simpler CI and containers.
- **We pay:** some AI and OR samples are Python-first and must be translated; Agent Framework .NET packages are newer than their Python equivalents.
- **Revisit when:** a required capability exists only in Python and cannot be reached through MCP.
