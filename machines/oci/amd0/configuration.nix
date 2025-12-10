# Install VM with
#  nix run github:nix-community/nixos-anywhere -- --flake .#<machine> \
#    --generate-hardware-config nixos-facter machines/oci/<machine>/facter.json \
#    --kexec "https://github.com/nix-community/nixos-images/releases/download/nixos-24.11/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz" \
#    --target-host <user>@<host>
# Run following command in Cloud Console to enable zram
#   modprobe zram && sleep 1 && zramctl /dev/zram0 --algorithm zstd --size "900MiB" && mkswap -U clear /dev/zram0 && swapon --discard --priority 100 /dev/zram0

{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../../modules/oci
  ];

  facter = {
    reportPath = ./facter.json;
  };

  networking.hostName = "amd0";
  system.stateVersion = "25.11";
}
