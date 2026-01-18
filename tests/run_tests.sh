#!/bin/bash

# Local test runner for dotfiles
# Usage: ./tests/run_tests.sh [fedora|ubuntu|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

build_and_test() {
    local os=$1
    local dockerfile="$SCRIPT_DIR/docker/Dockerfile.$os"

    if [[ ! -f "$dockerfile" ]]; then
        echo -e "${RED}Dockerfile not found: $dockerfile${NC}"
        return 1
    fi

    echo -e "${YELLOW}Building $os test container...${NC}"
    docker build -f "$dockerfile" -t "dotfiles-test-$os" "$PROJECT_DIR"

    echo -e "${YELLOW}Running $os test...${NC}"
    if docker run --rm "dotfiles-test-$os"; then
        echo -e "${GREEN}$os test PASSED${NC}"
        return 0
    else
        echo -e "${RED}$os test FAILED${NC}"
        return 1
    fi
}

case "${1:-all}" in
    fedora)
        build_and_test fedora
        ;;
    ubuntu)
        build_and_test ubuntu
        ;;
    debian)
        build_and_test debian
        ;;
    all)
        echo "Running tests for all Linux platforms..."
        echo ""

        FEDORA_RESULT=0
        UBUNTU_RESULT=0
        DEBIAN_RESULT=0

        build_and_test fedora || FEDORA_RESULT=1
        echo ""
        build_and_test ubuntu || UBUNTU_RESULT=1
        echo ""
        build_and_test debian || DEBIAN_RESULT=1

        echo ""
        echo "============================================"
        echo "Test Summary"
        echo "============================================"

        if [[ $FEDORA_RESULT -eq 0 ]]; then
            echo -e "Fedora: ${GREEN}PASSED${NC}"
        else
            echo -e "Fedora: ${RED}FAILED${NC}"
        fi

        if [[ $UBUNTU_RESULT -eq 0 ]]; then
            echo -e "Ubuntu: ${GREEN}PASSED${NC}"
        else
            echo -e "Ubuntu: ${RED}FAILED${NC}"
        fi

        if [[ $DEBIAN_RESULT -eq 0 ]]; then
            echo -e "Debian: ${GREEN}PASSED${NC}"
        else
            echo -e "Debian: ${RED}FAILED${NC}"
        fi

        if [[ $FEDORA_RESULT -ne 0 || $UBUNTU_RESULT -ne 0 || $DEBIAN_RESULT -ne 0 ]]; then
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 [fedora|ubuntu|debian|all]"
        exit 1
        ;;
esac
