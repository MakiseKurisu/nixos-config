{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  networking = {
    firewall = {
      allowedTCPPorts = [
        53 # systemd-resolved
        80 # nginx
        443 # nginx
        1080 # dante
      ];
      allowedUDPPorts = [
        53 # systemd-resolved
      ];
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "admin@protoducer.com";
    };
  };

  services = {
    cloudflare-ddns = {
      enable = true;
      domains = [
        "${config.networking.hostName}.protoducer.com"
      ];
      credentialsFile = config.sops.templates."cloudflare_ddns.env".path;
    };

    dante = {
      enable = true;
      config =
        let
          interface = if (pkgs.stdenv.hostPlatform.system == "x86_64-linux") then "ens3" else "enp0s6";
        in
        ''
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

    librespeed = {
      enable = true;
      domain = "${config.networking.hostName}.protoducer.com";
      frontend = {
        enable = true;
        contactEmail = "admin@protoducer.com";
      };
    };

    nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      virtualHosts =
        let
          ssl = {
            enableACME = true;
            kTLS = true;
          };
          http =
            host:
            host
            // {
              rejectSSL = true;
            };
          https =
            host:
            host
            // ssl
            // {
              forceSSL = true;
            };
        in
        {
          "_" = http { locations."/".return = "404"; };
          "${config.networking.hostName}.protoducer.com" = https { };
        };
    };

    resolved = {
      enable = true;
      extraConfig = ''
        DNSStubListenerExtra=10.0.20.1
        DNSStubListenerExtra=fd20::1
      '';
    };
  };
}
