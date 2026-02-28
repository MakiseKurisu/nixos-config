{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot = {
    kernelParams = [
      "amd_pstate=active"
    ];
  };

  services = {
    auto-epp.enable = true;

    udev.extraRules = ''
      # Tagging MSR devices
      SUBSYSTEM=="msr", TAG+="systemd", ENV{SYSTEMD_WANTS}+="msr@%k.service"
    '';
  };

  systemd = {
    services = {
      "msr@" = {
        description = "Set MSR registers to match Steam Deck";
        path = [
          pkgs.msr-tools
        ];
        scriptArgs = "%i";
        script = ''
          CPU=''${1#msr}
          wrmsr -p $CPU 0xC0010030 0x7473754320444D41
          wrmsr -p $CPU 0xC0010031 0x3020555041206D6F
          wrmsr -p $CPU 0xC0010032 0x353034
          wrmsr -p $CPU 0xC0010033 0x0
          wrmsr -p $CPU 0xC0010034 0x0
          wrmsr -p $CPU 0xC0010035 0x0
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };
    };
  };
}
