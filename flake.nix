{
  description = "NixOS configurations";

  inputs = {
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
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-droid";
      inputs.home-manager.follows = "home-manager-droid";
    };
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
    # Work In Progress PRs
    pr-mmdebstrap.url = "github:MakiseKurisu/nixpkgs/mmdebstrap";
    pr-fastapi-dls.url = "github:MakiseKurisu/nixpkgs/fastapi-dls";
    pr-mdevctl.url = "github:MakiseKurisu/nixpkgs/2db3f670641f422ebdd5ed5d1a071565742a1f2f";
    pr-pico-rpa.url = "github:MakiseKurisu/nixpkgs/pico-rpa";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , flake-parts
    , home-manager
    , nix-on-droid
    , nixos-vscode-server
    , NUR
    , dewclaw
    , gfwlist2dnsmasq
    , impermanence
    , disko
    , nixified-ai
    , pr-mmdebstrap
    , pr-fastapi-dls
    , pr-mdevctl
    , pr-pico-rpa
    , ...
    }: flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule

      ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, lib, system, ... }: {
        formatter = pkgs.nixpkgs-fmt;
        packages = {
          dewclaw-env = pkgs.callPackage dewclaw (import ./pkgs/dewclaw {
            inherit lib;
            gfwlist2dnsmasq = inputs.gfwlist2dnsmasq;
           });
          default = self.packages.${system}.dewclaw-env;
        };
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
              ./machines/app01
            ];
          };
          main = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/main
            ];
          };
          yuntian = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/yuntian
            ];
          };
          nas = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/nas
            ];
          };
          p15 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/p15
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
          n40 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/n40
            ];
          };
          b490 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/b490
            ];
          };
        };

        nixOnDroidConfigurations = {
          davinci = nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = inputs.nixpkgs-droid.legacyPackages."aarch64-linux";
            modules = [
              ./machines/davinci/nix-on-droid.nix
            ];
          };
          bla-al00 = nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = inputs.nixpkgs-droid.legacyPackages."aarch64-linux";
            modules = [
              ./machines/bla-al00
            ];
          };
          p027 = nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = inputs.nixpkgs-droid.legacyPackages."aarch64-linux";
            modules = [
              ./machines/p027
            ];
          };
        };
      };
    };
}
