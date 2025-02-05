# When OpenWrt is running from Incus, please add following configs:
#config:
#  raw.apparmor: |-
#    mount fstype=bpf -> /sys/fs/bpf/,
#    mount fstype=pstore -> /sys/fs/pstore/,
#    mount options=(rw,remount,noatime) -> /,
#    mount options=(rw,remount,bind) -> /tmp/ujail-*/**,
#devices:
#  eth0:
#    name: eth0
#    host_name: openwrt
#    nictype: bridged
#    parent: br0
#    type: nic
#    vlan: '1'
#    vlan.tagged: '10,20,30'
#
# Custom AppArmor rules may no longer be necessary with this commit:
# https://github.com/lxc/incus/commit/36e76aaecb1e5d8f39e453b16958fe4c7af05e5d

{ lib
, release
, target
, arch
, hostname
, ip
, ...}:
{
  deploy = {
    sshConfig = {
      StrictHostKeyChecking = "accept-new";
    };
    host = ip;
    rebootAllowance = 120;
    rollbackTimeout = 120;
  };

  packages = [
    "bash"
    "kitty-terminfo"
    "nano"
    "powertop"
    "qemu-ga"
    "kmod-i6300esb-wdt"
    "kmod-itco-wdt"
  ];

  etc = {
    "rc.local".text = ''
      powertop --auto-tune &
    '';
    "dropbear/authorized_keys".text = ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWMJsr4iwCY2yA6GyTkLfr3+EWcCKd9FYE96MdWVc0igB3ZRjMuaCup+qoeKtsIThWhrlCwdJyCGBprjSa3UJAXZ4jCRZLWzRDH0lXwmqExc729m5f4L8mJ0VpLGMMwCsiKHejNcDABHUbf04/N9jTNgAEZXqYRixkYZnagpzOKbq5UmZFvBMNmY64DPUh+Bokcws+naIpo/dnBCU3KLbqYOud+Bs+4Qa+xaHa4BqjQZ36mhwNNV0iR4URFRHt5FH2619ETV5JvmCcIVFCgMy/cixH2soBcv375JRRRNi2eoVEF+EM8xYP+RRMR8UoJIjsMmda2FuL0UXWrt7w2VioC2vn15K6oXrS2330VyJZKOpyPlER4U7gPts60KIRQvrlS8sRGiqf8IJZFOSVS3gRrQvr+xedbBUmVFYWNcrkwG8S4mJWWPX4gEabVvB0KdtBmtTeD5ALEtcWXvljDhnRaI71lI74iWBzvn2JJ0Cz0XrlUiEsGldcg6Q4KOZcDx0= yuntian@Yuntian
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNbARwJPNYn4MUPHvy7JRR7B+Yh2t50K7xUbMvdf58U1IPYOfDB818atx0MoJvvMro7H3NXateXMnFW6h111FkeTN4e6pLePIOCIyX20S9U6rq85T81ePTi9ied6SP6IEpyGEdWO73eiXbZAOj9VPnXOir3tvrKRNISz3mHp163NT7HMHRJjZ+9xCUhqPzw0VrKD3fTbrljdKk8Rfpd0wDvv2Nb6DA+nfvYME3w1ICU73Y4oP2x+Sx6epqr/FXk6vBsrKdyxPEALirCtct8LYYrt1KxTI2yfodr9kiOFgPIMwzuKPRixV2S15Eh5NwL5Hi6+RNQRXu82V8osSFUC0OypFplmTrY5yAHzDQB5DOYWlRG4KeKACd/tB2HMuW46qWIxngXYR2WSoAHFDdSuKj+fTsb21uQ+LvoQU6mnfUyYDokHuDPMi4iUlgFpcmyeNq1Dm7OD0LWLRbIdpJYgtd4aT9uT3XIQ8Ic8X/sZuNTv1jGLDhZMdV/awHtfDggtE= excalibur@main
    '';
    "opkg/distfeeds.conf".text = ''
      src/gz openwrt_core https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${release}/targets/${target}/packages
      src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${release}/packages/${arch}/base
      src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${release}/packages/${arch}/luci
      src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${release}/packages/${arch}/packages
      src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${release}/packages/${arch}/routing
      src/gz openwrt_telephony https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${release}/packages/${arch}/telephony
    '';
    "sysctl.d/90-nf_conntrack_max.conf".text = ''
      # Increase maximum active connection count
      net.nf_conntrack_max=32768
    '';
  };

  uci = {
    sopsSecrets = ./secrets.yaml;

    # leave the ucitrack and firewall packages as they are, retaining defaults if
    # freshly installed. the firewall rules are verbose and ucitrack is mostly not
    # necessary, so we don't want to include either here. we also keep luci to not
    # break the web interface, although configuration through the web ui is discouraged.
    # rpcd is needed for luci.
    retain = [
      "luci"
      "rpcd"
      "ucitrack"
      "ubootenv"
    ];

    settings = {
      firewall = {
        defaults = [{
          forward = "DROP";
          input = "DROP";
          output = "ACCEPT";
          synflood_protect = 1;
        }];
        include = [{
          path = "/etc/firewall.user";
          fw4_compatible = 1;
        }];
      };

      network = {
        interface.loopback = {
          device = "lo";
          ipaddr = "127.0.0.1";
          netmask = "255.0.0.0";
          proto = "static";
        };
        globals.globals = {
          ula_prefix = "fd09::/48";
        };
      };

      system = {
        led = [
          {
            name = "Receive";
            sysfs = "red:status";
            trigger = "netdev";
            dev = "wwan0";
            mode = "rx";
          }
          {
            name = "Transmit";
            sysfs = "green:status";
            trigger = "netdev";
            dev = "wwan0";
            mode = "tx";
          }
          {
            name = "Receive";
            sysfs = "inet:orange";
            trigger = "netdev";
            dev = "wwan0";
            mode = "rx";
          }
          {
            name = "Transmit";
            sysfs = "inet:blue";
            trigger = "netdev";
            dev = "wwan0";
            mode = "tx";
          }
          {
            name = "Power";
            sysfs = "power:blue";
            trigger = "default-on";
          }
          {
            name = "Status";
            sysfs = "power:orange";
            trigger = "heartbeat";
          }
        ];

        system = [{
          timezone = "CST-8";
          zonename = "Asia/Shanghai";
          ttylogin = 0;
          cronloglevel = 9;
          log_size = 1024;
          urandom_seed = 0;
          hostname = hostname;
        }];

        timeserver.ntp = {
          server = [
            "0.openwrt.pool.ntp.org"
            "1.openwrt.pool.ntp.org"
            "2.openwrt.pool.ntp.org"
            "3.openwrt.pool.ntp.org"
          ];
          enable_server = 1;
        };
      };

      uhttpd.uhttpd.main = {
        listen_http = [
          "0.0.0.0:80"
          "[::]:80"
        ];
        listen_https = [
          "0.0.0.0:443"
          "[::]:443"
        ];
        redirect_https = 1;
        home = "/www";
        lua_prefix = [ "/cgi-bin/luci=/usr/lib/lua/luci/sgi/uhttpd.lua" ];
        cgi_prefix = "/cgi-bin";
        ubus_prefix = "/ubus";
        cert = "/etc/uhttpd.crt";
        key = "/etc/uhttpd.key";
      };
    };
  };
}
