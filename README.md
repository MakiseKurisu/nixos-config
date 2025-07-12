# nixos-config

Personal NixOS configurations

## Usage

Run `./install` to view available profiles.

Run `./install <profile>` to install a profile.

Run `./rebuild` as if you are using `nixos-rebuild`. This is a small wrapper to override `NIXOS_LABEL_VERSION` with git HEAD hash.

Run `nixos-rebuild --fast --use-remote-sudo --target-host <machine> switch` to update another device. Need to have this flake installed under `/etc/nixos/flake.nix`.

If your initial build is large that can't fit NixOS ISO's tmpfs store, you will need to mount a work disk to overlay on top of `/nix/store`:

```bash
sudo mount -t overlay -o lowerdir=/nix/store,upperdir=/tmp/mnt/,workdir=/tmp/work/,uuid=on /nix/store/
```

Don't forget to use `nixos-enter` to update the account password.

## Install with `disko`

Launch the system with NixOS ISO, and enable ssh & disable sleep:

```
passwd
sudo systemctl start sshd
```

Edit the flake on the primary PC, disable impermanence related stuffs, then upload and start installation from SSH:

```
rsync -Pr ~/Documents/GitHub/nixos-config/ nixos@nixos:~/nixos-config
ssh nixos@nixos
```

```
nixos-generate-config --root /tmp/config --no-filesystems
cat /tmp/config/etc/nixos/hardware-configuration.nix    # remember to include this in the flake

cd nixos-config
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake .#<flake-attr>
sudo nixos-install --no-root-password --root /mnt --flake .#<flake-attr>

# Set your account password
sudo nixos-enter --root /mnt

# Only enable impermanence after boot, once you have copied the contents
# https://github.com/nix-community/impermanence/issues/34#issuecomment-766195787
```
