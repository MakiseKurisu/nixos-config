{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages =
      with pkgs; [
        git-crypt
        multipath-tools
        parted
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
          name = lib.mkDefault "MakiseKurisu";
          email = lib.mkDefault "MakiseKurisu@users.noreply.github.com";
          signingkey = lib.mkDefault "~/.ssh/id_rsa.pub";
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
        help.autocorrect = "prompt";
      };
    };
    ssh = {
      extraConfig = ''
        StrictHostKeyChecking accept-new

        Host openwrt
          User root
      '';
    };
  };

  services = {
    fail2ban.enable = true;
    # automatic-timezoned.enable = true;
  };

  # workaround broken geoclue service for now
  # https://github.com/NixOS/nixpkgs/issues/321121
  # https://bugzilla.redhat.com/show_bug.cgi?id=2284621
  time.timeZone = "Asia/Shanghai";
}
