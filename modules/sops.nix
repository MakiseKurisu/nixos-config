{ config, lib, pkgs, inputs, options, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${inputs.secrets}/nixos.yaml";
    secrets = {
      v2ray_address = {
        restartUnits = [ "v2ray.service" ];
      };
      v2ray_port = {
        restartUnits = [ "v2ray.service" ];
      };
      v2ray_id = {
        restartUnits = [ "v2ray.service" ];
      };
      p15_private_key = {
        restartUnits = [ 
          "wg-quick-wg0.service"
          "wireguard-wg2.service"
        ];
      };
      wg2_private_key = {
        restartUnits = [ "wireguard-wg2.service" ];
      };
      clash_provider = {
        restartUnits = [ "mihomo.service" ];
      };
      minimax_auth_token = { };
    };
    templates = {
      "v2ray.json" = {
        mode = "0444";
        content = ''
          {
            "inbounds":[
              {
                "port": 7899,
                "protocol": "socks",
                "settings": { "udp": true }
              }
            ],
            "outbounds": [
              {
                "protocol": "vmess",
                "settings":
                {
                  "udp": true,
                  "vnext": [
                    {
                      "address": "${config.sops.placeholder.v2ray_address}",
                      "port": ${config.sops.placeholder.v2ray_port},
                      "users": [
                          {
                              "id": "${config.sops.placeholder.v2ray_id}"
                          }
                        ]
                    }
                  ]
                }
              }
            ]
          }
        '';
      };
      "mihomo.yaml" = {
        mode = "0444";
        content = ''
          allow-lan: true
          mode: Global
          find-process-mode: off
          log-level: info
          unified-delay: true
          tcp-concurrent: true
          global-client-fingerprint: random
          geodata-mode: true
          geodata-loader: standard
          geo-auto-update: true

          external-controller: 0.0.0.0:9090
          external-controller-cors:
            allow-origins:
              - "*"
            allow-private-network: true

          profile:
            store-selected: true
            store-fake-ip: true

          dns:
            enable: false

          port: 7890
          socks-port: 7891
          mixed-port: 7892
          redir-port: 7893
          tproxy-port: 7894

          proxy-providers:
            clash:
              type: http
              url: "${config.sops.placeholder.clash_provider}"
              path: /var/lib/private/mihomo/clash.yaml
              interval: 300

          rule-providers:
            clash:
              type: file
              path: /var/lib/private/mihomo/clash.yaml
              interval: 300
              behavior: classical

          proxy-groups:
            - name: "DEFAULT"
              type: url-test
              url: "https://www.gstatic.com/generate_204"
              interval: 300
              use:
              - clash
        '';
      };
    };
  };
}
