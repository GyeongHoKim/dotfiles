# Oh My Zsh Settings
export ZSH="$HOME/.oh-my-zsh" # Path to OMZ config
zstyle ':omz:update' mode reminder  # Update behavior - inform when available
# Oh My Zsh Theme Configuration
# Choose between Oh My Zsh themes or Oh My Posh

# Option 1: Oh My Zsh built-in themes (currently active)
ZSH_THEME="agnoster"  # Options: robbyrussell, agnoster, powerlevel10k, etc.

# Option 2: Oh My Posh (uncomment to use instead of Oh My Zsh themes)
# ZSH_THEME=""  # Disable Oh My Zsh theme when using Oh My Posh
# if command -v oh-my-posh &> /dev/null; then
#   # Use default theme
#   eval "$(oh-my-posh init zsh)"
#
#   # Or use a specific theme (uncomment and adjust path)
#   # eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/jandedobbeleer.omp.json)"
#   # eval "$(oh-my-posh init zsh --config ~/.oh-my-posh-themes/jandedobbeleer.omp.json)"
# fi

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    vscode
)

ZSH_AUTOSUGGEST_STRATEGY=(
    completion
    history
)

source $ZSH/oh-my-zsh.sh

# Get environmental variables from ~/.env_vars if it exists (in order to keep separate env variables per computer)
if [ -f ~/.env_vars ]; then
    source ~/.env_vars
fi

# Aliases
alias zshconf="code ~/.zshrc" # Opens this file in VS Code. Requires VSCode "code" command
alias zshsrc="source ~/.zshrc" # Shortcut to source this file.
alias python="python3"
alias podman="docker" # use podman as a drop-in replacement for docker

# HOMEBREW ENV VARS
export PATH=/opt/homebrew/bin:$PATH

# Go ENV VARS
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# nvm ENV VRAS
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
