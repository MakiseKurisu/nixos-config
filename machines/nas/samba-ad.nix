# Provision:
# cp /etc/samba/smb.conf /tmp/smb.conf
# sudo nixos-container run samba-ad -- samba-tool domain provision \
#   --configfile=/tmp/smb.conf \
#   --interactive \
#   --host-name=dc01 \
#   --host-ip=192.168.9.6 \
#   --host-ip6=fd09::6 \
#   --use-rfc2307
# sudo nixos-container run samba-ad -- samba-tool domain passwordsettings set --min-pwd-age=0
# sudo nixos-container run samba-ad -- samba-tool domain passwordsettings set --max-pwd-age=0
# sudo nixos-container run samba-ad -- samba-tool domain passwordsettings set --account-lockout-threshold=10
# sudo nixos-container run samba-ad -- samba-tool user create keycloak
#
# Keycloak integration:
# | Keycloak field | Value |
# | --- | --- |
# | Vendor | Active Directory |
# | Connection URL | `ldaps://dc01.protoducer.com:636` |
# | Users DN | `CN=Users,DC=protoducer,DC=com` |
# | Bind DN | `CN=keycloak,CN=Users,DC=protoducer,DC=com` |
# | Bind credential | The account password entered above |
# | Username LDAP attribute | `sAMAccountName` |
# | RDN LDAP attribute | `cn` |
# | UUID LDAP attribute | `objectGUID` |
# | User object classes | `person, organizationalPerson, user` |
# | Edit mode | `READ_ONLY` |
# | Sync registrations | Off |

{ config, pkgs, ... }:

let
  certificateDir = config.security.acme.certs."protoducer.com".directory;
  ntpSigndDir = "/run/ntp_signd";
