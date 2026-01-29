export PATH="$HOME/.local/bin:$PATH"

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


alias vim='nvim'
alias cc="claude --dangerously-skip-permissions"
export EDITOR="nvim"
export AI_COMMIT_N=3
export OPENROUTER_API_KEY_FILE="$HOME/.config/secrets/openrouter_api_key"

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

# --- repo: ghq + fzf + zoxide + git-wt ---
# prerequisites: ghq, fzf, zoxide (z), gh (optional for repo get), git-wt (required for repo wt)

# 既存の alias / function を消してから定義（安全策）
unalias repo 2>/dev/null
unset -f repo 2>/dev/null
unset -f _repo_cd _repo_get _repo_wt 2>/dev/null

# ローカル ghq repo へ移動（zoxide 前提）
# 自分の GitHub owner（必要ならここだけ変える）
: "${REPO_MY_OWNER:=g960059}"

_repo_cd() {
  local query="${1:-}"
  local picked repo_path

  command -v ghq >/dev/null 2>&1 || { echo "repo: ghq が見つかりません（PATH=$PATH）" >&2; return 1; }
  command -v fzf >/dev/null 2>&1 || { echo "repo: fzf が見つかりません（PATH=$PATH）" >&2; return 1; }
  command -v z   >/dev/null 2>&1 || { echo "repo: zoxide(z) が見つかりません（PATH=$PATH）" >&2; return 1; }

  # ghq list を zoxide のスコア順（直近使用順）にソート
  # zoxide query -l はスコア降順でパスを返す
  _repo_sorted_list() {
    awk '
      NR == FNR { ghq[$0] = 1; next }
      $0 in ghq { print; delete ghq[$0] }
      END { for (p in ghq) print p }
    ' <(ghq list -p 2>/dev/null) <(zoxide query -l 2>/dev/null)
  }

  picked="$(
    _repo_sorted_list | \
      awk -v me="$REPO_MY_OWNER" -F'/' '
        $0 ~ /\/github\.com\// {
          repo=$(NF); owner=$(NF-1);
          owner_disp = (owner==me ? "" : "@" owner);
          print repo "\t" owner_disp "\t" $0
        }
      ' | \
      fzf --height 50% --reverse \
          --prompt 'repo> ' \
          --query "$query" \
          --delimiter $'\t' \
          --with-nth=1,2 \
          --preview 'git -C {3} rev-parse --is-inside-work-tree >/dev/null 2>&1 && git -C {3} status -sb || ls -la {3} | head -n 80'
  )" || return 1

  repo_path="${picked##*$'\t'}"
  z "$repo_path"
}


# GitHub repo を選んで ghq get（owner/repo 形式）
_repo_get() {
  local query="${1:-}"
  local pick name subpath repo_path

  command -v gh  >/dev/null 2>&1 || { echo "repo get: gh が見つかりません（PATH=$PATH）" >&2; return 1; }
  command -v ghq >/dev/null 2>&1 || { echo "repo get: ghq が見つかりません（PATH=$PATH）" >&2; return 1; }
  command -v fzf >/dev/null 2>&1 || { echo "repo get: fzf が見つかりません（PATH=$PATH）" >&2; return 1; }
  command -v z   >/dev/null 2>&1 || { echo "repo get: zoxide(z) が見つかりません（PATH=$PATH）" >&2; return 1; }

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

  name="${pick%%$'\t'*}"     # owner/repo
  ghq get "$name" || return 1

  subpath="github.com/$name"
  repo_path="$(ghq list -p -e "$subpath" 2>/dev/null | head -n 1)"
  [[ -n "$repo_path" ]] || repo_path="$(ghq root)/$subpath"

  z "$repo_path"
}

# repo wt: git-wt の薄いラッパー（1 branch = 1 worktree 前提）
_repo_wt() {
  emulate -L zsh
  setopt pipefail no_aliases

  command -v git-wt >/dev/null 2>&1 || {
    echo "repo wt: git-wt が見つかりません（PATH=$PATH）" >&2
    return 1
  }
  command -v fzf >/dev/null 2>&1 || { echo "repo wt: fzf が見つかりません（PATH=$PATH）" >&2; return 1; }
  command -v z   >/dev/null 2>&1 || { echo "repo wt: zoxide(z) が見つかりません（PATH=$PATH）" >&2; return 1; }

  local all=0 force=0
  local sub="" arg="" query=""
  local root=""

  # --- option/verb parse（薄く） ---
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a|--all) all=1; shift ;;
      -D|--force) force=1; shift ;;
      new|create|-n|-c) sub="new"; shift; break ;;   # ★createもnew扱い
      rm|remove|delete|-d) sub="rm"; shift; break ;;
      rmb|remove-branch) sub="rmb"; shift; break ;;
      -h|--help|help) sub="help"; shift; break ;;
      --) shift; break ;;
      *) break ;;
    esac
  done

  arg="${1:-}"
  query="$arg"

  # repo root を決める（repo外なら ghq で選択 → その repo の worktree）
  _pick_repo_root() {
    local r
    r="$(git rev-parse --show-toplevel 2>/dev/null)" && { echo "$r"; return 0; }

    command -v ghq >/dev/null 2>&1 || { echo "repo wt: ghq が見つかりません（PATH=$PATH）" >&2; return 1; }

    r="$(
      ghq list -p 2>/dev/null | \
        fzf --height 50% --reverse \
            --prompt 'repo(wt)> ' \
            --query "$query" \
            --preview 'git -C {} rev-parse --is-inside-work-tree >/dev/null 2>&1 && git -C {} status -sb || ls -la {} | head -n 80'
    )" || return 1
    echo "$r"
  }

  # `git wt` の一覧を fzf 用 TSV(branch \t path) にする
  _wt_list_tsv() {
    local r="$1"
    git -C "$r" wt 2>/dev/null | \
      awk '
        # header を除外（git-wt の表形式出力を想定）
        $1=="PATH" || $2=="PATH" { next }
        # marker あり "* path branch head"
        $1=="*" { print $3 "\t" $2; next }
        # marker なし  "path branch head"
        $1 ~ "^/" { print $2 "\t" $1; next }
      '
  }

  # worktree選択して path を返す
  _wt_pick_path() {
    local r="$1"
    local picked
    picked="$(
      _wt_list_tsv "$r" | \
        fzf --height 50% --reverse \
            --prompt 'wt> ' \
            --delimiter $'\t' --with-nth=1 \
            --query "$query" \
            --preview 'cd {2} && pwd && echo && git status -sb && echo && git log -n 20 --oneline --decorate --color=always'
    )" || return 1
    echo "${picked#*$'\t'}"
  }

  # branch名 or path から worktree path を解決
  _wt_resolve_path() {
    local r="$1" x="$2"
    if [[ -z "$x" ]]; then
      _wt_pick_path "$r"
      return $?
    fi
    if [[ -d "$x" ]]; then
      echo "$x"; return 0
    fi
    local line
    line="$(_wt_list_tsv "$r" | awk -F'\t' -v b="$x" '$1==b {print $0; exit}')"
    [[ -n "$line" ]] && { echo "${line#*$'\t'}"; return 0; }
    return 1
  }

  if [[ "$sub" == "help" ]]; then
    cat <<'EOF'
