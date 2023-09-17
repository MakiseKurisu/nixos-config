{ config, lib, pkgs, ... }:

{
  home-manager.users.excalibur = { pkgs, ... }: {
    xdg.configFile = {
      "hypr/machine.conf" = {
        source = pkgs.writeText "hyprland-machine.conf" ''
          exec-once=[workspace 1 silent] firefox
          exec-once=brightnessctl --device "tpacpi::kbd_backlight" set 100%
          source = ~/.config/hypr/thinkpad.conf
        '';
      };
    };
  };

  boot = {
    extraModprobeConfig = ''
      options vfio-pci ids=1c5c:1639,10de:1fb9,10de:10fa,10de:1e93,10de:10f8,10de:1ad8,10de:1ad9 disable_idle_d3=1
    '';
  };

  services.thinkfan = {
    enable = true;
    sensors = [
      {
        query = "/proc/acpi/ibm/thermal";
        type = "tpacpi";
        indices = [ 1 2 ];
      }
    ];
  };
}
