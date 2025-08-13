{ config, lib, pkgs, inputs, options, ... }:

{
  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    autoStart = true;
  };
}
