#!/bin/bash

# test_build.sh - Build with various memory debugging tools

set -e  # Exit on error

BUILD_DIR="./bin"
SRC="src"  # Source directory
BIN_NAME="mimir"

mkdir -p "$BUILD_DIR"

echo "======================================"
echo "Building with Memory Debugging Tools"
echo "======================================"

# Clean previous builds
echo "Cleaning previous builds..."
rm -f "$BUILD_DIR"/*

# 1. Debug build
echo ""
echo "[1/4] Building: Debug build..."
odin build "$SRC" \
    -out:"$BUILD_DIR/${BIN_NAME}_debug" \
    -debug \
    -o:none
echo "✓ Built: $BUILD_DIR/${BIN_NAME}_debug"

# 2. Build with address sanitizer
echo ""
echo "[2/4] Building: Address Sanitizer (ASan)..."
odin build "$SRC" \
    -out:"$BUILD_DIR/${BIN_NAME}_asan" \
    -debug \
    -o:none \
    -sanitize:address
echo "✓ Built: $BUILD_DIR/${BIN_NAME}_asan"

# 3. Build with memory sanitizer (if available)
echo ""
echo "[3/4] Building: Memory Sanitizer (MSan)..."
if odin build "$SRC" -out:"$BUILD_DIR/${BIN_NAME}_msan" -debug -o:none -sanitize:memory 2>/dev/null; then
    echo "✓ Built: $BUILD_DIR/${BIN_NAME}_msan"
else
    echo "⚠ MSan not available, skipping..."
fi

# 4. Build with thread sanitizer
echo ""
echo "[4/4] Building: Thread Sanitizer (TSan)..."
if odin build "$SRC" -out:"$BUILD_DIR/${BIN_NAME}_tsan" -debug -o:none -sanitize:thread 2>/dev/null; then
    echo "✓ Built: $BUILD_DIR/${BIN_NAME}_tsan"
else
    echo "⚠ TSan not available, skipping..."
fi

# 5. Release build for comparison
echo ""
echo "[5/5] Building: Release build..."
odin build "$SRC" \
    -out:"$BUILD_DIR/${BIN_NAME}" \
    -o:speed
echo "✓ Built: $BUILD_DIR/${BIN_NAME}"

echo ""
echo "======================================"
echo "Build Summary"
echo "======================================"
ls -lh "$BUILD_DIR"

echo ""
echo "Usage Examples:"
echo "  $BUILD_DIR/${BIN_NAME}_debug \"test message\""
echo "  $BUILD_DIR/${BIN_NAME}_asan \"test message\""
echo ""
echo "To run with Valgrind:"
echo "  valgrind --leak-check=full --show-leak-kinds=all $BUILD_DIR/${BIN_NAME}_debug \"test\""
echo ""
echo "ASan is best for memory errors (use-after-free, leaks, etc.)"
