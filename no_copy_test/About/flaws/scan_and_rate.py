#!/usr/bin/env python3
"""
Project Security Scanner & Rating Tool

Usage:
  python scan_and_rate.py [path] [--json]

- Scans a project directory for Docker/security heuristics and outputs:
  - Category scores (0-10) and an overall rating with recommendations.
- Pure standard library. Safe, read-only analysis.

Categories:
  - Dockerfiles & Containerization
  - Secrets & Sensitive Patterns
  - Database Practices
  - CI/Scanning & Automation Evidence
  - Repo Hygiene (env files, perms hints)

Heuristics are best-effort and deterministic for lightweight auditing.
"""
from __future__ import annotations
import os
import re
import json
import sys
from typing import List, Dict, Tuple

DOCKERFILE_NAMES = {"Dockerfile", "dockerfile"}
COMPOSE_NAMES = {"docker-compose.yml", "docker-compose.yaml", "compose.yaml", "compose.yml"}

EXCLUDED_EXTENSIONS = {".md", ".markdown"}

SECRET_PATTERNS = [
    re.compile(r"AWS_SECRET_ACCESS_KEY\s*[=:]", re.I),
    re.compile(r"AWS_ACCESS_KEY_ID\s*[=:]", re.I),
    re.compile(r"(?<![A-Z0-9_])SECRET(_?KEY)?\s*[=:]", re.I),
    re.compile(r"(?<![A-Z0-9_])API(_?KEY)?\s*[=:]", re.I),
    re.compile(r"PASSWORD\s*[=:]", re.I),
    re.compile(r"IDENTIFIED BY\s+'[^']*'", re.I),
    re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----", re.I),
    re.compile(r"GITHUB_TOKEN\s*[=:]", re.I),
    re.compile(r"GITLAB_TOKEN\s*[=:]", re.I),
    re.compile(r"DOCKER_PASSWORD\s*[=:]", re.I),
    re.compile(r"JWT_SECRET\s*[=:]", re.I),
    re.compile(r"DATABASE_URL\s*[=:].*://.*:.*@", re.I),
    re.compile(r"mongodb://.*:.*@", re.I),
    re.compile(r"redis://.*:.*@", re.I),
]

SCANNER_MENTIONS = [
    re.compile(r"trivy", re.I), re.compile(r"snyk", re.I), re.compile(r"dependabot", re.I), 
    re.compile(r"bandit", re.I), re.compile(r"safety", re.I), re.compile(r"semgrep", re.I),
    re.compile(r"codeql", re.I), re.compile(r"sonarqube", re.I), re.compile(r"anchore", re.I)
]


def walk_files(root: str) -> List[str]:
    files: List[str] = []
    for base, _, fnames in os.walk(root):
        # Skip common virtualenv/build dirs to speed up
        if any(sk in base.lower().split(os.sep) for sk in {".git", "__pycache__", "node_modules", "venv", ".venv", "site-packages", "dist", "build"}):
            continue
        for f in fnames:
            # Exclude documentation files from content scanning to avoid false positives
            if os.path.splitext(f)[1].lower() in EXCLUDED_EXTENSIONS:
                continue
            files.append(os.path.join(base, f))
    return files


def load_text(path: str) -> str:
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as fh:
            return fh.read()
    except Exception:
        return ""


def analyze_dockerfile(text: str) -> Dict[str, object]:
    lines = [l.strip() for l in text.splitlines()]
    from_count = sum(1 for l in lines if l.upper().startswith("FROM "))
    has_user = any(l.upper().startswith("USER ") for l in lines)
    user_non_root = any(re.search(r"^USER\s+(?!root\b)\S+", l, re.I) for l in lines)
    has_healthcheck = any(l.upper().startswith("HEALTHCHECK ") for l in lines)
    exposes = [l for l in lines if l.upper().startswith("EXPOSE ")]
    has_apt_cleanup = any("apt-get" in l and ("rm -rf /var/lib/apt/lists" in l or "apt-get clean" in l) for l in lines)
    uses_pip_no_cache = any("pip install" in l and "--no-cache-dir" in l for l in lines)
    
    # Additional security checks
    has_add_instead_copy = any(l.upper().startswith("ADD ") and not l.upper().startswith("ADD --") for l in lines)
    uses_latest_tag = any(re.search(r"FROM\s+[^\s:]+:latest", l, re.I) or re.search(r"FROM\s+[^\s:]+\s*$", l, re.I) for l in lines)
    has_secrets_mount = any("--mount=type=secret" in l for l in lines)
    runs_as_root = any(re.search(r"^USER\s+root\b", l, re.I) for l in lines)
    has_shell_form = any(re.search(r"^(RUN|CMD|ENTRYPOINT)\s+[^\[]", l) for l in lines if not l.startswith("#"))

    # Scoring (10 is best)
    score = 10
    notes: List[str] = []
    if from_count <= 1:
        score -= 2
        notes.append("Single-stage build; consider multi-stage to reduce image size and attack surface.")
    if not has_user:
        score -= 3
        notes.append("No USER specified; container likely runs as root.")
    elif not user_non_root or runs_as_root:
        score -= 2
        notes.append("USER set to root; switch to a non-root user.")
    if not has_healthcheck:
        score -= 2
        notes.append("No HEALTHCHECK defined.")
    if not has_apt_cleanup:
        score -= 1
        notes.append("No apt cache cleanup detected.")
    if has_add_instead_copy:
        score -= 1
        notes.append("Using ADD instead of COPY; prefer COPY for local files.")
    if uses_latest_tag:
        score -= 1
        notes.append("Using 'latest' tag or no tag; pin to specific versions.")
    if has_shell_form:
        score -= 1
        notes.append("Using shell form for RUN/CMD/ENTRYPOINT; prefer exec form for better signal handling.")
    if not has_secrets_mount and any("SECRET" in l.upper() or "PASSWORD" in l.upper() for l in lines):
        notes.append("Consider using --mount=type=secret for handling secrets.")
    if score < 0:
        score = 0

    return {
        "from_count": from_count,
        "has_user": has_user,
        "user_non_root": user_non_root,
        "has_healthcheck": has_healthcheck,
        "exposes": exposes,
        "has_apt_cleanup": has_apt_cleanup,
        "uses_pip_no_cache": uses_pip_no_cache,
        "has_add_instead_copy": has_add_instead_copy,
        "uses_latest_tag": uses_latest_tag,
        "has_secrets_mount": has_secrets_mount,
        "runs_as_root": runs_as_root,
        "has_shell_form": has_shell_form,
        "score": score,
        "notes": notes,
    }


