{ config, lib, pkgs, ... }:

{
  imports = [
    ./users-base.nix
    <home-manager/nixos>
  ];

  home-manager = {
    useGlobalPkgs = true;
    users.excalibur = { pkgs, ... }: {
      imports = [
        <nixos-vscode-server/modules/vscode-server/home.nix>
      ];
      xdg.configFile = {
        "hypr" = {
          source = ../configs/hypr;
          recursive = true;
        };
        "waybar" = {
          source = ../configs/waybar;
          recursive = true;
        };
        "kitty" = {
          source = ../configs/kitty;
          recursive = true;
        };
        "swayidle" = {
          source = ../configs/swayidle;
          recursive = true;
        };
        "discord" = {
          source = ../configs/discord;
          recursive = true;
        };
      };
      home = {
        username = "excalibur";
        homeDirectory = "/home/excalibur";
        stateVersion = "22.11";
      };
      programs = {
        home-manager.enable = true;
        obs-studio = {
          enable = true;
          package = pkgs.unstable.obs-studio;
          plugins = with pkgs.unstable.obs-studio-plugins; [
            input-overlay
            looking-glass-obs
            obs-pipewire-audio-capture
            wlrobs
          ];
        };
      };
      services.vscode-server.enable = true;
    };
  };
}
