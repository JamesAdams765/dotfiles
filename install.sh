#!/bin/bash

################################################################################
# Install dotfiles on Linux (Raspberry Pi, Ubuntu, Debian, etc.)
# Usage: curl -fsSL https://raw.githubusercontent.com/JamesAdams765/dotfiles/master/install.sh | bash
################################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Installing Custom Shell Configuration (.zshrc)         ║${NC}"
echo -e "${BLUE}║              for Raspberry Pi / Linux Systems                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"

# Detect OS
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      OS=$ID
    elif type lsb_release >/dev/null 2>&1; then
      OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    else
      OS="linux"
    fi
  else
    echo -e "${RED}❌ This script is for Linux (Raspberry Pi, Ubuntu, Debian, etc.)${NC}"
    exit 1
  fi
}

# Install dependencies
install_dependencies() {
  echo -e "${BLUE}📦 Installing dependencies...${NC}\n"
  
  # Update package manager
  echo "  → Updating package manager..."
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq >/dev/null 2>&1 || true
  fi
  
  # Install critical packages
  local critical_packages=("curl" "git" "zsh")
  for pkg in "${critical_packages[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
      echo "  → Installing $pkg..."
      if ! sudo apt-get install -y -qq "$pkg" >/dev/null 2>&1; then
        echo -e "${RED}❌ Failed to install $pkg - this is required${NC}"
        exit 1
      fi
    else
      echo "  ✓ $pkg already installed"
    fi
  done
  
  # Install optional but recommended packages (auto-install system)
  local optional_packages=("fzf" "build-essential" "nodejs" "npm" "wget" "tar" "gzip")
  for pkg in "${optional_packages[@]}"; do
    if ! command -v "$pkg" &>/dev/null && ! dpkg -l 2>/dev/null | grep -q "^ii.*$pkg"; then
      echo "  → Installing $pkg..."
      sudo apt-get install -y -qq "$pkg" >/dev/null 2>&1 || {
        echo -e "${YELLOW}  ⚠️  Could not install $pkg (non-critical, continuing)${NC}"
      }
    else
      echo "  ✓ $pkg already installed"
    fi
  done
}

# Install chezmoi
install_chezmoi() {
  echo -e "\n${BLUE}🔧 Installing chezmoi (dotfiles manager)...${NC}\n"
  
  if command -v chezmoi &>/dev/null; then
    echo "  ✓ chezmoi already installed at $(which chezmoi)"
    return
  fi
  
  mkdir -p "$HOME/.local/bin"
  
  # Download and install chezmoi for ARM (Raspberry Pi)
  echo "  → Downloading chezmoi..."
  if sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" >/dev/null 2>&1; then
    echo "  ✓ chezmoi installed successfully"
  else
    echo -e "${RED}❌ Failed to install chezmoi${NC}"
    exit 1
  fi
  
  # Add to PATH if not already there
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    echo "  → Added ~/.local/bin to PATH"
  fi
}

# Initialize dotfiles
init_dotfiles() {
  echo -e "\n${BLUE}📥 Cloning and applying dotfiles...${NC}\n"
  
  # Check if chezmoi repo already exists
  if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    echo "  → Dotfiles already initialized, pulling updates..."
    cd "$HOME/.local/share/chezmoi"
    git pull origin master >/dev/null 2>&1 || true
  else
    echo "  → Initializing dotfiles from GitHub..."
    
    # Try HTTPS first, then SSH
    if "$HOME/.local/bin/chezmoi" init --apply https://github.com/JamesAdams765/dotfiles.git >/dev/null 2>&1; then
      echo "  ✓ Dotfiles cloned and applied successfully (HTTPS)"
    else
      echo "  ✗ HTTPS failed, trying SSH..."
      if "$HOME/.local/bin/chezmoi" init --apply git@github.com:JamesAdams765/dotfiles.git >/dev/null 2>&1; then
        echo "  ✓ Dotfiles cloned and applied successfully (SSH)"
      else
        echo -e "${RED}❌ Failed to initialize dotfiles${NC}"
        exit 1
      fi
    fi
  fi
}

