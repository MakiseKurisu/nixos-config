{ config, lib, pkgs, inputs, ... }:

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
      mkdir -p /impermanence/old_roots
      timestamp=$(date --date="@$(stat -c %Y /impermanence/@)" "+%Y-%m-%d_%H:%M:%S")
      mv /impermanence/@ "/impermanence/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
      IFS=$'\n'
      for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/impermanence/$i"
      done
      btrfs subvolume delete "$1"
    }

    for i in $(find /impermanence/old_roots/ -maxdepth 1 -mtime +30); do
      delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /impermanence/@
    umount /impermanence
  '';
}
