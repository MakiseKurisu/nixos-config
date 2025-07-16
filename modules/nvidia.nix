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
      open = lib.mkDefault true;
      modesetting.enable = true;
      prime = {
        reverseSync.enable = true;
        offload.enable = true;
      };
    };
  };

  home-manager = {
    users.excalibur = { pkgs, ... }: {
      programs = {
        obs-studio = {
          package = pkgs.obs-studio.override {
            cudaSupport = true;
          };
        };
      };
    };
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };
}
