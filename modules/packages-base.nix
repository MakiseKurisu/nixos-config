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
      rebase.autoStash = true;
      credential.helper = "store";
      user = {
        name = "MakiseKurisu";
        email = "MakiseKurisu@users.noreply.github.com";
      };
      http = {
        version = "HTTP/1.1";
        postBuffer = 524288000;
      };
    };
  };

  services = {
    geoclue2.enable = true;
    localtimed.enable = true;
  };
}
