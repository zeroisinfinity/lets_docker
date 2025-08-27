#!/bin/bash
# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color
CONFIG_FILE="$HOME/.nav_config"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

# Set project directory
set_project() {
    if [ -z "$1" ]; then
        echo -e "${YELLOW}Current project directory: ${NAV_PROJECT_ROOT:-Not set}${NC}"
        return 0
    fi
    if [ ! -d "$1" ]; then
        echo -e "${YELLOW}Error: Directory does not exist${NC}"
        return 1
    fi
    NAV_PROJECT_ROOT="$(realpath "$1")"
    echo "NAV_PROJECT_ROOT=\"$NAV_PROJECT_ROOT\"" > "$CONFIG_FILE"
    echo -e "${GREEN}✓ Project directory set to: $NAV_PROJECT_ROOT${NC}"
}

# Main navigation function
nav() {
    if [ "$1" = "set" ]; then
        set_project "$2"
        return $?
    fi
    if [ -z "$NAV_PROJECT_ROOT" ]; then
        echo -e "${YELLOW}No project directory set. Use 'nav set <directory>' to set it.${NC}"
        return 1
    fi
    if [ $# -eq 0 ]; then
        cd "$NAV_PROJECT_ROOT"
        echo -e "${GREEN}✓ Project root: $PWD${NC}"
        return 0
    fi
    local target="$1"
    local target_dir="$NAV_PROJECT_ROOT/$target"
    if [ -d "$target_dir" ]; then
        cd "$target_dir"
        echo -e "${GREEN}✓ Navigated to: $PWD${NC}"
        return 0
    fi
    local matches=()
    while IFS= read -r -d '' dir; do
        matches+=("$dir")
    done < <(find "$NAV_PROJECT_ROOT" -type d -name "*$target*" -print0 2>/dev/null)
    if [ ${#matches[@]} -eq 0 ]; then
        echo -e "${YELLOW}No directory matching '$target' found in $NAV_PROJECT_ROOT${NC}"
        return 1
    elif [ ${#matches[@]} -eq 1 ]; then
        cd "${matches[0]}"
        echo -e "${GREEN}✓ Navigated to: $PWD${NC}"
    else
        echo -e "${YELLOW}Multiple matches found:${NC}"
        for i in "${!matches[@]}"; do
            echo "$((i+1)). ${matches[$i]}"
        done
        read -p "Select a directory (1-${#matches[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#matches[@]} ]; then
            cd "${matches[$((choice-1))]}"
            echo -e "${GREEN}✓ Navigated to: $PWD${NC}"
        else
            echo -e "${YELLOW}Invalid selection${NC}"
            return 1
        fi
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    nav "$@"
fi