export PATH="$HOME/Workspace/Repositories/scripts:$PATH"

# Opening Message
opening_msg | grad FFBBB8 D894D0 919EC9

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

plugins=(
  git
  fzf
  extract
  zsh-z
  you-should-use
  auto-notify
)

if [ -f "$HOME/Workspace/Repositories/scripts/.aliases" ]; then
    source "$HOME/Workspace/Repositories/scripts/.aliases"
fi

# Source the central CachyOS configuration
source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
