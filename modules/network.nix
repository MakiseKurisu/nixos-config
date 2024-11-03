{ config, lib, pkgs, ... }:

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
    };
  };
}
