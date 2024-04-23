{ config, lib, pkgs, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    nano
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org
  '';

  # Set your time zone
  time.timeZone = "Asia/Shanghai";

  # Configure home-manager
  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  
    config =
      { config, lib, pkgs, ... }:
      {
        # Read the changelog before changing this value
        home.stateVersion = "23.05";
  
        home.packages = with pkgs; [
          curl
          iperf
          ldns
          nmap
          openssh
          wget
          which
          (writeShellScriptBin "start_sshd" ''
            "${lib.getBin pkgs.openssh}/bin/sshd" \
              -f /data/data/com.termux.nix/files/home/.ssh/sshd_config "$@"
          '')
          (writeShellScriptBin "ping" ''
            /android/system/bin/linker64 /android/system/bin/ping "$@"
          '')
          (writeShellScriptBin "ping6" ''
            /android/system/bin/linker64 /android/system/bin/ping6 "$@"
          '')
        ];

        # insert home-manager config
        programs = {
          bash.enable = true;
          gh.enable = true;
          git.enable = true;
          home-manager.enable = true;
          less.enable = true;
          man.enable = true;
          ssh.enable = true;
          starship.enable = true;
          tmux.enable = true;
        };
      };
  };
}
