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
      # Workaround 580 driver GTK4 regression
      # https://forums.developer.nvidia.com/t/580-release-feedback-discussion/341205/20
      wayland.windowManager.hyprland.settings = {
        env = [
          "GSK_RENDERER,ngl"
        ];
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
    sunshine.package = pkgs.sunshine.override {
      cudaSupport = true;
    };
    wivrn = {
      package = pkgs.wivrn.override {
        cudaSupport = true;
      };
    };
  };
}
