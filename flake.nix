{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.90.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid.url = "github:nix-community/nix-on-droid/release-24.05";
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    NUR.url = "github:nix-community/NUR";
    dewclaw.url = "github:MakiseKurisu/dewclaw";
    gfwlist2dnsmasq = {
      url = "github:docker-geph/gfwlist2dnsmasq";
      flake = false;
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
    , flake-parts
    , home-manager
    , lix-module
    , nix-on-droid
    , nixos-vscode-server
    , NUR
    , dewclaw
    , gfwlist2dnsmasq
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
      perSystem = { config, self', inputs', pkgs, lib, system, ... }: {
        formatter = pkgs.nixpkgs-fmt;
        packages = {
          dewclaw-env = pkgs.callPackage dewclaw {
            configuration = {
              openwrt = {
                openwrt = import machines/openwrt {inherit lib inputs;};
              };
            };
          };
          default = self.packages.x86_64-linux.dewclaw-env;
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

        nixOnDroidConfigurations= {
          davinci = nix-on-droid.lib.nixOnDroidConfiguration {
            modules = [
              ./machines/davinci/nix-on-droid.nix
            ];
          };
        };
      };
    };
}
