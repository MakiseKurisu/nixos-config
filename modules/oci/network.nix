{ inputs, config, lib, pkgs, ... }:

{
  networking = {
    nat = {
      enable = true;
      enableIPv6 = true;
      internalInterfaces = [ "wg0" ];
      externalInterface = if (pkgs.stdenv.hostPlatform.system == "x86_64-linux") 
                          then "ens3"
                          else "enp0s6";
    };
  };

  systemd = {
    network = {
      config = {
        routeTables = {
          enp1s0 = 100;
        };
        addRouteTablesToIPRoute2 = true;
      };
    };

    services = {
      enp1s0 = {
        description = "Configure source-based routing";
        wantedBy = [ "multi-user.target" ];
        wants = [
          "network-online.target"
          "cloud-init.service"
        ];
        after = [
          "cloud-init.service"
        ];
        requires = [
          "network.target"
        ];
        bindsTo = [
          "sys-subsystem-net-devices-enp1s0.device"
        ];
        script = ''
          ${lib.getExe' pkgs.iproute2 "ip"} rule add from 10.0.1.0/24 table 100
          ${lib.getExe' pkgs.iproute2 "ip"} route add 10.0.1.0/24 dev enp1s0 table 100
          ${lib.getExe' pkgs.iproute2 "ip"} route add default via 10.0.1.1 dev enp1s0 table 100
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
          TimeoutSec = "infinity";
          StandardOutput = "journal+console";
        };
      };
    };
  };
}
