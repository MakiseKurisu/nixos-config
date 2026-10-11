{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  hostStateVersion = config.system.stateVersion;
in
{
  containers = {
    mwan-fast = let
        mihomo = config.sops.templates."mihomo.yaml".path;
        v2ray = config.sops.templates."v2ray.json".path;
      in {
      autoStart = true;
      bindMounts = {
        "${mihomo}" = {
          hostPath = "${mihomo}";
        };
        "${v2ray}" = {
          hostPath = "${v2ray}";
        };
        "/var/lib/private/mihomo" = {
          hostPath = "/var/lib/private/mihomo";
          isReadOnly = false;
        };
      };
      ephemeral = true;
      config =
        {
          config,
          lib,
          pkgs,
          ...
        }@inputs':
        {
          environment.enableAllTerminfo = true;

          networking = {
            firewall = {
              allowedTCPPorts = [
                7899 # v2ray / dante
                9090 # mihomo
              ];
              allowedTCPPortRanges = [
                # mihomo
                {
                  from = 7890;
                  to = 7894;
                }
              ];
            };
            nftables.enable = true;
            useHostResolvConf = lib.mkForce false;
          };

          services = {
            mihomo = {
              enable = true;
              configFile = "${mihomo}";
              webui = pkgs.metacubexd;
            };

            v2ray = {
              enable = false;
              configFile = "${v2ray}";
            };

            resolved.enable = true;
          };

          networking.interfaces.eth0.useDHCP = false;
          systemd.network = {
            enable = true;
            netdevs = {
              "20-br0" = {
                netdevConfig = {
                  Kind = "bridge";
                  Name = "br0";
                };
                bridgeConfig = {
                  STP = true;
                  VLANFiltering = true;
                };
              };
              "20-vlan20" = {
                netdevConfig = {
                  Kind = "vlan";
                  Name = "vlan20";
                };
                vlanConfig.Id = 20;
              };
            };
            networks = {
              "01-lo" = {
                matchConfig.Name = "lo";
                networkConfig = {
                  LinkLocalAddressing = "ipv6";
                  Address = "127.0.0.1/8";
                };
              };
              "30-eth0" = {
                matchConfig.Name = "eth0";
                networkConfig.Bridge = "br0";
                linkConfig.RequiredForOnline = "enslaved";
                bridgeVLANs = [
                  {
                    VLAN = 20;
                  }
                ];
              };
              "40-br0" = {
                matchConfig.Name = "br0";
                networkConfig = {
                  LinkLocalAddressing = false;
                };
                bridgeConfig = { };
                bridgeVLANs = [
                  {
                    VLAN = 20;
                  }
                ];
                vlan = [
                  "vlan20"
                ];
                linkConfig = {
                  RequiredForOnline = false;
                };
              };
              "50-vlan20" = {
                matchConfig.Name = "vlan20";
                networkConfig = {
                  DHCP = true;
                  Domains = "protoducer.org";
                  Address = "192.168.9.4/24";
                };
                linkConfig = {
                  RequiredForOnline = false;
                  MACAddress = "a6:80:59:cd:08:08";
                };
              };
            };
          };

          system.stateVersion = lib.mkDefault hostStateVersion;
        };
      hostBridge = "br0";
      privateNetwork = true;
    };
  };

  systemd = {
    network.networks = {
      "30-vb-mwan-fast" = {
        matchConfig.Name = "vb-mwan-fast";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
        bridgeVLANs = [
          {
            VLAN = 20;
          }
        ];
      };
    };
  };
}
