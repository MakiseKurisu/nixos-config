{ config, lib, pkgs, ... }:

{
  imports = [
    ./packages-base.nix
  ];

  environment =
    let
      dotnet-combined = (with pkgs.dotnetCorePackages; combinePackages [
        sdk_8_0
      ]).overrideAttrs (finalAttrs: previousAttrs: {
        # This is needed to install workload in $HOME
        # https://discourse.nixos.org/t/dotnet-maui-workload/20370/2

        postBuild = (previousAttrs.postBuild or '''') + ''

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
      });
    in
    {
      sessionVariables = {
        DOTNET_ROOT = "${dotnet-combined}";
      };
      systemPackages =
        let
          python-packages = p: with p; [
            dbus-python
            requests
            servefile
            tqdm
            pre-commit-hooks
            pyyaml
            pyusb
          ];
        in
        with pkgs; [
          android-tools
          asciinema
          nur.repos.xddxdd.baidunetdisk
          binutils
          brightnessctl
          cmake
          debian-devscripts
          duplicacy
          nur.repos.xddxdd.dingtalk
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
          git
          glib
          gnumake
          gptfdisk
          imhex
          inetutils
          iperf
          ldns
          libhugetlbfs
          libnotify
          libxml2
          linux.dev
          lm_sensors
          minicom
          neovim
          nfs-utils
          nix-index
          nixos-generators
          nixos-option
          nmap
          ntfs3g
          nvme-cli
          oci-cli
          openssl
          p7zip
          pciutils
          picocom
          playerctl
          podman-compose
          (python3.withPackages python-packages)
          rar
          rkdeveloptool
          rPackages.glmnet
          shellcheck
          speechd
          ssh-copy-id
          smartmontools
          unzipNLS
          usbutils
        ];
    };

  programs = {
    htop = {
      enable = true;
      settings = {
        hide_kernel_threads = false;
        show_cpu_frequency = true;
        show_cpu_temperature = true;
        column_meters_0 = "LeftCPUs Memory Swap Zram DiskIO";
        column_meter_modes_0 = "1 1 1 1 2";
        column_meters_1 = "RightCPUs Tasks LoadAverage Uptime NetworkIO";
        column_meter_modes_1 = "1 2 2 2 2";
      };
    };
    nix-ld.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };
  services.pcscd.enable = true;
}
