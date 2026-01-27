# 普段用: y
function y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi --cwd-file="$tmp" "$@"
  local cwd
  cwd="$(cat -- "$tmp" 2>/dev/null)"
  rm -f -- "$tmp"
  [[ -n "$cwd" && -d "$cwd" && "$cwd" != "$PWD" ]] && cd -- "$cwd"
}

# 狭い用: yn（親/プレビュー無しレイアウトの設定を読む）
function yn() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  YAZI_CONFIG_HOME="$HOME/.config/yazi-narrow" yazi --cwd-file="$tmp" "$@"
  local cwd
  cwd="$(cat -- "$tmp" 2>/dev/null)"
  rm -f -- "$tmp"
  [[ -n "$cwd" && -d "$cwd" && "$cwd" != "$PWD" ]] && cd -- "$cwd"
}

# --- repo: ghq + fzf + zoxide + git-wt ---
# prerequisites: ghq, fzf, zoxide (z), gh (optional for repo get), git-wt (optional for repo wt)

# ローカル ghq repo へ移動（zoxide 前提）
_repo_cd() {
  local query="${1:-}"
  local target

  target="$(
    ghq list -p 2>/dev/null | \
      fzf --height 50% --reverse \
          --prompt 'repo> ' \
          --query "$query" \
          --preview 'git -C {} rev-parse --is-inside-work-tree >/dev/null 2>&1 && git -C {} status -sb || ls -la {} | head -n 80'
  )" || return 1

  z "$target"
}

# GitHub repo を選んで ghq get（owner/repo 形式）
_repo_get() {
  local query="${1:-}"
  local pick

  command -v gh >/dev/null 2>&1 || { echo "repo get: gh が必要です" >&2; return 1; }
  command -v ghq >/dev/null 2>&1 || { echo "repo get: ghq が必要です" >&2; return 1; }

  pick="$(
    gh repo list --limit 200 \
      --json nameWithOwner,description,updatedAt \
      --jq '.[] | "\(.nameWithOwner)\t\(.updatedAt)\t\(.description // "")"' | \
    fzf --height 50% --reverse \
        --prompt 'repo get> ' \
        --with-nth=1,3 --delimiter $'\t' \
        --query "$query" \
        --preview 'echo {1}; echo; echo {3}; echo; echo "updated: {2}"'
  )" || return 1

  ghq get "${pick%%$'\t'*}"
}

# 現 repo で worktree へ移動（なければ作成）
_repo_wt() {
  local branch="${1:-}"
  local root path

  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "repo wt: git repo の中で実行してください（先に `repo` で移動）" >&2
    return 1
  }

  # git-wt が提供する `git wt` が動く前提
  git wt --help >/dev/null 2>&1 || {
    echo "repo wt: git-wt が必要です（`git wt` が動く状態にしてください）" >&2
    return 1
  }

  if [[ -z "$branch" ]]; then
    branch="$(
      git -C "$root" branch --format='%(refname:short)' | \
        fzf --height 50% --reverse \
            --prompt 'wt> ' \
            --preview "git -C '$root' log -n 20 --oneline --decorate --color=always {}"
    )" || return 1
  fi

  # --nocd でパスだけ取得し、移動は zoxide に統一
  path="$(git -C "$root" wt --nocd "$branch")" || return 1
  z "$path"
}

repo() {
  local sub="${1:-}"
  case "$sub" in
    get|clone)
      shift; _repo_get "$@"
      ;;
    wt|worktree|w)
      shift; _repo_wt "$@"
      ;;
    -h|--help|help)
      cat <<'EOF'
repo              : ghq のローカル repo へ移動（fzf + zoxide）
repo <query>      : クエリ付きで repo 選択
repo get [query]  : GitHub repo を選んで ghq get（owner/repo）
repo wt [branch]  : 現 repo の worktree へ移動（なければ作成）
EOF
      ;;
    *)
      _repo_cd "$@"
      ;;
  esac
}

alias vim='nvim'
alias cc="claude --dangerously-skip-permissions"
export EDITOR="nvim"
export AI_COMMIT_N=3
export OPENROUTER_API_KEY_FILE="$HOME/.config/secrets/openrouter_api_key"
export PATH="$HOME/.local/bin:$PATH"

eval "$(fzf --zsh)"
eval "$(sheldon source)"
eval "$(git wt --init zsh --nocd)"

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ----- home-manager helper (no install required) -----
_hm_flake="${HOME}/.config/home-manager"
_hm_runner=(nix run github:nix-community/home-manager --)

hm_target() {
  [[ -n "${HM_TARGET:-}" ]] && { echo "$HM_TARGET"; return 0; }

  local hn
  hn="$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "")"
  case "$hn" in
    Apple-Virtual-Machine-*|virtualmachine|UTM_VM|utm*|vm*) echo "virtualmachine" ;;
    *)                                                     echo "hirakawa" ;;
  esac
}

hmcd() { cd "${_hm_flake}" || return 1; }

hms() {
  local sub target
  if (( $# >= 1 )); then
    sub="$1"; shift
  else
    sub="switch"
  fi

  target="$(hm_target)"

  case "$sub" in
    switch) "${_hm_runner[@]}" switch --flake "${_hm_flake}#${target}" "$@" ;;
    update) (cd "${_hm_flake}" && nix flake update) && \
            "${_hm_runner[@]}" switch --flake "${_hm_flake}#${target}" "$@" ;;
    host)   "${_hm_runner[@]}" switch --flake "${_hm_flake}#hirakawa" "$@" ;;
    vm)     "${_hm_runner[@]}" switch --flake "${_hm_flake}#virtualmachine" "$@" ;;
    show)   nix flake show "${_hm_flake}" ;;
    *)      "${_hm_runner[@]}" switch --flake "${_hm_flake}#${target}" "$sub" "$@" ;;
  esac
}
