#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
cd ..
DOCKERFILE="./multistagebuild/Dockerfile"
IMAGE_NAME="project"

export DOCKER_BUILDKIT=1

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}🚀 Docker Build Script${NC}"
echo -e "${BLUE}==========================================${NC}"

TARGET=$1

if [ -z "$TARGET" ]; then
    echo -e "${YELLOW}Usage: ./build_img.sh <dev|test|stage|prod|all>${NC}"
    exit 1
fi

build_dev() {
    echo -e "${GREEN}➡️ Building DEV image...${NC}"
    docker buildx build \
        --target dev \
        -t ${IMAGE_NAME}:dev \
        --load \
        -f ${DOCKERFILE} .
}

build_test() {
    echo -e "${GREEN}➡️ Building TEST-QA image...${NC}"
    docker buildx build \
        --target test-qa \
        -t ${IMAGE_NAME}:test \
        --load \
        -f ${DOCKERFILE} .
}

build_stage() {
    echo -e "${GREEN}➡️ Building STAGE image...${NC}"
    docker buildx build \
        --target stage \
        -t ${IMAGE_NAME}:stage \
        --load \
        -f ${DOCKERFILE} .
}

build_prod() {
    echo -e "${GREEN}➡️ Building PROD image...${NC}"
    docker buildx build \
        --target prod \
        -t ${IMAGE_NAME}:prod \
        --load \
        -f ${DOCKERFILE} .
}

case $TARGET in

    dev)
        build_dev
        ;;

# inside build_img.sh case block
    test|test-qa)
    build_test   # assumes build_test() builds --target test-qa and tags project:test
        ;;


    stage)
        build_stage
        build_test   # 🔥 ALWAYS regenerate QA image
        ;;

    prod)
        build_prod
        build_test   # 🔥 ALWAYS regenerate QA image
        ;;

    all)
        build_dev
        build_test
        build_stage
        build_prod
        ;;

    *)
        echo -e "${RED}❌ Invalid target: ${TARGET}${NC}"
        echo "Valid targets: dev, test, stage, prod, all"
        exit 1
        ;;
esac

echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}✅ Build Complete${NC}"
echo -e "${BLUE}==========================================${NC}"
