{ config, lib, pkgs, ... }:

{
  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.11";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store https://cache.nixos.org
  '';

  # Set your time zone
  time.timeZone = "Asia/Shanghai";

  # Configure home-manager
  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  
    config =
      { config, lib, pkgs, ... }: let
        android-system-bin-wrapper = pkgs.callPackage ./android-system-bin-wrapper.nix {};
      in {
        home = {
          # Read the changelog before changing this value
          stateVersion = "23.11";

          sessionVariables = {
            NOD_FLAKE_DEFAULT_DEVICE = "davinci";
            TERM = "linux";
          };

          sessionPath = [
            "${lib.getBin android-system-bin-wrapper}/bin"
          ];
          shellAliases = {
            ping = lib.getExe' android-system-bin-wrapper "ping";
          };

          packages = with pkgs; [
            cachix
            curl
            findutils
            gnugrep
            iperf
            iputils
            ldns
            nano
            nmap
            openssh
            wget
            which
            (writeShellScriptBin "sshd-start" ''
              set -e
              if [[ ! -f /data/data/com.termux.nix/files/home/.ssh/id_ed25519 ]]; then
                echo "HostKey is missing. Please run 'postinstall-setup' and try again." >&2
                exit 1
              fi
              PID_FILE="/tmp/sshd.pid"
              if [[ -f $PID_FILE ]]; then
                echo "sshd is already running." >&2
                exit 1
              fi
              "${lib.getBin pkgs.openssh}/bin/sshd" \
                -f "${pkgs.writeText "sshd_config" ''
                  HostKey /data/data/com.termux.nix/files/home/.ssh/id_ed25519
                  PidFile /tmp/sshd.pid
                  Port 2222
                ''}" \
                "$@"
              echo "sshd is now listening."
            '')
            (writeShellScriptBin "sshd-stop" ''
              set -e
              PID_FILE="/tmp/sshd.pid"
              if [[ ! -f $PID_FILE ]]; then
                echo "sshd is not running." >&2
                exit 1
              fi
              kill "$("${lib.getBin pkgs.coreutils}/bin/cat" "$PID_FILE")"
              echo "sshd is now stopped."
            '')
            (writeShellScriptBin "postinstall-setup" ''
              cachix use nix-on-droid
              echo "proot cachix configured."

              mkdir -p "$HOME/.ssh"
              ssh-keygen -q -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
              echo "sshd HostKey generated."

              if [[ ! -e "$HOME/.ssh/authorized_keys" ]]; then
                echo "Missing .ssh/authorized_keys! The sshd HostKey will be enabled by default." >&2
                cp "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/authorized_keys"
              fi

              echo "Post install setup completed."
            '')
          ];

          file = {
            "bin/termux-file-editor" = {
              executable = true;
              text = ''
                #!${lib.getBin pkgs.bash}/bin/bash

                "${lib.getBin pkgs.nano}/bin/nano" "$@"
              '';
            };
          };
        };

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
