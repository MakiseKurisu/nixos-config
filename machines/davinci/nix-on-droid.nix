{ config, lib, pkgs, ... }:

{
  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.11";

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
      { config, lib, pkgs, ... }: {
        home = {
          # Read the changelog before changing this value
          stateVersion = "23.11";

          sessionVariables = {
            NOD_FLAKE_DEFAULT_DEVICE = "davinci";
            TERM = "linux";
          };

          packages = with pkgs; [
            cachix
            findutils
            gnugrep
            iperf
            ldns
            nano
            nmap
            openssh
            wget
            which
            (writeShellScriptBin "start_sshd" ''
              set -e
              if [ ! -f /data/data/com.termux.nix/files/home/.ssh/id_ed25519 ]; then
                echo "HostKey missing. Please run 'postinstall_setup' and try again." >&2
                exit 1
              fi
              "${lib.getBin pkgs.openssh}/bin/sshd" \
                -f "${pkgs.writeText "sshd_config" ''
                  HostKey /data/data/com.termux.nix/files/home/.ssh/id_ed25519
                  Port 2222
                ''}" \
                "$@"
              echo "sshd is now listening."
            '')
            (callPackage ./android-system-bin-wrapper.nix {})
            (writeShellScriptBin "postinstall_setup" ''
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
