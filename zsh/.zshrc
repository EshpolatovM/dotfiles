# ==============================================================================
# Powerlevel10k Instant Prompt
# Should stay close to the top of ~/.zshrc.
# ==============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# Environment & PATH Configuration
# ==============================================================================
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$HOME/.opencode/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Preferred editor
if command -v vi >/dev/null 2>&1; then
  export EDITOR="vi"
fi

# ==============================================================================
# Oh My Zsh & Custom Completions Configuration
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Additional completions (loaded before Oh My Zsh for single compinit optimization)
if [ -d "$ZSH/custom/plugins/zsh-completions/src" ]; then
  fpath=("$ZSH/custom/plugins/zsh-completions/src" $fpath)
fi

# Performance & Update settings
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 14
DISABLE_MAGIC_FUNCTIONS="true"
COMPLETION_WAITING_DOTS="false"

# Plugins configuration
# Order matters:
# 1. Standard utilities & completions
# 2. fzf-tab (replaces completion menu, must load before autosuggestions)
# 3. zsh-autosuggestions
# 4. zsh-syntax-highlighting (must be near the end)
# 5. zsh-history-substring-search (must be after syntax-highlighting)
plugins=(
  git
  sudo
  extract
  copypath
  copyfile
  colored-man-pages
  dnf
  command-not-found
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

source "$ZSH/oh-my-zsh.sh"

# ==============================================================================
# Shell Options & Ergonomics
# ==============================================================================
setopt AUTO_CD                  # Type directory name to cd into it
setopt AUTO_PUSHD               # Automatically push visited dirs to stack
setopt PUSHD_IGNORE_DUPS        # Do not store duplicate entries in dir stack
setopt PUSHD_MINUS              # Reverses the +/- operators in pushd
setopt INTERACTIVE_COMMENTS     # Allow comments in interactive shell (# ...)
setopt NO_BEEP                  # Disable annoying terminal beeps
setopt EXTENDED_GLOB            # Extended globbing patterns (#, ~, ^)

# ==============================================================================
# History Configuration
# ==============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY         # Write timestamps to history
setopt INC_APPEND_HISTORY       # Write history entries immediately
setopt SHARE_HISTORY            # Share history between active sessions
setopt HIST_IGNORE_ALL_DUPS     # Do not record duplicate entries
setopt HIST_FIND_NO_DUPS        # Skip dupes during search
setopt HIST_IGNORE_SPACE        # Do not record commands beginning with space
setopt HIST_REDUCE_BLANKS       # Tidy up extraneous whitespace
setopt HIST_VERIFY              # Review command before executing from history

# ==============================================================================
# Keyboard Bindings (Ergonomic Navigation)
# ==============================================================================
bindkey -e
bindkey '^[[1;5C' forward-word                  # Ctrl+Right
bindkey '^[[1;5D' backward-word                 # Ctrl+Left
bindkey '^H' backward-kill-word                 # Ctrl+Backspace
bindkey '^?' backward-delete-char               # Backspace
bindkey '^[[3;5~' kill-word                     # Ctrl+Delete
bindkey '^[[3~' delete-char                     # Delete
bindkey '^[[H' beginning-of-line                # Home
bindkey '^[[F' end-of-line                      # End
bindkey '^ ' autosuggest-accept                 # Ctrl+Space to accept suggestion

# History Substring Search Keybindings (Up/Down Arrow)
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
if (( $+functions[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up    # Up Arrow
  bindkey '^[[B' history-substring-search-down  # Down Arrow
  bindkey '^[OA' history-substring-search-up    # Up Arrow (app mode)
  bindkey '^[OB' history-substring-search-down  # Down Arrow (app mode)
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi

# ==============================================================================
# Autosuggestions Configuration
# ==============================================================================
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"

# ==============================================================================
# FZF-Tab Configuration (Interactive Fuzzy Completion & Previews)
# ==============================================================================
# Disable sort when completing git checkout
zstyle ':completion:*:git-checkout:*' sort false
# Descriptions format to group completion items
zstyle ':completion:*:descriptions' format '[%d]'
# Filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Allow fzf-tab to capture completion prefix
zstyle ':completion:*' menu no
# Preview directory contents with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath 2>/dev/null'
# Preview file content with bat when opening/reading files
zstyle ':fzf-tab:complete:(bat|cat|vi|vim|nano|nvim|less|head|tail):*' fzf-preview 'bat --style=numbers --color=always --line-range :500 $realpath 2>/dev/null || cat $realpath 2>/dev/null'
# Preview systemctl status
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null'
# Preview process list on kill/killall
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,%cpu,%mem,command -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
# Switch groups using '<' and '>'
zstyle ':fzf-tab:*' switch-group '<' '>'
# FZF flags for fzf-tab
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border --inline-info

# ==============================================================================
# FZF Native Shell Integration
# ==============================================================================
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules'
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null || ls -la {} 2>/dev/null'"
fi

# ==============================================================================
# Modern CLI Tool Integrations (Zoxide, Eza, Bat)
# ==============================================================================
# Zoxide smart directory jumping (z <dir>)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Eza modern file listing
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons"
  alias ll="eza -lh --icons --git"
  alias la="eza -lah --icons --git"
  alias lt="eza --tree --level=2 --icons --git-ignore -I 'node_modules|.git'"
  alias l.="eza -d .* --icons"
fi

# Bat modern pager
if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
fi

# ==============================================================================
# Developer Aliases & Shortcuts
# ==============================================================================
# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias cd..="cd .."
alias -- -="cd -"

# App shortcuts
alias d="yazi"
alias lg="lazygit"
alias dev="cd ~/developer"

# Git aliases
alias g="git"
alias gst="git status -sb"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit -v"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gl="git pull"
alias gd="git diff"
alias gds="git diff --staged"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Podman container aliases
alias p="podman"
alias pps="podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias pimg="podman images"
alias prm="podman rm"
alias prmi="podman rmi"
alias pstop="podman stop"

# Fedora / DNF package manager aliases
alias update="sudo dnf upgrade --refresh"
alias install="sudo dnf install"
alias remove="sudo dnf remove"
alias search="dnf search"

# Clipboard aliases (Wayland / X11)
if command -v wl-copy >/dev/null 2>&1; then
  alias clip="wl-copy"
  alias paste="wl-paste"
elif command -v xclip >/dev/null 2>&1; then
  alias clip="xclip -selection clipboard"
  alias paste="xclip -selection clipboard -o"
fi

# ==============================================================================
# Handy Productivity Functions
# ==============================================================================
# Create directory and immediately cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Fuzzy cd into any directory (interactive)
fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git --exclude node_modules 2>/dev/null | fzf --preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null') && cd "$dir"
}

# Fuzzy file search and open in $EDITOR
fed() {
  local file
  file=$(fd --type f --hidden --follow --exclude .git --exclude node_modules 2>/dev/null | fzf --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null') && ${EDITOR:-vi} "$file"
}

# Display open listening ports
ports() {
  sudo ss -tulanp 2>/dev/null || ss -tulanp
}

# Display local and public IP addresses
myip() {
  echo -n "Local IP:  "
  ip -4 addr show scope global 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1
  echo -n "Public IP: "
  curl -s --connect-timeout 2 https://ifconfig.me/ip 2>/dev/null || echo "Unavailable"
}

# ==============================================================================
# Lazy-loaded NVM (Instant Shell Startup)
# ==============================================================================
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
  _load_nvm() {
    unset -f nvm node npm npx corepack 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  }
  nvm() { _load_nvm && nvm "$@"; }
  node() { _load_nvm && node "$@"; }
  npm() { _load_nvm && npm "$@"; }
  npx() { _load_nvm && npx "$@"; }
fi

# ==============================================================================
# Local / Machine-Specific Overrides
# ==============================================================================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ==============================================================================
# Powerlevel10k Configuration (Must remain at the very end of ~/.zshrc)
# ==============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
