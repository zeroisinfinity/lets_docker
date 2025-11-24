#!/bin/bash

# Quiet mode by default: only print a clean final message and errors
QUIET=${QUIET:-1}

# Set environment variables first
export DB_NAME=${DB_NAME:-proj_playground}
export DB_USER=${DB_USER:-root}
export DB_PASSWORD=${DB_PASSWORD:-root}
export DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY:-")++($$q)bze=edd1x(#16dd$zbuge5)ph=v^8b=yvb@-5zht_l"}
export DB_HOST=${DB_HOST:-127.0.0.1}
export DB_PORT=${DB_PORT:-3306}
export DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE:-Playground.settings}
export PORT=${PORT:-8000}

# Try to activate virtual environment, but don't fail if not found
VENV_ACTIVATE="$HOME/gitt_premises/lets_docker/no_copy_test/gunicorn/bin/activate"
if [ -f "$VENV_ACTIVATE" ]; then
    # shellcheck source=/dev/null
    . "$VENV_ACTIVATE"
else
    if [ "$QUIET" -ne 1 ]; then
      echo "Virtualenv not found at $VENV_ACTIVATE. Continuing without activation."
    fi
fi

# Change to the Django project directory
cd "$HOME/gitt_premises/lets_docker/no_copy_test/mount-1.0/Project_playground/" || {
  echo "Failed to cd into project directory"; exit 1;
}

# Verify we're in the right place
if [ ! -f "manage.py" ]; then
    echo "Error: manage.py not found in $(pwd)"
    exit 1
fi

# Ensure required executables exist
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found in PATH"; exit 1;
fi
if ! command -v gunicorn >/dev/null 2>&1; then
  echo "gunicorn not found in PATH"; exit 1;
fi

# Ensure static files are collected (silence normal output)
if [ "$QUIET" -ne 1 ]; then echo "Collecting static files..."; fi
python3 manage.py collectstatic --noinput >/dev/null 2>&1 || { echo "collectstatic failed"; exit 1; }

# Optionally stop existing process on our port (best-effort)
if command -v lsof >/dev/null 2>&1; then
  PID_ON_PORT=$(lsof -ti tcp:"$PORT" 2>/dev/null || true)
  if [ -n "$PID_ON_PORT" ]; then
    if [ "$QUIET" -ne 1 ]; then echo "Stopping existing process on port $PORT (PID: $PID_ON_PORT)"; fi
    kill "$PID_ON_PORT" >/dev/null 2>&1 || true
    sleep 0.3
  fi
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# Derive sensible concurrency defaults
CPU_CORES=${CPU_CORES:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)}
# classic rule of thumb: 2*cores+1, but cap to a safe default range to avoid over-provisioning
DEFAULT_WORKERS=$(( 2 * CPU_CORES + 1 ))
if [ "$DEFAULT_WORKERS" -lt 3 ]; then DEFAULT_WORKERS=3; fi
if [ "$DEFAULT_WORKERS" -gt 8 ]; then DEFAULT_WORKERS=8; fi
WORKERS=${WORKERS:-$DEFAULT_WORKERS}
# threads can help for I/O heavy Django; modest default
THREADS=${THREADS:-4}
# tune logging and network knobs
LOG_LEVEL=${LOG_LEVEL:-info}
ACCESS_LOG=${ACCESS_LOG:-logs/access.log}
ERROR_LOG=${ERROR_LOG:-logs/error.log}
BACKLOG=${BACKLOG:-2048}
KEEPALIVE=${KEEPALIVE:-5}
TMPDIR=${TMPDIR:-/dev/shm}

# Optional: enable auto-reload to mimic runserver behavior (set RELOAD=1)
RELOAD_FLAG=""
if [ "${RELOAD:-0}" = "1" ]; then
  RELOAD_FLAG="--reload"
fi

# Build gunicorn command
GUNICORN_CMD=(
  gunicorn Playground.wsgi:application
  --config ''
  --bind 0.0.0.0:"$PORT"
  --workers "$WORKERS"
  --threads "$THREADS"
  --worker-class gthread
  --timeout 120
  --graceful-timeout 30
  --log-level "$LOG_LEVEL"
  --backlog "$BACKLOG"
  --keep-alive "$KEEPALIVE"
  --worker-tmp-dir "$TMPDIR"
  --access-logfile "$ACCESS_LOG"
  --error-logfile "$ERROR_LOG"
  --capture-output
  --enable-stdio-inheritance
)

if [ -n "$RELOAD_FLAG" ]; then
  GUNICORN_CMD+=( "$RELOAD_FLAG" )
fi

# Start Gunicorn in background to allow printing a clean message
nohup "${GUNICORN_CMD[@]}" >/dev/null 2>&1 &
GUNICORN_PID=$!

# Briefly wait and verify the process is alive
sleep 0.7
if ! kill -0 "$GUNICORN_PID" >/dev/null 2>&1; then
  echo "Failed to start Gunicorn. Check $ERROR_LOG"; exit 1;
fi

# Print a single clean line with the URL and logs location
HOST_HINT=${HOST_HINT:-localhost}
echo "Server running: http://$HOST_HINT:$PORT  (PID $GUNICORN_PID)  logs: $ACCESS_LOG | $ERROR_LOG"
