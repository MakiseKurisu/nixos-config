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
scp -r ~/Documents/GitHub/nixos-config/. nixos@nixos:~/nixos-config
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

## Incus setup

```
sudo incus config trust add-certificate incus-ui.crt

sudo btrfs subvolume create /media/root/@incus
sudo incus storage delete default
sudo incus storage create local:default btrfs source=/media/root/@incus

sudo incus profile device add local:default root disk pool=default path=/
sudo incus profile device add local:default eth0 nic name=eth0 nictype=bridged parent=br0 vlan=1 vlan.tagged=10,20,30

sudo incus create images:openwrt/24.10 local:openwrt -p default
sudo incus config device override local:openwrt eth0 host_name=openwrt
sudo incus config device add local:openwrt ppp unix-char mode=0600 path=/dev/ppp required=false
sudo incus config device add local:openwrt wdm unix-char mode=0600 path=/dev/cdc-wdm0 required=false
sudo incus config device add local:openwrt wwan nic nictype=physical parent=wwan10
# https://discuss.linuxcontainers.org/t/unable-to-update-some-network-settings-when-apparmor-is-enabled/22109/3
sudo incus config set local:openwrt raw.lxc 'lxc.apparmor.profile=unconfined//&:incus-openwrt_<var-lib-incus>:unconfined'
sudo incus config set local:openwrt volatile.wwan.name wwan0
sudo incus config set local:openwrt boot.autostart true
sudo incus snapshot create local:openwrt
sudo incus start local:openwrt
```