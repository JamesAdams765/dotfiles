#!/bin/bash
# Fallback commands menu if function isn't loading from .zshrc

if ! command -v fzf &>/dev/null; then
  echo "❌ Error: 'fzf' is required for the commands menu"
  echo ""
  echo "Install it with:"
  echo "  sudo apt-get install -y fzf  (on Linux/Raspberry Pi)"
  echo "  brew install fzf              (on macOS)"
  echo ""
  echo "Or view all commands with: useful-aliases"
  exit 1
fi

cmd=$(printf "%-24s %s\n" \
  "backup"                "📦  Backup/restore important files" \
  "backlog"               "📋  Markdown kanban board (backlog.md)" \
  "calendar"              "📅  Manage calendar events" \
  "computer"              "🖥️   Show system info (neofetch)" \
  "config"                "⚙️   Edit & reload .zshrc configuration" \
  "copilot"               "🤖  GitHub Copilot AI assistant" \
  "dotfiles"              "🔄  Sync dotfiles with GitHub (push + pull)" \
  "dotfiles-force"        "☁️   Force overwrite local dotfiles from GitHub" \
  "dotfiles-force-override-cloud"  "⬆️   Force push local dotfiles to GitHub" \
  "edit-commands"         "✏️   Edit this .zshrc file" \
  "email"                 "📧  Open email client (neomutt)" \
  "file"                  "📁  Browse files (alias for files)" \
  "files"                 "📂  Browse files with yazi" \
  "freememory"            "🧹  Drop system memory caches" \
  "gemini"                "✨  Google Gemini AI assistant" \
  "gping"                 "📡  Graphical ping monitor" \
  "health-check"          "🔍  Check installed tools & dependencies" \
  "help"                  "❓  List all aliases" \
  "html"                  "🌐  HTTP client / API tester (posting)" \
  "journal"               "📓  Open a journal (select topic)" \
  "journal-architecture"  "📓  Architecture journal" \
  "journal-data-platform" "📓  Data platform journal" \
  "journal-dev"           "📓  Dev journal" \
  "journal-work"          "📓  Work journal" \
  "lazyssh"               "🔑  SSH connection manager" \
  "memory"                "📊  System resource monitor (btop)" \
  "monitor"               "🔍  System resource monitor (htop)" \
  "mutt"                  "📧  Open email client (neomutt)" \
  "music"                 "🎵  Terminal music player" \
  "network"               "🔌  Network monitor (bottom)" \
  "notes"                 "📝  Quick note taking utility" \
  "path"                  "📍  Show PATH directories" \
  "profile"               "⏱️   Show shell startup time profile" \
  "refresh"               "🔄  Reload shell configuration" \
  "repos"                 "📦  Check git repos status" \
  "rss"                   "📰  RSS feed reader (newsboat)" \
  "storage"               "💾  Disk usage analyzer (ncdu)" \
  "sync"                  "🔄  Quick alias for dotfiles" \
  "sync-force"            "⚡  Quick alias for dotfiles --force" \
  "tasks"                 "✅  Task manager (select project)" \
  "update-apps"           "⬆️   Update all installed apps" \
  "useful-aliases"        "⌨️   View useful shell aliases & navigation tricks" \
  "weather"               "🌤️   Show current weather" \
  "web"                   "🔗  Terminal web browser (lynx)" \
  "z"                     "🚀  Jump to frecent directory (zoxide)" \
  | fzf --prompt="Select Command: " --height=~30 --layout=reverse --border --no-sort)

cmd=$(echo "$cmd" | awk '{print $1}')
[[ -n "$cmd" ]] && eval "$cmd"
