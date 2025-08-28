#!/bin/bash

#!/usr/bin/env bash
# This script temporarily changes the host's MySQL bind-address to allow connections
# from the application container, and automatically reverts the change on exit.
#
# Environment Variables:
#   - DB_NAME: Database name
#   - DB_USER: Database username
#   - DB_PASSWORD: Database password
#   - DJANGO_SECRET_KEY: Secret key for Django
#   - MYSQL_CONFIG_FILE: Path to MySQL config (default: /etc/mysql/mysql.conf.d/mysqld.cnf)
#   - DOCKER_IMAGE: Docker image to run (default: mount_trekker:01.09)

# --- Configuration ---
# This is the standard path for MySQL config on Debian/Ubuntu systems.
MYSQL_CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"
# The Docker image name is taken from the environment, defaulting to "your-image-name"
DOCKER_IMAGE="mount_trekker:01.09"

# --- Script Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/creds/.env"

# --- Required Environment Variables ---
REQUIRED_VARS=(
    "DB_NAME"
    "DB_USER"
    "DB_PASSWORD"
    "DJANGO_SECRET_KEY"
)

# --- Load environment variables from .env file ---
load_environment() {
    if [ -f "$ENV_FILE" ]; then
        echo "📄 Loading environment variables from $ENV_FILE..."
        set -a
        # shellcheck source=/dev/null
        source "$ENV_FILE"
        set +a
        
        # Verify required variables are set
        local missing_vars=()
        for var in "${REQUIRED_VARS[@]}"; do
            if [ -z "${!var}" ]; then
                missing_vars+=("$var")
            fi
        done
        
        if [ ${#missing_vars[@]} -gt 0 ]; then
            echo "❌ Missing required environment variables: ${missing_vars[*]}"
            return 1
        fi
        
        echo "✅ Environment variables loaded successfully"
        return 0
    else
        echo "❌ Error: Environment file not found at $ENV_FILE"
        return 1
    fi
}

# Load environment variables
if ! load_environment; then
    exit 1
fi

# --- Cleanup function ---
# This function is called automatically when the script exits for any reason.
cleanup() {
    echo ""
    echo "---"
    echo "⏩ Reverting MySQL configuration to be secure..."
    # Use sudo to change the configuration back to localhost only
    sudo sed -i 's/bind-address\s*=\s*0.0.0.0/bind-address = 127.0.0.1/' "$MYSQL_CONFIG_FILE"
    # Use sudo to restart mysql
    sudo systemctl restart mysql
    echo "✅ MySQL config reverted to listen on 127.0.0.1 only."
    echo "---"
}

# --- Trap EXIT signal ---
# This ensures the 'cleanup' function runs whenever the script ends,
# either by finishing normally or by being interrupted (e.g., with Ctrl+C).
trap cleanup EXIT

# --- Main script ---
# Check if the MySQL config file exists
if [ ! -f "$MYSQL_CONFIG_FILE" ]; then
    echo "❌ Error: MySQL config file not found at $MYSQL_CONFIG_FILE"
    exit 1
fi

echo "---"
echo "🚀 Temporarily opening database access for Docker..."
echo "🔑 You may be asked for your password for 'sudo' commands."
echo "---"

# Step 1: Modify MySQL config to allow connections from Docker
echo "🛠️ Modifying MySQL config to allow external connections..."
sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' "$MYSQL_CONFIG_FILE"
sudo systemctl restart mysql
echo "✅ MySQL is now temporarily listening on 0.0.0.0."
echo "---"

# --- Docker Run Configuration ---
DOCKER_VOLUMES=(
    "$PROJECT_ROOT/updated_zip/Project_playground.zip:/app/Project_playground.zip"
    "$PROJECT_ROOT/bash_files/entrypoint.sh:/usr/local/bin/entrypoint.sh"
)

# Build docker run command
DOCKER_CMD=(
    "docker" "run" "--rm"
)

# Add volume mounts
for vol in "${DOCKER_VOLUMES[@]}"; do
    # Check if source file/directory exists
    local_path="${vol%%:*}"
    if [ ! -e "$local_path" ]; then
        echo "⚠️  Warning: Local path does not exist: $local_path"
    fi
    DOCKER_CMD+=("-v" "$vol")
done

# Add environment variables
DOCKER_CMD+=(
    "--network" "host"
    "-e" "DB_NAME=${DB_NAME}"
    "-e" "DB_USER=${DB_USER}"
    "-e" "DB_PASSWORD=${DB_PASSWORD}"
    "-e" "DB_HOST=127.0.0.1"
    "-e" "DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}"
    "${DOCKER_IMAGE}"
)

# Step 2: Run the user's Docker container
echo "🐛 Running your Docker container. Press Ctrl+C to stop it."
echo "   Your app should be available at http://localhost:8000"

# Execute the docker command
"${DOCKER_CMD[@]}"

# The 'trap' command will ensure the cleanup function is called automatically now.
