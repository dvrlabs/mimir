# Default recipe
default:
    @just --list

# Build release version
build:
    @echo "Building release..."
    odin build src -out:bin/mimir -o:speed
    @echo "✓ Built: bin/mimir"

# Build debug version
build-debug:
    @echo "Building debug..."
    odin build src -out:bin/mimir_debug -debug -o:none
    @echo "✓ Built: bin/mimir_debug"

# Build with Address Sanitizer
build-asan:
    @echo "Building with ASan..."
    odin build src -out:bin/mimir_asan -debug -o:none -sanitize:address
    @echo "✓ Built: bin/mimir_asan"

# Build all variants
build-all: build build-debug build-asan
    @echo "✓ All builds complete"

# Clean
clean:
    rm -rf bin/*

# Install
install: build
    @mkdir -p ~/.local/bin
    cp bin/mimir ~/.local/bin/
    @chmod +x ~/.local/bin/mimir
    @echo "✓ Installed to ~/.local/bin/mimir"

# Uninstall
uninstall:
    rm -f ~/.local/bin/mimir
    @echo "✓ Uninstalled"

# Run release
run *args: build
    ./bin/mimir {{args}}

# Development mode (ASan)
dev *args: build-asan
    ASAN_OPTIONS=detect_leaks=1 ./bin/mimir_asan {{args}}

# Run with Valgrind
valgrind: build-debug
    valgrind --leak-check=full --show-leak-kinds=all ./bin/mimir_debug -c "How many known galaxies are there?"

# Quick test
test: build-asan
    @echo "Testing with ASan..."
    ASAN_OPTIONS=detect_leaks=1 ./bin/mimir_asan -c "Hello world"
    @echo "✓ Test passed"

# Show binary sizes
sizes: build-all
    @ls -lh bin/

