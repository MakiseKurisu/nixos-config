{ config, lib, pkgs, ... }:

{
  hardware = {
    nvidia = {
      open = lib.mkDefault true;
      modesetting.enable = true;
      prime = {
        offload ={
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
    nvidia-container-toolkit.enable = true;
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
    xserver.videoDrivers = [ 
      "modesetting"
      "nvidia"
    ];
    llama-cpp = {
      package = pkgs.unstable.llama-cpp.override {
        cudaSupport = true;
      };
    };
    comfyui = {
      acceleration = "cuda";
    };
  };
}
