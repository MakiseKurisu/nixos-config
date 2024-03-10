{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv = {
      url = "github:cachix/devenv";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    NUR.url = "github:nix-community/NUR";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Work In Progress PRs
    pr-ch9344.url = "github:MakiseKurisu/nixpkgs/ch9344-2.0";
    pr-dolphin.url = "github:MakiseKurisu/nixpkgs/dolphin";
    pr-mmdebstrap.url = "github:MakiseKurisu/nixpkgs/mmdebstrap";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , devenv
    , flake-compat
    , flake-parts
    , flake-utils
    , home-manager
    , nixos-vscode-server
    , NUR
    , pre-commit-hooks
    , pr-ch9344
    , pr-dolphin
    , pr-mmdebstrap
    , ...
    }: flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule

      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Run `nix fmt` to use this command
        formatter = pkgs.nixpkgs-fmt;
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.


        nixosConfigurations = {
          app01 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/app01/configuration.nix
            ];
          };
          main = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/main/configuration.nix
            ];
          };
          nas = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/nas/configuration.nix
            ];
          };
          p15 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/p15/configuration.nix
            ];
          };
          rpi3 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/rpi3/configuration.nix
            ];
          };
          w540 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/w540/configuration.nix
            ];
          };
        };
      };
    };
}
