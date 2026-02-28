{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      pr-pico-rpa = import inputs.pr-pico-rpa {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];
  imports = [
    "${inputs.pr-pico-rpa}/nixos/modules/services/misc/pico-remote-play-assistant.nix"
  ];
  # Alternative with NixOS Container
  #
  # networking.firewall.allowedTCPPorts = [ 9000 14500 ];
  # containers = {
  #   pico-remote-play-assistant = {
  #     nixpkgs = inputs.pr-pico-rpa;
  #     bindMounts = {
  #       "/media" = {
  #         hostPath = "/media";
  #       };
  #       "/var/lib/private" = {
  #         hostPath = "/var/lib/private";
  #         isReadOnly = false;
  #       };
  #     };
  #     autoStart = true;
  #     ephemeral = true;
  #     config = { config, pkgs, ... }: {
  #       services.pico-remote-play-assistant = {
  #         enable = true;
  #       };
  #       nixpkgs.config.allowUnfree = true;
  #     };
  #   };
  # };
}
