{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages =
      with pkgs; [
        git-crypt
        kitty
        parted
        tmux
        wget
      ];
  };

  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "main";
      };
      pull.rebase = true;
      user = {
        name = "MakiseKurisu";
        email = "MakiseKurisu@users.noreply.github.com";
      };
    };
  };
}
