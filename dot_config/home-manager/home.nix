{ config, pkgs, ... }:
{
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    git
    chezmoi
    ripgrep
    fd
    bat
    eza
    fzf
    zoxide
    keifu
    sheldon
    tree-sitter
  ];

  programs.starship = {
    enable = true;
  };
}
