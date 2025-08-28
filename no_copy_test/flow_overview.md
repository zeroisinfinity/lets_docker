# End-to-End Flow Overview (no_copy_test)
Last updated: 2025-08-28 12:21 local

This document maps the complete journey from cloning the repo to running the Django server, including what triggers each step and what happens behind the scenes. It’s written as a quick but detailed flow “chart,” using numbered stages with arrows and explicit file references.

High-Level Journey (ASCII Flow)
1) Clone repo → 2) Optional: Install nav → 3) Build image → 4) Generate secret key → 5) Configure env & DB → 6) (Optional) Update mounts → 7) Package project → 8) Run app

Details by Stage

1. Clone the repository
- Trigger (you):
  - git clone https://github.com/zeroisinfinity/lets_docker.git
  - cd lets_docker/no_copy_test
- Backend/Files involved:
  - Entire codebase becomes available locally.
  - Key files you’ll use later: README.md, quick_guide.md, Dockerfile, build_img.sh, run_docker_with_db.sh, desktopish.py, initial_data.sql, bash_files/entrypoint.sh, mount-1.0/Project_playground/.
- Output:
  - Local working copy of the project.

2. Optional: Install navigation helper (nav)
- Why: Quickly navigate directories by name and list directory trees.
- Trigger (you):
  - chmod +x install_nav.sh navigate.sh
  - ./install_nav.sh
  - source ~/.bashrc
  - nav set $(pwd)
- Frontend trigger file:
  - no_copy_test/install_nav.sh → installs no_copy_test/navigate.sh to /usr/local/bin/nav
- Backend actions:
  - install_nav.sh checks for navigate.sh, requests sudo, copies it to /usr/local/bin/nav, sets executable permissions, and appends a source line to your shell rc if needed.
  - navigate.sh implements “nav set”, directory jumping, and a colorized tree listing.
- Output:
  - nav command available; quicker movement inside the project.

3. Build the Docker image
- Trigger (you):
  - chmod +x ./build_img.sh
  - ./build_img.sh
- Frontend trigger file:
  - no_copy_test/build_img.sh
- Backend actions:
  - Loads .env if present (in a subshell) for context (doesn’t export persistently to your shell).
  - Runs: docker build -t mount_trekker:01.09 .
  - Dockerfile steps:
    - Base: python:3.12-slim
    - Installs: build-essential, default-libmysqlclient-dev, pkg-config, unzip, curl, tzdata, tree
    - Copies requirements.txt and installs Python deps
    - Copies bash_files/entrypoint.sh to /usr/local/bin and marks executable
    - Exposes port 8000
    - ENTRYPOINT set to /usr/local/bin/entrypoint.sh
- Output:
  - Local image mount_trekker:01.09 built.

4. Generate a Django secret key (once)
- Trigger (you):
  - nav Project_playground (or cd mount-1.0/Project_playground)
  - python3 manage.py shell
  - from django.core.management.utils import get_random_secret_key; get_random_secret_key()
- Files involved:
  - mount-1.0/Project_playground/manage.py → sets DJANGO_SETTINGS_MODULE to Playground.settings and boots Django shell.
- Output:
  - A secret key you will paste into desktopish.py prompts (or pass with --django-secret-key).

5. Configure environment and prepare the database
- Recommended: Interactive setup
  - Trigger (you): python3 desktopish.py
- Alternative: Non-interactive
  - Trigger (you): python3 desktopish.py --no-input --db-user 'USER' --db-password 'PASS' --django-secret-key 'KEY' [--db-name proj_playground --db-host 127.0.0.1 --db-port 3306]
- Frontend trigger file:
  - no_copy_test/desktopish.py
- Backend actions (desktopish.py):
  - Creates/overwrites .env with: DJANGO_SECRET_KEY, DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, DB_PORT.
  - Verifies DB connectivity by running a mysql client command (requires MySQL client on host).
  - Creates database if not exists (SHOW DATABASES LIKE … then CREATE DATABASE …).
  - Loads initial data if initial_data.sql exists via mysql … -e "source initial_data.sql".
- Files referenced:
  - no_copy_test/initial_data.sql → creates domain_image and problem statements tables and sample data.
- Output:
  - .env written. DB verified/created. Initial data loaded.

6. (Optional) Update mounts tooling
- Trigger (you): python3 update_mounts.py [--sh-name entrypoint.sh] [--image-name mount_trekker:01.09]
- Frontend trigger file:
  - no_copy_test/update_mounts.py
- Backend actions:
  - Currently marks a bash script executable and prepares a volume path string; it is a work-in-progress and does not actually run a container. Consider it experimental.
- Output:
  - No changes to running environment by default; informational/experimental.

7. Package the Django project into a zip
- Trigger (you):
  - mkdir -p updated_zip
  - cd mount-1.0 && zip -r "../updated_zip/Project_playground.zip" "Project_playground"
