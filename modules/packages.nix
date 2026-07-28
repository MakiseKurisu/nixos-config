{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./packages-base.nix
  ];

  environment =
    let
      dotnet-combined = (with pkgs.dotnetCorePackages; combinePackages [ dotnet_10.sdk ]);
    in
    {
      sessionVariables = {
        DOTNET_PATH = "${dotnet-combined}/bin/dotnet";
        DOTNET_ROOT = "${dotnet-combined}/share/dotnet";
      };
      systemPackages =
        let
          python-packages =
            p: with p; [
              dbus-python
              requests
              servefile
              tqdm
              pre-commit-hooks
              pyyaml
              pyusb
            ];
        in
        with pkgs;
        [
          android-tools
          asciinema
          binutils
          brightnessctl
          cmake
          debian-devscripts
          duplicacy
          distrobox
          dmidecode
          dotnet-combined
          dpkg
          dtc
          efitools
          fakeroot
          file
          gcc
          gh
          glib
          gnumake
          gptfdisk
          imhex
          inetutils
          iperf
          libhugetlbfs
          libnotify
          libxml2
          linux.dev
          lm_sensors
          minicom
          neovim
          nfs-utils
          nixos-generators
          nixos-option
          ntfs3g
          nvme-cli
          oci-cli
          openssl
          p7zip
          picocom
          playerctl
          podman-compose
          (python3.withPackages python-packages)
          (lib.mkIf (pkgs.stdenv.hostPlatform.system != "aarch64-linux") rar)
          (lib.mkIf (pkgs.stdenv.hostPlatform.system == "aarch64-linux") pkgs.pkgsCross.gnu64.rar)
          rkdeveloptool
          rPackages.glmnet
          shellcheck
          speechd
          ssh-copy-id
          unzipNLS
        ];
    };

  programs = {
    command-not-found.enable = false;
    nh = {
      enable = true;
      clean.enable = true;
    };
    nix-index.enable = true;
    nix-ld.enable = true;
  };
  services.pcscd.enable = true;
}