def scan(root: str) -> Dict[str, object]:
    files = walk_files(root)

    dockerfiles = [p for p in files if os.path.basename(p) in DOCKERFILE_NAMES]
    compose_files = [p for p in files if os.path.basename(p) in COMPOSE_NAMES]

    docker_results = [analyze_dockerfile(load_text(p)) for p in dockerfiles]
    docker_score = 10 if docker_results else 5  # neutral if none found
    docker_notes: List[str] = []
    if docker_results:
        docker_score = int(sum(d["score"] for d in docker_results) / len(docker_results))
        for i, res in enumerate(docker_results):
            prefix = f"[{os.path.relpath(dockerfiles[i], root)}] "
            docker_notes.extend(prefix + n for n in res["notes"]) 

    # Secrets scanning
    secret_findings: List[Tuple[str, str]] = []
    for p in files:
        name = os.path.basename(p).lower()
        if name.endswith(('.png', '.jpg', '.jpeg', '.gif', '.pdf', '.zip', '.tar', '.gz', '.7z', '.rar', '.pyc')):
            continue
        text = load_text(p)
        if not text:
            continue
        for pat in SECRET_PATTERNS:
            for m in pat.finditer(text):
                snippet = text[max(0, m.start()-20): m.end()+20]
                secret_findings.append((os.path.relpath(p, root), snippet.replace('\n', ' ')))
                break  # one hit per pattern per file is enough
    # Score: start at 10, penalize by number of distinct files with hits
    secret_files = {f for f, _ in secret_findings}
    secrets_score = max(0, 10 - min(10, len(secret_files) * 2))

    # Database practices
    db_findings: List[Tuple[str, str]] = []
    grant_all = re.compile(r"GRANT\s+ALL\s+PRIVILEGES\s+ON\s+\*\.\*", re.I)
    wildcard_host = re.compile(r"'[^']*'@'[^']*%'")
    for p in files:
        text = load_text(p)
        if not text:
            continue
        if grant_all.search(text) or wildcard_host.search(text):
            for m in grant_all.finditer(text):
                db_findings.append((os.path.relpath(p, root), "GRANT ALL PRIVILEGES *.* usage"))
                break
            for m in wildcard_host.finditer(text):
                db_findings.append((os.path.relpath(p, root), "Wildcard host in DB user '@%'") )
                break
    db_score = max(0, 10 - min(10, len({f for f, _ in db_findings}) * 3))

    # CI/Scanning evidence
    ci_files = [p for p in files if any(part in p for part in (os.sep + ".github" + os.sep, os.sep + ".gitlab-ci.yml"))]
    scanner_mentions = []
    for p in files:
        text = load_text(p)
        if not text:
            continue
        for pat in SCANNER_MENTIONS:
            if pat.search(text):
                scanner_mentions.append(os.path.relpath(p, root))
                break
    ci_score = 5
    if ci_files:
        ci_score += 3
    if scanner_mentions:
        ci_score += 2
    ci_score = min(10, ci_score)

    # Repo hygiene - expanded checks
    hygiene_hits: List[str] = []
    security_files: List[str] = []
    
    for p in files:
        base = os.path.basename(p).lower()
        if base == ".env" or base.endswith(".env"):
            hygiene_hits.append(os.path.relpath(p, root))
        # Check for security-related files
        if base in {".dockerignore", ".gitignore", "security.md", "security.txt", ".security.yml"}:
            security_files.append(os.path.relpath(p, root))
    
    # Check for .gitignore presence
    has_gitignore = any(os.path.basename(p) == ".gitignore" for p in files)
    has_dockerignore = any(os.path.basename(p) == ".dockerignore" for p in files)
    
    hygiene_score = 10
    if hygiene_hits:
        hygiene_score -= min(6, len(hygiene_hits) * 2)
    if not has_gitignore:
        hygiene_score -= 2
    if not has_dockerignore and dockerfiles:
        hygiene_score -= 1
    hygiene_score = max(0, hygiene_score)

    # Overall score weighted
    weights = {
        "docker": 0.35,
        "secrets": 0.25,
        "database": 0.20,
        "ci": 0.10,
        "hygiene": 0.10,
    }
    overall = (
        docker_score * weights["docker"]
        + secrets_score * weights["secrets"]
        + db_score * weights["database"]
        + ci_score * weights["ci"]
        + hygiene_score * weights["hygiene"]
    )
    overall = round(overall, 1)

    def letter(score: float) -> str:
        if score >= 9.0:
            return "A+"
        if score >= 8.0:
            return "A"
        if score >= 7.0:
            return "B"
        if score >= 6.0:
            return "C"
        if score >= 5.0:
            return "D"
        return "E"

    recs: List[str] = []
    if docker_notes:
        recs.extend(sorted(set(docker_notes)))
    if secret_findings:
        recs.append("🚨 CRITICAL: Potential secrets/risky patterns detected in: " + ", ".join(sorted(secret_files)))
        recs.append("   → Review and remove hardcoded secrets, use environment variables or secret management")
    if db_findings:
        recs.append("⚠️  Database uses GRANT ALL or wildcard hosts; restrict privileges and hosts.")
    if not scanner_mentions:
        recs.append("📊 Consider integrating security scanners (Trivy, Bandit, Dependabot, Semgrep).")
    if hygiene_hits:
        recs.append("📁 .env files found; ensure they are gitignored and not committed with secrets.")
    if not has_gitignore:
        recs.append("📝 Missing .gitignore file; add one to prevent committing sensitive files.")
    if not has_dockerignore and dockerfiles:
        recs.append("🐳 Missing .dockerignore file; add one to reduce build context size.")
    
    # Priority recommendations based on score
    if overall < 5.0:
        recs.insert(0, "🚨 URGENT: Project has critical security issues that need immediate attention!")
    elif overall < 7.0:
        recs.insert(0, "⚠️  WARNING: Project has significant security concerns to address.")

    results = {
        "path": os.path.abspath(root),
        "scores": {
            "docker": docker_score,
            "secrets": secrets_score,
            "database": db_score,
            "ci": ci_score,
            "hygiene": hygiene_score,
            "overall": overall,
            "grade": letter(overall),
        },
        "details": {
            "dockerfiles": docker_results,
            "dockerfile_paths": [os.path.relpath(p, root) for p in dockerfiles],
            "compose_files": [os.path.relpath(p, root) for p in compose_files],
            "secret_findings": secret_findings,
            "db_findings": db_findings,
            "ci_files": [os.path.relpath(p, root) for p in ci_files],
            "scanner_mentions": sorted(set(scanner_mentions)),
            "hygiene_hits": hygiene_hits,
            "security_files": security_files,
            "has_gitignore": has_gitignore,
            "has_dockerignore": has_dockerignore,
            "total_files_scanned": len(files),
        },
        "recommendations": recs,
    }
    return results


