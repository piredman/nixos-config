{
  config,
  lib,
  pkgs,
  userSettings,
  systemSettings,
  ...
}:

{
  home.packages = with pkgs; [
    hyprland-protocols
    xdg-desktop-portal-hyprland
    wl-clipboard
  ];

  home.sessionVariables = {
    HYPR_MONITOR_PRIMARY = systemSettings.monitors.primary;
    HYPR_MONITOR_SECONDARY = systemSettings.monitors.secondary;
    HYPR_NVIDIA_ENABLED = if systemSettings.nvidia.enabled then "1" else "0";
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

  xdg.configFile = {
    "hypr/hyprland.lua" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/${userSettings.username}/hypr/hyprland.lua";
    };

    "hypr/host_rules.lua".text = lib.concatStringsSep "\n" (map (rule:
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
    ) (systemSettings.windowRules or []));
  };

  stylix.targets.hyprland = {
    enable = true;
  };
}
