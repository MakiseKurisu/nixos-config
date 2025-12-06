# Build VM image with
# nix build .#nixosConfigurations.<machine>.config.system.build.OCIImage

{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/oci-image.nix"
    ../../../modules/base.nix
    ../../../modules/users-base.nix
  ];

  services = {
    avahi.enable = false;
    btrfs.autoScrub.enable = false;
    cloud-init.enable = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "amd01";
  system.stateVersion = "25.11";
}
