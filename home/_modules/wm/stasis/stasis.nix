{ pkgs, ... }:

let
  lockDisplaySession = pkgs.writeShellScriptBin "wm-lock-session" ''
    session_id="$(${pkgs.systemd}/bin/loginctl show-user "$(${pkgs.coreutils}/bin/id -u)" --property=Display --value)"

    if [ -z "$session_id" ]; then
      echo "No graphical logind session found" >&2
      exit 1
    fi

    exec ${pkgs.systemd}/bin/loginctl lock-session "$session_id"
  '';

  stasisDpms = pkgs.writeShellScriptBin "stasis-dpms" ''
    case "''${XDG_CURRENT_DESKTOP:-}" in
      niri)
        if [ "''${1:-}" = "off" ]; then
          exec ${pkgs.niri}/bin/niri msg action power-off-monitors
        fi
        exec ${pkgs.niri}/bin/niri msg action power-on-monitors
        ;;
      Hyprland|hyprland)
        exec ${pkgs.hyprland}/bin/hyprctl dispatch dpms "''${1:-}"
        ;;
      *)
        echo "Unsupported compositor: ''${XDG_CURRENT_DESKTOP:-unset}" >&2
        exit 1
        ;;
    esac
  '';
in
{
  home.packages = [ lockDisplaySession ];

  services.stasis = {
    enable = true;
    extraConfig = builtins.readFile ./stasis.rune;
    extraPathPackages = [
      lockDisplaySession
      stasisDpms
    ];
  };
}
