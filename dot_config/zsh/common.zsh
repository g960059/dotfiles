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


ghq-z()   { z "$(ghq root)/$(ghq list | fzf --height 50% --reverse)"; }
ghq-get() { ghq get "$(gh repo list --json name --jq '.[].name' | fzf --height 50% --reverse)"; }
alias repo='ghq-z'
alias vim='nvim'

alias cc="claude --dangerously-skip-permissions"

eval "$(fzf --zsh)"
eval "$(sheldon source)"
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
