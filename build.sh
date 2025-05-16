#!/bin/bash

# Set variables

# Function to show help
show_help() {
    echo "Usage: ./build.sh [OPTION]"
    echo "Build and manage the LarkClone application using bazel."
    echo
    echo "Options:"
    echo "  1, --clean     Clean build directory"
    echo "  2, --build     Build the application"
    echo "  3, --debug     Run the app in debug mode"
    echo "  4, --setupenv  Set up rust development environment"
    echo "  5, --generate  Generate mock data"
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

setupenv(){
    echo "Setting up rust development environment..."
    ./script/setup_rust.sh
    echo "Setting up bazel development environment..."
    ./script/setup_bazel.sh
}

generate(){
    echo "Generating mock data..."
    cd LarkClone
    ../scripts/run_generate_contacts.sh
    ../scripts/run_generate_mails.sh
    cd ..
}
# Function to build the app
build_app() {
    echo "Building the app..."
    setupenv
    generate
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
    4|--setupenv) setupenv ;;
    5|--generate) generate ;;
    --help|-h) show_help ;;
    *) 
        echo "Invalid choice!"
        echo "Use --help to see available options."
        ;;
esac