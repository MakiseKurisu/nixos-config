{ config, lib, pkgs, inputs, ... }:

# Post install file copy:
# sudo mkdir -p /persistent/user/excalibur/home/
# sudo mkdir -p /persistent/system/etc/NetworkManager /persistent/system/etc/nixos
# sudo mkdir -p /persistent/system/var
# sudo rsync -arP /etc/adjtime /etc/machine-id /etc/passwd /etc/shadow /etc/nixos/flake.nix /etc/ssh /persistent/system/etc
# sudo rsync -arP /etc/NetworkManager/system-connections /persistent/system/etc/NetworkManager
# sudo rsync -arP /var/lib /var/log /persistent/system/var
#
# Rebuild new machine:
# nixos-rebuild --fast --use-remote-sudo --target-host <machine> boot

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  fileSystems = {
    "/persistent".neededForBoot = true;
  };

  services = {
    openssh = {
      # https://github.com/nix-community/impermanence/issues/192
      hostKeys = [
        {
          type = "ed25519";
          path = "/persistent/system/etc/ssh/ssh_host_ed25519_key";
        }
        {
          type = "rsa";
          bits = 4096;
          path = "/persistent/system/etc/ssh/ssh_host_rsa_key";
        }
      ];
    };
  };

  environment = {
    etc = {
      # Important for boot, "files" won't work as it cannot be symbolic links
      "passwd".source = "/persistent/system/etc/passwd";
      "shadow".source = "/persistent/system/etc/shadow";
    };
    persistence = {
      "/persistent/system" = {
        hideMounts = true;
        directories = [
          "/etc/NetworkManager/system-connections"
          "/etc/ssh"
          "/var/backup"
          "/var/lib"
          "/var/log"
        ];
        files = [
          "/etc/adjtime"
          "/etc/machine-id"
          "/etc/nixos/flake.nix"
        ];
      };
      "/persistent/user/excalibur" = {
        hideMounts = true;
        users.excalibur = {
          directories = [
            "Desktop"
            "Documents"
            "Downloads"
            "Games"
            "Music"
            "Pictures"
            "Public"
            "Templates"
            "Videos"
            { directory = ".gnupg"; mode = "0700"; }
            { directory = ".ssh"; mode = "0700"; }
            { directory = ".local/share/keyrings"; mode = "0700"; }
            ".vscode"
				    ".cache"
            ".config"
            ".local/share"
            ".local/state/nix"  
            ".local/state/home-manager"
          ];
          files = [
            ".bash_history"
            ".git-credentials"
          ];
        };
      };
    };
  };

  boot.initrd.postResumeCommands = lib.mkAfter ''
    mkdir -p /impermanence
    mount -o compress=zstd,subvol=/ /dev/disk/by-partlabel/disk-main-root /impermanence

    if [[ -e /impermanence/@ ]]; then
      timestamp=$(date --date="@$(stat -c %Y /impermanence/@)" "+%Y-%m-%d_%H:%M:%S")
      mkdir -p "/impermanence/snapshots/$timestamp"
      for i in /impermanence/@*; do
        btrfs subvolume snapshot "$i" "/impermanence/snapshots/$timestamp"
      done
    fi

    for i in $(find /impermanence/snapshots/ -mindepth 1 -maxdepth 1 -mtime +30); do
      for j in "$i"/@*; do
          btrfs subvolume delete --recursive "$j"
      done
      rm -rf "$i"
    done

    btrfs subvolume delete --recursive /impermanence/@
    btrfs subvolume create /impermanence/@
    umount /impermanence
  '';
}
