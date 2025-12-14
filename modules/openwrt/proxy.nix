{ lib
, gfwlist2dnsmasq
, service_ip
, ...
}:

{
  packages = [
    "luci-app-https-dns-proxy"
    "redsocks"
    "coreutils-base64"

    "hev-socks5-tunnel"
  ];

  providers = {
    dnsmasq = "dnsmasq-full";
  };

  etc = {
    "redsocks.conf".text = ''
      base {
        daemon = on;
        redirector = iptables;
        rlimit_nofile = 65535;
        redsocks_conn_max = 65535;
        //log_info = on;
      }

      redsocks {
        local_ip = 192.168.9.1;
        local_port = 20002;
        ip = 10.0.20.1;
        port = 1080;
        type = socks5;
        listenq = 512;
      }

      redsocks {
        local_ip = 192.168.9.1;
        local_port = 20001;
        ip = 10.0.21.1;
        port = 1080;
        type = socks5;
        listenq = 512;
      }

      redsocks {
        local_ip = 192.168.9.1;
        local_port = 20003;
        ip = 192.168.2.4;
        port = 7891;
        type = socks5;
        listenq = 512;
      }

      redsocks {
        local_ip = 192.168.9.1;
        local_port = 20000;
        ip = ${service_ip};
        port = 7891;
        type = socks5;
        listenq = 512;
      }
    '';
    "firewall.user".text = ''
      # create nftset
      nft "add set inet fw4 gfwlist { type ipv4_addr; flags interval; }"
      nft "add set inet fw4 gfwlist6 { type ipv6_addr; flags interval; }"
      nft "add set inet fw4 proxy_bypass { type ipv4_addr; flags interval; }"
      nft "add set inet fw4 proxy_force { type ipv4_addr; flags interval; }"
      # add telegram ip
      nft "add element inet fw4 gfwlist { 91.108.4.0/22, 91.108.8.0/22, 91.108.56.0/22, 109.239.140.0/24, 149.154.160.0/20 }"
      # add routing rules
      nft "add chain inet fw4 dstnat_lan"
      nft "add rule inet fw4 dstnat iifname { br-lan.20 } jump dstnat_lan comment \"!fw4: Handle guest IPv4/IPv6 dstnat traffic\""
      sh /etc/proxy/enable_proxy

      nft "add chain inet fw4 dstnat_output { type nat hook output priority -100; policy accept; }"
      nft "add rule inet fw4 dstnat_output meta l4proto tcp ip daddr @gfwlist dnat ip to 192.168.9.1:20000"
      nft "add rule inet fw4 dstnat_output meta l4proto tcp ip6 daddr @gfwlist6 dnat ip6 to [fd09::1]:20000"
    '';
    "crontabs/root".text = ''
      0 0 * * * sh /etc/proxy/update_gfwlist
    '';
    "dnsmasq.d/github.conf".text = ''
      server=/githubusercontent.com/192.168.9.1#5053
      nftset=/githubusercontent.com/4#inet#fw4#gfwlist,6#inet#fw4#gfwlist6
      server=/github.com/192.168.9.1#5053
      nftset=/github.com/4#inet#fw4#gfwlist,6#inet#fw4#gfwlist6
    '';
    "proxy/gfwlist2dnsmasq.sh".text = lib.readFile "${gfwlist2dnsmasq}/gfwlist2dnsmasq.sh";
    "proxy/whitelist.conf".text = '''';
    "proxy/gfwlist.conf".text = lib.readFile ./gfwlist.conf;
    "proxy/blocklist.conf".text = lib.readFile ./blocklist.conf;
    "proxy/update_gfwlist".text = ''
      #!/usr/bin/env sh
      set -euo pipefail
      touch /root/whitelist.conf /root/gfwlist.conf /root/blocklist.conf
      cp /root/whitelist.conf /root/gfwlist.conf /root/blocklist.conf /tmp/
      echo | tee -a /tmp/whitelist.conf | tee -a /tmp/gfwlist.conf | tee -a /tmp/blocklist.conf
      cat /etc/proxy/whitelist.conf >> /tmp/whitelist.conf
      cat /etc/proxy/gfwlist.conf >> /tmp/gfwlist.conf
      cat /etc/proxy/blocklist.conf >> /tmp/blocklist.conf
      echo | tee -a /tmp/whitelist.conf | tee -a /tmp/gfwlist.conf | tee -a /tmp/blocklist.conf
      curl -Ls https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt | sed -e "s/^full://g" -e "s/^regexp:.*//g" >> /tmp/whitelist.conf
      curl -Ls https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt | sed -e "s/^full://g" -e "s/^regexp:.*//g" >> /tmp/gfwlist.conf
      curl -Ls https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/reject-list.txt | sed -e "s/^full://g" -e "s/^regexp:.*//g" >> /tmp/blocklist.conf

      sh /etc/proxy/gfwlist2dnsmasq.sh -d 192.168.9.1 -p 5053 --nftset4 gfwlist --nftset6 gfwlist6 --exclude-domain-file /tmp/whitelist.conf --extra-domain-file /tmp/gfwlist.conf -o /etc/dnsmasq.d/gfwlist.conf
      grep -v "^\s*$" /tmp/blocklist.conf | sed "s/\(.*\)/address=\/\1\/127.0.0.1/g" >/etc/dnsmasq.d/blocklist.conf
      service dnsmasq restart
    '';
    "proxy/enable_proxy".text = ''
      #!/usr/bin/env sh

      sh /etc/proxy/disable_proxy

      nft "add rule inet fw4 dstnat_lan meta l4proto tcp ip saddr @proxy_bypass accept"
      nft "add rule inet fw4 dstnat_lan meta l4proto tcp ip saddr @proxy_force dnat ip to 192.168.9.1:20000"
      nft "add rule inet fw4 dstnat_lan meta l4proto tcp ip daddr @gfwlist dnat ip to 192.168.9.1:20000"
      nft "add rule inet fw4 dstnat_lan meta l4proto tcp ip6 daddr @gfwlist6 dnat ip6 to [fd09::1]:20000"
    '';
    "proxy/disable_proxy".text = ''
      #!/usr/bin/env sh

      while read -r; do
        if echo "$REPLY" | grep -q -e @proxy_bypass -e @proxy_force -e @gfwlist -e @gfwlist6; then
          nft delete rule inet fw4 dstnat_lan h$(echo "$REPLY" | cut -d 'h' -f 2)
        fi
      done < <(nft -a list chain inet fw4 dstnat_lan)
    '';
    "proxy/tunnel.yaml".text = ''
      tunnel:
        name: tun0
        mtu: 8500
        multi-queue: true
        ipv4: 10.0.40.1
        ipv6: 'fd40::1'

      socks5:
        port: 7891
        address: ${service_ip}
        udp: 'udp'
        mark: 438
    ''
  };

  uci = {
    settings = {
      https-dns-proxy = {
        main.config = {
          dnsmasq_config_update = "-";
          procd_trigger_wan6 = 0;
          force_dns = 0;
        };
        https-dns-proxy = [{
          user = "nobody";
          group = "nogroup";
          listen_addr = "192.168.9.1";
          listen_port = 5053;
          bootstrap_dns = "1.1.1.1,1.0.0.1,2606:4700:4700::1111,2606:4700:4700::1001,8.8.8.8,8.8.4.4,9.9.9.9";
          resolver_url = "https://cloudflare-dns.com/dns-query";
          proxy_server = "socks5h://${service_ip}:7891";
        }];
      };

      hev-socks5-tunnel = {
        hev-socks5-tunnel.config = {
          enabled = true;
          conffile = "/etc/proxy/tunnel.yaml";
        };
      };
    };
  };
}
