{ arch
, release
, ...
}:

{
  imports = [
    ./mwan3.nix
    (import ./leigod.nix {
      inherit arch;
    })
  ];

  packages = [
    "luci-app-ddns"
    "luci-app-sqm"
    "luci-proto-wireguard"
    "luci-app-wol"
    "luci-app-nlbwmon"
    "openssh-sftp-server"
    "snort3"
    "openappid"
    "coreutils-sort"

    # needed by ddns
    "curl"
    # busybox's tar does not support xvf  
    "tar"
  ];
  etc = {
    "rc.local".text = ''
      (
        if [ ! -f /usr/local/bin/udp2raw ]; then
          # wait for network to be online
          sleep 120
          # we need to download tar because Nix can't convert this archive into input:
          # https://github.com/NixOS/nix/pull/11195
          wget -O /tmp/udp2raw_binaries.tar.gz https://github.com/wangyu-/udp2raw/releases/download/20230206.0/udp2raw_binaries.tar.gz
          cd /tmp
          tar xvf udp2raw_binaries.tar.gz
          cd $OLDPWD
          mkdir -p /usr/local/bin
          case "${arch}" in
          x86_64)
            mv /tmp/udp2raw_amd64_hw_aes /usr/local/bin/udp2raw
            ;;
          aarch64*)
            mv /tmp/udp2raw_arm_asm_aes /usr/local/bin/udp2raw
            ;;
          esac
          chmod +x /usr/local/bin/udp2raw
          chown root:root /usr/local/bin/udp2raw
        fi
        /usr/local/bin/udp2raw -c -l 127.0.0.1:51818 -r 167.71.206.148:51820 >/dev/null &
      )&
      (
        # pppoe-wan may not be ready at boot
        sleep 120
        service ddns start
      )&
    '';
  };

  uci = {
    settings = {
      nlbwmon = {
        nlbwmon = [
          {
            netlink_buffer_size = 524288;
            commit_interval = "10m";
            refresh_interval = "30s";
            database_directory = "/usr/lib/nlbwmon";
            database_generations = 12;
            database_interval = 1;
            database_limit = 100000;
            protocol_database = "/usr/share/nlbwmon/protocols";
            database_compress = true;
            local_network = [
              "192.168.0.0/16"
              "guest"
              "lan"
            ];
          }
        ];
      };
      ddns = {
        ddns.global = {
          ddns_dateformat = "%F %R";
          ddns_loglines = 250;
          ddns_rundir = "/var/run/ddns";
          ddns_logdir = "/var/log/ddns";
        };
        service = {
          protoducer = {
            service_name = "now-dns.com";
            use_ipv6 = 1;
            enabled = 1;
            lookup_host = "protoducer-cn-szx-6.vpndns.net";
            domain = "protoducer-cn-szx-6.vpndns.net";
            username._secret = "ddns_username";
            password._secret = "ddns_password";
            use_syslog = 2;
            dns_server = "ns1.now-dns.com";
            ip_source = "interface";
            interface = "br-lan.20";
            check_interval = 5;
            check_unit = "minutes";
            force_unit = "minutes";
            retry_unit = "seconds";
            ip_interface = "br-lan.20";
          };
        };
      };
      sqm = {};
      etherwake = {};
      snort = {
        snort.snort = {
          enabled = true;
          manual = false;
          home_net = "192.168.8.0/24 192.168.9.0/24";
          external_net = "!$HOME_NET";
          openappid = true;
          interface = "wwan0";
          mode = "ips";
          method = "nfq";
          logging = true;
          log_dir = "/var/log";
          config_dir = "/etc/snort";
        };
      };
    };
  };
}
