#!/bin/bash

# Production Build Script for Smart Logo Maker
# This script automates the production build process with environment configuration

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if .env.production exists
check_env_file() {
    if [ ! -f ".env.production" ]; then
        print_error ".env.production file not found!"
        print_info "Please create .env.production from .env.production.template"
        exit 1
    fi
    print_success "Environment file found"
}

# Function to load environment variables
load_env() {
    print_info "Loading environment variables..."
    export $(cat .env.production | grep -v '^#' | xargs)
    print_success "Environment variables loaded"
}

# Function to check keystore for Android
check_android_keystore() {
    if [ ! -f "android/key.properties" ]; then
        print_warning "Android keystore not configured (android/key.properties missing)"
        print_warning "Release will be signed with debug key"
        return 1
    fi
    print_success "Android keystore configured"
    return 0
}

# Function to run Flutter analyze
run_analyze() {
    print_info "Running Flutter analyze..."
    if flutter analyze; then
        print_success "Flutter analyze passed"
    else
        print_error "Flutter analyze failed. Please fix issues before building."
        exit 1
    fi
}

# Function to run tests
run_tests() {
    print_info "Running tests..."
    if flutter test; then
        print_success "All tests passed"
    else
        print_error "Some tests failed. Please fix before building."
        exit 1
    fi
}

# Function to clean build
clean_build() {
    print_info "Cleaning previous builds..."
    flutter clean
    flutter pub get
    print_success "Build cleaned"
}

# Main menu
echo ""
echo "=================================="
echo "  Smart Logo Maker - Build Tool  "
echo "=================================="
echo ""
echo "Select build type:"
echo "1) Android APK (Release)"
echo "2) Android App Bundle (Play Store)"
echo "3) iOS (Release)"
echo "4) Run Quality Checks Only"
echo "5) Clean Build"
echo "q) Quit"
echo ""
read -p "Enter choice: " choice

case $choice in
    1)
        print_info "Building Android APK for Production..."
        check_env_file
        load_env
        check_android_keystore || print_warning "Continuing with debug signing..."
        
        read -p "Run quality checks first? (y/n): " run_checks
        if [ "$run_checks" = "y" ]; then
            run_analyze
            run_tests
        fi
        
        print_info "Building APK..."
        flutter build apk --release \
            --dart-define=PRODUCTION=true \
            --dart-define=DEBUG_LOGS=false \
            --dart-define=SUPABASE_URL="$SUPABASE_URL" \
            --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
        
        print_success "APK built successfully!"
        print_info "Output: build/app/outputs/flutter-apk/app-release.apk"
        ;;
        
    2)
        print_info "Building Android App Bundle for Play Store..."
        check_env_file
        load_env
        
        if ! check_android_keystore; then
            print_error "Android keystore is required for App Bundle!"
            print_info "Please configure android/key.properties"
            exit 1
        fi
        
        read -p "Run quality checks first? (y/n): " run_checks
        if [ "$run_checks" = "y" ]; then
            run_analyze
            run_tests
        fi
        
        print_info "Building App Bundle..."
        flutter build appbundle --release \
            --dart-define=PRODUCTION=true \
            --dart-define=DEBUG_LOGS=false \
            --dart-define=SUPABASE_URL="$SUPABASE_URL" \
            --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
        
        print_success "App Bundle built successfully!"
        print_info "Output: build/app/outputs/bundle/release/app-release.aab"
        ;;
        
    3)
        print_info "Building iOS for Production..."
        check_env_file
        load_env
        
        read -p "Run quality checks first? (y/n): " run_checks
        if [ "$run_checks" = "y" ]; then
            run_analyze
            run_tests
        fi
        
        print_info "Building iOS..."
        flutter build ios --release \
            --dart-define=PRODUCTION=true \
            --dart-define=DEBUG_LOGS=false \
            --dart-define=SUPABASE_URL="$SUPABASE_URL" \
            --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
        
        print_success "iOS build completed!"
        print_info "Next steps:"
        print_info "1. Open ios/Runner.xcworkspace in Xcode"
        print_info "2. Select 'Any iOS Device' as destination"
        print_info "3. Product → Archive"
        print_info "4. Upload to App Store Connect"
        ;;
        
    4)
        print_info "Running quality checks..."
        run_analyze
        run_tests
        print_success "All quality checks passed!"
        ;;
        
    5)
        clean_build
        ;;
        
    q|Q)
        print_info "Exiting..."
        exit 0
        ;;
        
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_success "Build process completed!"
echo ""
