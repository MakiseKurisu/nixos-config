{ config, lib, pkgs, ... }:

{
  services = {
    nfs.server = {
      enable = true;
    };

    # make shares visible for windows 10 clients
    samba-wsdd.enable = true;
    samba = {
      enable = true;
      extraConfig = ''
        workgroup = WORKGROUP
        server string = nas
        netbios name = nas
        security = user 
        #use sendfile = yes
        #max protocol = smb2
        # note: localhost is the ipv6 localhost ::1
        hosts allow = 192.168.9. 10.0.32. 127.0.0.1 localhost
        hosts deny = 0.0.0.0/0
        guest account = nobody
        map to guest = bad user
      '';
      openFirewall = true;
      securityType = "user";
    };
  };

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
      # wsdd
      5357
      # NFSv4
      2049
    ];
    allowedUDPPorts = [
      # wsdd
      3702
    ];
  };
}
