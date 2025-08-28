#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_header() {
    echo -e "${YELLOW}"
    echo "  _   _   _   _   _   _   _   _  "
    echo " / \ / \ / \ / \ / \ / \ / \ / \ "
    echo "( N | a | v | i | g | a | t | e )"
    echo " \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ "
    echo -e "${NC}\n"
    echo -e "${GREEN}🚀 Project Navigation System Setup${NC}\n"
}

install_nav() {
    echo -e "${YELLOW}Installing navigation script...${NC}"

    # First check for navigate.sh before asking for sudo
    if [ ! -f "navigate.sh" ]; then
        echo -e "${RED}Error: navigate.sh not found in current directory${NC}"
        return 1
    fi

    # Get current username
    current_user=$(whoami)
    
    # Ask for password with username
    echo -e "${YELLOW}This operation requires administrative privileges.${NC}"
    read -s -p "$(echo -e "${YELLOW}[sudo] password for $current_user: ${NC}")" password
    echo -e "\n"

    # Try to get root privileges
    echo "$password" | sudo -S -v >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Incorrect password or sudo access denied${NC}"
        return 1
    fi
    
    # Clear the password from memory after use
    unset password

    # Now perform the installation with sudo
    echo -e "${YELLOW}Installing system-wide...${NC}"
    
    # Create a temporary file with elevated permissions
    temp_script=$(mktemp)
    cat navigate.sh > "$temp_script"
    
    # Install with proper permissions
    if sudo cp "$temp_script" /usr/local/bin/nav && \
       sudo chmod +x /usr/local/bin/nav; then
        echo -e "${GREEN}✓ Navigation script installed successfully${NC}"
    else
        echo -e "${RED}✗ Installation failed${NC}"
        rm -f "$temp_script"
        return 1
    fi
    
    # Clean up
    rm -f "$temp_script"

    # Add to shell config
    for rcfile in ~/.bashrc ~/.zshrc; do
        if [ -f "$rcfile" ] && ! grep -q "source /usr/local/bin/nav" "$rcfile"; then
            echo -e "\n# Add nav command" | sudo -S tee -a "$rcfile" > /dev/null
            echo "source /usr/local/bin/nav 2>/dev/null || echo \"Nav command not found. Make sure to run install_nav.sh\"" | sudo -S tee -a "$rcfile" > /dev/null
            echo -e "${GREEN}✓ Added to $rcfile${NC}"
        fi
    done
    
    echo -e "${GREEN}✓ Navigation system installed successfully!${NC}"
    echo -e "\n${YELLOW}To start using the navigation system:${NC}"
    echo "1. Set your project directory:"
    echo "   $ nav set /path/to/your/project"
    echo "2. Navigate to a directory:"
    echo "   $ nav directory_name"
    echo -e "\n${YELLOW}Note:${NC} You may need to restart your terminal or run 'source ~/.bashrc'"
}

main() {
    show_header
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}Error: Please run as a non-root user${NC}"
        exit 1
    fi
    install_nav
}

main