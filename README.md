# Dotfiles - Custom Shell Configuration

A comprehensive, production-ready `.zshrc` shell configuration for macOS and Linux (including Raspberry Pi). Includes auto-installation of dependencies, 35+ utility functions, and seamless GitHub synchronization.

## Quick Start

### Installation (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/JamesAdams765/dotfiles/master/install.sh | bash
```

The script will:
- ✓ Detect your OS (macOS, Raspberry Pi, Ubuntu, Debian, etc.)
- ✓ Install required dependencies (curl, git, zsh)
- ✓ Install development tools (build-essential, nodejs, npm)
- ✓ Install and initialize chezmoi (dotfiles manager)
- ✓ Clone and apply your dotfiles
- ✓ Pre-install optional tools (fzf, btop, ncdu, neofetch, etc.)
- ✓ Set zsh as your default shell
- ✓ Verify everything is working

### After Installation

Start a new terminal session and you're ready to go!

```bash
# View all available commands
commands

# Check installed tools
health-check

# Edit configuration
config

# Sync with GitHub
dotfiles
```

## Features

### 35+ Utility Functions
- **Configuration Management**: `config`, `dotfiles`, `sync`
- **System Monitoring**: `health-check`, `profile`, `monitor`
- **Productivity**: `notes`, `backup`, `journal`, `tasks`
- **Development**: `lazyssh`, `repos`, `update-apps`
- **System Tools**: `weather`, `music`, `email`, `files`, `web`
- **And many more...**

### Smart Shell Features
- **Oh My Zsh** - Popular shell framework with plugins
- **Powerlevel10k** - Modern, beautiful shell prompt
- **zoxide** - Smart directory navigation (smarter `cd`)
- **Auto-completion** - Fish-like autosuggestions
- **Syntax Highlighting** - Colored command input
- **Git Integration** - Useful git aliases and info

### Auto-Installation
- Dependencies auto-install on first use
- Cross-platform support (macOS/Linux)
- Non-interactive installation
- Graceful error handling

### Dotfiles Management
- **GitHub Sync**: Push/pull configuration to GitHub
- **Conflict Resolution**: Smart merge conflict handling
- **Auto-apply**: Changes applied immediately to your system
- **chezmoi**: Industry-standard dotfiles manager

## Installation Options

### Option 1: One-Command (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/JamesAdams765/dotfiles/master/install.sh | bash
```

### Option 2: Manual Installation

**1. Update system**
```bash
sudo apt-get update && sudo apt-get upgrade -y
```

**2. Install dependencies**
```bash
sudo apt-get install -y curl git zsh
```

