{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-KINGSTON_OM8PDP31024B-A01_50026B728286CDB7";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "--checksum blake2"
                ];
                mountpoint = "/media/root";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
                subvolumes = {
                  "/@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  "/@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  "/@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
