#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Installation & Restoration Script
# Sets up symlinks from dotfiles repo to user environment.
# ==============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for pretty output
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

log_info() {
  printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
  printf "${GREEN}[OK]${NC} %s\n" "$1"
}

log_warn() {
  printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

link_file() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    log_warn "Source does not exist: $src (skipping)"
    return
  fi

  # Ensure destination parent directory exists
  mkdir -p "$(dirname "$dest")"

  # If destination exists and is a regular file/dir (not a symlink to src), create backup
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    log_warn "Existing file found at $dest, backing up to $backup"
    mv "$dest" "$backup"
  fi

  # Create or update symbolic link
  ln -sfn "$src" "$dest"
  log_success "Linked: $dest -> $src"
}

setup_zsh_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_warn "Oh My Zsh is not installed at ~/.oh-my-zsh. Skipping custom plugins setup."
    return
  fi

  # Powerlevel10k theme
  if [ ! -d "$zsh_custom/themes/powerlevel10k" ]; then
    log_info "Cloning Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$zsh_custom/themes/powerlevel10k"
  fi

  # Custom plugins
  local plugins=(
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions:https://github.com/zsh-users/zsh-completions"
    "fzf-tab:https://github.com/Aloxaf/fzf-tab"
    "zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search"
  )

  for entry in "${plugins[@]}"; do
    local name="${entry%%:*}"
    local url="${entry#*:}"
    local target="$zsh_custom/plugins/$name"

    if [ ! -d "$target" ]; then
      log_info "Cloning plugin: $name..."
      git clone --depth=1 "$url" "$target"
    fi
  done
}

main() {
  log_info "Starting dotfiles setup from: $DOTFILES_DIR"

  # 1. Zsh & Prompt Configurations
  log_info "Configuring Zsh & Powerlevel10k..."
  setup_zsh_plugins
  link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

  # 2. Git Configurations
  log_info "Configuring Git..."
  link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
  if [ -f "$DOTFILES_DIR/git/.gitignore_global" ]; then
    link_file "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
  fi

  # 3. Sway Window Manager
  log_info "Configuring Sway WM..."
  mkdir -p "$HOME/.config/sway"
  link_file "$DOTFILES_DIR/sway/config" "$HOME/.config/sway/config"
  if [ -f "$DOTFILES_DIR/sway/wallpaper.png" ]; then
    link_file "$DOTFILES_DIR/sway/wallpaper.png" "$HOME/.config/sway/wallpaper.png"
  fi

  # 4. IdeaVim
  log_info "Configuring IdeaVim..."
  if [ -f "$DOTFILES_DIR/ideavim/.ideavimrc" ]; then
    link_file "$DOTFILES_DIR/ideavim/.ideavimrc" "$HOME/.ideavimrc"
  fi

  # 5. Neovim
  log_info "Configuring Neovim..."
  mkdir -p "$HOME/.config/nvim"
  if [ -f "$DOTFILES_DIR/nvim/init.lua" ]; then
    link_file "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"
  fi
  if [ -f "$DOTFILES_DIR/nvim/lazy-lock.json" ]; then
    link_file "$DOTFILES_DIR/nvim/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json"
  fi

  # 6. Custom Scripts
  log_info "Configuring Custom Scripts in ~/.local/bin..."
  mkdir -p "$HOME/.local/bin"
  if [ -d "$DOTFILES_DIR/scripts" ]; then
    for script in "$DOTFILES_DIR/scripts"/*; do
      if [ -f "$script" ]; then
        chmod +x "$script"
        local script_name
        script_name="$(basename "$script")"
        link_file "$script" "$HOME/.local/bin/$script_name"
      fi
    done
  fi

  log_success "All dotfiles successfully installed and linked!"
  log_info "Reload your shell (exec zsh) or swaywm (swaymsg reload) to apply changes."
}

main "$@"
