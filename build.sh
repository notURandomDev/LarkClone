#!/bin/bash

# Set variables

# Function to show help
show_help() {
    echo "Usage: ./build.sh [OPTION]"
    echo "Build and manage the LarkClone application."
    echo
    echo "Options:"
    echo "  1, --clean     Clean build directory"
    echo "  2, --build     Build the application"
    echo "  3, --debug     Run the app in debug mode"
    echo "  --help         Show this help message and exit"
    echo
    echo "Without arguments, the script will use the numeric option passed as the first parameter."
}

# Function to clean build directory
clean_build() {
    echo "Cleaning build directory..."
    rm -rf "lark_clone_app_payload"
    bazel clean --expunge
}

# Function to build the app
build_app() {
    echo "Building the app..."
    bazel build //LarkClone:LarkCloneApp --platforms=//platforms:aarch64_apple_ios
}

# Function to run the app in debug mode
debug_app() {
    echo "Running the app in debug mode..."
    mkdir -p ./lark_clone_app_payload && unzip -o bazel-bin/LarkClone/LarkCloneApp.ipa -d ./lark_clone_app_payload
    xcrun simctl install booted ./lark_clone_app_payload/Payload/LarkCloneApp.app
    xcrun simctl launch --console-pty booted teamNH.LarkClone
}

# Main menu
choice=$1

case $choice in
    1|--clean) clean_build ;;
    2|--build) build_app ;;
    3|--debug) debug_app ;;
    --help|-h) show_help ;;
    *) 
        echo "Invalid choice!"
        echo "Use --help to see available options."
        ;;
esac