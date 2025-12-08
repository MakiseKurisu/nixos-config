{ config, lib, pkgs, ... }:

{
  imports = [
    ./intel-base.nix
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
    # https://github.com/NixOS/nixpkgs/issues/432403
    intel-media-sdk = pkgs.intel-media-sdk.overrideAttrs (old: {
      cmakeFlags = old.cmakeFlags ++ ["-DCMAKE_CXX_STANDARD=17"];
      NIX_CFLAGS_COMPILE = "-std=c++17";
    });
  };

  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-ocl
    ];
  };
}