# Apply changes
apply_dotfiles() {
  echo -e "\n${BLUE}✨ Applying configuration files...${NC}\n"
  
  if "$HOME/.local/bin/chezmoi" apply >/dev/null 2>&1; then
    echo "  ✓ Configuration applied successfully"
  else
    echo -e "${YELLOW}⚠️  Some files may not have been applied, continuing...${NC}"
  fi
}

# Install Oh My Zsh and plugins
install_oh_my_zsh() {
  echo -e "\n${BLUE}🎨 Installing Oh My Zsh and plugins...${NC}\n"
  
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  ✓ Oh My Zsh already installed"
  else
    echo "  → Installing Oh My Zsh..."
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >/dev/null 2>&1; then
      echo "  ✓ Oh My Zsh installed"
    else
      echo -e "${YELLOW}⚠️  Oh My Zsh installation had issues, continuing...${NC}"
    fi
  fi
  
  # Install zsh plugins
  install_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
  install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
}

# Helper function to install zsh plugins
install_zsh_plugin() {
  local plugin_name="$1"
  local plugin_url="$2"
  local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
  
  if [ -d "$plugin_dir" ]; then
    echo "  ✓ $plugin_name already installed"
  else
    echo "  → Installing $plugin_name..."
    if git clone "$plugin_url" "$plugin_dir" >/dev/null 2>&1; then
      echo "  ✓ $plugin_name installed"
    else
      echo -e "${YELLOW}  ⚠️  Could not install $plugin_name${NC}"
    fi
  fi
}

# Install Powerlevel10k theme
install_powerlevel10k() {
  echo -e "\n${BLUE}🎯 Installing Powerlevel10k theme...${NC}\n"
  
  local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  
  if [ -d "$p10k_dir" ]; then
    echo "  ✓ Powerlevel10k already installed"
  else
    echo "  → Installing Powerlevel10k..."
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir" >/dev/null 2>&1; then
      echo "  ✓ Powerlevel10k installed"
    else
      echo -e "${YELLOW}⚠️  Could not install Powerlevel10k${NC}"
    fi
  fi
}

# Set zsh as default shell
set_default_shell() {
  echo -e "\n${BLUE}🐚 Setting zsh as default shell...${NC}\n"
  
  ZSH_PATH=$(which zsh)
  
  if [ -z "$ZSH_PATH" ]; then
    echo -e "${RED}❌ zsh not found${NC}"
    exit 1
  fi
  
  # Check if zsh is already the default shell
  if [ "$SHELL" == "$ZSH_PATH" ]; then
    echo "  ✓ zsh is already your default shell"
  else
    echo "  → Setting $ZSH_PATH as default shell..."
    
    # Try chsh, handle permission issues gracefully
    if chsh -s "$ZSH_PATH" >/dev/null 2>&1; then
      echo "  ✓ Default shell set to zsh"
    elif sudo chsh -s "$ZSH_PATH" "$USER" >/dev/null 2>&1; then
      echo "  ✓ Default shell set to zsh (with sudo)"
    else
      echo -e "${YELLOW}⚠️  Could not set default shell (you can do this manually)${NC}"
      echo "     Run: chsh -s $(which zsh)"
    fi
  fi
}

