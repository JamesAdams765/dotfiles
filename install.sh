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
  
  # Install required packages
  local packages=("curl" "git" "zsh")
  for pkg in "${packages[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
      echo "  → Installing $pkg..."
      sudo apt-get install -y -qq "$pkg" >/dev/null 2>&1 || {
        echo -e "${RED}❌ Failed to install $pkg${NC}"
        exit 1
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
  
  if [ $issues -eq 0 ]; then
    echo -e "\n${GREEN}✅ Installation completed successfully!${NC}\n"
    return 0
  else
    echo -e "\n${YELLOW}⚠️  Installation completed with $issues issue(s)${NC}\n"
    return 1
  fi
}

# Show next steps
show_next_steps() {
  echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
  echo -e "${GREEN}🎉 Next Steps:${NC}\n"
  echo "  1. Start a new terminal session (logout and login, or reopen terminal)"
  echo "  2. Run 'commands' to see all available utilities"
  echo "  3. Run 'health-check' to verify all tools are installed"
  echo "  4. Run 'config' to customize your shell configuration"
  echo ""
  echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
  echo "📚 Documentation: https://github.com/JamesAdams765/dotfiles"
  echo "💬 For help, type: commands"
  echo ""
}

# Main execution
main() {
  detect_os
  install_dependencies
  install_chezmoi
  init_dotfiles
  apply_dotfiles
  set_default_shell
  verify_installation
  show_next_steps
}

# Run main function
main
