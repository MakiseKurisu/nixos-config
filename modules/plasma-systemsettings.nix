{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; with libsForQt5; [
      systemsettings
      plasma-desktop
    ];
    # This is needed to have KPackage 'kcm_workspace' working
    pathsToLink = [
      "/share/kpackage/kcms"
    ];
  };
}
