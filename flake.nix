{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    NUR.url = "github:nix-community/NUR";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    devenv,
    home-manager,
    nixos-vscode-server,
    NUR,
    }: {
    nixosConfigurations = {
        app01 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/app01/configuration.nix
            ];
        };
        main = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/main/configuration.nix
            ];
        };
        nas = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/nas/configuration.nix
            ];
        };
        p15 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/p15/configuration.nix
            ];
        };
        rpi3 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/rpi3/configuration.nix
            ];
        };
        w540 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/w540/configuration.nix
            ];
        };
    };
  };
}
