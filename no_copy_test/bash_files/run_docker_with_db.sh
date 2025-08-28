#!/bin/bash

# This script temporarily changes the host's MySQL bind-address to allow connections
# from the application container, and automatically reverts the change on exit.

# --- Configuration ---
# This is the standard path for MySQL config on Debian/Ubuntu systems.
MYSQL_CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"
# The Docker image name is taken from the environment, defaulting to "your-image-name"
DOCKER_IMAGE="mount_trekker:01.09"

# --- Load environment variables from .env file ---
if [ -f .env ]; then
    echo "📄 Loading environment variables from .env file..."
    set -a
    # shellcheck source=.env
    source .env
    set +a
    echo "✅ Environment variables loaded: DB_NAME=${DB_NAME}, DB_USER=${DB_USER}"
else
    echo "❌ No .env file found!"
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

# Step 2: Run the user's Docker container
echo "🐛 Running your Docker container. Press Ctrl+C here to stop it."
echo "   Your app should be available at http://localhost:8000"
docker run --rm \
  -v "$(pwd)/updated_zip/Project_playground.zip:/app/Project_playground.zip" \
  -v "$(pwd)/bash_files/entrypoint.sh:/usr/local/bin/entrypoint.sh" \
  --network host \
  -e DB_NAME="${DB_NAME}" \
  -e DB_USER="${DB_USER}" \
  -e DB_PASSWORD="${DB_PASSWORD}" \
  -e DB_HOST="127.0.0.1" \
  -e DJANGO_SECRET_KEY="${DJANGO_SECRET_KEY}" \
  "${DOCKER_IMAGE}"

# The 'trap' command will ensure the cleanup function is called automatically now.
