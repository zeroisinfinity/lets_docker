#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

# Default project root is the current directory
PROJECT_ROOT="$(pwd)"
CONFIG_FILE="$HOME/.nav_config"

# Load saved project root if it exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Function to save project root
save_project_root() {
    local dir="$1"
    echo "PROJECT_ROOT=\"$dir\"" > "$CONFIG_FILE"
    echo -e "${GREEN}✓ Project root set to: $dir${NC}"
}

# Function to find directory in project
find_in_project() {
    local target="$1"
    
    # First try exact match in current directory
    if [ -d "$PROJECT_ROOT/$target" ]; then
        echo "$PROJECT_ROOT/$target"
        return 0
    fi
    
    # Try to use fd if available
    if command -v fd &> /dev/null; then
        fd --max-depth 5 --type d --glob "$target" "$PROJECT_ROOT" 2>/dev/null | head -1
    else
        # Fallback to find if fd is not available
        find "$PROJECT_ROOT" -maxdepth 5 -type d -name "$target" 2>/dev/null | head -1
    fi
}

# Main function
nav() {
    # Show help if no arguments
    if [ $# -eq 0 ]; then
        cd "$PROJECT_ROOT"
        echo -e "${GREEN}✓ Project root: $PROJECT_ROOT${NC}"
        return 0
    fi
    
    # Handle --set flag
    if [ "$1" = "--set" ]; then
        if [ -d "$2" ]; then
            save_project_root "$(realpath "$2")"
        else
            echo -e "${YELLOW}Error: Directory does not exist${NC}"
            return 1
        fi
        return 0
    fi
    
    # Navigate to target
    local target="$1"
    local target_dir
    
    # If it's a full path, just cd to it
    if [[ "$target" == /* ]]; then
        if [ -d "$target" ]; then
            cd "$target"
            echo -e "${GREEN}✓ Navigated to: $PWD${NC}"
        else
            echo -e "${YELLOW}Error: Directory does not exist${NC}"
            return 1
        fi
    else
        # Search in project
        target_dir=$(find_in_project "$target")
        
        if [ -n "$target_dir" ]; then
            cd "$target_dir"
            echo -e "${GREEN}✓ Navigated to: $PWD${NC}"
        else
            echo -e "${YELLOW}Directory '$target' not found in project${NC}"
            return 1
        fi
    fi
}

# If not sourced, execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    nav "$@"
fi