**3. Install chezmoi**
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
```

**4. Initialize dotfiles**
```bash
~/.local/bin/chezmoi init --apply https://github.com/JamesAdams765/dotfiles.git
```

**5. Set zsh as default shell**
```bash
chsh -s $(which zsh)
```

**6. Start new terminal**
```bash
zsh
```

### Option 3: SSH (if configured)
```bash
~/.local/bin/chezmoi init --apply git@github.com:JamesAdams765/dotfiles.git
```

## Available Commands

Type `commands` to see all available utilities with descriptions:

### Productivity Tools
- `journal` - Open a journal (select topic)
- `tasks` - Task manager (multiple projects)
- `backlog` - Markdown kanban board
- `notes` - Quick note taking with timestamps
- `backup` - Backup/restore files

### System Utilities
- `health-check` - Check installed tools and dependencies
- `monitor` - System resource monitoring (htop)
- `update-apps` - Update all package managers at once
- `freememory` - Clear system memory caches (Linux)

### Development Tools
- `lazyssh` - SSH connection manager
- `repos` - Check git repository status
- `config` - Edit and reload .zshrc
- `copilot` - GitHub Copilot AI assistant (auto-installs)
- `gemini` - Google Gemini AI assistant (auto-installs)

### Terminal Applications
- `weather` - Current weather
- `music` - Terminal music player
- `email` - Email client (neomutt)
- `files` - File browser (yazi)
- `web` - Terminal web browser (lynx)
- `rss` - RSS feed reader

### Network & Monitoring
- `gping` - Graphical ping monitor
- `network` - Network monitor (bottom)
- `html` - HTTP client for API testing

## Configuration

### Edit Configuration
```bash
config
```
This opens your `.zshrc` in your editor and reloads the shell automatically.

### Sync with GitHub
```bash
dotfiles
```
Pulls latest from GitHub and pushes local changes.

### Force Override
```bash
dotfiles --force
```
Discard local changes and pull everything from GitHub.

### Force Push to GitHub
```bash
dotfiles-force-override-cloud
```
Push local configuration to GitHub, overwriting remote changes.

## Shell Features

### Aliases
- `..` - Go up one directory
- `...` - Go up two directories
- `....` - Go up three directories
- `cd-` - Go back to previous directory
- `z <pattern>` - Jump to frequently used directory
- `la` - List all files with details
- `ll` - List files
- `lh` - List files with human-readable sizes

### Directory Navigation
- `z` - Jump to frequently accessed directories (zoxide)
- Tab completion - Press Tab for auto-completion
- Plugins - Git, autosuggestions, syntax highlighting

### Git Integration
- Git aliases and shortcuts
- Branch status in prompt
- Staging and committing helpers

## System Requirements

### macOS
- zsh (pre-installed)
- Homebrew (auto-installs dependencies)

### Linux (Raspberry Pi, Ubuntu, Debian, etc.)
- `apt-get` (Debian/Ubuntu package manager)
- Will auto-install: `curl`, `git`, `zsh`

## Troubleshooting

### curl not found
```bash
sudo apt-get install -y curl
```

### zsh not found
```bash
sudo apt-get install -y zsh
```

### chezmoi init fails with HTTPS
Try SSH instead:
```bash
~/.local/bin/chezmoi init --apply git@github.com:JamesAdams765/dotfiles.git
```

### "command not found: commands"
Start a new terminal session or reload:
```bash
exec zsh -l
```

### Permission denied on chsh
```bash
sudo chsh -s $(which zsh) $USER
```

## What Gets Installed

### Configuration Files
- `.zshrc` - Main shell configuration (900+ lines)
- `.p10k.zsh` - Powerlevel10k prompt customization
- `.zsh_history` - Command history

### Programs
- **chezmoi** - Dotfiles manager
- **Oh My Zsh** - Shell framework
- **zoxide** - Smart directory navigation
- **Powerlevel10k** - Modern shell prompt

### Optional Tools (auto-install on use)
- btop - System monitor
- neofetch - System info
- yazi - File browser
- neomutt - Email client
- newsboat - RSS reader
- lazyssh - SSH manager

## File Structure

```
~/.local/share/chezmoi/          # Chezmoi repository
├── dot_zshrc                    # Source .zshrc file
├── install.sh                   # Installation script
├── README.md                    # This file
└── .git/                        # Git repository
```

## Updates

Update your dotfiles from GitHub:
```bash
dotfiles
```

Update the installation script:
```bash
curl -fsSL https://raw.githubusercontent.com/JamesAdams765/dotfiles/master/install.sh | bash
```

## Performance

- **Startup time**: ~400ms
- **Minimal overhead**: Minimal plugins for fast startup
- **Optimized**: Auto-loading of heavy tools only when needed

## Tips & Tricks

### Quickly edit config
```bash
config
```

### See all commands
```bash
commands
```

### Check what's installed
```bash
health-check
```

### Jump to a directory
```bash
z projectname
```

### View your notes
```bash
notes
```

### Backup important files
```bash
backup ~/important-folder
```

### Check git repos status
```bash
repos ~/projects
```

## License

This configuration is provided as-is for personal use.

## Support

For issues or questions:
1. Type `commands` to see available utilities
2. Type `health-check` to diagnose problems
3. Check GitHub: https://github.com/JamesAdams765/dotfiles
4. Edit configuration: `config`

---

**Happy coding!** 🚀
