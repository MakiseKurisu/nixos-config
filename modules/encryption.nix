{ config
, secretFile
, ... }:

# Pending https://github.com/latchset/clevis/pull/462

# To create secret, run following command:
# echo -n $SECRET | sudo clevis encrypt sss '{"t": 1, "pins": {"tpm1": {}}}' > secret.jwe

{
  boot.initrd = {
    availableKernelModules = [ "tpm_crb" "tpm_tis" ];
    clevis = {
      enable = true;
      devices."${config.fileSystems."/".device}".secretFile = secret;
      useTang = true;
    }
  };
  services.tang = {
    enable = true;
    ipAddressAllow = "192.168.9.0/24"
  };
  networking.firewall.allowedTCPPorts = [ 7654 ];
}
