# Shortcuts
alias ll='ls -la'
alias la='ls -A'
alias l='ls'

# Tools
alias pubip='curl ipinfo.io'
alias frp='/opt/frp/frp_0.61.2_darwin_arm64/frpc -c /opt/frp/frp_0.61.2_darwin_arm64/frpc.toml'

# Directories
alias dotfiles="cd $DOTFILES"
alias projects="cd $HOME/Code"
alias wk='cd ~/Desktop/workspace'
alias td='cd ~/Desktop'
alias pj='cd ~/Desktop/projects'
alias js='cd ~/Desktop/joispace'

# IDE/Editors
alias cs='cursor'
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"


# JS
alias p='pnpm'
alias pi='pnpm install'
alias pa='pnpm add'

# Ai
alias ai="aider --no-git --model gemini-exp"

# Git
alias gs="git status"
alias gb="git branch"
alias gc="git checkout"
alias gl="git log --oneline --decorate --color"
alias amend="git add . && git commit --amend --no-edit"
alias git-fetch-all='find . -type d -name ".git" -exec sh -c '\''cd "$(dirname {})" && echo "Fetching $(pwd)" && git fetch'\'' \;' 

