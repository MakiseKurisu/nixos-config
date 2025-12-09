# Install VM with
#  nix run github:nix-community/nixos-anywhere -- --flake .#<machine> \
#    --generate-hardware-config nixos-facter machines/oci/<machine>/facter.json \
#    --kexec "https://github.com/nix-community/nixos-images/releases/download/nixos-24.11/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz" \
#    --target-host <user>@<host>
# Run following command in Cloud Console to enable zram
#   modprobe zram && sleep 1 && zramctl /dev/zram0 --algorithm zstd --size "900MiB" && mkswap -U clear /dev/zram0 && swapon --discard --priority 100 /dev/zram0

{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../../modules/base-base.nix
    ../../../modules/kernel.nix
    ../../../modules/oci.nix
    ../../../modules/users-base.nix
    inputs.nixos-facter-modules.nixosModules.facter
  ];

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      amneziawg
    ];
  };

  facter = {
    reportPath = ./facter.json;
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        1080 #dante
      ];
      allowedUDPPorts = [
        51820 #amneziawg
      ];
    };

    wireguard = {
      useNetworkd = false;
      interfaces = {
        wg0 = {
          type = "amneziawg";
          privateKeyFile = "/var/lib/wireguard/wg0.key";
          mtu = 1280;
          listenPort = 51820;
          ips = [
            "10.0.20.1/24"
            "fd20::1/64"
          ];
          extraOptions = {
            Jc = 1;
            Jmin = 10;
            Jmax = 50;
            S1 = 16;
            S2 = 48;
          };
          peers = [
            {
              publicKey = "NaKi5MmgIfiul+zfZQHih8PBDqAuhCxO8x+4r+LAwDI=";
              allowedIPs = [
                "10.0.20.2/32"
                "fd20::2/128"
              ];
            }
            {
              publicKey = "T8RsOpzg6HInLTcQA9uev95KPZohQ2GE7JZv84Q2QTk=";
              allowedIPs = [
                "10.0.20.3/32"
                "fd20::3/128"
              ];
            }
          ];
        };
      };
    };
  };

  services = {
    dante = {
      enable = true;
      config = ''
        internal: wg0 port = 1080
        external: ens3
        clientmethod: none
        socksmethod: none
        client pass {
          from: 0/0 to: 0/0
          log: connect disconnect error
        }
        socks pass {
          from: 0/0 to: 0/0
          log: connect disconnect error
        }
      '';
    };

    iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };

  networking.hostName = "amd1";
  system.stateVersion = "25.11";
}
