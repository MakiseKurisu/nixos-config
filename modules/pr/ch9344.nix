{ config, lib, pkgs, inputs,
stdenv, fetchzip, kernel,
... }:

{
  disabledModules = [
    "pkgs/os-specific/linux/ch9344/default.nix"
  ];
  imports = [
    (import "${inputs.pr-ch9344}/pkgs/os-specific/linux/ch9344/default.nix" {
      stdenv = stdenv;
      lib = lib;
      fetchzip = fetchzip;
      kernel = kernel;
    })
  ];
}
