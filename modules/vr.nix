{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}:

{
  services = {
    wivrn = {
      enable = true;
      openFirewall = true;
      autoStart = true;
    };
  };
}