in
{
  security.acme.certs."protoducer.com".postRun = ''
    ${pkgs.systemd}/bin/systemctl --machine=samba-ad try-restart samba-ad-dc.service || true
  '';

  systemd.services."container@samba-ad" = {
    requires = [ "acme-protoducer.com.service" ];
    after = [ "acme-protoducer.com.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/samba-ad 0755 root root -"
  ];

  containers.samba-ad = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "br0";
    bindMounts."/var/lib/samba" = {
      hostPath = "/var/lib/samba-ad";
      isReadOnly = false;
    };
    bindMounts.${certificateDir} = {
      hostPath = certificateDir;
      isReadOnly = true;
    };

    config = { lib, pkgs, ... }: {
      environment.enableAllTerminfo = true;

      networking = {
        hostName = "dc01";
        domain = "protoducer.com";
        useHostResolvConf = lib.mkForce false;
        nameservers = [ "127.0.0.1" ];
        nftables.enable = true;
        hosts = {
          "192.168.9.6" = [
            "dc01.protoducer.com"
            "dc01"
          ];
          "fd09::6" = [
            "dc01.protoducer.com"
            "dc01"
          ];
        };
        firewall = {
          allowedTCPPorts = [
            53
            88
            135
            139
            389
            445
            464
            636
            3268
            3269
          ];
          allowedUDPPorts = [
            53
            88
            123
            137
            138
            389
            464
          ];
          allowedTCPPortRanges = [
            {
              from = 49152;
              to = 65535;
            }
          ];
        };
      };

      networking.interfaces.eth0.useDHCP = false;
      systemd.network = {
        enable = true;
        netdevs = {
          "20-br0" = {
            netdevConfig = {
              Kind = "bridge";
              Name = "br0";
            };
            bridgeConfig = {
              STP = true;
              VLANFiltering = true;
            };
          };
          "20-vlan20" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "vlan20";
            };
            vlanConfig.Id = 20;
          };
        };
        networks = {
          "01-lo" = {
            matchConfig.Name = "lo";
            networkConfig = {
              LinkLocalAddressing = "ipv6";
              Address = "127.0.0.1/8";
            };
          };
          "30-eth0" = {
            matchConfig.Name = "eth0";
            networkConfig.Bridge = "br0";
            linkConfig.RequiredForOnline = "enslaved";
            bridgeVLANs = [
              {
                VLAN = 20;
              }
            ];
          };
          "40-br0" = {
            matchConfig.Name = "br0";
            networkConfig = {
              LinkLocalAddressing = false;
            };
            bridgeConfig = { };
            bridgeVLANs = [
              {
                VLAN = 20;
              }
            ];
            vlan = [
              "vlan20"
            ];
            linkConfig = {
              RequiredForOnline = false;
            };
          };
          "50-vlan20" = {
            matchConfig.Name = "vlan20";
            networkConfig = {
              DHCP = false;
              IPv6AcceptRA = false;
              Address = [
                "192.168.9.6/24"
                "fd09::6/64"
              ];
              Gateway = [
                "192.168.9.1"
                "fd09::1"
              ];
            };
            linkConfig.RequiredForOnline = "routable";
          };
        };
      };

      systemd.tmpfiles.rules = [
        "d ${ntpSigndDir} 0750 root chrony -"
        # The Samba module creates private/; tighten its permissions afterwards.
        "z /var/lib/samba/private 0700 root root -"
        "d /var/lib/samba/state 0755 root root -"
        "d /var/lib/samba/cache 0755 root root -"
        "d /var/lib/samba/bind-dns 0750 root root -"
      ];

      security.krb5 = {
        enable = true;
        settings = {
          libdefaults = {
            default_realm = "PROTODUCER.COM";
            dns_lookup_realm = false;
            dns_lookup_kdc = true;
            rdns = false;
          };
          domain_realm = {
            ".protoducer.com" = "PROTODUCER.COM";
            "protoducer.com" = "PROTODUCER.COM";
          };
        };
      };

      services.resolved.enable = lib.mkForce false;
      services.chrony = {
        enable = true;
        servers = config.networking.timeServers;
        extraFlags = [ "-x" ];
        enableRTCTrimming = false;
        extraConfig = ''
          allow 192.168.9.0/24
          allow fd09::/64
          ntpsigndsocket ${ntpSigndDir}
        '';
      };
      systemd.services.chronyd.after = [ "samba-ad-dc.service" ];
      services.samba = {
        enable = true;
        package = pkgs.samba4Full;
        # The AD daemon manages its own child daemons.
        smbd.enable = false;
        nmbd.enable = false;
        winbindd.enable = false;
        settings = {
          global = {
            "ad dc functional level" = "2016";
            "server role" = "active directory domain controller";
            realm = "PROTODUCER.COM";
            workgroup = "PROTODUCER";
            "netbios name" = "DC01";
            security = "auto";
            "invalid users" = [ ];
            "map to guest" = "Never";
            interfaces = [
              "lo"
              "vlan20"
            ];
            "bind interfaces only" = true;
            "private dir" = "/var/lib/samba/private";
            "ntp signd socket directory" = ntpSigndDir;
            "state directory" = "/var/lib/samba/state";
            "cache directory" = "/var/lib/samba/cache";
            "lock directory" = "/var/lib/samba";
            "binddns dir" = "/var/lib/samba/bind-dns";
            "idmap_ldb:use rfc2307" = true;
            "dns forwarder" = "192.168.9.7";
            "tls enabled" = true;
            "tls cafile" = "";
            "restrict anonymous" = 2;
            "disable netbios" = true;
            "smb ports" = [ 445 ];
            "printcap name" = "/dev/null";
            "load printers" = false;
            "disable spoolss" = true;
            printing = "bsd";
            "ntlm auth" = "mschapv2-and-ntlmv2-only";
            "password hash userPassword schemes" = [
              "CryptSHA256"
              "CryptSHA512"
            ];
            "full_audit:failure" = "none";
            "full_audit:success" = [
              "pwrite"
              "write"
              "renameat"
            ];
            "full_audit:prefix" = "IP=%I|USER=%u|MACHINE=%m|VOLUME=%S";
            "full_audit:facility" = "local7";
            "full_audit:priority" = "NOTICE";
          };
          sysvol = {
            path = "/var/lib/samba/state/sysvol";
            "read only" = false;
            "vfs objects" = [ "dfs_samba4" "acl_xattr" "full_audit" ];
          };
          netlogon = {
            path = "/var/lib/samba/state/sysvol/protoducer.com/scripts";
            "read only" = false;
            "vfs objects" = [ "dfs_samba4" "acl_xattr" "full_audit" ];
          };
        };
      };

      systemd.services.samba-ad-dc = {
        description = "Samba Active Directory Domain Controller";
        documentation = [ "man:samba(8)" "man:smb.conf(5)" ];
        wantedBy = [ "samba.target" ];
        partOf = [ "samba.target" ];
        wants = [ "network-online.target" ];
        after = [ "network.target" "network-online.target" ];
        unitConfig = {
          RequiresMountsFor = "/var/lib/samba";
          ConditionPathExists = "/var/lib/samba/private/sam.ldb";
        };
        serviceConfig = {
          Type = "notify";
          Slice = "system-samba.slice";
          LimitNOFILE = 16384;
          # Samba checks private key ownership and mode before starting LDAP.
          ExecStartPre = [
            "${pkgs.coreutils}/bin/install -d -o root -g root -m 0700 /var/lib/samba/private/tls"
            "${pkgs.coreutils}/bin/install -o root -g root -m 0600 ${certificateDir}/key.pem /var/lib/samba/private/tls/key.pem"
            "${pkgs.coreutils}/bin/install -o root -g root -m 0644 ${certificateDir}/fullchain.pem /var/lib/samba/private/tls/cert.pem"
          ];
          ExecStart = "${pkgs.samba4Full}/sbin/samba --foreground --no-process-group --configfile=/etc/samba/smb.conf";
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        };
      };

      system.stateVersion = config.system.stateVersion;
    };
  };

  systemd.network.networks."30-vb-samba-ad" = {
    matchConfig.Name = "vb-samba-ad";
    networkConfig.Bridge = "br0";
    linkConfig.RequiredForOnline = "enslaved";
    bridgeVLANs = [
      {
        VLAN = 20;
      }
    ];
  };
}
