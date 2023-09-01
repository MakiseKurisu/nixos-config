{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages =
      with pkgs; [
        git
        git-crypt
        kitty
        parted
        tmux
        wget
      ];
  };
}
