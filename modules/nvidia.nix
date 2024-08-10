{ config, lib, pkgs, ... }:

{
  boot = {
    blacklistedKernelModules = [ "nouveau" ];
  };

  environment = {
    systemPackages =
      let
        nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
          export __NV_PRIME_RENDER_OFFLOAD=1
          export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
          export __GLX_VENDOR_LIBRARY_NAME=nvidia
          export __VK_LAYER_NV_optimus=NVIDIA_only
          exec "$@"
        '';
      in
      with pkgs; [
        nvidia-offload
      ];
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      prime = {
        offload.enable = true;
        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
        intelBusId = "PCI:0:2:0";
        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };
}
