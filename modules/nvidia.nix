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
  };
}
