#!/bin/bash

################################################################################
# Install dotfiles on macOS, Linux (Ubuntu, Debian, Raspberry Pi), and Windows (WSL/Git Bash)
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
echo -e "${BLUE}║        for macOS, Windows, Ubuntu, Debian & Raspberry Pi      ║${NC}"
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
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="windows"
  else
    echo -e "${YELLOW}⚠️  Unknown OS: $OSTYPE. Attempting to proceed anyway...${NC}"
    OS="unknown"
  fi
  echo "  ✓ Detected OS: $OS"
}

# Helper to check if a command exists
has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# Helper to run commands with or without sudo
run_cmd() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif has_cmd sudo; then
    sudo "$@"
  else
    echo -e "${RED}❌ sudo not found and you are not root. Please install sudo or run as root.${NC}"
    exit 1
  fi
}

# Install dependencies
install_dependencies() {
  echo -e "\n${BLUE}📦 Installing dependencies...${NC}\n"
  
  if has_cmd apt-get; then
    echo "  → Updating apt package manager..."
    run_cmd apt-get update -qq >/dev/null 2>&1 || true
    
    local critical_packages=("curl" "git" "zsh")
    for pkg in "${critical_packages[@]}"; do
      if ! has_cmd "$pkg"; then
        echo "  → Installing $pkg..."
        run_cmd apt-get install -y -qq "$pkg" >/dev/null 2>&1 || echo -e "${RED}❌ Failed to install $pkg - this is required${NC}"
      else
        echo "  ✓ $pkg already installed"
      fi
    done
    
    local optional_packages=("fzf" "zoxide" "direnv" "build-essential" "nodejs" "npm" "wget" "tar" "gzip")
    for pkg in "${optional_packages[@]}"; do
      if ! has_cmd "$pkg" && ! dpkg -l 2>/dev/null | grep -q "^ii.*$pkg"; then
        echo "  → Installing $pkg..."
        run_cmd apt-get install -y -qq "$pkg" >/dev/null 2>&1 || echo -e "${YELLOW}  ⚠️  Could not install $pkg (non-critical, continuing)${NC}"
      else
        echo "  ✓ $pkg already installed"
      fi
    done

  elif has_cmd brew; then
    echo "  → Updating brew package manager..."
    brew update -q >/dev/null 2>&1 || true

    local critical_packages=("curl" "git" "zsh")
    for pkg in "${critical_packages[@]}"; do
      if ! has_cmd "$pkg"; then
        echo "  → Installing $pkg..."
        brew install "$pkg" -q >/dev/null 2>&1 || echo -e "${RED}❌ Failed to install $pkg - this is required${NC}"
      else
        echo "  ✓ $pkg already installed"
      fi
    done
    
    local optional_packages=("fzf" "zoxide" "direnv" "node" "wget")
    for pkg in "${optional_packages[@]}"; do
      if ! has_cmd "$pkg"; then
        echo "  → Installing $pkg..."
        brew install "$pkg" -q >/dev/null 2>&1 || echo -e "${YELLOW}  ⚠️  Could not install $pkg (non-critical, continuing)${NC}"
      else
        echo "  ✓ $pkg already installed"
      fi
    done

  elif [[ "$OS" == "macos" ]]; then
    echo "  → Homebrew not found. Attempting to install it..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1; then
      echo "  ✓ Homebrew installed successfully"
      eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
      install_dependencies # Retry with brew
    else
      echo -e "${RED}❌ Failed to install Homebrew. Please install it manually: https://brew.sh/${NC}"
      exit 1
    fi
  elif has_cmd pacman; then
    # Git Bash / MSYS / Arch
    echo "  → Using pacman package manager..."
    run_cmd pacman -Sy --noconfirm curl git zsh >/dev/null 2>&1 || true
  else
    echo -e "${YELLOW}  ⚠️  No supported package manager found (apt-get, brew, or pacman).${NC}"
    echo "  → Please manually install curl, git, and zsh if they are missing."
  fi
}

# Install chezmoi
install_chezmoi() {
  echo -e "\n${BLUE}🔧 Installing chezmoi (dotfiles manager)...${NC}\n"
  
  if has_cmd chezmoi; then
    echo "  ✓ chezmoi already installed at $(which chezmoi)"
    return
  fi
  
  if has_cmd brew && [[ "$OS" == "macos" ]]; then
    echo "  → Installing chezmoi via Homebrew..."
    brew install chezmoi -q >/dev/null 2>&1
    echo "  ✓ chezmoi installed successfully"
    return
  fi

  mkdir -p "$HOME/.local/bin"
  
  echo "  → Downloading chezmoi..."
  if sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" >/dev/null 2>&1; then
    echo "  ✓ chezmoi installed successfully"
  else
    echo -e "${RED}❌ Failed to install chezmoi${NC}"
    exit 1
  fi
  
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    echo "  → Added ~/.local/bin to PATH"
  fi
}

