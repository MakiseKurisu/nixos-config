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
    mwan-slow = {
      autoStart = true;
      bindMounts = {
        "/media/raid/aria2" = {
          hostPath = "/media/raid/aria2";
          isReadOnly = false;
        };
        "/var/lib/aria2" = {
          hostPath = "/var/lib/aria2";
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
                6800  # webui
                6888  # bt
              ];
              allowedUDPPorts = [
                6888  # bt dht
              ];
            };
            nftables.enable = true;
            useHostResolvConf = lib.mkForce false;
          };

          services = {
            aria2 = {
              enable = true;
              rpcSecretFile = pkgs.writeText "aria2-rpc-token.txt" "P3TERX";
              openPorts = true;
              serviceUMask = "0007";
              settings = {
                bt-prioritize-piece = "head,tail";
                bt-remove-unselected-file = true;
                check-integrity = true;
                continue = true;
                dht-listen-port = 6888;
                dir = "/media/raid/aria2";
                file-allocation = "falloc";
                http-accept-gzip = true;
                input-file = "/var/lib/aria2/aria2.session";
                listen-port = [ { from = 6888; to = 6888; } ];
                max-concurrent-downloads = 100;
                max-connection-per-server = 10;
                max-overall-upload-limit = "64K";
                rpc-listen-all = true;
                save-session-interval = 10;
                seed-ratio = 0.1;
                seed-time = 0;
                show-console-readout = false;
                summary-interval = 0;
              };
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
                  Address = "192.168.9.5/24";
                };
                linkConfig = {
                  RequiredForOnline = false;
                  MACAddress = "f2:83:95:be:e4:40";
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
      "30-vb-mwan-slow" = {
        matchConfig.Name = "vb-mwan-slow";
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
