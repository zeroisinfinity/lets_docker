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
#   - DOCKER_IMAGE: Docker image to run (default: project:dev)
#   - DOCKER_STAGE: Which stage to run (dev|stage|prod) (default: dev)

# --- Configuration ---
# This is the standard path for MySQL config on Debian/Ubuntu systems.
MYSQL_CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"

# Docker configuration - defaults to dev stage
DOCKER_STAGE="${DOCKER_STAGE:-dev}"
DOCKER_IMAGE="${DOCKER_IMAGE:-project:${DOCKER_STAGE}}"

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

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Load environment variables from .env file ---
load_environment() {
    if [ -f "$ENV_FILE" ]; then
        echo -e "${BLUE}📄 Loading environment variables from $ENV_FILE...${NC}"
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
            echo -e "${RED}❌ Missing required environment variables: ${missing_vars[*]}${NC}"
            return 1
        fi
        
        echo -e "${GREEN}✅ Environment variables loaded successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Error: Environment file not found at $ENV_FILE${NC}"
        return 1
    fi
}

# --- Cleanup function ---
# This function is called automatically when the script exits for any reason.
cleanup() {
    echo ""
    echo "---"
    echo -e "${YELLOW}⏪ Reverting MySQL configuration to be secure...${NC}"
    # Use sudo to change the configuration back to localhost only
    sudo sed -i 's/bind-address\s*=\s*0.0.0.0/bind-address = 127.0.0.1/' "$MYSQL_CONFIG_FILE"
    # Use sudo to restart mysql
    sudo systemctl restart mysql
    echo -e "${GREEN}✅ MySQL config reverted to listen on 127.0.0.1 only.${NC}"
    echo "---"
}

# --- Trap EXIT signal ---
# This ensures the 'cleanup' function runs whenever the script ends,
# either by finishing normally or by being interrupted (e.g., with Ctrl+C).
trap cleanup EXIT

# --- Check if image exists ---
check_image() {
    if ! docker image inspect "$DOCKER_IMAGE" >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Docker image '$DOCKER_IMAGE' not found${NC}"
        echo -e "${YELLOW}💡 Build it first with:${NC}"
        echo "   cd $PROJECT_ROOT"
        echo "   docker buildx build -f multistagebuild/Dockerfile --target $DOCKER_STAGE -t $DOCKER_IMAGE --load ."
        return 1
    fi
    echo -e "${GREEN}✅ Docker image '$DOCKER_IMAGE' found${NC}"
    return 0
}

# --- Main script ---
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🐳 Docker Multi-Stage Runner - $DOCKER_STAGE stage${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Load environment variables
if ! load_environment; then
    exit 1
fi

# Check if image exists
if ! check_image; then
    exit 1
fi

# Check if the MySQL config file exists
if [ ! -f "$MYSQL_CONFIG_FILE" ]; then
    echo -e "${RED}❌ Error: MySQL config file not found at $MYSQL_CONFIG_FILE${NC}"
    exit 1
fi

echo "---"
echo -e "${YELLOW}🚀 Temporarily opening database access for Docker...${NC}"
echo -e "${YELLOW}🔒 You may be asked for your password for 'sudo' commands.${NC}"
echo "---"

# Step 1: Modify MySQL config to allow connections from Docker
echo -e "${BLUE}🛠️  Modifying MySQL config to allow external connections...${NC}"
sudo sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' "$MYSQL_CONFIG_FILE"
sudo systemctl restart mysql
echo -e "${GREEN}✅ MySQL is now temporarily listening on 0.0.0.0.${NC}"
echo "---"

# --- Docker Run Configuration based on stage ---
DOCKER_VOLUMES=()
DOCKER_CMD=("docker" "run" "--rm" "--name" "project_${DOCKER_STAGE}")

# Configure volumes based on stage
if [ "$DOCKER_STAGE" = "dev" ]; then
    echo -e "${BLUE}📦 Running DEV stage - mounting volumes for live development${NC}"
    DOCKER_VOLUMES=(
        "$PROJECT_ROOT/updated_zip/Project_playground.zip:/app/Project_playground.zip:ro"
        "$PROJECT_ROOT/bash_files/entrypoint.sh:/usr/local/bin/entrypoint.sh:ro"
    )
else
    echo -e "${BLUE}🚀 Running ${DOCKER_STAGE^^} stage - using embedded code${NC}"
    # Stage/Prod have code embedded, no volume mounts needed
fi

# Add volume mounts
for vol in "${DOCKER_VOLUMES[@]}"; do
    # Check if source file/directory exists
    local_path="${vol%%:*}"
    if [ ! -e "$local_path" ]; then
        echo -e "${YELLOW}⚠️  Warning: Local path does not exist: $local_path${NC}"
    else
        DOCKER_CMD+=("-v" "$vol")
    fi
done

# Add common configuration
DOCKER_CMD+=(
    "--network" "host"
    "-e" "DB_NAME=${DB_NAME}"
    "-e" "DB_USER=${DB_USER}"
    "-e" "DB_PASSWORD=${DB_PASSWORD}"
    "-e" "DB_HOST=127.0.0.1"
    "-e" "DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}"
    "${DOCKER_IMAGE}"
)

# Display configuration
echo ""
echo -e "${BLUE}📋 Configuration:${NC}"
echo -e "   Stage: ${GREEN}${DOCKER_STAGE}${NC}"
echo -e "   Image: ${GREEN}${DOCKER_IMAGE}${NC}"
echo -e "   Database: ${GREEN}${DB_NAME}@127.0.0.1${NC}"
if [ ${#DOCKER_VOLUMES[@]} -gt 0 ]; then
    echo -e "   Volumes: ${GREEN}${#DOCKER_VOLUMES[@]} mounted${NC}"
else
    echo -e "   Volumes: ${GREEN}None (embedded code)${NC}"
fi
echo ""

# Step 2: Run the user's Docker container
echo -e "${GREEN}🎬 Running your Docker container. Press Ctrl+C to stop it.${NC}"
echo -e "${BLUE}   Your app should be available at http://localhost:8000${NC}"
echo "---"

# Execute the docker command
"${DOCKER_CMD[@]}"

# The 'trap' command will ensure the cleanup function is called automatically now.