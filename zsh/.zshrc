###########################################################################
# .zshrc
#
# This is the primary configuration file for zsh.
# It's sourced whenever a new zsh session starts and is used to configure
# plugins, themes, aliases, environment variables, and other settings.
###########################################################################

###########################################################################
# Oh My Zsh configuration
###########################################################################
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git fzf z history-substring-search)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vi'
else
    export EDITOR='vi'
fi

###########################################################################
# fzf configuration
###########################################################################
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh