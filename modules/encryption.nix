{
  config,
  secretFile,
  ...
}:

# Pending https://github.com/latchset/clevis/pull/462

# To create secret, run following command:
# echo -n $SECRET | sudo clevis encrypt sss '{"t": 1, "pins": {"tpm2": {}}}' > secret.jwe

{
  boot.initrd = {
    availableKernelModules = [
      "tpm_crb"
      "tpm_tis"
      "virtio-pci"
    ];
    clevis = {
      enable = true;
      devices."${config.fileSystems."/".device}".secretFile = ./secret.jwe;
      useTang = true;
    };
    network = {
      enable = true;
      udhcpc.enable = true;
    };
  };
  services.tang = {
    enable = true;
    ipAddressAllow = "192.168.9.0/24";
  };
  networking.firewall.allowedTCPPorts = [ 7654 ];
}
