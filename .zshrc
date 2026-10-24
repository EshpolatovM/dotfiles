# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Powerlevel10k theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh-My-Zsh plaginlari
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Powerlevel10k konfiguratsiyasini yuklash
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Yagona va toza PATH konfiguratsiyasi ---
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

# --- NVM (Node Version Manager) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- Senior Aliases ---
# WebStorm (yagona to'g'ri symlink orqali)
alias ws="/usr/local/bin/webstorm"

# Dolphin fayl menejeri fon rejimida
alias d="dolphin . >/dev/null 2>&1 &"

# Tezkor loyihalar papkasiga o'tish
alias dev="cd ~/developer"

# Git qisqartmalari
alias g="git"
alias gst="git status"
alias gco="git checkout"
alias gp="git push"
alias gl="git pull"

# Podman konteynerlari uchun qulaylik
alias p="podman"
alias pps="podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

# Maxfiy mahalliy o'zgaruvchilar (agar mavjud bo'lsa, Git'ga kirmaydi)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local