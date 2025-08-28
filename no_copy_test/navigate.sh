#!/bin/bash
# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
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

# Get color for file type
_get_file_color() {
    local file="$1"
    if [ -d "$file" ]; then
        echo -n "$BLUE"  # Directory
    elif [ -x "$file" ]; then
        echo -n "\033[38;5;208m"  # Bright Orange for executables
    else
        case "$file" in
            # Archives
            *.zip|*.tar|*.gz|*.bz2|*.xz|*.7z|*.rar) echo -n "$RED" ;;
            # Scripts
            *.sh|*.bash|*.zsh) echo -n "$GREEN" ;;  # Shell scripts
            *.py) echo -n "$CYAN" ;;                # Python files
            # Web files
            *.js|*.jsx|*.ts|*.tsx) echo -n "$YELLOW" ;;  # JavaScript/TypeScript
            *.html|*.htm) echo -n "$PURPLE" ;;      # HTML
            *.css|*.scss|*.sass) echo -n "$BLUE" ;;  # Stylesheets
            # Config files
            *.json|*.yaml|*.yml) echo -n "$YELLOW" ;; # Config files
            # Text files
            *.md|*.txt|*.log) echo -n "$NC" ;;       # Text files
            # Default
            *) echo -n "$NC" ;;
        esac
    fi
}

# Print directory tree
_print_tree() {
    local dir="$1"
    local prefix="$2"
    local is_top_level="$3"
    local -i i=0
    local -i count=0
    local -a files
    local file
    local color
    
    # Bright light blue for top-level directories
    local BRIGHT_BLUE='\033[1;96m'  # Bright cyan-blue
    
    # Get all files/directories in current directory
    while IFS= read -r file; do
        files+=("$file")
    done < <(ls -A "$dir" 2>/dev/null)
    
    count=${#files[@]}
    
    for ((i=0; i<count; i++)); do
        file="${files[$i]}"
        local fullpath="$dir/$file"
        local color=$(_get_file_color "$fullpath")
        local icon="📄"
        
        if [ -d "$fullpath" ]; then
            icon="📁"
        elif [ -x "$fullpath" ]; then
            icon="⚡"
        else
            case "$file" in
                *.zip|*.tar|*.gz|*.bz2|*.xz|*.7z|*.rar) icon="🗜️" ;;
            esac
        fi
        
        # Use bright blue for top-level directories
        local display_color=$color
        if [ -d "$fullpath" ] && [ -n "$is_top_level" ]; then
            display_color=$BRIGHT_BLUE
        fi
        
        # Print current file/directory
        if [ $i -eq $((count-1)) ]; then
            echo -e "${prefix}└── ${display_color}${icon} $file${NC}"
            local new_prefix="$prefix    "
        else
            echo -e "${prefix}├── ${display_color}${icon} $file${NC}"
            local new_prefix="${prefix}│   "
        fi
        
        # If directory, recurse (pass empty string for is_top_level to disable bright blue)
        if [ -d "$fullpath" ]; then
            _print_tree "$fullpath" "$new_prefix" ""
        fi
    done
}

# List directory contents in tree format
list_tree() {
    local dir="${1:-.}"
    echo -e "${GREEN}${dir}${NC}"
    _print_tree "$dir" "" "top_level"
}

# Show help
show_help() {
    echo -e "${GREEN}Nav - Directory Navigation Tool${NC}"
    echo -e "\n${YELLOW}Usage:${NC}"
    echo "  nav                     : Go to project root"
    echo "  nav set <directory>     : Set project root directory"
    echo "  nav -l, --list [dir]    : List directory tree"
    echo "  nav -h, --help         : Show this help"
    echo -e "\n${YELLOW}Color Legend:${NC}"
    echo -e "\033[1;96m📁 Top-level Directory${NC}"
    echo -e "${BLUE}📁 Subdirectory${NC}"
    echo -e "\033[38;5;208m⚡ Executable${NC}"
    echo -e "${RED}🗜️  Archive (zip, tar, etc)${NC}"
    echo -e "${GREEN}📄 Shell Script${NC}"
    echo -e "${CYAN}📄 Python${NC}"
    echo -e "${YELLOW}📄 JavaScript/TypeScript/Config${NC}"
    echo -e "${PURPLE}📄 HTML${NC}"
    echo -e "📄 Regular files"
}

# Main navigation function
nav() {
    # Show help if no arguments or help flag is provided
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        return 0
    fi
    
    if [ "$1" = "set" ]; then
        set_project "$2"
        return $?
    elif [ "$1" = "-l" ] || [ "$1" = "--list" ]; then
        local target="${2:-.}"
        if [ -n "$NAV_PROJECT_ROOT" ]; then
            if [ "$target" != "." ]; then
                target="$NAV_PROJECT_ROOT/$target"
            else
                target="$NAV_PROJECT_ROOT"
            fi
        fi
        list_tree "$target"
        return 0
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