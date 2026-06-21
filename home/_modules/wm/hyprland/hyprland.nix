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
    HYPR_MONITOR_SECONDARY = systemSettings.monitors.secondary;
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
    };

    configFile = {
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