# Verify installation
verify_installation() {
  echo -e "\n${BLUE}✅ Verifying installation...${NC}\n"
  
  local issues=0
  
  # Check .zshrc
  if [ -f "$HOME/.zshrc" ]; then
    echo "  ✓ .zshrc installed"
  else
    echo -e "${RED}  ❌ .zshrc not found${NC}"
    issues=$((issues + 1))
  fi
  
  # Check chezmoi
  if command -v chezmoi &>/dev/null; then
    echo "  ✓ chezmoi installed"
  else
    echo -e "${RED}  ❌ chezmoi not found${NC}"
    issues=$((issues + 1))
  fi
  
  # Check zsh
  if command -v zsh &>/dev/null; then
    echo "  ✓ zsh installed"
  else
    echo -e "${RED}  ❌ zsh not found${NC}"
    issues=$((issues + 1))
  fi
  
  # Check fzf (important for commands function)
  if command -v fzf &>/dev/null; then
    echo "  ✓ fzf installed (commands menu will work)"
  else
    echo -e "${YELLOW}  ⚠️  fzf not found (commands menu requires fzf)${NC}"
    echo "     To install: sudo apt-get install -y fzf"
  fi
  
  # Check Oh My Zsh
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  ✓ Oh My Zsh installed"
  else
    echo -e "${YELLOW}  ⚠️  Oh My Zsh not found${NC}"
  fi
  
  if [ $issues -eq 0 ]; then
    echo -e "\n${GREEN}✅ Installation completed successfully!${NC}\n"
    return 0
  else
    echo -e "\n${YELLOW}⚠️  Installation completed with $issues critical issue(s)${NC}\n"
    return 1
  fi
}

# Install optional command-line tools (auto-installed on first use)
install_optional_tools() {
  echo -e "\n${BLUE}📚 Installing optional tools (auto-installed on first use)...${NC}\n"
  
  # Tools and their installation commands
  # Format: "tool_name" "apt-get package"
  local tools=(
    "btop:btop"                    # System resource monitor
    "ncdu:ncdu"                    # Disk usage analyzer
    "neofetch:neofetch"            # System info display
    "neomutt:neomutt"              # Email client
    "newsboat:newsboat"            # RSS feed reader
    "lynx:lynx"                    # Terminal web browser
    "htop:htop"                    # System monitor (fallback for monitor)
  )
  
  echo "  Attempting to pre-install common optional tools:"
  
  for tool_entry in "${tools[@]}"; do
    IFS=':' read -r tool_name pkg_name <<< "$tool_entry"
    
    if ! command -v "$tool_name" &>/dev/null && ! dpkg -l 2>/dev/null | grep -q "^ii.*$pkg_name"; then
      echo "  → Installing $tool_name..."
      if sudo apt-get install -y -qq "$pkg_name" >/dev/null 2>&1; then
        echo "    ✓ $tool_name installed"
      else
        echo -e "    ${YELLOW}⚠️  Could not install $tool_name (will try on first use)${NC}"
      fi
    else
      echo "  ✓ $tool_name already installed"
    fi
  done
  
  echo ""
  echo "  Note: Other tools (yazi, lazyssh, etc.) will auto-install on first use"
  echo "        using _ensure() function in your shell configuration."
}

# Show next steps
show_next_steps() {
  echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
  echo -e "${GREEN}🎉 Next Steps:${NC}\n"
  echo "  1. Exit this terminal session: exit"
  echo "  2. Open a new terminal (or SSH session)"
  echo "  3. You should now be using zsh by default"
  echo "  4. Run these commands to verify:"
  echo "     - commands      (see all available utilities)"
  echo "     - health-check  (verify all tools are installed)"
  echo "     - config        (customize your shell configuration)"
  echo ""
  echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
  echo "📚 Documentation: https://github.com/JamesAdams765/dotfiles"
  echo "💬 For help, type: commands"
  echo ""
  
  # If fzf is not installed, show warning
  if ! command -v fzf &>/dev/null; then
    echo -e "${YELLOW}⚠️  NOTE: The 'commands' menu requires fzf${NC}"
    echo "   Install it with: sudo apt-get install -y fzf"
    echo ""
  fi
}

# Main execution
main() {
  detect_os
  install_dependencies
  install_chezmoi
  init_dotfiles
  apply_dotfiles
  install_oh_my_zsh
  install_powerlevel10k
  install_optional_tools
  set_default_shell
  verify_installation
  show_next_steps
}

# Run main function
main
