{ config, pkgs, ... }:
{
  home.username = "hirakawa";
  home.homeDirectory = "/Users/hirakawa";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    git
    chezmoi
    ripgrep
    fd
    bat
    eza
    fzf
  ];
}

