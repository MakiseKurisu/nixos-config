{
  description = "NixOS configurations";

  inputs = {
    secrets = {
      url = "git+file:secrets";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-droid.url = "github:MakiseKurisu/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-droid = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-droid";
    };
    nixos-hardware.url = "github:RadxaYuntian/nixos-hardware/sky1-6.18";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-droid";
      inputs.home-manager.follows = "home-manager-droid";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    NUR.url = "github:nix-community/NUR";
    dewclaw.url = "github:MakiseKurisu/dewclaw";
    gfwlist2dnsmasq = {
      url = "github:docker-geph/gfwlist2dnsmasq";
      flake = false;
    };
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixified-ai.url = "github:nixified-ai/flake";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Work In Progress PRs
    pr-mmdebstrap.url = "github:MakiseKurisu/nixpkgs/mmdebstrap";
    pr-fastapi-dls.url = "github:MakiseKurisu/nixpkgs/fastapi-dls";
    pr-mdevctl.url = "github:MakiseKurisu/nixpkgs/2db3f670641f422ebdd5ed5d1a071565742a1f2f";
    pr-pico-rpa.url = "github:MakiseKurisu/nixpkgs/pico-rpa";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./machines
      ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, lib, system, ... }: {
        formatter = pkgs.nixpkgs-fmt;
        packages = {
          dewclaw-env = pkgs.callPackage inputs.dewclaw (import ./pkgs/dewclaw {
            inherit lib inputs;
           });
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
          p15 = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./machines/p15
            ];
          };
          rpi3 = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./machines/rpi3/configuration.nix
            ];
          };
          w540 = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./machines/w540/configuration.nix
            ];
          };
          n40 = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./machines/n40
            ];
          };
        };

        nixOnDroidConfigurations = {
          davinci = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = inputs.nixpkgs-droid.legacyPackages."aarch64-linux";
            modules = [
              ./machines/davinci/nix-on-droid.nix
            ];
          };
          bla-al00 = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = inputs.nixpkgs-droid.legacyPackages."aarch64-linux";
            modules = [
              ./machines/bla-al00
            ];
          };
          p027 = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = inputs.nixpkgs-droid.legacyPackages."aarch64-linux";
            modules = [
              ./machines/p027
            ];
          };
        };
      };
    };
}
