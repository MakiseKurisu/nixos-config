{ config, lib, pkgs, ... }:

{
  imports = [
    ./pr/mdevctl.nix
  ];

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    kernelPackages = pkgs.unstable.linuxPackages_6_6;
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

  # https://docs.nvidia.com/vgpu/latest/pdf/grid-vgpu-user-guide.pdf
  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.vgpu_17_3;
      modesetting.enable = true;
      prime = {
        offload.enable = true;
      };
      vgpu = {
        patcher = {
          enable = true;
          options.doNotForceGPLLicense = true;
          runtimeOptions.enable = true;
          copyVGPUProfiles = {
            "1E93:0000" = "1E30:12BA"; # GeForce RTX 2080 SUPER Mobile / Max-Q
            "1E07:0000" = "1E30:12BA"; # GeForce RTX 2080 Ti Rev. A
          };
          profileOverrides = {
            # GRID RTX6000-6Q
            "260" = {
              vramAllocation = 6144;
              heads = 4;
              enableCuda = true;
              display = {
                width = 7680;
                height = 4320;
              };
              framerateLimit = 0;
            };
            # GRID RTX6000-24Q
            "263" = {
              vramAllocation = 20480;
              heads = 4;
              enableCuda = true;
              display = {
                width = 7680;
                height = 4320;
              };
              framerateLimit = 0;
            };
          };
        };
        driverSource = {
          name = "NVIDIA-Linux-x86_64-550.90.05-vgpu-kvm.run";
          url = "http://downloads.protoducer.com/vGPU/17.3/Host_Drivers/NVIDIA-Linux-x86_64-550.90.05-vgpu-kvm.run";
          sha256 = "sha256-vBsxP1/SlXLQEXx70j/g8Vg/d6rGLaTyxsQQ19+1yp0=";
        };
      };
    };
  };

  programs.mdevctl = {
    enable = true;
    # mdevs = {
    #   "0000:01:00.0" = {
    #     "0f046260-c22b-49aa-aba1-dcef69faeb50".mdev_type = "nvidia-260";
    #   };
    # };
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };
}
