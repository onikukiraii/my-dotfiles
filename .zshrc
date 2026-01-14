# zmodload zsh/zprof  # プロファイリング時のみ有効化

# PATH
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/Users/masato.takayama/.antigravity/antigravity/bin:$PATH"

# mise (runtime version manager)
eval "$(mise activate zsh)"

# Directory environment
eval "$(direnv hook zsh)"

# Docker CLI completions
fpath=(/Users/masato.takayama/.docker/completions $fpath)
autoload -Uz compinit
# 1日1回だけ補完キャッシュを再生成（高速化）
setopt extendedglob
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
unsetopt extendedglob

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

# lazy tools
alias lg='lazygit'
alias ld='lazydocker'

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
      _gwt_post_setup "$repo_root" "$worktree_dir"
    else
      echo "Failed to create worktree"
      return 1
    fi
  else
    # ブランチが存在しない場合は新規ブランチを作成
    if git worktree add -b "$branch" "$worktree_dir"; then
      _gwt_post_setup "$repo_root" "$worktree_dir"
    else
      echo "Failed to create worktree with new branch"
      return 1
    fi
  fi
}

# worktree作成後の共通セットアップ
_gwt_post_setup() {
  local main_repo="$1"
  local worktree_dir="$2"

  cd "$worktree_dir"

  # .env系ファイルをシンボリックリンク
  for envfile in "$main_repo"/.env*; do
    if [[ -f "$envfile" ]]; then
      local filename=$(basename "$envfile")
      ln -sf "$envfile" "$worktree_dir/$filename"
      echo "Linked: $filename"
    fi
  done

  # direnv allowを自動実行
  if [[ -f "$worktree_dir/.envrc" ]]; then
    direnv allow
    echo "direnv: allowed"
  fi

  echo "Created and moved to: $worktree_dir"
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

# .venvがあるディレクトリに入ったら自動アクティベート
auto_activate_venv() {
  if [[ -d .venv ]] && [[ -f .venv/bin/activate ]]; then
    source .venv/bin/activate 2>/dev/null
  fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd auto_activate_venv
auto_activate_venv  # シェル起動時も実行
