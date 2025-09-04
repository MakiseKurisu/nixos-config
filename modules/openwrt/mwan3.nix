let
  mwanInterface = {
    track_ip = [
      "xiaomi.com"
      "163.com"
      "taobao.com"
      "qq.com"
      "bilibili.com"
    ];
    flush_conntrack = [
      "ifup"
    ];
    initial_state = "online";
    family = "ipv4";
    track_method = "ping";
    reliability = 3;
    count = 1;
    size = 56;
    max_ttl = 60;
    check_quality = true;
    failure_latency = 1000;
    failure_loss = 40;
    recovery_latency = 500;
    recovery_loss = 10;
    timeout = 4;
    interval = 10;
    failure_interval = 5;
    recovery_interval = 5;
    down = 5;
    up = 5;
    enabled = true;
  };

  mwanMembers = nic: {
    "${nic}_10" = {
      interface = nic;
      metric = 10;
    };
    "${nic}_20" = {
      interface = nic;
      metric = 20;
    };
  };

  mwanPolicies = nic1: nic2: {
    "${nic1}_${nic2}" = {
      use_member = [
        "${nic1}_10"
        "${nic2}_20"
      ];
      last_resort = "default";
    };
    "${nic2}_${nic1}" = {
      use_member = [
        "${nic2}_10"
        "${nic1}_20"
      ];
      last_resort = "default";
    };
  };
in
{
  packages = [
    "luci-app-mwan3"
  ];

  uci = {
    settings = {
      mwan3 = {
        globals.globals = {
          mmx_mask = "0x3F00";
        };
        interface = {
          pppoe = mwanInterface;
          wwan0 = mwanInterface;
        };
        member = (mwanMembers "pppoe") // (mwanMembers "wwan0");
        policy = mwanPolicies "pppoe" "wwan0";
        rule = {
          default = {
            proto = "all";
            sticky = false;
            use_policy = "pppoe_wwan0";
            family = "ipv4";
          };
          unreachable = {
            proto = "all";
            sticky = false;
            use_policy = "unreachable";
            family = "ipv6";
          };
        };
      };
    };
  };
}