def main(argv: List[str]) -> int:
    import argparse
    parser = argparse.ArgumentParser(description="Scan project and rate basic security hygiene.")
    parser.add_argument("path", nargs="?", default=".", help="Path to project root")
    parser.add_argument("--json", action="store_true", help="Output JSON instead of text")
    args = parser.parse_args(argv)

    root = os.path.abspath(args.path)
    res = scan(root)

    if args.json:
        print(json.dumps(res, indent=2))
        return 0

    s = res["scores"]
    print(f"🔍 Project: {res['path']}")
    print(f"📁 Files scanned: {res['details']['total_files_scanned']}")
    print("\n📊 Security Scores (0-10):")
    print(f"  🐳 Docker:     {s['docker']}/10")
    print(f"  🔐 Secrets:    {s['secrets']}/10")
    print(f"  🗄️  Database:   {s['database']}/10")
    print(f"  🔄 CI/Scan:    {s['ci']}/10")
    print(f"  🧹 Hygiene:    {s['hygiene']}/10")
    print(f"\n🎯 Overall Score: {s['overall']}/10 (Grade: {s['grade']})")
    print()
    if res["recommendations"]:
        print("Recommendations:")
        for r in res["recommendations"]:
            print(f"- {r}")
    else:
        print("No recommendations. Good job!")

    # Show a small summary list of Dockerfiles analyzed
    if res["details"]["dockerfile_paths"]:
        print("\nDockerfiles analyzed:")
        for p in res["details"]["dockerfile_paths"]:
            print(f"- {p}")

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
