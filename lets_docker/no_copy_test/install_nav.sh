#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display header
show_header() {
    echo -e "${YELLOW}"
    echo "  _   _   _   _   _   _   _   _  "
    echo " / \\ / \\ / \\ / \\ / \\ / \\ / \\ / \\ "
    echo "( N | a | v | i | g | a | t | e )"
    echo " \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ "
    echo -e "${NC}\n"
    echo -e "${GREEN}🚀 Project Navigation System Setup${NC}\n"
}

# Function to install required tools
install_requirements() {
    echo -e "${YELLOW}Installing required tools...${NC}"
    
    if ! command -v fdfind &> /dev/null; then
        echo "Installing fd-find..."
        sudo apt-get update && sudo apt-get install -y fd-find
        sudo ln -sf $(which fdfind) /usr/local/bin/fd 2>/dev/null || true
    fi
    
    if ! command -v rg &> /dev/null; then
        echo "Installing ripgrep..."
        sudo apt-get update && sudo apt-get install -y ripgrep
    fi
}

# Function to install nav script
install_nav() {
    echo -e "${YELLOW}Installing navigation script...${NC}"
    
    # Make sure navigate.sh exists
    if [ ! -f "navigate.sh" ]; then
        echo -e "${RED}Error: navigate.sh not found in current directory${NC}"
        return 1
    fi
    
    # Install to /usr/local/bin
    sudo cp navigate.sh /usr/local/bin/nav
    sudo chmod +x /usr/local/bin/nav
    
    # Add to shell config if not already present
    if ! grep -q "source /usr/local/bin/nav" ~/.bashrc; then
        echo -e "\n# Navigation command\nsource /usr/local/bin/nav" >> ~/.bashrc
    fi
    
    if [ -f ~/.zshrc ] && ! grep -q "source /usr/local/bin/nav" ~/.zshrc; then
        echo -e "\n# Navigation command\nsource /usr/local/bin/nav" >> ~/.zshrc
    fi
    
    echo -e "${GREEN}✓ Navigation system installed successfully!${NC}"
    echo -e "Run 'source ~/.bashrc' or open a new terminal to start using 'nav'"
}

# Create the nav script
create_nav_script() {
    echo -e "${YELLOW}Creating navigation script...${NC}"
    
    cat > /tmp/nav << 'EOL'
#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Find directory using fd
find_dir() {
    local target="$1"
    local result
    
    # First try exact match
    result=$(fd --max-depth 5 --type d --glob "${target}" . 2>/dev/null | head -1)
    
    # If no exact match, try case insensitive
    if [ -z "$result" ]; then
        result=$(fd --max-depth 5 --type d --ignore-case --glob "*${target}*" . 2>/dev/null | head -1)
    fi
    
    echo "$result"
}

# Main navigation function
nav() {
    if [ $# -eq 0 ]; then
        echo -e "${YELLOW}Usage: nav <directory>${NC}"
        return 1
    fi
    
    local target="$1"
    local target_dir
    
    if [ "$target" = "." ]; then
        cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
        return 0
    fi
    
    # Try to find the directory
    target_dir=$(find_dir "$target")
    
    if [ -n "$target_dir" ]; then
        cd "$target_dir"
        echo -e "${GREEN}✓ Navigated to: ${PWD}${NC}"
    else
        echo -e "${RED}❌ Error: navigate.sh not found in current directory${NC}"
        exit 1
    fi
}

# Main installation
main() {
    show_header
    install_requirements
    create_nav_script
}

# Run installation
main
