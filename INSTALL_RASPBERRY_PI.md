# Installing on Raspberry Pi

This guide provides detailed instructions for installing your custom shell configuration on a Raspberry Pi.

## Quick Start (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/JamesAdams765/dotfiles/master/install.sh | bash
```

Then **logout and log back in** (or open a new SSH session) to start using zsh.

## What the Script Does

The installation script automatically:

1. ✓ **Detects your OS** - Identifies Raspberry Pi (ARM/ARM64)
2. ✓ **Installs core dependencies** - curl, git, zsh
3. ✓ **Installs optional tools** - fzf (for menu system), Node.js, npm
4. ✓ **Installs chezmoi** - Dotfiles manager
5. ✓ **Clones dotfiles** - From GitHub
6. ✓ **Installs Oh My Zsh** - Shell framework
7. ✓ **Installs Powerlevel10k** - Modern prompt theme
8. ✓ **Sets zsh as default** - Changes your shell
9. ✓ **Verifies installation** - Checks everything worked

## After Installation

### Logout and Login

The script sets zsh as your default shell, so you need to **start a new session**:

```bash
# If installing via SSH
exit
ssh pi@raspberry.local    # Log back in

# If installing locally
logout
# Log in again
```

### Verify Installation

Once you're in a new zsh session, run these commands:

```bash
# See all available commands
commands

# Check what tools are installed
health-check

# Edit your shell configuration
config

# Sync with GitHub
dotfiles
```

## Troubleshooting

### "command not found: commands"

This error means zsh is not your default shell yet. The script tries to set it automatically, but on some systems it requires a logout/login:

**Solution:**
```bash
# Logout and log back in
exit

# Then log in again and try:
commands
```

### "commands" shows fzf error

The `commands` function needs `fzf` (fuzzy finder). The script tries to install it, but on older Raspberry Pi OS versions it might not be available in the default repos.

**Solution:**
```bash
# Install fzf manually
sudo apt-get install -y fzf

# Or use the alternative menu
useful-aliases
```

### AI Assistant Commands (copilot, gemini) fail to install

If these commands fail, it's likely because npm/Node.js is not properly installed.

**Solution:**
```bash
# Check if Node.js is installed
node --version

# If not, the install script should have installed it:
sudo apt-get install -y nodejs npm

# Verify npm is available
npm --version

# The copilot and gemini functions will auto-install on first use
copilot "your question here"
```

If you need a newer version of Node.js than what's in the repo:
```bash
# Install nvm (Node Version Manager) for better Node.js management
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload shell
exec zsh

# Then install Node.js LTS
nvm install --lts

# Verify
npm --version
```

### Oh My Zsh installation failed

If the install script shows warnings about Oh My Zsh, you can install it manually:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

### Powerlevel10k font issues

If your prompt looks garbled, you need Nerd Fonts. Install them:

```bash
# Install fonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

# Download a Nerd Font (e.g., FiraCode)
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/FiraCode.zip
unzip FiraCode.zip

# Refresh font cache
fc-cache -fv
```

Then configure your terminal to use the font (in PuTTY, Windows Terminal, iTerm2, etc.).

### "Permission denied" when setting default shell

Some systems require sudo. The script tries this automatically, but if it fails:

```bash
sudo chsh -s $(which zsh) $USER
```

### Auto-install failures for optional tools

Tools like yazi, btop, or ncdu may fail to install on some Raspberry Pi configurations. This is non-critical - they'll be installed on-demand when you first use them.

**Example:**
```bash
# First time you run this:
storage  # This will attempt to install ncdu

# If it fails, you can install manually:
sudo apt-get install -y ncdu
```

## Manual Installation

If you prefer to install step-by-step:

### 1. Update system
```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 2. Install dependencies
```bash
sudo apt-get install -y curl git zsh fzf build-essential
```

### 3. Install chezmoi
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
```

### 4. Initialize dotfiles
```bash
~/.local/bin/chezmoi init --apply https://github.com/JamesAdams765/dotfiles.git
```

### 5. Install Oh My Zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

### 6. Install zsh plugins
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

### 7. Install Powerlevel10k theme
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
```

### 8. Set zsh as default shell
```bash
chsh -s $(which zsh)
```

### 9. Start new session
```bash
exit
# Log in again
```

## Configuration

### Edit your .zshrc
```bash
config
```

This opens `.zshrc` in your default editor and reloads the shell.

### View all available commands
```bash
commands
```

### Check installed tools
```bash
health-check
```

## Git Integration

Your dotfiles are synchronized with GitHub using chezmoi.

### Pull latest changes from GitHub
```bash
dotfiles
```

### Force pull (discard local changes)
```bash
dotfiles --force
```

### Push local changes to GitHub
```bash
dotfiles
```

(Automatic - happens when you run `dotfiles`)

## What Gets Installed

### Files
- `~/.zshrc` - Main shell configuration (900+ lines)
- `~/.p10k.zsh` - Powerlevel10k prompt customization
- `~/.oh-my-zsh/` - Oh My Zsh framework

### Programs
- **zsh** - Shell
- **chezmoi** - Dotfiles manager
- **fzf** - Fuzzy finder (for commands menu)
- **git** - Version control
- **curl** - Download tool

### Optional (auto-install on use)
- **htop** - System monitor
- **neofetch** - System info
- **yazi** - File browser
- **neomutt** - Email client
- **newsboat** - RSS reader
- **lazyssh** - SSH manager

## Performance Notes

- **Startup time**: ~400-600ms (normal for Raspberry Pi)
- **Memory usage**: Minimal - only essential plugins loaded
- **CPU impact**: Negligible

## Support

If you encounter issues:

1. **Check the install log**: The script shows exactly what failed
2. **Run health-check**: `health-check` shows what's installed
3. **Check fzf**: `fzf` is required for the commands menu
4. **View manual**: `useful-aliases` works without fzf
5. **Check GitHub**: https://github.com/JamesAdams765/dotfiles

## Next Steps

After installation:

1. ✓ Customize your configuration: `config`
2. ✓ Explore available commands: `commands` or `useful-aliases`
3. ✓ Sync your dotfiles: `dotfiles`
4. ✓ Check what's installed: `health-check`
5. ✓ Update all apps: `update-apps`

---

**Enjoy your new shell configuration!** 🚀
