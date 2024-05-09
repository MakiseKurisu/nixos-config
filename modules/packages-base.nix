{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages =
      with pkgs; [
        git-crypt
        parted
        tmux
        wget
      ];
  };

  programs = {
    git = {
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
          maxRequestBuffer = 524288000;
        };
      };
    };
    ssh = {
      startAgent = true;
      extraConfig = ''
        StrictHostKeyChecking accept-new
      '';
    };
  };

  services = {
    fail2ban.enable = true;
    geoclue2.enable = true;
    localtimed.enable = true;
  };
}
