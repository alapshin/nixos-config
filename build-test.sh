#!/usr/bin/env bash
# Phase 4a Build Verification Script
# Tests all NixOS configurations to ensure they build successfully

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Build results tracking
declare -A BUILD_RESULTS
declare -a HOSTS=("bifrost" "midgard" "niflheim" "carbon" "desktop" "altdesk")
TOTAL_HOSTS=${#HOSTS[@]}
SUCCESSFUL_BUILDS=0
FAILED_BUILDS=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Phase 4a: Build Verification${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Testing ${TOTAL_HOSTS} NixOS configurations..."
echo ""

# Function to build a single host
build_host() {
    local host=$1
    local start_time=$(date +%s)

    echo -e "${YELLOW}[$(date '+%H:%M:%S')] Building ${host}...${NC}"

    if nix build ".#nixosConfigurations.${host}.config.system.build.toplevel" \
        --keep-going 2>&1 | tee "build-${host}.log"; then

        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        BUILD_RESULTS[$host]="✅ SUCCESS (${duration}s)"
        ((SUCCESSFUL_BUILDS++))
        echo -e "${GREEN}✅ ${host} built successfully in ${duration}s${NC}"

    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        BUILD_RESULTS[$host]="❌ FAILED (${duration}s)"
        ((FAILED_BUILDS++))
        echo -e "${RED}❌ ${host} failed after ${duration}s${NC}"
        echo -e "${RED}   Check build-${host}.log for details${NC}"
    fi

    echo ""
}

# Build each host
for host in "${HOSTS[@]}"; do
    build_host "$host"
done

# Print summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Build Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

for host in "${HOSTS[@]}"; do
    echo -e "${BUILD_RESULTS[$host]} - ${host}"
done

echo ""
echo -e "Total: ${GREEN}${SUCCESSFUL_BUILDS} successful${NC}, ${RED}${FAILED_BUILDS} failed${NC}"
echo ""

# Check if all succeeded
if [ $FAILED_BUILDS -eq 0 ]; then
    echo -e "${GREEN}✅ All hosts built successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review the build logs (no errors expected)"
    echo "2. If all builds succeeded, proceed to Phase 4c (cleanup)"
    echo "3. If any builds failed, check the logs above for details"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some builds failed. Review the logs above.${NC}"
    echo ""
    echo "Failed hosts:"
    for host in "${HOSTS[@]}"; do
        if [[ "${BUILD_RESULTS[$host]}" == *"FAILED"* ]]; then
            echo "  - ${host}: see build-${host}.log"
        fi
    done
    echo ""
    exit 1
fi
