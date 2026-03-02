#!/bin/bash

# Visuales UCLV - Build and Development Script
# This script helps with common development and build tasks

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed. Please install Flutter first."
        echo "Visit: https://docs.flutter.dev/get-started/install"
        exit 1
    fi
    print_success "Flutter found: $(flutter --version | head -n 1)"
}

check_dependencies() {
    print_info "Checking dependencies..."
    flutter pub get
    print_success "Dependencies installed"
}

run_tests() {
    print_header "Running Tests"
    flutter test
    print_success "All tests passed"
}

analyze_code() {
    print_header "Analyzing Code"
    flutter analyze
    print_success "No issues found"
}

clean_build() {
    print_header "Cleaning Build"
    flutter clean
    flutter pub get
    print_success "Build cleaned"
}

build_debug() {
    print_header "Building Debug APK"
    flutter build apk --debug
    print_success "Debug APK built: build/app/outputs/flutter-apk/app-debug.apk"
}

build_release() {
    print_header "Building Release APK"
    flutter build apk --release
    print_success "Release APK built: build/app/outputs/flutter-apk/app-release.apk"
}

build_appbundle() {
    print_header "Building App Bundle"
    flutter build appbundle --release
    print_success "App Bundle built: build/app/outputs/bundle/release/app-release.aab"
}

run_app() {
    print_header "Running App"
    flutter run
}

show_help() {
    print_header "Visuales UCLV - Build Script"
    echo "Usage: ./build.sh [command]"
    echo ""
    echo "Commands:"
    echo "  setup       - Check Flutter and install dependencies"
    echo "  test        - Run all tests"
    echo "  analyze     - Analyze code for issues"
    echo "  clean       - Clean build artifacts"
    echo "  debug       - Build debug APK"
    echo "  release     - Build release APK"
    echo "  bundle      - Build app bundle (Play Store)"
    echo "  run         - Run app on connected device"
    echo "  all         - Run setup, test, analyze, and build release"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./build.sh setup"
    echo "  ./build.sh release"
    echo "  ./build.sh all"
}

# Main script
case "${1:-help}" in
    setup)
        print_header "Setting Up Project"
        check_flutter
        check_dependencies
        print_success "Setup complete!"
        ;;
    test)
        check_flutter
        run_tests
        ;;
    analyze)
        check_flutter
        analyze_code
        ;;
    clean)
        check_flutter
        clean_build
        ;;
    debug)
        check_flutter
        check_dependencies
        build_debug
        ;;
    release)
        check_flutter
        check_dependencies
        build_release
        ;;
    bundle)
        check_flutter
        check_dependencies
        build_appbundle
        ;;
    run)
        check_flutter
        check_dependencies
        run_app
        ;;
    all)
        print_header "Complete Build Process"
        check_flutter
        check_dependencies
        run_tests
        analyze_code
        build_release
        print_header "Build Complete!"
        print_success "APK location: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    help|*)
        show_help
        ;;
esac

exit 0
