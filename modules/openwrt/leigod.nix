{
  arch,
  ...
}:

{
  packages = [
    "luci-lua-runtime"
    "luci-compat"
    "luci-lib-ipkg"
  ];
  etc = {
    "rc.local".text = ''
      (
        if [ ! -f /usr/sbin/leigod/version ]; then
          # wait for network to be online
          sleep 120
          case "${arch}" in
          x86_64)
            wget -O /tmp/leigod-acc.ipk https://github.com/miaoermua/luci-app-leigod-acc/releases/download/1.3.0.30-1/leigod-acc_1.3.0.30-1_x86_64.ipk
            ;;
          aarch64*)
            ;;
          esac
          opkg update
          okpg install /tmp/leigod-acc.ipk
        fi
        if [ ! -f /etc/init.d/acc ]; then
          # wait for network to be online
          sleep 120
          wget -O /tmp/luci-app-leigod-acc.ipk https://github.com/miaoermua/luci-app-leigod-acc/releases/download/1.3.0.30-1/luci-app-leigod-acc_1-3_all.ipk
          opkg update
          okpg install /tmp/luci-app-leigod-acc.ipk
        fi
        if [ ! -f /usr/sbin/leigod/leigod-helper.sh ]; then
          # wait for network to be online
          sleep 120
          wget -O /usr/sbin/leigod/leigod-helper.sh https://github.com/miaoermua/leigod-helper/raw/57365ac086c14f7144e2a0b0579440809e248e52/leigod-helper.sh
          chmod +x /usr/sbin/leigod/leigod-helper.sh
        fi
      )&
    '';
    "firewall.user".text = ''
      #iptables -t nat -D PREROUTING -j GAMEACC
      #iptables -t mangle -D PREROUTING -j GAMEACC
      #iptables -t filter -D INPUT -j GAMEACC
      #
      #iptables -t mangle -A PREROUTING --src 192.168.9.20 ! --dest 192.168.0.0/16 -p tcp -j TPROXY --tproxy-mark 0x99/0x99 --on-ip 10.20.30.40 --on-port 6699
      #iptables -t mangle -A PREROUTING --src 192.168.9.20 ! --dest 192.168.0.0/16 -p udp -j TPROXY --tproxy-mark 0x99/0x99 --on-ip 10.20.30.40 --on-port 6699
      #iptables -t mangle -D PREROUTING --src 192.168.9.20 ! --dest 192.168.0.0/16 -p tcp -j TPROXY --tproxy-mark 0x99/0x99 --on-ip 10.20.30.40 --on-port 6699
      #iptables -t mangle -D PREROUTING --src 192.168.9.20 ! --dest 192.168.0.0/16 -p udp -j TPROXY --tproxy-mark 0x99/0x99 --on-ip 10.20.30.40 --on-port 6699
      #nft add rule inet fw4 dstnat_lan \
      #  meta l4proto tcp \
      #  ip saddr 192.168.9.20 \
      #  ip daddr != 192.168.0.0/16 \
      #  tproxy ip to 10.20.30.40:6699 \
      #  meta mark set 0x99 \
      #  comment "TPROXY TCP streams"
      #nft add rule inet fw4 dstnat_lan \
      #  meta l4proto udp \
      #  ip saddr 192.168.9.20 \
      #  ip daddr != 192.168.0.0/16 \
      #  tproxy ip to 10.20.30.40:6699 \
      #  meta mark set 0x99 \
      #  comment "TPROXY UDP packets"
    '';
  };

  uci = {
    settings = {
      accelerator = {
        system.base = {
          url = "https://opapi.nn.com/speed/router/plug/check";
          heart = "https://opapi.nn.com/speed/router/heartbeat";
          base_url = "https://opapi.nn.com/speed";
          enabled = true;
          tun = false;
          neigh = "br-lan.20";
        };
        hardware.device = {
          "82a0f6244c88" = 5;
          "5a95f990e8af" = 5;
          "74c14f60e983" = 7;
          "c4411ef8177e" = 9;
        };
        acceleration = {
          Phone.state = 2;
          PC.state = 2;
          Game.state = 2;
          Unknown.state = 2;
        };
      };
      upnpd = { };
    };
  };
}
