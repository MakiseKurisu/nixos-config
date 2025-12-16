{ config, lib, pkgs, inputs, options, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${inputs.secrets}/nixos.yaml";
    secrets = {
      v2ray_address = {
        restartUnits = [ "v2ray.service" ];
      };
      v2ray_port = {
        restartUnits = [ "v2ray.service" ];
      };
      v2ray_id = {
        restartUnits = [ "v2ray.service" ];
      };
    };
  };
}
