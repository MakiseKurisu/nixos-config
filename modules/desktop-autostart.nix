{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  home-manager.users.excalibur =
    { pkgs, ... }:
    {
      wayland.windowManager.hyprland = {
        settings = {
          exec-once = [
            "[workspace 1 silent] discord --start-minimized"
            "[workspace 11 silent] gtk-launch bytedance-feishu"
            "[workspace 12 silent] thunderbird"
            "[workspace 14 silent] element-desktop"
            "[workspace 15 silent] teams-for-linux"
            "[workspace 16 silent] dingtalk"
            "[workspace 17 silent] qq"
            "[workspace 18 silent] wechat"
            "[workspace 19 silent] steam"
          ];
        };
      };
    };
}