- Files involved:
  - The Project_playground Django project directory is zipped as updated_zip/Project_playground.zip
- Backend actions:
  - Produces the zip that container entrypoint will extract to /app/project.
- Output:
  - updated_zip/Project_playground.zip exists and is ready to be mounted into the container.

8. Run the application
- Trigger (you): ./run_docker_with_db.sh
- Frontend trigger file:
  - no_copy_test/run_docker_with_db.sh
- Backend actions (on host):
  - Loads .env (exports vars for the docker run call).
  - Temporarily modifies host MySQL bind-address in /etc/mysql/mysql.conf.d/mysqld.cnf from 127.0.0.1 → 0.0.0.0 and restarts MySQL (sudo required).
  - Starts container using host network and mounts the project zip and entrypoint:
    - docker run --rm \
      -v "$(pwd)/updated_zip/Project_playground.zip:/app/Project_playground.zip" \
      -v "$(pwd)/bash_files/entrypoint.sh:/usr/local/bin/entrypoint.sh" \
      --network host \
      -e DB_NAME -e DB_USER -e DB_PASSWORD -e DB_HOST=127.0.0.1 -e DJANGO_SECRET_KEY \
      mount_trekker:01.09
  - Traps EXIT to revert the MySQL bind-address back to 127.0.0.1 and restart MySQL.
- Container startup (inside container: bash_files/entrypoint.sh):
  - Validates required env vars: DB_HOST, DB_NAME, DB_USER, DB_PASSWORD.
  - If /app/Project_playground.zip exists and /app/project doesn’t, unzip it into /app/project.
  - cd /app/project/Project_playground
  - Wait ~5s for DB, print tree /app for diagnostics.
  - python3 manage.py makemigrations → migrate → runserver 0.0.0.0:8000
- Django internals:
  - mount-1.0/Project_playground/manage.py: main() calls execute_from_command_line(sys.argv).
  - Playground/settings.py: reads DB creds via os.environ (DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, DB_PORT) and SECRET_KEY via DJANGO_SECRET_KEY.
  - Installed apps include: accounts_mode, domain, interface_profile, level, prob_statements, solution.
- Output:
  - Server accessible at http://localhost:8000

File and Trigger Map (Cheat Sheet)
- install_nav.sh → copies navigate.sh to /usr/local/bin/nav; sets up nav command.
- build_img.sh → docker build … → Dockerfile → image mount_trekker:01.09
- desktopish.py → writes .env; checks/creates DB; loads initial_data.sql
- update_mounts.py → experimental; chmods selected script; prepares mount string (no docker run yet)
- Packaging step → produces updated_zip/Project_playground.zip
- run_docker_with_db.sh → temporarily opens host MySQL + docker run (host network)
- entrypoint.sh (in container) → unzip, migrations, runserver 0.0.0.0:8000
- manage.py → Django CLI entry; routes to Playground.settings
- Playground/settings.py → reads env vars for SECRET_KEY and DATABASES

Data Flow Highlights
- .env on host → used by run_docker_with_db.sh to pass env vars into container.
- initial_data.sql on host → loaded during desktopish.py setup into MySQL.
- DB_HOST inside container is 127.0.0.1 due to --network host and host MySQL listening on 0.0.0.0 (temporarily).
- SECRET_KEY is required by Django; settings.py expects it via env DJANGO_SECRET_KEY.

Security & Ops Notes (dev-only posture)
- run_docker_with_db.sh temporarily changes MySQL bind-address; script reverts on exit but use only for local dev.
- Host network mode increases coupling; consider docker-compose with a DB service for production-like workflows.

Where to look for issues
- Logs: Terminal where you ran run_docker_with_db.sh and container stdio.
- DB access: Ensure MySQL is running and credentials match .env.
- Ports: If 8000 is busy, change runserver binding in entrypoint.sh or stop other services.

Related Tools & Reports
- scan_and_rate.py → static repo scanner (Docker/security heuristics); run: python3 scan_and_rate.py .
- About/scan_and_rating.md → narrative assessment and remarks.

Appendix: Key Files
- no_copy_test/README.md → general overview, quick start
- no_copy_test/quick_guide.md → condensed steps with nav helper
- no_copy_test/Dockerfile → image definition
- no_copy_test/build_img.sh → build script
- no_copy_test/run_docker_with_db.sh → launcher with MySQL bind-address toggle
- no_copy_test/desktopish.py → env & DB bootstrapper
- no_copy_test/update_mounts.py → experimental mount utility
- no_copy_test/initial_data.sql → DB schema and seed data
- no_copy_test/bash_files/entrypoint.sh → container entrypoint
- no_copy_test/mount-1.0/Project_playground/manage.py → Django CLI entry
- no_copy_test/mount-1.0/Project_playground/Playground/settings.py → settings
