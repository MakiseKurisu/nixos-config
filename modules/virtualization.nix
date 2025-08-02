{ config, lib, pkgs, ... }:

{
  imports = [
    ./virtualization-base.nix
  ];

  environment = {
    etc = {
      "looking-glass-client.ini" = {
        source = ../configs/looking-glass/looking-glass-client.ini;
      };
    };
    systemPackages =
      with pkgs; [
        waydroid-helper
        wl-clipboard # used by waydroid
      ];
  };

  virtualisation = {
    lxc = {
      enable = true; # waydroid uses lxc
      defaultConfig = "lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf";
      lxcfs.enable = true;
    };
    waydroid.enable = true;
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          #"[workspace 13 silent] waydroid first-launch"
        ];
      };
    };
  };
}
