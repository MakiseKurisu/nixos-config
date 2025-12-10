{ inputs, config, lib, pkgs, ... }:

{
  networking = {
    firewall = {
      allowedTCPPorts = [
        1080 #dante
      ];
    };
  };

  services = {
    dante = {
      enable = true;
      config = let
        interface = if (pkgs.stdenv.hostPlatform.system == "x86_64-linux") 
                    then "ens3"
                    else "enp0s6";
      in ''
        internal: wg0 port = 1080
        external: ${interface}
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
}
