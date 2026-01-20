{
  description = "My Home Manager config (macOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";

      overlays = [
        (final: prev: {
          keifu = final.callPackage ./pkgs/keifu.nix { };
        })
      ];

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      mkHome = { username, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ({ ... }: {
              home.username = username;
              home.homeDirectory = homeDirectory;
            })
          ];
        };
    in
    {
      homeConfigurations = {
        hirakawa = mkHome {
          username = "hirakawa";
          homeDirectory = "/Users/hirakawa";
        };

        virtualmachine = mkHome {
          username = "virtualmachine";
          homeDirectory = "/Users/virtualmachine";
        };
      };
    };
}

