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
        dotnet-sdk
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
        htop
        inetutils
        iperf
        ldns
        libhugetlbfs
        libnotify
        linux.dev
        minicom
        multipath-tools
        neovim
        nfs-utils
        unstable.nixops_unstable
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
        unzip
        usbutils
      ];
  };

  programs.nix-ld.enable = true;
}
