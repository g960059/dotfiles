function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}


ghq-z()   { z "$(ghq root)/$(ghq list | fzf --height 50% --reverse)"; }
ghq-get() { ghq get "$(gh repo list --json name --jq '.[].name' | fzf --height 50% --reverse)"; }
alias repo='ghq-z'


alias cc="claude --dangerously-skip-permissions"

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

# ---- home-manager helpers (no install required) ----
# Use:
#   hms            -> switch for this machine (auto selects profile)
#   hms update     -> nix flake update + switch
#   hms host       -> force hirakawa
#   hms vm         -> force virtualmachine
#   hms show       -> nix flake show
#   hmcd           -> cd to flake dir
#   hms --show-trace  -> pass options to switch

_hm_flake="${HOME}/.config/home-manager"
_hm_runner=(nix run github:nix-community/home-manager --)

hm_target() {
  local hn
  hn="$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "")"

  case "$hn" in
    virtualmachine|UTM_VM|utm*|vm*)
      echo "virtualmachine"
      ;;
    *)
      echo "hirakawa"
      ;;
  esac
}

hmcd() { cd "${_hm_flake}" || return 1; }

hms() {
  local sub="${1:-switch}"
  shift || true

  local target
  target="$(hm_target)"

  case "$sub" in
    switch)
      "${_hm_runner[@]}" switch --flake "${_hm_flake}#${target}" "$@"
      ;;
    update)
      (cd "${_hm_flake}" && nix flake update) && \
      "${_hm_runner[@]}" switch --flake "${_hm_flake}#${target}" "$@"
      ;;
    host)
      "${_hm_runner[@]}" switch --flake "${_hm_flake}#hirakawa" "$@"
      ;;
    vm)
      "${_hm_runner[@]}" switch --flake "${_hm_flake}#virtualmachine" "$@"
      ;;
    show)
      nix flake show "${_hm_flake}"
      ;;
    *)
      # default: treat the first arg as an extra option for switch
      "${_hm_runner[@]}" switch --flake "${_hm_flake}#${target}" "$sub" "$@"
      ;;
  esac
}
# ---- end ----

