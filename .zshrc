# PATH
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/Users/masato.takayama/.antigravity/antigravity/bin:$PATH"

# mise (runtime version manager)
eval "$(mise activate zsh)"

# Directory environment
eval "$(direnv hook zsh)"

# Docker CLI completions
fpath=(/Users/masato.takayama/.docker/completions $fpath)
autoload -Uz compinit
compinit

# carapace (multi-shell completion)
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

# starship
eval "$(starship init zsh)"

# zsh plugins (cache brew prefix for performance)
BREW_PREFIX=$(brew --prefix)
source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf
source <(fzf --zsh)

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# git aliases
alias gs='git switch'
alias gsb='git switch -c'
alias gst='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph'

# git worktree helpers
gwt() {
  if [ -z "$1" ]; then
    echo "Usage: gwt <branch-name> [directory-suffix]"
    echo "Example: gwt feature/my-branch review"
    return 1
  fi

  local branch="$1"
  local suffix="${2:-$(echo $branch | sed 's/.*\///')}"
  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  local repo_name=$(basename "$repo_root")
  local worktree_dir="$(dirname "$repo_root")/${repo_name}-${suffix}"

  # 既にworktreeとして存在する場合は移動
  local existing=$(git worktree list | grep "\[$branch\]" | awk '{print $1}')
  if [ -n "$existing" ]; then
    echo "Branch '$branch' already checked out at: $existing"
    cd "$existing"
    echo "Moved to: $existing"
    return 0
  fi

  # ブランチが存在するかチェック
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    # ブランチが存在する場合は通常のworktree追加
    if git worktree add "$worktree_dir" "$branch"; then
      cd "$worktree_dir"
      echo "Created and moved to: $worktree_dir"
    else
      echo "Failed to create worktree"
      return 1
    fi
  else
    # ブランチが存在しない場合は新規ブランチを作成
    if git worktree add -b "$branch" "$worktree_dir"; then
      cd "$worktree_dir"
      echo "Created new branch '$branch' and moved to: $worktree_dir"
    else
      echo "Failed to create worktree with new branch"
      return 1
    fi
  fi
}

gwtl() {
  git worktree list
}

gwtr() {
  local current=$(pwd)
  local main_worktree=$(git worktree list | head -1 | awk '{print $1}')

  if [ "$current" = "$main_worktree" ]; then
    echo "Cannot remove main worktree"
    return 1
  fi

  cd "$main_worktree"
  git worktree remove "$current"
  echo "Removed: $current"
}
