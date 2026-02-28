{
  config,
  lib,
  pkgs,
  ...
}:

{
  services = {
    nfs.server = {
      enable = true;
    };

    # make shares visible for windows 10 clients
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    samba = {
      enable = true;
      settings = {
        global = {
          "invalid users" = [
            "root"
          ];
          "passwd program" = "/run/wrappers/bin/passwd %u";
          security = "user";
          workgroup = "WORKGROUP";
          "server string" = "nas";
          "netbios name" = "nas";
          # "use sendfile" = "yes";
          # "max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = [
            "192.168.9."
            "10.0.32."
            "127.0.0.1"
            "localhost"
          ];
          "hosts deny" = [
            "0.0.0.0/0"
          ];
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
      };
      openFirewall = true;
    };
  };

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
      # NFSv4
      111
      2049
    ];
  };
}
