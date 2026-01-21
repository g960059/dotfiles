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
    keifu
    sheldon
  ];

  programs.starship = {
    enable = true;
  };
}
