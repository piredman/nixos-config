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

in
{
  home.packages = [ lockDisplaySession ];

  services.stasis = {
    enable = true;
    extraConfig = builtins.readFile ./stasis.rune;
    extraPathPackages = [
      lockDisplaySession
    ];
  };
}
