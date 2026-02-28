{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      git-crypt
      multipath-tools
      parted
      rsync
      wget
      usbutils
      pciutils
      smartmontools
      nmap
      ldns
      btrfs-progs
      bcachefs-tools
    ];
  };

  programs = {
    git = {
      enable = true;
      config = {
        credential = {
          "https://github.com/MakiseKurisu".username = "MakiseKurisu";
        };
        init = {
          defaultBranch = "main";
        };
        pull.rebase = true;
        rebase = {
          autoStash = true;
          autoSquash = true;
        };
        credential = {
          helper = "store";
          "https://github.com".username = lib.mkDefault "MakiseKurisu";
        };
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
        commit = {
          gpgSign = true;
          template = "~/.gitmessage";
        };
        tag.gpgSign = true;
        push = {
          autoSetupRemote = true;
          gpgSign = "if-asked";
        };
        help.autocorrect = "prompt";
        format.signOff = true;
      };
    };
    nano = {
      nanorc = ''
        set autoindent
        set historylog
        set indicator
        set linenumbers
        set magic
        set mouse
        set noconvert
        set positionlog
        set smarthome
      '';
    };
    ssh = {
      extraConfig = ''
        Host openwrt
          User root

        Host *
          StrictHostKeyChecking accept-new
      '';
    };
  };

  services = {
    fail2ban.enable = true;
    automatic-timezoned.enable = true;
  };
}
