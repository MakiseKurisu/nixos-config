{ inputs, ... }:
{
  imports = [
    ./amd0
    ./amd1
    ./arm0
    ./arm1
  ];

  flake = {
    deploy = {
      nodes = {
        amd0 = {
          sshOpts = [
            "-J"
            "10.0.20.1"
          ];
          sshUser = "excalibur";
          user = "root";
          hostname = "10.0.0.10";
          profiles.system.path =
            let
              cfg = inputs.self.nixosConfigurations.amd0;
              system = cfg.config.nixpkgs.hostPlatform.system;
            in
            inputs.deploy-rs.lib.${system}.activate.nixos cfg;
        };

        amd1 = {
          sshOpts = [
            "-J"
            "10.0.20.1"
          ];
          sshUser = "excalibur";
          user = "root";
          hostname = "10.0.0.11";
          profiles.system.path =
            let
              cfg = inputs.self.nixosConfigurations.amd1;
              system = cfg.config.nixpkgs.hostPlatform.system;
            in
            inputs.deploy-rs.lib.${system}.activate.nixos cfg;
        };

        arm0 = {
          sshOpts = [
            "-J"
            "10.0.20.1"
          ];
          sshUser = "excalibur";
          user = "root";
          hostname = "10.0.0.20";
          profiles.system.path =
            let
              cfg = inputs.self.nixosConfigurations.arm0;
              system = cfg.config.nixpkgs.hostPlatform.system;
            in
            inputs.deploy-rs.lib.${system}.activate.nixos cfg;
        };

        arm1 = {
          sshOpts = [
            "-J"
            "10.0.20.1"
          ];
          sshUser = "excalibur";
          user = "root";
          hostname = "10.0.0.21";
          profiles.system.path =
            let
              cfg = inputs.self.nixosConfigurations.arm1;
              system = cfg.config.nixpkgs.hostPlatform.system;
            in
            inputs.deploy-rs.lib.${system}.activate.nixos cfg;
        };
      };
    };
  };
}
