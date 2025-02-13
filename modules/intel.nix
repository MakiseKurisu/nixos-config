{ config, lib, pkgs, ... }:

{
  imports = [
    ./intel-base.nix
  ];

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
}
