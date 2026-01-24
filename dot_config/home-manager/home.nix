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
    # LSP servers (managed by Nix for reproducibility)
    lua-language-server
    nil
    nodePackages.typescript
    nodePackages.typescript-language-server
    pyright
    nodePackages.bash-language-server
  ];

  programs.starship = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
