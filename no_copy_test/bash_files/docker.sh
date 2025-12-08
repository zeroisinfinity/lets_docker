

set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   🐳 Docker Multistage Manager                           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo -e "${YELLOW}Quick Actions:${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} Build dev stage"
    echo -e "  ${GREEN}2.${NC} Build test stage"
    echo -e "  ${GREEN}3.${NC} Build stage"
    echo -e "  ${GREEN}4.${NC} Build prod stage"
    echo -e "  ${GREEN}5.${NC} Build ALL stages"
    echo ""
    echo -e "  ${BLUE}6.${NC} Run dev (with mounts)"
    echo -e "  ${BLUE}7.${NC} Run tests"
    echo -e "  ${BLUE}8.${NC} Run stage"
    echo -e "  ${BLUE}9.${NC} Run prod"
    echo ""
    echo -e "  ${MAGENTA}10.${NC} List images"
    echo -e "  ${MAGENTA}11.${NC} List running containers"
    echo -e "  ${MAGENTA}12.${NC} Stop all project containers"
    echo -e "  ${MAGENTA}13.${NC} Clean up unused images"
    echo ""
    echo -e "  ${CYAN}14.${NC} Create Project ZIP"
    echo -e "  ${CYAN}15.${NC} View logs"
    echo ""
    echo -e "  ${RED}0.${NC} Exit"
    echo ""
}

build_stage() {
    local stage=$1
    echo -e "${BLUE}🏗️  Building $stage...${NC}"
    cd "$SCRIPT_DIR"
    ./build_img.sh "$stage"
}

run_stage() {
    local stage=$1
    echo -e "${BLUE}🚀 Running $stage...${NC}"
    cd "$SCRIPT_DIR"
    DOCKER_STAGE="$stage" ./run_docker_with_db.sh
}

run_tests() {
    echo -e "${BLUE}🧪 Running tests...${NC}"
    if ! docker image inspect "project:test-qa" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Test image not found. Building first...${NC}"
        build_stage "test-qa"
    fi

    echo "📦 Running TEST-QA image..."

    # Move from bash_files/ → project root
    cd "$(dirname "$0")/.."

    docker run --rm -it \
      -v "$(pwd)/updated_zip/Project_playground.zip":/app/Project_playground.zip \
      -e DJANGO_SETTINGS_MODULE=Project_playground.settings \
      project:test
}


list_images() {
    echo -e "${BLUE}📦 Project Images:${NC}"
    docker images | grep -E "^(REPOSITORY|project)" || echo -e "${YELLOW}No project images found${NC}"
}

list_containers() {
    echo -e "${BLUE}🐳 Running Containers:${NC}"
    docker ps | grep -E "^(CONTAINER|project)" || echo -e "${YELLOW}No project containers running${NC}"
}

stop_all() {
    echo -e "${YELLOW}🛑 Stopping all project containers...${NC}"
    local containers=$(docker ps -q -f "name=project_")
    if [ -n "$containers" ]; then
        docker stop $containers
        echo -e "${GREEN}✅ Stopped all project containers${NC}"
    else
        echo -e "${YELLOW}No project containers running${NC}"
    fi
}

cleanup_images() {
    echo -e "${YELLOW}🧹 Cleaning up unused images...${NC}"
    docker image prune -f
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

create_zip() {
    echo -e "${BLUE}📦 Creating Project ZIP...${NC}"
    cd "$PROJECT_ROOT"
    mkdir -p updated_zip
    if [ -d "mount-1.0/Project_playground" ]; then
        cd mount-1.0
        zip -r "../updated_zip/Project_playground.zip" "Project_playground"
        echo -e "${GREEN}✅ ZIP created at: updated_zip/Project_playground.zip${NC}"
    else
        echo -e "${RED}❌ Project_playground directory not found in mount-1.0/${NC}"
    fi
}

view_logs() {
    echo -e "${BLUE}📋 Available containers:${NC}"
    docker ps -a -f "name=project_" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    echo ""
    read -p "$(echo -e ${YELLOW}Enter container name to view logs: ${NC})" container_name
    if [ -n "$container_name" ]; then
        docker logs -f "$container_name"
    fi
}

# Main loop
main() {
    show_banner

    while true; do
        show_menu
        read -p "$(echo -e ${YELLOW}Select an option: ${NC})" choice
        echo ""

        case $choice in
            1) build_stage "dev" ;;
            2) build_stage "test-qa" ;;
            3) build_stage "stage" ;;
            4) build_stage "prod" ;;
            5) build_stage "all" ;;
            6) run_stage "dev" ;;
            7) run_tests ;;
            8) run_stage "stage" ;;
            9) run_stage "prod" ;;
            10) list_images ;;
            11) list_containers ;;
            12) stop_all ;;
            13) cleanup_images ;;
            14) create_zip ;;
            15) view_logs ;;
            0) echo -e "${GREEN}👋 Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}❌ Invalid option${NC}" ;;
        esac

        echo ""
        read -p "$(echo -e ${CYAN}Press Enter to continue...${NC})"
        clear
        show_banner
    done
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi