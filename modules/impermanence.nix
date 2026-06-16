{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

# Post install file copy:
# sudo mkdir -p /persistent/user/excalibur/home/
# sudo mkdir -p /persistent/system/etc/NetworkManager /persistent/system/etc/nixos
# sudo mkdir -p /persistent/system/var
# sudo rsync -arP /etc/adjtime /etc/machine-id /etc/nixos/flake.nix /etc/ssh /persistent/system/etc
# sudo rsync -arP /etc/NetworkManager/system-connections /persistent/system/etc/NetworkManager
# sudo rsync -arP /var/lib /var/log /persistent/system/var
#
# Rebuild new machine:
# nixos-rebuild --ask-sudo-password --no-reexec --target-host <machine> boot

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
          {
            file = "/etc/nixos/flake.nix";
            method = "symlink";
          }
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
            {
              directory = ".gnupg";
              mode = "0700";
            }
            {
              directory = ".ssh";
              mode = "0700";
            }
            {
              directory = ".local/share/keyrings";
              mode = "0700";
            }
            ".vscode"
            ".cache"
            ".config"
            ".local/share"
            ".local/state/nix"
            ".local/state/home-manager"
            ".mozilla"
            ".thunderbird"
          ];
          files = [
            ".bash_history"
            ".git-credentials"
          ];
        };
      };
    };
    systemPackages = [
      (pkgs.writeShellApplication {
        name = "passwd-imp";
        text = ''
          user="''${1:-$USER}"
          passwd="/persistent/user/$user/passwd"

          read -srp "Enter New User Password: " p1
          echo ""
          read -srp "Password (again): " p2
          echo ""

          if [[ "$p1" != "$p2" ]]; then
            echo "Passwords do not match! Exiting ..." >&2
            exit 1
          elif [[ "$p1" == "" ]]; then
            echo "Empty password. Exiting ..." >&2
            exit 2
          fi

          if mkpasswd -m sha-512 "$p1" | sudo tee "$passwd" &>/dev/null; then
            sudo chmod 0600 "$passwd"
            echo ""
            echo "New password written to $passwd"
          else
            echo "Failed to update passwd file. Exiting ..." >&2
            exit 3
          fi
        '';
      })
    ];
  };

  boot.initrd.systemd = {
    services.impermance-btrfs-rolling-root = {
      description = "Archiving existing BTRFS root subvolume and creating a fresh one";
      # Specify dependencies explicitly
      unitConfig.DefaultDependencies = false;
      # The script needs to run to completion before this service is done
      serviceConfig = {
        Type = "oneshot";
        # NOTE: to be able to see errors in your script do this
        StandardOutput = "journal+console";
        StandardError = "journal+console";
      };
      # This service is required for boot to succeed
      requiredBy = [ "initrd.target" ];
      # Should complete before any file systems are mounted
      before = [ "sysroot.mount" ];

      # Wait until the root device is available
      # If you're altering a different device, specify its device unit explicitly.
      # see: systemd-escape(1)
      requires = [ "initrd-root-device.target" ];
      after = [
        "initrd-root-device.target"
        # Allow hibernation to resume before trying to alter any data
        "local-fs-pre.target"
      ];

      # The body of the script. Make your changes to data here
      script = ''
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
    };
    extraBin = {
      # "mkfs.ext4" = "${pkgs.e2fsprogs}/bin/mkfs.ext4";
      "mkdir" = "${pkgs.coreutils}/bin/mkdir";
      "date" = "${pkgs.coreutils}/bin/date";
      "stat" = "${pkgs.coreutils}/bin/stat";
      "mv" = "${pkgs.coreutils}/bin/mv";
      "find" = "${pkgs.findutils}/bin/find";
      "btrfs" = "${pkgs.btrfs-progs}/bin/btrfs";
      # mount & umount already exist
    }; # NOTE: path = [...]; doesnt work for initrd, use full paths in your script or extraBin
  };

  users = {
    mutableUsers = false;
    users.excalibur = {
      hashedPasswordFile = "/persistent/user/excalibur/passwd";
    };
  };
}
