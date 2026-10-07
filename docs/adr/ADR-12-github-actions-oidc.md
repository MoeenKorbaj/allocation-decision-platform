# ADR-12: GitHub Actions with OIDC; protected main with required checks

- **Status:** Accepted (OIDC deployment lands with the infrastructure step)
- **Date:** 2026-10-07

## Context
In a system that allocates public money, the question "how do you know what is running in
production was reviewed and tested?" must have a verifiable answer. Long-lived deployment secrets
are a liability: they leak, expire unexpectedly and need manual rotation.

## Decision
- **No direct changes to `main`.** A ruleset (`protect-main`) blocks deletion and force pushes and
  requires a pull request. Required approvals are 0 (single maintainer); CI is the gatekeeper.
- **Required status checks** before merge:
  `build-test` (build with warnings as errors in CI, tests),
  `codeql (csharp)` (static analysis),
  `secrets-scan` (Gitleaks over full history),
  `dependency-review` (blocks new dependencies with high-severity vulnerabilities).
- **Dependabot** opens grouped weekly update PRs for NuGet and GitHub Actions; security updates are immediate.
- **OIDC federation** between GitHub Actions and Azure: a federated credential per environment,
  short-lived tokens, least-privilege role assignments. The repository stores identifiers only, never secrets.
- Deployment to `prod` requires manual approval through a GitHub environment.
- The repository is public: required for rulesets on a free plan, and gives unlimited Actions minutes.

## Alternatives considered
| Option | Why rejected |
|---|---|
| Service principal client secret in GitHub Secrets | Long-lived secret; expiry and rotation burden; leak risk |
| Azure DevOps Pipelines | Viable, but the code, reviews and checks already live in GitHub |
| Private repository | Rulesets require a paid plan; limited Actions minutes |
| One required approval | A single maintainer cannot approve their own pull request |

## Consequences
- **We gain:** no stored secrets; every change to `main` is built, tested and scanned; an auditable trail per pull request.
- **We pay:** every change, however small, goes through a branch and a pull request.
- **Revisit when:** a second contributor joins (require one approval and code-owner review).
