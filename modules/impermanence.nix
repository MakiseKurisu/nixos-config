{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  fileSystems = {
    "/persistent".neededForBoot = true;
  };

  environment.persistence = {
    "/persistent/system" = {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/apt"
        { directory = "/var/lib/aria2"; user = "aria2"; group = "aria2"; mode = "0770"; }
        { directory = "/var/lib/bluetooth"; mode = "0700"; }
        { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "0750"; }
        "/var/lib/containers"
        "/var/lib/cups"
        { directory = "/var/lib/fail2ban"; mode = "0750"; }
        { directory = "/var/lib/fwupd"; user = "fwupd-refresh"; group = "fwupd-refresh"; }
        { directory = "/var/lib/geoclue"; user = "geoclue"; group = "geoclue"; }
        { directory = "/var/lib/incus"; mode = "0711"; }
        { directory = "/var/lib/iwd"; mode = "0700"; }
        "/var/lib/jellyfin"
        "/var/lib/libvirt"
        "/var/lib/lxc"
        "/var/lib/lxcfs"
        { directory = "/var/lib/mpd"; user = "mpd"; group = "mpd"; }
        "/var/lib/NetworkManager"
        "/var/lib/nfs"
        "/var/lib/nixos"
        "/var/lib/nixos-containers"
        { directory = "/var/lib/private"; mode = "0700"; }
        "/var/lib/samba"
        "/var/lib/systemd"
        { directory = "/var/lib/waydroid"; mode = "0777"; }
        "/var/log"
      ];
      files = [
        "/etc/adjtime"
        "/etc/machine-id"
        "/etc/nixos/flake.nix"
        "/var/lib/logrotate.status"
      ];
    };
    "/persistent/user/excalibur" = {
      hideMounts = true;
      users.excalibur = {
        directories = [
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          "Templates"
          "Public"
          "Desktop"
          "Games"
          { directory = ".gnupg"; mode = "0700"; }
          { directory = ".ssh"; mode = "0700"; }
          { directory = ".local/share/keyrings"; mode = "0700"; }
          ".local/share/direnv"
          ".bash_history"
        ];
        files = [
          ".git-credentials"
          ".config/nix/nix.conf"
        ];
      };
    };
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir -p /impermanence
    mount -o subvol=/ /dev/disk/by-label/nixos /impermanence

    if [[ -e /impermanence/root ]]; then
        mkdir -p /impermanence/old_roots
        timestamp=$(date --date="@$(stat -c %Y /impermanence/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /impermanence/root "/impermanence/old_roots/$timestamp"
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

    btrfs subvolume create /impermanence/root
    umount /impermanence
  '';
}