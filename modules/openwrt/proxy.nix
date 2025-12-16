{ lib
, gfwlist2dnsmasq
, service_ip
, ...
}:

{
  packages = [
    "luci-app-https-dns-proxy"
    "coreutils-base64"

    "luci-app-pbr"
  ];

  providers = {
    dnsmasq = "dnsmasq-full";
  };

  etc = {
    "firewall.user".text = ''
      # create nftset
      nft "add set inet fw4 gfwlist { type ipv4_addr; flags interval; auto-merge; }"
      nft "add set inet fw4 gfwlist6 { type ipv6_addr; flags interval; auto-merge; }"
      nft "add set inet fw4 proxy_bypass { type ipv4_addr; flags interval; auto-merge; }"
      nft "add set inet fw4 proxy_force { type ipv4_addr; flags interval; auto-merge; }"
      # add telegram ip
      nft "add element inet fw4 gfwlist { 91.108.4.0/22, 91.108.8.0/22, 91.108.56.0/22, 109.239.140.0/24, 149.154.160.0/20 }"
      # add cloudflare ip
      nft "add element inet fw4 gfwlist { $(curl https://www.cloudflare.com/ips-v4/ | tr '\n' ',') }"
      nft "add element inet fw4 gfwlist6 { $(curl https://www.cloudflare.com/ips-v6/ | tr '\n' ',') }"
      # add routing rules
      nft "add rule inet fw4 mangle_output meta l4proto tcp ip daddr @gfwlist counter ct mark set 440"
      nft "add rule inet fw4 mangle_output meta l4proto tcp ip daddr @gfwlist counter meta mark set ct mark"
      nft "add rule inet fw4 mangle_output meta l4proto tcp ip6 daddr @gfwlist6 counter ct mark set 440"
      nft "add rule inet fw4 mangle_output meta l4proto tcp ip6 daddr @gfwlist6 counter meta mark set ct mark"

      nft "add rule inet fw4 mangle_prerouting meta l4proto tcp ip saddr @proxy_bypass counter accept"
      nft "add rule inet fw4 mangle_prerouting meta l4proto tcp ip saddr @proxy_force counter ct mark set 440"
      nft "add rule inet fw4 mangle_prerouting meta l4proto tcp ip saddr @proxy_force counter meta mark set ct mark"
      nft "add rule inet fw4 mangle_prerouting meta l4proto tcp ip daddr @gfwlist counter ct mark set 440"
      nft "add rule inet fw4 mangle_prerouting meta l4proto tcp ip daddr @gfwlist counter meta mark set ct mark"
      nft "add rule inet fw4 mangle_prerouting meta l4proto tcp ip6 daddr @gfwlist6 counter ct mark set 440"
      nft "add rule inet fw4 mangle_prerouting meta l4proto tcp ip6 daddr @gfwlist6 counter meta mark set ct mark"
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
    "rc.local".text = ''
      chmod +x /etc/proxy/update_gfwlist
    '';
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
          proxy_server = "socks5h://10.0.20.1:1080";
        }];
      };

      pbr = {
        pbr.config = {
          enabled = false;
	        strict_enforcement = true;
	        resolver_set = "dnsmasq.nftset";
	        resolver_instance = ["*"];
	        ipv6_enabled = true;
	        ignored_interface = "vpnserver";
	        rule_create_option = "add";
          procd_boot_trigger_delay = 5000;
          procd_reload_delay = true;
          webui_show_ignore_target = false;
          nft_rule_counter = false;
          nft_set_auto_merge = 1;
          nft_set_counter = 0;
          nft_set_flags_interval = 1;
          nft_set_flags_timeout = 0;
          nft_set_gc_interval = "";
          nft_set_policy = "performance";
          nft_set_timeout = "";
	        webui_supported_protocol = ["all" "tcp" "udp" "tcp udp" "icmp"];
        };
        include = [
          {
            path = "/usr/share/pbr/pbr.user.dnsprefetch";
            enabled = false;
          }
          {
            path = "/usr/share/pbr/pbr.user.aws";
            enabled = false;
          }
          {
            path = "/usr/share/pbr/pbr.user.netflix";
            enabled = false;
          }
        ];
      };
    };
  };
}