repo wt                         : worktree 一覧から選んで移動（repo外ならrepo選択→worktree選択）
repo wt <query>                 : query を初期絞り込みにして同上（完全一致branchがあれば直行）
repo wt -a [query]              : ghq配下の全repo×全worktree横断で検索→移動（重い）
repo wt new|create <branch>     : git wt --nocd <branch> で作成/取得→移動
repo wt rm <branch|path>        : worktree を削除（branchは残す）
repo wt rmb <branch|path>       : worktree 削除 + branch 削除（-D なら強制）
repo wt -D rm|rmb <...>         : 強制（worktree remove --force / branch -D）
EOF
    return 0
  fi

  # --- 全repo横断(-a) ---
  if (( all )); then
    command -v ghq >/dev/null 2>&1 || { echo "repo wt -a: ghq が見つかりません（PATH=$PATH）" >&2; return 1; }

    local picked
    picked="$(
      ghq list -p 2>/dev/null | \
        while IFS= read -r r; do
          [[ -d "$r/.git" ]] || continue
          _wt_list_tsv "$r" | awk -F'\t' -v repo="$r" '{print repo "\t" $1 "\t" $2}'
        done | \
      fzf --height 60% --reverse \
          --prompt 'wt(all)> ' \
          --with-nth=1,2 --delimiter $'\t' \
          --query "$query" \
          --preview 'cd {3} && pwd && echo && git status -sb && echo && git log -n 20 --oneline --decorate --color=always'
    )" || return 1

    local wt_path="${picked##*$'\t'}"
    z "$wt_path"
    return 0
  fi

  # --- repo単位 ---
  root="$(_pick_repo_root)" || return 1

  # --- 作成（new/create） ---
  if [[ "$sub" == "new" ]]; then
    [[ -n "$arg" ]] || { echo "repo wt new/create: branch 名を指定してください" >&2; return 1; }
    local p
    p="$(git -C "$root" wt --nocd "$arg")" || return 1
    z "$p"
    return 0
  fi

  # --- 削除（rm / rmb） ---
  if [[ "$sub" == "rm" || "$sub" == "rmb" ]]; then
    local p b
    p="$(_wt_resolve_path "$root" "$arg")" || {
      echo "repo wt $sub: 対象が見つかりません（branch or path）" >&2
      return 1
    }
    b="$(_wt_list_tsv "$root" | awk -F'\t' -v p="$p" '$2==p {print $1; exit}')"

    if (( force )); then
      git -C "$root" worktree remove --force "$p" || return 1
    else
      git -C "$root" worktree remove "$p" || return 1
    fi

    if [[ "$sub" == "rmb" && -n "$b" ]]; then
      if (( force )); then
        git -C "$root" branch -D "$b"
      else
        git -C "$root" branch -d "$b"
      fi
    fi
    return 0
  fi

  # --- ナビ（repo wt / repo wt <query>） ---
  # 1) branch 完全一致があれば直行（速い）
  if [[ -n "$arg" ]]; then
    local exact_path
    exact_path="$(_wt_list_tsv "$root" | awk -F'\t' -v b="$arg" '$1==b {print $2; exit}')"
    if [[ -n "$exact_path" ]]; then
      z "$exact_path"
      return 0
    fi
  fi

  # 2) 一覧（query 初期化）→選択移動
  local picked_path
  picked_path="$(_wt_pick_path "$root")" || return 1
  z "$picked_path"
}

# repo コマンド本体
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
repo                 : ghq のローカル repo へ移動（fzf + zoxide）
repo <query>         : クエリ付きで repo 選択
repo get [query]     : GitHub repo を選んで ghq get（owner/repo）
repo wt [...]        : git-wt の薄いラッパー（repo外でもOK / -a横断あり）
  - 詳細: repo wt --help
EOF
      ;;
    *)
      _repo_cd "$@"
      ;;
  esac
}

