# nixos-config

Personal NixOS configurations

## Usage

Run `./install` to view available profiles.

Run `./install <profile>` to install a profile.

Run `./rebuild` as if you are using `nixos-rebuild`. This is a small wrapper to override `NIXOS_LABEL_VERSION` with git HEAD hash.

Run `sudo nix --extra-experimental-features "flakes nix-command" run 'github:nix-community/disko/latest#disko-install' -- --write-efi-boot-entries --flake "$PWD#<machine>" --disk main <disk path>` to install.

Run `nixos-rebuild --fast --use-remote-sudo --target-host <machine> switch` to update another device. Need to have this flake installed under `/etc/nixos/flake.nix`.

If your initial build is large that can't fit NixOS ISO's tmpfs store, you will need to mount a work disk to overlay on top of `/nix/store`:

```bash
sudo mount -t overlay -o lowerdir=/nix/store,upperdir=/tmp/mnt/,workdir=/tmp/work/,uuid=on /nix/store/
```

Don't forget to use `nixos-enter` to update the account password.
