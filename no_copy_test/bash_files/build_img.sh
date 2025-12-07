#!/usr/bin/env bash
# Build script for multistage Docker setup
# Usage: ./build_img.sh [stage]
#   stage: dev, test-qa, stage, prod, or all (default: dev)

set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCKERFILE="$PROJECT_ROOT/multistagebuild/Dockerfile"
BUILDER_NAME="${BUILDER_NAME:-llb_builder}"

# Default stage
BUILD_STAGE="${1:-dev}"

# --- Helper Functions ---
print_header() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  🏗️  Docker Multistage Build System                       ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_stage_info() {
    local stage=$1
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│  Building: ${GREEN}${stage}${BLUE}                                        │${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

check_dockerfile() {
    if [ ! -f "$DOCKERFILE" ]; then
        echo -e "${RED}❌ Error: Dockerfile not found at $DOCKERFILE${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Dockerfile found: $DOCKERFILE${NC}"
}

check_builder() {
    if docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Builder '$BUILDER_NAME' is ready${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Builder '$BUILDER_NAME' not found${NC}"
        echo -e "${BLUE}💡 Creating builder...${NC}"
        docker buildx create --name "$BUILDER_NAME" --driver remote tcp://localhost:1234 || {
            echo -e "${RED}❌ Failed to create builder${NC}"
            exit 1
        }
        docker buildx use "$BUILDER_NAME"
        echo -e "${GREEN}✅ Builder created successfully${NC}"
    fi
}

check_zip() {
    local zip_path="$PROJECT_ROOT/updated_zip/Project_playground.zip"
    if [ ! -f "$zip_path" ]; then
        echo -e "${YELLOW}⚠️  Warning: Project ZIP not found at $zip_path${NC}"
        echo -e "${YELLOW}   This is required for 'stage' and 'prod' builds${NC}"
        echo -e "${BLUE}💡 Create it with:${NC}"
        echo "   cd $PROJECT_ROOT/mount-1.0"
        echo "   zip -r \"../updated_zip/Project_playground.zip\" \"Project_playground\""
        return 1
    fi
    echo -e "${GREEN}✅ Project ZIP found${NC}"
    return 0
}

build_stage() {
    local stage=$1
    local tag="project:${stage}"

    print_stage_info "$stage"

    # Check if ZIP is needed
    if [ "$stage" = "stage" ] || [ "$stage" = "prod" ]; then
        if ! check_zip; then
            echo -e "${RED}❌ Cannot build $stage without Project ZIP${NC}"
            return 1
        fi
    fi

    echo -e "${BLUE}🔨 Building $stage stage...${NC}"

    cd "$PROJECT_ROOT"

    if docker buildx build \
        --builder="$BUILDER_NAME" \
        -f "$DOCKERFILE" \
        --target "$stage" \
        -t "$tag" \
        --load \
        .; then
        echo -e "${GREEN}✅ Successfully built: $tag${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}❌ Build failed for stage: $stage${NC}"
        return 1
    fi
}

build_all() {
    echo -e "${BLUE}🏗️  Building all stages...${NC}"
    echo ""

    local stages=("dev" "test-qa" "stage" "prod")
    local failed=()

    for stage in "${stages[@]}"; do
        if ! build_stage "$stage"; then
            failed+=("$stage")
        fi
    done

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  📊 Build Summary                                          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

    if [ ${#failed[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All stages built successfully!${NC}"
        echo ""
        echo -e "${BLUE}Available images:${NC}"
        docker images | grep "^project" | awk '{printf "   %-20s %-15s %s\n", $1":"$2, $3, $7}'
    else
        echo -e "${RED}❌ Failed stages: ${failed[*]}${NC}"
        return 1
    fi
}

show_usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 [stage]"
    echo ""
    echo -e "${YELLOW}Stages:${NC}"
    echo "  dev      - Development stage (with build tools, for mounting code)"
    echo "  test-qa  - Test stage (runs QA tests)"
    echo "  stage    - Pre-production stage (embedded code, non-root user)"
    echo "  prod     - Production stage (same as stage)"
    echo "  all      - Build all stages"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0              # Build dev (default)"
    echo "  $0 dev          # Build dev stage"
    echo "  $0 prod         # Build prod stage"
    echo "  $0 all          # Build all stages"
    echo ""
}

# --- Main Script ---
print_header

# Check for help flag
if [ "$BUILD_STAGE" = "-h" ] || [ "$BUILD_STAGE" = "--help" ]; then
    show_usage
    exit 0
fi

# Validate stage
valid_stages=("dev" "test-qa" "stage" "prod" "all")
if [[ ! " ${valid_stages[*]} " =~ " ${BUILD_STAGE} " ]]; then
    echo -e "${RED}❌ Error: Invalid stage '$BUILD_STAGE'${NC}"
    echo ""
    show_usage
    exit 1
fi

# Pre-flight checks
echo -e "${BLUE}🔍 Pre-flight checks...${NC}"
check_dockerfile
check_builder
echo ""

# Build
if [ "$BUILD_STAGE" = "all" ]; then
    build_all
else
    build_stage "$BUILD_STAGE"

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  ✅ Build Complete                                         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📦 Image built: ${GREEN}project:${BUILD_STAGE}${NC}"
    echo ""
    echo -e "${YELLOW}💡 Next steps:${NC}"
    if [ "$BUILD_STAGE" = "dev" ]; then
        echo "   Run with: ./run_docker_with_db.sh"
    elif [ "$BUILD_STAGE" = "test-qa" ]; then
        echo "   Run tests: docker run --rm project:test-qa"
    else
        echo "   Run with: DOCKER_STAGE=$BUILD_STAGE ./run_docker_with_db.sh"
    fi
fi