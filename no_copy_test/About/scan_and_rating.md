# Project Scan & Rating — lets_docker/no_copy_test

Last updated: 2025-08-27 00:39

Scope: Quick, opinionated scan of the no_copy_test environment (Dockerfile, scripts, Django settings, entrypoint, README), complemented by the in-repo security audit at About/flaws/flaws.md.

Overall Rating: 6.5/10

Category Scores
- Developer Experience: 8/10
- Documentation & Onboarding: 8/10
- Maintainability: 6/10
- Docker Best Practices: 5/10
- Security Posture: 5/10

Key Strengths
- Clear dev workflow and onboarding (README, scripts, entrypoint messages).
- Practical developer tooling: interactive setup (desktopish.py), auto DB creation/checks, zip-based project extraction.
- Reasonable separation of app and config via .env (not committed), and environment-variable based Django settings.
- Entrypoint enforces presence of required env vars and runs migrations before starting dev server.

Notable Risks and Findings
- Security
  - run_docker_with_db.sh opens host MySQL to 0.0.0.0 temporarily and uses sudo; functional for local dev but risky if left running or adapted beyond dev.
  - README troubleshooting suggests VERY broad MySQL grants (ALL PRIVILEGES on *.* to 172.17.0.%); already called out in About/flaws/flaws.md.
  - Dockerfile runs as root; no USER non-root and no HEALTHCHECK.
  - Host network mode is used; increases coupling and risk surface.
- Maintainability / Robustness
  - requirements.txt uses broad versions (e.g., Django>=4.0) which may lead to upgrade breakage; pinning recommended.
  - update_mounts.py appears incomplete (constructs volume path but does not execute docker run); likely dead or WIP.
  - Entry-point depends on zip presence and uses tree for diagnostics; fine for dev, noisy for CI/lean images.
- Architecture / Best Practices
  - No docker-compose to declare DB service, networks, and env in a reproducible stack.
  - Image lacks multi-stage or hardening steps; build tools left in final layer.
  - No CI, tests, or image scanning integrated.

Quick Wins (Low Effort → High Impact)
- Pin dependency versions (Django, mysqlclient, python-dotenv). Consider a constraints file.
- Add USER appuser and a simple HEALTHCHECK in Dockerfile.
- Prefer docker-compose with a MySQL service over host MySQL + host network + sudo edits.
- Replace broad GRANT guidance with least-privilege examples (already noted in flaws.md).
- Tighten entrypoint: reduce verbosity in non-debug mode; parameterize wait-for-DB with retries.
- Mark update_mounts.py as experimental or complete its intended functionality.

What’s Working Well
- Onboarding is simple and clearly communicated.
- Scripts fail fast and provide user feedback (colors, messages, exit codes).
- Django settings pull from environment and include basic security validators.

Suggested Next Steps (to reach 8+/10)
- Introduce docker-compose (web + db) with non-root users, isolated network, and env files.
- Harden Docker image: non-root user, healthcheck, minimal packages; consider multi-stage.
- Add basic CI and dependency scanning (e.g., GitHub Actions + pip-audit, Trivy).
- Implement app-level configuration for production toggles (DEBUG from env, ALLOWED_HOSTS from env).
- Document backup/restore and logging approach for DB in dev.

References
- See detailed security audit: About/flaws/flaws.md
