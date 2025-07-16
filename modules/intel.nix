{ config, lib, pkgs, ... }:

{
  imports = [
    ./intel-base.nix
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-ocl
    ];
  };
}
