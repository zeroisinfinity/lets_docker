#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_header() {
    echo -e "${YELLOW}"
    echo "  _   _   _   _   _   _   _   _  "
    echo " / \\ / \\ / \\ / \\ / \\ / \\ / \\ / \\ "
    echo "( N | a | v | i | g | a | t | e )"
    echo " \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ "
    echo -e "${NC}\n"
    echo -e "${GREEN}🚀 Project Navigation System Setup${NC}\n"
}

install_nav() {
    echo -e "${YELLOW}Installing navigation script...${NC}"
    if [ ! -f "navigate.sh" ]; then
        echo -e "${RED}Error: navigate.sh not found in current directory${NC}"
        return 1
    fi
    sudo cp navigate.sh /usr/local/bin/nav
    sudo chmod +x /usr/local/bin/nav
    for rcfile in ~/.bashrc ~/.zshrc; do
        if [ -f "$rcfile" ] && ! grep -q "source /usr/local/bin/nav" "$rcfile"; then
            echo -e "\n# Add nav command" >> "$rcfile"
            echo "source /usr/local/bin/nav 2>/dev/null || echo \"Nav command not found. Make sure to run install_nav.sh\"" >> "$rcfile"
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