{ config, lib, pkgs, ... }:

{
  imports = [
    ./packages-base.nix
  ];

  environment = {
    systemPackages = let
      python-packages = p: with p; [
        dbus-python
        requests
        servefile
        tqdm
      ];
    in
      with pkgs; [
        android-tools
        asciinema
        binutils
        brightnessctl
        cmake
        debian-devscripts
        duplicacy
        unstable.distrobox
        dmidecode
        unstable.dotnet-sdk_8
        dpkg
        dtc
        efitools
        fakeroot
        file
        gcc
        gh
        git
        glib
        gnupg
        gnumake
        gptfdisk
        inetutils
        iperf
        ldns
        libhugetlbfs
        libnotify
        linux.dev
        lm_sensors
        minicom
        multipath-tools
        neovim
        nfs-utils
        unstable.nixops_unstable
        nix-index
        nixos-generators
        nixos-option
        nmap
        oci-cli
        oil
        openssl
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
        unzip
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
  };
}
