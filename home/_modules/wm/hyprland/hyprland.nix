{
  config,
  lib,
  pkgs,
  userSettings,
  systemSettings,
  ...
}:

{
  imports = [
    ./session.nix
  ];

  home.packages = with pkgs; [
    hyprland-protocols
    wl-clipboard
  ];

  home.sessionVariables = {
    TERMINAL = "ghostty";
    HYPR_MONITOR_PRIMARY = systemSettings.monitors.primary;
    HYPR_MONITOR_SECONDARY = systemSettings.monitors.secondary or "";
    HYPR_NVIDIA_ENABLED = if systemSettings.nvidia.enabled then "1" else "0";
  };

  systemd.user.sessionVariables = {
    TERMINAL = "ghostty";
  };

  wayland.windowManager.hyprland = {
    enable = false;
  };

  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  xdg = {
    portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];

      # Route screen capture/screenshot to the hyprland portal instead of the
      # common "gtk" default. Per-desktop key -> hyprland-portals.conf,
      # consulted only when XDG_CURRENT_DESKTOP=Hyprland. Portals loads at most
      # one conf per directory (per-desktop wins over generic portals.conf),
      # so this file must be self-contained: default=gtk here covers
      # FileChooser etc. so nothing rides the deprecated UseIn / last-resort
      # fallback paths.
      config.hyprland = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
    };

    configFile = {
      # Persist share choices across sessions (no re-prompt each meeting).
      # xdph reads hypr/xdph.conf (hyprlang); the picker still appears, this
      # just pre-ticks the restore-token box.
      "hypr/xdph.conf".text = ''
        screencopy {
            allow_token_by_default = true
        }
      '';

      "hypr/hyprland.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/${userSettings.username}/hypr/hyprland.lua";
      };

      "hypr/host_rules.lua".text = lib.concatStringsSep "\n" (
        map (
          rule:
          let
            matchType = builtins.head (builtins.attrNames rule.match);
            matchPattern = rule.match.${matchType};
          in
          ''
            hl.window_rule({
              match = { ${matchType} = "${matchPattern}" },
              workspace = "${rule.workspace}",
            })
          ''
        ) (systemSettings.windowRules or [ ])
      );

      "hypr/monitors.lua".text = lib.concatStringsSep "\n" (
        map (configStr:
          let
            parts = lib.splitString "," configStr;
            output = lib.trim (builtins.head parts);
            mode = lib.trim (builtins.elemAt parts 1);
            position = lib.trim (builtins.elemAt parts 2);
            scale = lib.trim (builtins.elemAt parts 3);
            extra = map lib.trim (lib.drop 4 parts);
            isMirror = builtins.length extra >= 2 && builtins.elemAt extra 0 == "mirror";
          in
          if isMirror then
            ''
              hl.monitor({
                output = "${output}",
                mode = "${mode}",
                position = "${position}",
                scale = ${scale},
                mirror = "${builtins.elemAt extra 1}",
              })
            ''
          else
            ''
              hl.monitor({
                output = "${output}",
                mode = "${mode}",
                position = "${position}",
                scale = ${scale},
              })
            ''
        ) (systemSettings.monitors.setup or [ ])
      );
    };
  };

  stylix.targets.hyprland = {
    enable = true;
  };
}
