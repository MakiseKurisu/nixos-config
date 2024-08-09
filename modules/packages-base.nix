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
        rebase = {
          autoStash = true;
          autoSquash = true;
        };
        credential.helper = "store";
        user = {
          name = "MakiseKurisu";
          email = "MakiseKurisu@users.noreply.github.com";
          signingkey = "~/.ssh/id_rsa.pub";
        };
        http = {
          version = "HTTP/1.1";
          postBuffer = 524288000;
          maxRequestBuffer = 524288000;
        };
        gpg.format = "ssh";
        commit.gpgSign = true;
        tag.gpgSign = true;
        push.gpgSign = "if-asked";
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
