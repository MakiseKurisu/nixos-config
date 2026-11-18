{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      pr-vscode-jsonnet = import inputs.pr-vscode-jsonnet {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];
}
