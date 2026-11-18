{ config, lib, ... }:

{
  containers.technitium = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "br0";
    # Preserve the backing directory used by systemd's DynamicUser and StateDirectory.
    bindMounts."/var/lib/private/technitium-dns-server" = {
      hostPath = "/var/lib/private/technitium-dns-server";
      isReadOnly = false;
    };

    config = { lib, ... }: {
      networking = {
        hostName = "technitium";
        useHostResolvConf = lib.mkForce false;
        nameservers = [ "192.168.9.1" ];
        nftables.enable = true;
        firewall.interfaces = {
          vlan20 = {
            allowedTCPPorts = [ 53 5380 ];
            allowedUDPPorts = [ 53 ];
          };
          vlan30 = {
            allowedTCPPorts = [ 53 ];
            allowedUDPPorts = [ 53 ];
          };
        };
      };

      networking.interfaces.eth0.useDHCP = false;
      systemd.network = {
        enable = true;
        netdevs = {
          "20-br0" = {
            netdevConfig = { Name = "br0"; Kind = "bridge"; };
            bridgeConfig = { STP = true; VLANFiltering = true; };
          };
          "20-vlan20" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "vlan20";
            };
            vlanConfig.Id = 20;
          };
          "20-vlan30" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "vlan30";
            };
            vlanConfig.Id = 30;
          };
        };
        networks = {
          "30-eth0" = {
            matchConfig.Name = "eth0";
            networkConfig.Bridge = "br0";
            linkConfig.RequiredForOnline = "enslaved";
            bridgeVLANs = [
              {
                VLAN = 20;
              }
              {
                VLAN = 30;
              }
            ];
          };
          "40-br0" = {
            matchConfig.Name = "br0";
            networkConfig.LinkLocalAddressing = false;
            bridgeVLANs = [
              {
                VLAN = 20;
              }
              {
                VLAN = 30;
              }
            ];
            vlan = [ "vlan20" "vlan30" ];
            linkConfig.RequiredForOnline = false;
          };
          "50-vlan20" = {
            matchConfig.Name = "vlan20";
            networkConfig = {
              DHCP = false;
              IPv6AcceptRA = false;
              Address = [ "192.168.9.7/24" "fd09::7/64" ];
              Gateway = "192.168.9.1";
            };
            linkConfig.RequiredForOnline = "routable";
          };
          "50-vlan30" = {
            matchConfig.Name = "vlan30";
            networkConfig = {
              DHCP = false;
              IPv6AcceptRA = false;
              Address = [ "192.168.8.7/24" "fd09:0:0:30::7/64" ];
            };
            linkConfig.RequiredForOnline = "routable";
          };
        };
      };

      services.resolved.enable = lib.mkForce false;
      services.technitium-dns-server.enable = true;
      system.stateVersion = config.system.stateVersion;
    };
  };

  systemd.network.networks."30-vb-technitium" = {
    matchConfig.Name = "vb-technitium";
    networkConfig.Bridge = "br0";
    linkConfig.RequiredForOnline = "enslaved";
    bridgeVLANs = [
      {
        VLAN = 20;
      }
      {
        VLAN = 30;
      }
    ];
  };
}
