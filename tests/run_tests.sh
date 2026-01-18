#!/bin/bash

# Local test runner for dotfiles
# Usage: ./tests/run_tests.sh [fedora|ubuntu|debian|darwin|windows|all|parallel]

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

    echo -e "${YELLOW}[$os] Building test container...${NC}"
    if ! docker build -f "$dockerfile" -t "dotfiles-test-$os" "$PROJECT_DIR" > /tmp/dotfiles-build-$os.log 2>&1; then
        echo -e "${RED}[$os] Build FAILED${NC}"
        cat /tmp/dotfiles-build-$os.log
        return 1
    fi

    echo -e "${YELLOW}[$os] Running test...${NC}"
    if docker run --rm "dotfiles-test-$os" > /tmp/dotfiles-test-$os.log 2>&1; then
        echo -e "${GREEN}[$os] PASSED${NC}"
        return 0
    else
        echo -e "${RED}[$os] FAILED${NC}"
        echo -e "${YELLOW}[$os] Last 50 lines of output:${NC}"
        tail -50 /tmp/dotfiles-test-$os.log
        return 1
    fi
}

run_parallel() {
    echo "Running tests for all platforms in parallel..."
    echo ""

    local pids=()
    local os_list=("fedora" "ubuntu" "debian")

    # Start all tests in background
    for os in "${os_list[@]}"; do
        (
            build_and_test "$os"
        ) &
        pids+=($!)
        echo -e "${YELLOW}[$os] Started (PID: $!)${NC}"
    done

    echo ""
    echo "Waiting for all tests to complete..."
    echo ""

    # Wait for all and collect results
    local results=()
    for i in "${!pids[@]}"; do
        if wait "${pids[$i]}"; then
            results[$i]=0
        else
            results[$i]=1
        fi
    done

    # Print summary
    echo ""
    echo "============================================"
    echo "Test Summary (Parallel Execution)"
    echo "============================================"

    local failed=0
    for i in "${!os_list[@]}"; do
        if [[ ${results[$i]} -eq 0 ]]; then
            echo -e "${os_list[$i]}: ${GREEN}PASSED${NC}"
        else
            echo -e "${os_list[$i]}: ${RED}FAILED${NC}"
            ((failed++))
        fi
    done

    echo "============================================"
    echo "Logs saved to /tmp/dotfiles-test-*.log"
    echo "============================================"

    if [[ $failed -gt 0 ]]; then
        exit 1
    fi
}

run_sequential() {
    echo "Running tests for all Linux platforms sequentially..."
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
}

case "${1:-parallel}" in
    fedora)
        build_and_test fedora
        ;;
    ubuntu)
        build_and_test ubuntu
        ;;
    debian)
        build_and_test debian
        ;;
    darwin|macos)
        echo -e "${YELLOW}macOS tests are only available in CI (GitHub Actions).${NC}"
        echo "See: https://github.com/$(git remote get-url origin 2>/dev/null | sed -E 's#.+github\.com[:/](.+)\.git#\1#')/actions"
        echo ""
        echo "The CI workflow runs on macos-latest runner and:"
        echo "  1. Installs chezmoi"
        echo "  2. Applies dotfiles"
        echo "  3. Runs tests/verify_install.sh"
        ;;
    windows)
        echo -e "${YELLOW}Windows tests are only available in CI (GitHub Actions).${NC}"
        echo "See: https://github.com/$(git remote get-url origin 2>/dev/null | sed -E 's#.+github\.com[:/](.+)\.git#\1#')/actions"
        echo ""
        echo "The CI workflow runs on windows-latest runner and:"
        echo "  1. Installs chezmoi via PowerShell"
        echo "  2. Applies dotfiles"
        echo "  3. Runs tests/verify_install.ps1"
        ;;
    all)
        run_sequential
        ;;
    parallel)
        run_parallel
        ;;
    *)
        echo "Usage: $0 [fedora|ubuntu|debian|darwin|windows|all|parallel]"
        echo ""
        echo "Options:"
        echo "  fedora    - Test Fedora only (Docker)"
        echo "  ubuntu    - Test Ubuntu only (Docker)"
        echo "  debian    - Test Debian only (Docker)"
        echo "  darwin    - Show macOS test info (CI only)"
        echo "  windows   - Show Windows test info (CI only)"
        echo "  all       - Test all Linux platforms sequentially"
        echo "  parallel  - Test all Linux platforms in parallel (default)"
        exit 1
        ;;
esac
