{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-droid.url = "github:MakiseKurisu/nixpkgs/nixos-24.05";
    home-manager-droid = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-droid";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-droid";
      inputs.home-manager.follows = "home-manager-droid";
    };

    omniflake = {
      url = "github:fzakaria/omniflake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+file:secrets";
      flake = false;
    };
    gfwlist2dnsmasq = {
      url = "github:docker-geph/gfwlist2dnsmasq";
      flake = false;
    };

    # Work In Progress PRs
    pr-mmdebstrap.url = "github:MakiseKurisu/nixpkgs/mmdebstrap";
    pr-mdevctl.url = "github:MakiseKurisu/nixpkgs/2db3f670641f422ebdd5ed5d1a071565742a1f2f";
    pr-pico-rpa.url = "github:MakiseKurisu/nixpkgs/pico-rpa";
  };

  outputs =
    { self, ... }@inputs:
    inputs.omniflake.flakes.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./machines
        ./modules/nix-on-droid.flake-module.nix
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          lib,
          system,
          ...
        }:
        {
          formatter = pkgs.nixfmt-tree;
          packages = {
            dewclaw-env = pkgs.callPackage inputs.omniflake.flakes.dewclaw (
              import ./pkgs/dewclaw {
                inherit lib inputs;
              }
            );
            default = self'.packages.dewclaw-env;
          };
        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
        nixosConfigurations = {
          app01 = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./machines/app01
            ];
          };
        };

        checks = builtins.mapAttrs (
          system: deployLib: deployLib.deployChecks self.deploy
        ) inputs.omniflake.flakes.deploy-rs.lib;
      };
    };
}
