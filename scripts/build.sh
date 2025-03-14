#!/bin/bash

# EmbedKit Build Script
# Version: 0.1.0 (2025-03-13)

set -e

# Color codes for prettier output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== EmbedKit Build Script ===${NC}"
echo -e "${BLUE}Version: 0.1.0${NC}"
echo

# Check if we're running on a Mac
if [[ "$(uname)" != "Darwin" ]]; then
  echo -e "${RED}Error: This script is designed to run on macOS.${NC}"
  exit 1
fi

# Check Swift version
SWIFT_VERSION=$(swift --version | head -n 1)
echo -e "${BLUE}Using:${NC} $SWIFT_VERSION"
echo

# Parse command line arguments
BUILD_TYPE="debug"
PERFORM_TESTS=true
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --release)
      BUILD_TYPE="release"
      shift
      ;;
    --no-tests)
      PERFORM_TESTS=false
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help)
      echo "Usage: ./build.sh [options]"
      echo
      echo "Options:"
      echo "  --release        Build in release mode (default: debug)"
      echo "  --no-tests       Skip running tests"
      echo "  --verbose        Enable verbose output"
      echo "  --help           Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help to see available options"
      exit 1
      ;;
  esac
done

# Set build flags
BUILD_FLAGS=""
TEST_FLAGS=""

if [[ "$BUILD_TYPE" == "release" ]]; then
  BUILD_FLAGS="-c release -Xswiftc -O"
  TEST_FLAGS="--configuration release"
fi

if [[ "$VERBOSE" == true ]]; then
  BUILD_FLAGS="$BUILD_FLAGS -v"
  TEST_FLAGS="$TEST_FLAGS -v"
fi

# Clean previous build artifacts
echo -e "${YELLOW}Cleaning previous build artifacts...${NC}"
swift package clean

# Build the package
echo -e "${YELLOW}Building EmbedKit...${NC}"
if [[ "$VERBOSE" == true ]]; then
  swift build $BUILD_FLAGS
else
  swift build $BUILD_FLAGS >/dev/null
fi

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Build successful!${NC}"
else
  echo -e "${RED}Build failed!${NC}"
  exit 1
fi

# Run tests
if [[ "$PERFORM_TESTS" == true ]]; then
  echo -e "${YELLOW}Running tests...${NC}"
  set +e
  if [[ "$VERBOSE" == true ]]; then
    swift test $TEST_FLAGS
  else
    swift test $TEST_FLAGS
  fi
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
  else
    echo -e "${RED}Tests failed!${NC}"
    exit 1
  fi
  set -e
fi

# Show build products
echo -e "${YELLOW}Build products:${NC}"
ls -la .build/$BUILD_TYPE

echo -e "${GREEN}EmbedKit build completed successfully.${NC}"
echo -e "${BLUE}Version: 0.1.0${NC}"