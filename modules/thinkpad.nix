{ config, lib, pkgs, inputs, ... }:

{
  home-manager.users.excalibur = { pkgs, ... }: {
    xdg.configFile = {
      "hypr/machine.conf" = {
        source = pkgs.writeText "hyprland-machine.conf" ''
          workspace=eDP-1, 2
          exec-once=brightnessctl --device "tpacpi::kbd_backlight" set 100%
          bindl=,switch:off:Lid Switch,exec,brightnessctl --device "tpacpi::kbd_backlight" set 100%
          source = ~/.config/hypr/thinkpad.conf
        '';
      };
    };
  };

  boot = {
    extraModprobeConfig = ''
      options vfio-pci ids=1c5c:1639 # Hynix NVMe SSD
      options vfio-pci ids=10de:1fb9,10de:10fa # NVIDIA T1000
      options vfio-pci ids=10de:1e93,10de:10f8,10de:1ad8,10de:1ad9 # NVIDIA GeForce RTX 2080 Max-Q 
      options vfio-pci ids=10de:11fc,10de:0e0b # NVIDIA Quadro K2100M
      options vfio-pci disable_idle_d3=1
      options vfio-pci disable_vga=1
    '';
  };

  services.thinkfan = {
    enable = true;
    sensors = [
      {
        query = "/proc/acpi/ibm/thermal";
        type = "tpacpi";
        indices = [ 0 1 ];
      }
    ];
  };
}
