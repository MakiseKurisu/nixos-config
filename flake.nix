{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
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
    impermanence.url = "github:nix-community/impermanence";
    vgpu4nixos.url = "github:MakiseKurisu/vgpu4nixos";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Work In Progress PRs
    pr-dolphin.url = "github:MakiseKurisu/nixpkgs/dolphin";
    pr-mmdebstrap.url = "github:MakiseKurisu/nixpkgs/mmdebstrap";
    pr-fastapi-dls.url = "github:MakiseKurisu/nixpkgs/fastapi-dls";
    pr-mdevctl.url = "github:MakiseKurisu/nixpkgs/2db3f670641f422ebdd5ed5d1a071565742a1f2f";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , flake-parts
    , home-manager
    , lix-module
    , nix-on-droid
    , nixos-vscode-server
    , NUR
    , dewclaw
    , gfwlist2dnsmasq
    , impermanence
    , vgpu4nixos
    , disko
    , pr-dolphin
    , pr-mmdebstrap
    , pr-fastapi-dls
    , pr-mdevctl
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
                rax3000m = import machines/openwrt/wireless-router {
                  inherit lib inputs;
                  release = "23.05.5";
                  target = "mediatek/filogic";
                  arch = "aarch64_cortex-a53";
                  hostname = "RAX3000M";
                  ip = "192.168.9.1";
                } // {
                  uci.settings.wireless.wifi-device.radio0.path = "platform/18000000.wifi";
                  uci.settings.wireless.wifi-device.radio1.path = "platform/18000000.wifi+1";
                };
                rt3200 = import machines/openwrt/wireless-ap {
                  inherit lib inputs;
                  release = "23.05.5";
                  target = "mediatek/mt7622";
                  arch = "aarch64_cortex-a53";
                  hostname = "RT3200";
                  ip = "192.168.9.10";
                } // {
                  uci.settings.wireless.wifi-device.radio0.path = "platform/18000000.wmac";
                  uci.settings.wireless.wifi-device.radio1.path = "1a143000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0";
                };
                openwrt = import machines/openwrt/router {
                  inherit lib inputs;
                  release = "24.10.0";
                  target = "x86/64";
                  arch = "x86_64";
                  hostname = "OpenWrt";
                  ip = "192.168.9.1";
                  kver = "6.6.73-1-a21259e4f338051d27a6443a3a7f7f1f";
                };
                m93p = import machines/openwrt/router {
                  inherit lib inputs;
                  release = "23.05.5";
                  target = "x86/64";
                  arch = "x86_64";
                  hostname = "M93p";
                  ip = "192.168.9.1";
                } // {
                  packages = [
                    "kmod-iwlwifi"
                    "iwlwifi-firmware-iwl7260"
                    "kmod-r8169"
                    "r8169-firmware"
                  ];
                };
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
              ./machines/main
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
          n40 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            modules = [
              ./machines/n40/configuration.nix
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
