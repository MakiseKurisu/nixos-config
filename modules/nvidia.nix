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
      open = true;
      modesetting.enable = true;
      prime = {
        offload.enable = true;
      };
    };
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };
}
