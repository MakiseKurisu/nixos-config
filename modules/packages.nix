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
      dotnet-combined =
        (
          with pkgs.dotnetCorePackages;
          combinePackages [
            sdk_8_0
          ]
        ).overrideAttrs
          (
            finalAttrs: previousAttrs: {
              # This is needed to install workload in $HOME
              # https://discourse.nixos.org/t/dotnet-maui-workload/20370/2

              postBuild = (previousAttrs.postBuild or "") + ''

                for i in $out/sdk/*
                do
                  i=$(basename $i)
                  length=$(printf "%s" "$i" | wc -c)
                  substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
                  i="$substring""00"
                  mkdir -p $out/metadata/workloads/''${i/-*}
                  touch $out/metadata/workloads/''${i/-*}/userlocal
                done
              '';
            }
          );
    in
    {
      sessionVariables = {
        DOTNET_ROOT = "${dotnet-combined}";
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
