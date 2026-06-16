{
  config,
  lib,
  pkgs,
  ...
}:

{
  hardware = {
    amdgpu = {
      opencl.enable = true;
      overdrive.enable = true;
    };
  };

  services = {
    llama-cpp = {
      package = pkgs.llama-cpp.override {
        rocmSupport = true;
      };
    };
    comfyui = {
      acceleration = "rocm";
    };
  };
}
