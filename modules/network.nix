{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    nftables.enable = true;
    wireless.iwd.enable = true;
  };

  systemd.network = {
    enable = true;
    config.networkConfig = {
      SpeedMeter = true;
    };
    netdevs = {
      "20-vlan1" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan1";
        };
        vlanConfig.Id = 1;
      };
      "20-vlan10" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan10";
        };
        vlanConfig.Id = 10;
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
      "20-vlan40" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan40";
        };
        vlanConfig.Id = 40;
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
    };
  };
}
