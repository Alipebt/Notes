# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install

# Created by newuser for 5.9
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/autojump/autojump.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ====================================================================================
# 以下为自己配置的一些内容
# fzf 快速搜索默认开启
source <(fzf --zsh)


# 定义搜索路径
search_paths=(
  $HOME
  # 当前目录
  .
)

format_paths() {
  local paths=("$@")

  # 定义标志变量，用于检测是否包含 `/` 字符
  contains_slash=false

  # 遍历数组，检查是否包含 `/` 字符
  for path in "${paths[@]}"; do
    if [[ "$path" == *"/"* ]]; then
      contains_slash=true
      break
    fi
  done

  # 如果包含 `/` 字符，则在索引0的位置添加 `.` 字符
  # 为什么要加 `.`？ 参考：https://github.com/sharkdp/fd/pull/913
  # 路径中，存在'/',而'/'在正则中使用，例如为了匹配/root目录，在fd中需要使用 `. /root`
  if $contains_slash; then
    paths=("." "${paths[@]}")
  fi

  # 格式化搜索路径：使用 printf 将数组元素合并成一个字符串转换为用空格分隔的字符串
  local formatted=$(printf "%s " "${paths[@]}")

  echo "$formatted"
}

# 调用函数并存储搜索路径的结果
formatted_paths=$(format_paths "${search_paths[@]}")

# 目录黑名单
ignore_paths=(
  .git
  node_modules
  __pycache__
)
get_ingored_paths() {
  case "$1" in
    "fdfind"|"fd") ignore_flag="--exclude" ;;
    "find") ignore_flag="-I" ;;
    "lsd") ignore_flag="-I" ;;
    # 默认情况下，ignore_flag 为空
    *) ignore_flag="" ;;
  esac

  local result=""
  for path in "${ignore_paths[@]}"; do
    result="$result $ignore_flag \"$path\""
  done
  echo "$result"
}

# 定义通用的 fzf 搜索函数
FZF_SEARCH_TEMPLATE() {
  # 完整命令为：fd --hidden --follow --exclude ".git" --exclude "node_modules" . /root .
  local result="fd --hidden --follow $@ $(get_ingored_paths fdfind) $formatted_paths"
  echo $result
}
preview_opts="--preview='(
    batcat -n --color=always {} ||
    bat -n --color=always {} ||
    cat {} ||
    lsd --tree $(get_ingored_paths lsd) {}
  ) 2>/dev/null | head -n 100'
"

# 默认输入"fzf"回车之后的命令
export FZF_DEFAULT_COMMAND="$(FZF_SEARCH_TEMPLATE)"
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border
  $preview_opts
"
# 配置：fzf 的 【Ctrl+T、Alt+C】快捷键
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  $preview_opts
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_ALT_C_COMMAND="$(FZF_SEARCH_TEMPLATE --type d)"
export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS"
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

# 配置补全：fzf 的【**快捷键】
export FZF_COMPLETION_TRIGGER='`'
# 补全调整
export FZF_COMPLETION_OPTS="$FZF_DEFAULT_OPTS"
# **快捷键进行【命令行】补全，调用此函数
_fzf_compgen_path() {
  # 需要使用 eval 执行字符串中的命令
  # fzf会传递 当前目录，不接收该参数，因为在 search_paths 已经手动定义
  # eval "$FZF_CTRL_T_COMMAND $1"
  eval "$FZF_CTRL_T_COMMAND"
}
# **快捷键进行【路径】补全，调用此函数
_fzf_compgen_dir() {
  # eval "$FZF_ALT_C_COMMAND $1"
  eval "$FZF_ALT_C_COMMAND"
}
# **快捷键，为【特定命令】，添加【额外参数】
_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd)     eval "fzf $preview_opts"               "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
    ssh)          fzf --preview 'ping {}'           "$@" ;;
    *)      eval "fzf $preview_opts"               "$@" ;;
  esac
}
# fzf 配置结束