# Initialize dotfiles
init_dotfiles() {
  echo -e "\n${BLUE}📥 Cloning and applying dotfiles...${NC}\n"
  
  local chezmoi_bin="chezmoi"
  if ! has_cmd chezmoi; then
    chezmoi_bin="$HOME/.local/bin/chezmoi"
  fi

  if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    echo "  → Dotfiles already initialized, pulling updates..."
    (cd "$HOME/.local/share/chezmoi" && git pull >/dev/null 2>&1 || true)
  else
    echo "  → Initializing dotfiles from GitHub..."
    if "$chezmoi_bin" init --apply https://github.com/JamesAdams765/dotfiles.git >/dev/null 2>&1; then
      echo "  ✓ Dotfiles cloned and applied successfully (HTTPS)"
    else
      echo "  ✗ HTTPS failed, trying SSH..."
      if "$chezmoi_bin" init --apply git@github.com:JamesAdams765/dotfiles.git >/dev/null 2>&1; then
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
  
  local chezmoi_bin="chezmoi"
  if ! has_cmd chezmoi; then
    chezmoi_bin="$HOME/.local/bin/chezmoi"
  fi

  # Use --force to ensure non-interactive execution
  if "$chezmoi_bin" apply --force; then
    echo -e "\n  ✓ Configuration applied successfully"
  else
    echo -e "\n${YELLOW}⚠️  Some files may not have been applied, continuing...${NC}"
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
  
  ZSH_PATH=$(which zsh || true)
  
  if [ -z "$ZSH_PATH" ]; then
    echo -e "${RED}❌ zsh not found. Please install zsh manually.${NC}"
    return
  fi
  
  # Update PATH for current session in case tools were just installed
  export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

  if [ "$SHELL" == "$ZSH_PATH" ]; then
    echo "  ✓ zsh is already your default shell"
  else
    echo "  → Setting $ZSH_PATH as default shell..."
    
    if run_cmd chsh -s "$ZSH_PATH" "$USER" >/dev/null 2>&1; then
      echo "  ✓ Default shell set to zsh"
    elif run_cmd chsh -s "$ZSH_PATH" >/dev/null 2>&1; then
      echo "  ✓ Default shell set to zsh"
    else
      echo -e "${YELLOW}⚠️  Could not set default shell automatically.${NC}"
      echo "     Please run: chsh -s $ZSH_PATH"
    fi
  fi
}

# Verify installation
verify_installation() {
  echo -e "\n${BLUE}✅ Verifying installation...${NC}\n"
  
  local issues=0
  
  if [ -f "$HOME/.zshrc" ]; then
    echo "  ✓ .zshrc installed"
  else
    echo -e "${RED}  ❌ .zshrc not found${NC}"
    issues=$((issues + 1))
  fi
  
  if has_cmd chezmoi || [ -f "$HOME/.local/bin/chezmoi" ]; then
    echo "  ✓ chezmoi installed"
  else
    echo -e "${RED}  ❌ chezmoi not found${NC}"
    issues=$((issues + 1))
  fi
  
  if has_cmd zsh; then
    echo "  ✓ zsh installed"
  else
    echo -e "${RED}  ❌ zsh not found${NC}"
    issues=$((issues + 1))
  fi
  
  if has_cmd fzf; then
    echo "  ✓ fzf installed"
  else
    echo -e "${YELLOW}  ⚠️  fzf not found (commands menu requires fzf)${NC}"
  fi
  
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

# Configure npm to use user-writable directory
configure_npm() {
  if ! has_cmd npm; then
    return 0
  fi
  
  echo -e "\n${BLUE}⚙️  Configuring npm for user installations...${NC}\n"
  mkdir -p "$HOME/.npm-global/bin"
  npm config set prefix "$HOME/.npm-global" >/dev/null 2>&1
  echo "  ✓ npm configured (PATH set in shell config)"
}

# Install optional command-line tools (auto-installed on first use)
install_optional_tools() {
  echo -e "\n${BLUE}📚 Installing optional tools (auto-installed on first use)...${NC}\n"
  
  local tools=(
    "btop" "ncdu" "fastfetch" "neomutt" "newsboat" "lynx" "htop"
  )
  
  echo "  Attempting to pre-install common optional tools:"
  
  for tool_name in "${tools[@]}"; do
    if ! has_cmd "$tool_name"; then
      if has_cmd apt-get; then
        echo "  → Installing $tool_name..."
        run_cmd apt-get install -y -qq "$tool_name" >/dev/null 2>&1 && echo "    ✓ $tool_name installed" || {
          # Fallback for fastfetch to neofetch
          if [[ "$tool_name" == "fastfetch" ]]; then
            run_cmd apt-get install -y -qq "neofetch" >/dev/null 2>&1 && echo "    ✓ neofetch installed (fallback for fastfetch)" || echo -e "    ${YELLOW}⚠️  Could not install $tool_name (nor neofetch fallback)${NC}"
          else
            echo -e "    ${YELLOW}⚠️  Could not install $tool_name${NC}"
          fi
        }
      elif has_cmd brew; then
        echo "  → Installing $tool_name..."
        brew install "$tool_name" -q >/dev/null 2>&1 && echo "    ✓ $tool_name installed" || echo -e "    ${YELLOW}⚠️  Could not install $tool_name${NC}"
      elif has_cmd pacman; then
        echo "  → Installing $tool_name..."
        run_cmd pacman -S --noconfirm "$tool_name" >/dev/null 2>&1 && echo "    ✓ $tool_name installed" || echo -e "    ${YELLOW}⚠️  Could not install $tool_name${NC}"
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
  configure_npm
  install_optional_tools
  set_default_shell
  verify_installation
  show_next_steps
}

# Run main function
main
