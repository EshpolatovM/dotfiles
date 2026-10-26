# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# Environment & PATH Configuration
# ==============================================================================
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$HOME/.opencode/bin:$PATH"
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Preferred editor
if command -v vi >/dev/null 2>&1; then
  export EDITOR="vi"
fi

# ==============================================================================
# Oh My Zsh Configuration
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Performance & Update settings
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 14
DISABLE_MAGIC_FUNCTIONS="true"
COMPLETION_WAITING_DOTS="false"

# Plugins (zsh-syntax-highlighting must be loaded last)
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ==============================================================================
# Ergonomic Keyboard Bindings & History
# ==============================================================================
# History configuration
HISTSIZE=50000
SAVEHIST=50000
setopt INC_APPEND_HISTORY       # Write history entries immediately
setopt SHARE_HISTORY            # Share history between sessions
setopt HIST_IGNORE_ALL_DUPS     # Do not record duplicate entries
setopt HIST_FIND_NO_DUPS        # Skip dupes during search
setopt HIST_IGNORE_SPACE        # Do not record commands beginning with space
setopt HIST_REDUCE_BLANKS       # Tidy up extraneous whitespace
setopt HIST_VERIFY              # Review command before executing from history

# Modern terminal keybindings
bindkey -e
bindkey '^[[1;5C' forward-word                  # Ctrl+Right
bindkey '^[[1;5D' backward-word                 # Ctrl+Left
bindkey '^H' backward-kill-word                 # Ctrl+Backspace
bindkey '^[[3;5~' kill-word                     # Ctrl+Delete
bindkey '^ ' autosuggest-accept                 # Ctrl+Space to accept suggestion

# Up/Down history prefix search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search      # Up Arrow
bindkey '^[[B' down-line-or-beginning-search    # Down Arrow
bindkey '^[OA' up-line-or-beginning-search      # Up Arrow (app mode)
bindkey '^[OB' down-line-or-beginning-search    # Down Arrow (app mode)

# Autosuggestions async performance tweak (zero input latency)
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ==============================================================================
# Modern CLI Tool Integrations (Zoxide, FZF, Eza, Bat)
# ==============================================================================
# Zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# FZF integration
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules'
fi

# Eza modern file listing
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons"
  alias ll="eza -lh --icons --git"
  alias la="eza -lah --icons --git"
  alias lt="eza --tree --level=2 --icons --git-ignore -I 'node_modules|.git'"
fi

# Bat modern pager
if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
fi

# ==============================================================================
# Developer Aliases
# ==============================================================================
alias d="yazi"
alias lg="lazygit"
alias dev="cd ~/developer"
alias g="git"
alias gst="git status"
alias gco="git checkout"
alias gp="git push"
alias gl="git pull"
alias p="podman"
alias pps="podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

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
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
